[Member states](https://community.fabric.microsoft.com/t5/DAX-Commands-and-Tips/YOY-for-only-those-weeks-present-in-current-yrear/m-p/3321614#M124331)

# YOY for only those weeks present in current year

Hi 

I have  sales table which has data from different retailers (eg- A,B,C)
now i want yoy growth of sales in such a way that it compares the weeks of current year and calculate yoy for that.
for example for current year/max year there is data only till may,
now for this want to calculate yoy growth for sales till may in this year from sales till may last year
while for rest of the years  it should be norrmal yoy growth.
also different retailers have different data( like for A data is there till may(20 weeks), for B it is there till feb(10 weeks) and for c it is there till april-13 weeks)

i have a slicer of retailer and year on my page , when is select year 2023( max year) and select retailer A i want yoy growth till may from last year sales till may, on selecting B it should be till feb to feb of lasy year and so on.



i did use the below dax but i think it is taking the max weeks of overall data (20)
can anyone help me with max weeks for each retailers-


Last year sales =
Var Maxyr = CALCULATE(MAX(DateTable[Year]), ALL(DateTable))
VAR MaxWeekCurrentYear = MAXX(FILTER(DateTable, DateTable[Year] = Maxyr), DateTable[WeekNo])
RETURN
CALCULATE(
    SUM('Combined Data'[sales]),
    DateTable[Year] =Maxyr-1,
    DateTable[WeekNo] <= MaxWeekCurrentYear
)
 
i have 2 tables combined data and datetable connected by a date key and retailers column is in combined data
