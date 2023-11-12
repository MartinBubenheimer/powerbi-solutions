# Understanding Matrix Totals in Power BI

The purpose of this solution is to explain how the totals in a Power BI Matrix visual (and Table visual) are calculated. 
The values in a Matrix visual, including the totals, are the result of a a single query of the dataset. 
Totals are queried as rollups. For the SQL users among you, this might sound familiar. Rollups in SQL are calculated in their entire context, not from the smaller aggregates of the categories they roll up. 
The same is valid for Power BI Matrix visuals: Totals and subtotals are an evaluation of the measure in their context, not an assembly of smaller aggregates (e.g. a sum of the values displayed in a column). 
In Power BI Matrix visual, totals are calculated on query level - as rollups- not on visual level as aggregations of displayed values. 
Stacked visuals, e.g. stacked bar chart, differ from this behavior since, because of their specific use case, it's only reasonable to use stacked charts if the total is the sum of the segments. 
Thus, stacked visuals calculate totals on visual level as the sum of the segments. 
For the Matrix visual, this constraint is not enforced to allow for a more universal use of the "Total" calculation, e.g. to calculate weighted averages correctly on all levels.

The SQL code in this example explains how the structure of a Matrix query applies the measure to calculate the values and totals. 
In Power BI, the query of the dataset always returns an unpivoted table, pivoting the result into the Matrix visual is done on visual level. 
