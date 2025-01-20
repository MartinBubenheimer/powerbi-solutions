Two T-SQL stored procedures for Microsoft SQL-Server to flatten parent-child hierarchies for use with Power BI tabular model. The stored prcedure can be directly called in Power Query, thus a data mart can still provide tool-independent parent-child columns and Power BI can load hierarchy columns as needed for build-in visual types.

This one procedure supports any table, any depth of hierarchy levels, and any content for the level columns, even SQL expressions, e.g. to concatenate text from multiple original columns.

The two scripts do:
1. Count the maximum path depth in the original data.
2. Transform the parent-child-structure into a one column per level structure.

Parameters apply. Detailed documentation see PDF file in this folder.
Not suitable for Power BI Direct Query or Dual Storage Mode!
Not suitable for Azure Synapse Serverless SQL!

If the goal is to build a concatenated hierarchy from two table with a parent child hierarchy each, e.g. a project work breakdown structure (WBS) with an attached cost element hierarchy per WBS element, then the approch must be to
1. first create one table with the lines from both table common parent-child columns and link the the parent nodes of the attached hierachy to the child nodes of the top hierarchy
2. Then apply the stored procedure.
Doing it vice-versa the nodes of the attached hierarch would not appear at the next level after each child of the top hierarchy, but instead there would be as many emtpy columns as there are columns needed for the top hierarchy's longest path, only then attached hierary elements would start to occur at any node.
