# Connected Scatterplot for Deneb Visual in Vega

Purpse of this solution is to show a Lorenz Curve, e.g., for ABC analysis.

The Power BI file shows different approaches:
* Power BI native visual using scatter plot.
* Deneb visual showing values from Power BI DAX measures
* Deneb visual doing sorting and cumulation in visual level calculations
* PlotlyJS commercial custom visual

## Backlog

1. Customize label density, e.g. by counting catgories and creating a filtered list with only every n-th value to see only e.g. 10 values in the chart.
2. Add ABC thresholds and shading or threshold refrence lines of ABC classification in chart background. Threshold should come from Power BI measures. Technically, sliders could be added in Vega, but then these values could not be synchronized with any other visuals.
3. Add colums for Pareto chart to make it a combined column and line chart. For columns, the x-axis might also show text labels for categories, not only numbers.
4. Add cross-highlighting for line, just showing the selected dots in  different color. The corresponding cross-highlighted value could be added to the tooltip.
5. Add cross-highlighting for columns, highlighting the categories and value proportions from cross-hoghlighting.
