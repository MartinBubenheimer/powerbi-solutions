Be aware of the difference between filter and query parameter: A filter is applied on the query result, i.e., the data source needs to execute the unfiltered query. A query parameter actually reduces the load on the data source and the amount of transferred data.

Key to apply multivalued parameters on a Power BI or SSAS Tabular data source in a DAX query is using the RSCustomDaxFilter macro as described by Chris Webb in this post: https://blog.crossjoin.co.uk/2019/11/03/power-bi-report-builder-and-rscustomdaxfilter/

What you need to modify to work with the files:

1. Publish the Power BI file to your Power BI workspace.
2. In the paginated report, connect the dataset with your publishhed dataset in your workspace.
3. Then publish the Paginated Report into your workspace.
4. In the Power BI file, you now need to update the URLs/links to the paginated report with the URL of your paginated report in your workspace.
5. Publish the modified Power BI report to your workspace again (overwriting the original dataset and report).
