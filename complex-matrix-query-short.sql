-- complex matrix query example with business rules depending on category values
-- Desinged for: AdventureWorksDW2019
-- Remark: There are not necessarily sales for all country and quarter combinations
SELECT                                                                     -- defining the context of the visual: context is independend of business rules (!)
	 [Country]   = COALESCE([t].[SalesTerritoryCountry], 'Total')          -- by country...
	,[Quarter]   = COALESCE(CONVERT(CHAR, [d].[CalendarQuarter]), 'Total') -- ... and quarter
	,[Discounted Amount] = CONVERT(
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
	[dbo].[FactResellerSales] [s]                                          -- The query summarizes the fact table...
INNER JOIN                                                                 -- ... by date...
	[dbo].[DimDate] [d]           ON [d].[DateKey] = [s].[OrderDateKey]
INNER JOIN                                                                 -- ...and sales territory.
	[dbo].[DimSalesTerritory] [t] ON [t].[SalesTerritoryKey] = [s].[SalesTerritoryKey]
WHERE 1=1
--	AND [d].[CalendarYear] = 2012                                          -- filters can be applied here, e.g. for a specific year - filter can also come from any other dimension, it just needs to be joined to the fact table
GROUP BY ROLLUP (                                                          -- rollup is reevaluating its entire context, not reusing smaller aggregates
	 [d].[CalendarQuarter]
	,[t].[SalesTerritoryCountry]
)
ORDER BY
	 GROUPING_ID([d].[CalendarQuarter])
	,[d].[CalendarQuarter]
	,GROUPING_ID([t].[SalesTerritoryCountry])
	,[t].[SalesTerritoryCountry]