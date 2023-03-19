# Flatten Parent Child Hierarchy in Power Query
This Power Query solution creates columns per hierarchy level from a parent-child-hierarchy with any number of levels. 
The user does not need to investigate the required number of columns upfront since the script automatically determins and creates the required columns.
The script even adds columns automatically as the depth of the hierarchy growth in the source table.

Automation scripts for Tabular Editor help creating Calculation Groups for correctly showing values in a ragged hierarchy. The scripts rely on hierarchy objects that need to created first from the hierarchy columns.
