query 50100 SalesItemChartQuery
{
    // This query aggregates total quantity sold per item
    elements
    {
        dataitem(SalesLine; "Sales Line")
        {
            // Only include lines that are actual items (not G/L, resources, etc.)
            DataItemTableFilter = Type = const(Item);

            // Item number (used as identifier and label in chart)
            column(ItemNo; "No.")
            {
            }

            // Sum of quantity sold per item
            column(TotalQuantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}