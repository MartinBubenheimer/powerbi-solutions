# Facts in Different Granularities

Example:

Sales is on date (day) level granilarity.

Budget is on month level granularity.

## How to show daily sales in a common visual

1. For all common level use common dimension tables, including common hierarchy levels of the dimensions that have different granularity, e.g. for monthly and daily level, build a monthly date table and a daily date table. Prefer using dimension tables over using columns from the higher grranularity fact table as categories in visuals.
2. For all fact tables, create key columns to both the dimension tables, the lower and the higher granualrity table, and link both fact tables to both dimension tables.
3. In the higher granularity fact table, the key column to the lower cardinality dimension table simply contains the key to the corresponding lower granularity category (e.g.,  a fact row assigned to a date will get the key of the corresponding month in a month key column to a month dimension)
4. In the lower cardinality fact table, fill the higher granularity key column with all null, or even better, applying full referencial integrity introduce a placeholder dimension value and surrogate key in the high granularity dimension table that is used as the key in the lower cardinality fact table.
5. In visuals and filters, for all shared granularities, e.g. month,  year, if one fact table is on monthly level and one is on daily level, you must use the fields from the low granularity dimension table.
6. Use fields from the higher granularity dimension table only for showing higher granularity categories than available in the lower cardinality fact table.
7. Now, lower granularity measures do no longer appear with every row of the higher granularity categories.
8. Implement measures and filters as needed.
