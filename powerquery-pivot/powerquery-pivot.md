# Safely Pivot in PowerQuery

This PowerQuery template solution solves the following problems when using Table.Pivot:

1. An attribute does not occur in refreshed data. Result is a missing column. That means the schema of the refreshed query does no longer comply with the schema of the semantic and thus the refresh fails.
2. Table.Pivot is applied without aggregation and in a data refresh two values occur for the same record and attribute. In this case the refresh wouldn't even show an error in Power BI service, the values would just be discarded resulting in incorrect data. In Power BI Desktop, on the other hand, refresh would fail in this case, leaving people wondering why refresh seems to work in Power BI service but not in Power BI Desktop. That's why aggregation should be mandatory.
3. Different attributes can be of different data type and require different aggreation rules.
4. Provide default values, individually per attribute and in the correct data type, if a record doesn't have a certain attribute.
