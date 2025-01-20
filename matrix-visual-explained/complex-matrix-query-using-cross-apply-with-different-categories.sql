-- complex matrix query example using CROSS APPLY:
-- the measure has specific rules for different categories
-- the business rules are calculated in a CROSS APLLY sections and are applicable to any categories and slices in the outer query
-- Desinged for: AdventureWorksDW2019
-- Remark: There are not necessarily sales for all country and quarter combinations
SELECT                                                                     -- defining the context of the visual: context is independend of business rules (!)
	 [Product Category]   = IIF(GROUPING_ID([c].[EnglishProductCategoryName]) = 0, COALESCE([c].[EnglishProductCategoryName], 'N/A'), 'Total') -- by prduct group...
	,[Year]   = COALESCE(CONVERT(CHAR(4), [d].[CalendarYear]), 'Total') -- ... and year
	,[Discounted Amount] = ROUND(SUM([ca].[Context Discounted Amount]), 2) -- SUM aggregator required to use ROLLUP, but is always just the sum of one value
	,[Amount] = SUM([s].[SalesAmount])
	,[% Off] = CONVERT(MONEY, ROUND((1 - (SUM([ca].[Context Discounted Amount]) / NULLIF(SUM([s].[SalesAmount]), 0))) * 100, 1))
FROM
	[dbo].[FactResellerSales] [s]
INNER JOIN                                                                 
	[dbo].[DimDate] [d]           ON [d].[DateKey] = [s].[OrderDateKey]
INNER JOIN
	[dbo].[DimProduct] [p] ON [p].[ProductKey] = [s].[ProductKey]
LEFT JOIN -- not every product is assigned to a product category
	[dbo].[DimProductSubCategory] [u] ON [u].[ProductSubCategoryKey] = [p].[ProductSubcategoryKey]
LEFT JOIN
	[dbo].[DimProductCategory] [c] ON [c].[ProductCategoryKey] = [u].[ProductSubcategoryKey]
CROSS APPLY (
	SELECT
	    [Context Discounted Amount] = CONVERT(MONEY, SUM([i].[Amount]))    -- total discounted amount in any context is the discounted amount in the context plus the undiscounted amount in the context
	FROM
	(
		SELECT                                                             -- section applying rules for discount:
			 [Amount] = (1 - .15) * SUM([SalesAmount])                     -- assuming discount 15%
		FROM 
			[dbo].[FactResellerSales] [cas]
		INNER JOIN 
			[dbo].[DimDate] [cad]           ON [cad].[DateKey]           = [cas].[OrderDateKey]
		INNER JOIN
			[dbo].[DimSalesTerritory] [cat] ON [cat].[SalesTerritoryKey] = [cas].[SalesTerritoryKey]
		WHERE 1=1
			AND (                                                          -- Business rules:
				   [cat].[SalesTerritoryCountry] <> 'United States'        -- outside US always discount
				OR [cad].[CalendarQuarter] = 4                             -- in quarter 4 everywhere discount
			)
			AND [cas].[SalesOrderNumber]     = [s].[SalesOrderNumber]      -- linking context and business rules on the primary key of the fact table
			AND [cas].[SalesOrderLineNumber] = [s].[SalesOrderLineNumber]  -- it's a composite key in this example
		UNION ALL
		SELECT                                                             -- section applying rules for no discount:
			 [Amount] = SUM([SalesAmount])
		FROM 
			[dbo].[FactResellerSales] [cas]
		INNER JOIN 
			[dbo].[DimDate] [cad]           ON [cad].[DateKey]           = [cas].[OrderDateKey]
		INNER JOIN
			[dbo].[DimSalesTerritory] [cat] ON [cat].[SalesTerritoryKey] = [cas].[SalesTerritoryKey]
		WHERE 1=1
			AND (                                                          -- Business rules:
				[cat].[SalesTerritoryCountry] = 'United States'            -- inside US ...
				AND [cad].[CalendarQuarter] <> 4                           -- ... no discount except quarter 4
			)
			AND [cas].[SalesOrderNumber]     = [s].[SalesOrderNumber]      -- linking context and business rules on the primary key of the fact table
			AND [cas].[SalesOrderLineNumber] = [s].[SalesOrderLineNumber]  -- it's a composite key in this example
	) [i]
) [ca]
WHERE 1=1
--	AND [d].[CalendarYear] = 2012                                          -- filters can be applied here, e.g. for a specific year
GROUP BY ROLLUP (                                                          -- rollup is reevaluating its entire context, not reusing smaller aggregates
	 [d].[CalendarYear]
	,[c].[EnglishProductCategoryName]
)
ORDER BY
	 GROUPING_ID([d].[CalendarYear])
	,[d].[CalendarYear]
	,GROUPING_ID([c].[EnglishProductCategoryName])
	,[c].[EnglishProductCategoryName]