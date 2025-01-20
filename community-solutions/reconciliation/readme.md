[Member states:](https://community.fabric.microsoft.com/t5/Power-Query/Removing-Duplicates-from-Merged-Tables-in-Power-Query/m-p/3303419)

# Removing Duplicates from Merged Tables in Power Query

I am doing a reconciliation from two different data set to find variances but when I do a full outer join between the tables I get duplicates if one of the tables are more than one row for the merge fields. There no unique identifier so I'm merging them using Resource, Date and hours

 

Table A	 	 	 
Resource	Invoice ID	Date	Hours
John Doe	12345	8/28/2023	40
Table B	 	 	 
Resource	Invoice ID	Date	Hours
John Doe	45678	8/28/2023	40
John Doe	98765	8/28/2023	-40
John Doe	76543	8/28/2023	40
 

Here's what I'm getting: 

Table A Resource	
Table A

Invoice ID

Table A Date	Table A Hours	
Table B

Resource

Table B Invoice ID	Table B Date	Table B Hours
John Doe	12345	8/28/2023	40	John Doe	45678	8/28/2023	40
John Doe	12345	8/28/2023	40	John Doe	98765	8/28/2023	-40
John Doe	12345	8/28/2023	40	John Doe	76543	8/28/2023	40
 

Here's what I want to see:

Table A Resource	Table A Invoice ID	Table A Date	Table A Hours	Table B Resource	Table B Invoice ID	Table B Date	Table B Hours
John Doe	12345	8/28/2023	40	John Doe	45678	8/28/2023	40
 	 	 	40	John Doe	98765	8/28/2023	-40
 	 	 	40	John Doe	76543	8/28/2023	40
 

Can someone help me, please?

# Solution

The example above for sure is not a merge including the hours because 40 and -40 won't match. In my solution I only merged on Resource and Date.

You cannot produce the result you want from a single merge step. If your requirements demand these empty cells then you need to clean up them afterwards (what you want is something like a "reverse-filldown" in Power Query). E.g., you could compare the Resource and Date columns with the previous row as described [here](https://www.thebiccountant.com/2018/07/12/fast-and-easy-way-to-reference-previous-or-next-rows-in-power-query-or-power-bi/), check whether a Table A row is a duplicate of the previous row, and add custom columns in your first-and-blank-rows format. Then finally remove the columns from table A from the merge result that you don't want to have.
