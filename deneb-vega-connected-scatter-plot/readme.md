# Connected Scatterplot for Deneb Visual in Vega

Purpse of this solution is to show a Lorenz Curve, e.g., for ABC analysis.

![Vega](https://github.com/MartinBubenheimer/powerbi-solutions/blob/main/deneb-vega-connected-scatter-plot/deneb-lorenz-curve.png?raw=true)

The Power BI file shows different approaches:
* Power BI native visual using scatter plot.
* Deneb visual showing values from Power BI DAX measures
* Deneb visual doing sorting and cumulation in visual level calculations
* PlotlyJS commercial custom visual

## Using the Visual in Power BI

When using this Vega code in Power BI, then the Deneb visual needs the following fields with exactly these names:
* Customer: Text
* Rank: decimal value in range 0..1 (percentage) for x-axis
* Sales: decimal value in range 0..1 (percentage) for y-axis
* Tooltip: decimal value (currency amount) for tooltip

The fields can be renmed locally for this visual to match these names.

The code can be tested in the [Vega online Editor](https://vega.github.io/editor/#/), e.g., using this test data:

```
      "values": [
        {"Customer": "A", "Rank": 0.2, "Sales": 0.50, "Tooltip": 5000000.00 },
        {"Customer": "A", "Rank": 0.2, "Sales": 0.30, "Tooltip": 3000000.00 },
        {"Customer": "A", "Rank": 0.2, "Sales": 0.12, "Tooltip": 1200000.00 },
        {"Customer": "A", "Rank": 0.2, "Sales": 0.06, "Tooltip": 600000.00 },
        {"Customer": "A", "Rank": 0.2, "Sales": 0.02, "Tooltip": 200000.00 },
      ]
```

_Remarks_
The Vega code uses the function pbiFormat which is not part of the Vega schema. Thus,
* The code does not include an explicit schema reference
* The code needs to be modified to run in Vega online editor

Use [format()](https://vega.github.io/vega/docs/expressions/#format-functions:~:text=%23%20format(value%2C%20specifier)) instead. See [d3-format specification)[https://github.com/d3/d3-format/?tab=readme-ov-file] for differences in formatting synatax.

For mor information about the pbiFormat function, which is specific to the Deneb Power BI custom visual, see:

* https://gist.github.com/MoloneyKing/d069882c3201e5cd798f2470887e685e
* https://github.com/deneb-viz/deneb-viz.github.io/issues/22

## Backlog

1. Customize label density, e.g. by counting catgories and creating a filtered list with only every n-th value to see only e.g. 10 values in the chart.
2. Add ABC thresholds and shading or threshold refrence lines of ABC classification in chart background. Threshold should come from Power BI measures. Technically, sliders could be added in Vega, but then these values could not be synchronized with any other visuals.
3. Add colums for Pareto chart to make it a combined column and line chart. For columns, the x-axis might also show text labels for categories, not only numbers.
4. Add cross-highlighting for line, just showing the selected dots in  different color. The corresponding cross-highlighted value could be added to the tooltip.
5. Add cross-highlighting for columns, highlighting the categories and value proportions from cross-hoghlighting.
