query 50100 SalesItemChartQuery
{
    QueryType = Normal;

    elements
    {
        dataitem(SalesLine; "Sales Line")
        {
            column(ItemNo; "No.")
            {
            }

            column(Quantity; Quantity)
            {
                Method = Sum;
            }

            filter(Type; Type)
            {
                Const = Item;
            }
        }
    }
}