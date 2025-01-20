-- complex matrix query example with business rules depending on category values
-- evaluation is done by different dimensions than business rules
-- Desinged for: AdventureWorksDW2019
-- Remark: There are not necessarily sales for all country and quarter combinations
SELECT                                                                     -- defining the context of the visual: context is independend of business rules (!)
	 [Promotion] = IIF(                                                    -- by promotion...
	      GROUPING_ID([p].[EnglishPromotionName]) = 0
		 ,COALESCE([p].[EnglishPromotionName], 'N/A')
		 ,'Total'
	 )
	,[Reseller] = IIF(                                                     -- ... and reseller
		 GROUPING_ID([r].[ResellerName]) = 0
		,COALESCE(CONVERT(CHAR, [r].[ResellerName]), 'N/A')
		,'Subtotal Promotion'
	 )
	,[Discounted Amount] = CONVERT(                                        -- defining the business rules in their required context:
		 MONEY
		,ROUND(
			 SUM( 
				 IIF(                                                      -- Apply business rules according to sales territoty (inside/outside US) and date (in/not in Q4)
						[t].[SalesTerritoryCountry] <> 'United States'     -- Outside of US, always discount
					 OR [d].[CalendarQuarter] = 4,                         -- in quarter 4, everywhare discount
					 (1 - .15) * [SalesAmount],                            -- assuming discount 15%
					 [SalesAmount]
				 )
			 )
            ,2
		 )
	 )
FROM
	[dbo].[FactResellerSales] [s]                                          -- The query summarizes the fact table.
-- Join categories for slicing the result...
INNER JOIN                                                                 -- ... by promotion...
    [dbo].[DimPromotion] [p]      ON [p].[PromotionKey] = [s].[PromotionKey]
INNER JOIN                                                                 -- ... and reseller.
    [dbo].[DimReseller] [r]       ON [r].[ResellerKey] = [s].[ResellerKey]
-- Join categories for business rules...
INNER JOIN                                                                 -- ... by date...
	[dbo].[DimDate] [d]           ON [d].[DateKey] = [s].[OrderDateKey]
INNER JOIN                                                                 -- ...and sales territory.
	[dbo].[DimSalesTerritory] [t] ON [t].[SalesTerritoryKey] = [s].[SalesTerritoryKey]
WHERE 1=1
--	AND [d].[CalendarYear] = 2012                                          -- filters can be applied here, e.g. for a specific year - filter can also come from any other dimension, it just needs to be joined to the fact table
    AND [p].[EnglishPromotionName] <> 'No Discount'
GROUP BY ROLLUP (                                                          -- rollup is reevaluating its entire context, not reusing smaller aggregates
	 [p].[EnglishPromotionName]
	,[r].[ResellerName]
)
ORDER BY
	 GROUPING_ID([p].[EnglishPromotionName])
	,[p].[EnglishPromotionName]
	,GROUPING_ID([r].[ResellerName])
	,[r].[ResellerName]