query 50100 SalesItemChartQuery
{
    elements
    {
        dataitem(SalesLine; "Sales Line")
        {
            DataItemTableFilter = Type = const(Item);

            column(ItemNo; "No.")
            {
            }

            column(TotalQuantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}