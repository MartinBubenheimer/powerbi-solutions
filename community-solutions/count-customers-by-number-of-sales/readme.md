# [Member states:](https://community.fabric.microsoft.com/t5/DAX-Commands-and-Tips/Continuous-sum-based-on-discrete-dates/m-p/3356770#M126157)

I have a table with customer IDs, and the date of their first, second, third, and fourth car purchases. (Some customers might not have four purchases, for them the dates would be 2099, data shown below) 

What I need is, for each day, I would like to know how many customers have one car, how many customers have two cars etc. Basically I want to plot the distribution of customers based on how many cars they have against time, and this plot should cover all days from first purchase date until today. For example, first car is purchased on 12th Feb 2019

On this date %100 of my customers have one car. 1 day later on 13th Feb, still %100 of my customers have one car.

On 15th Feb 2019, same customer purchases a car again, so %100 of my customers have two cars. 

On 3rd October, 2019 another customer purchases a car, now I have two customers, one of them have one car and one of them have two cars, and I would like to plot their distribution.

Basically my X axis should be the dates, and on Y axis I would like to have percentage of customers who have one car, two cars and so on. Would appreciate the help so much! Thanks in advance

# Solution

![table.png](https://github.com/MartinBubenheimer/powerbi-solutions/blob/main/community-solutions/count-customers-by-number-of-sales/table.png?raw=true)
