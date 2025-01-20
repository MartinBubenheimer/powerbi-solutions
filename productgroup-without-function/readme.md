# In Response to YouTube Video from PeryTUS

[https://www.youtube.com/watch?v=xv5UxtUCOK0](https://www.youtube.com/watch?v=xv5UxtUCOK0)

## Proposed solution in video

Use Power Query custom function

```
(productGroup, Product) =>
let
    Source = Product,
    Len = Text.Length(productGroup),
    #"Inserted First Characters" = Table.AddColumn(Source, "First", each Text.Start([Id], Len), type text),
    SelectedProducts = Table.SelectRows( #"Inserted First Characters", each [First] = productGroup)
in
    SelectedProducts
```

and call this function, providing the table in the second parameter as a buffered table from calling Table.Buffer()

## Alternative solution

Don't use custom function. Expand the Product table to have every potential product group for each product in one column. Then do a single join of the Product Groups and the expanded Products table.

Loading duration with comparable amount of data is one second including overhead to record Power Query diagnostics.
