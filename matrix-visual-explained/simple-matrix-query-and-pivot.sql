-- simple matrix query example:
-- the measure does not require distinction by any category
-- the same calculation applies to any entire slice
-- Desinged for: AdventureWorksDW2019
-- Remark: NULL values in the query result actually come from no sales in this context.
SELECT
	 [Region] = COALESCE([Region], 'Total')
	,[2010], [2011], [2012], [2013], [Total]
FROM -- In Power BI, the visual runs a query like this inner [Table] query to get the data, pivoting the data into the [Matrix] visual is done on visual level
(
	SELECT
		 [Region] = [t].[SalesTerritoryRegion]
		,[Year]   = COALESCE(CONVERT(CHAR(4), [d].[CalendarYear]), 'Total')
		,[Sales per Salesperson] =                            -- this corresponds to the measure:
			ROUND(                                            -- business rules evaluated in each context
				 SUM([s].[SalesAmount]) /
				 NULLIF(COUNT(DISTINCT [e].[EmployeeKey]), 0)
				,2
			)
	FROM
		 [dbo].[FactResellerSales] [s]
		,[dbo].[DimDate]           [d]
		,[dbo].[DimSalesTerritory] [t]
	LEFT JOIN
		[dbo].[DimEmployee] [e] ON [e].[SalesTerritoryKey] = [t].[SalesTerritoryKey]
	WHERE 1=1
		AND [d].[DateKey]           = [s].[OrderDateKey]
		AND [t].[SalesTerritoryKey] = [s].[SalesTerritoryKey]
		AND [e].[SalesPersonFlag]   = 1
	GROUP BY ROLLUP (  -- calculating totals in rollups; rollups are calcualted in their entire context, not reusing smaller aggregates
		 [d].[CalendarYear]
		,[t].[SalesTerritoryRegion]
	)
	UNION ALL
	SELECT  -- append horizontal totals, SQL ROLLUP is not designed to calculate vertical and horizontal total in one pass
		 [Region] = COALESCE([t].[SalesTerritoryRegion], 'Total')
		,[Year]   = 'Total'
		,[Sales per Salesperson] =
			ROUND(
				 SUM([s].[SalesAmount]) /
				 NULLIF(COUNT(DISTINCT [e].[EmployeeKey]), 0)
				,2
			)
	FROM
		 [dbo].[FactResellerSales] [s]
		,[dbo].[DimDate]           [d]
		,[dbo].[DimSalesTerritory] [t]
	LEFT JOIN
		[dbo].[DimEmployee] [e] ON [e].[SalesTerritoryKey] = [t].[SalesTerritoryKey]
	WHERE 1=1
		AND [d].[DateKey]           = [s].[OrderDateKey]
		AND [t].[SalesTerritoryKey] = [s].[SalesTerritoryKey]
		AND [e].[SalesPersonFlag]   = 1
	GROUP BY 
	     [t].[SalesTerritoryRegion]
) AS [Table]
PIVOT
(
	SUM([Sales per Salesperson])
	FOR [YEAR] IN ([2010], [2011], [2012], [2013], [Total])
) AS [Matrix]
ORDER BY 
     IIF([Region] IS NULL, 1, 0) -- sort "Total" to the bottom - would even work with a region called "Total" :)
	,[Region]                    -- sort [Region] alphabetically