Two T-SQL stored procedures for Microsoft SQL-Server to flatten parent-child hierarchies for use with Power BI tabular model. The stored prcedure can be directly called in Power Query, thus a data mart can still provide tool-independent parent-child columns and Power BI can load hierarchy columns as needed for build-in visual types.

The two scripts do:
1. Count the maximum path depth in the original data.
2. Transform the parent-child-structure into a one column per level structure.

Parameters apply. Detailed documentation to come.
