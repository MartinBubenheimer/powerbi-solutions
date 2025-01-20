Member states:

# Future aging inventory balances

I have two table. One is a Date table and the other is a STOCK table. The STOCK table contains lines of inventory and has three columns, Part Number, Receive Date, and Value. I joined the Receive Date to the Date field in the Date table. I want to create a matrix visual that I can put the Part Number in the Rows, Year/Month in the columns, and a value measure that sums all inventory lines that are over 36 months old within the months displayed over the columns. In the example below, I have a STOCK line of Pipe, based on it's receive date, will be over 36 months old in April 2023 and I have additional lines of Pipe in the STOCK table that will be over 36 months old in Dec 2023. I have a few lines of Paper, that total $12 in value, all over 36 months as of Jan 2023. I have a line of Notebook that will be over 36 months starting in March 2023 and no other lines of Notebook that will turn over 36 months for the rest of the year.

Part Number  |  Jan 2023 | Feb 2023 | March 2023 | April 2023| ......| Dec 2023|

Pipe                         0                 0               0                $36                   $120

Paper                      $12             $12           $12             $12                    $12

Notebook                0                  0             $20             $20                   $20

What I'm trying to accomplish to project my over 36 month inventory values over future months. If I don't sell a single thing for the rest of the year, how much over 36 month inventory will I have for each future month.
