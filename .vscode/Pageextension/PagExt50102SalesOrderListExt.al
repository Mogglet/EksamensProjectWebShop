pageextension 50102 SalesOrderListExt extends "Sales Order List"
{
    /// <summary>
    /// This page extension adds a sales item chart to the Sales Order List page.
    /// The chart displays the top-selling items based on the sales orders.
    /// </summary>
    layout
    {
        // Add chart to the right-side FactBox area
        addlast(FactBoxes)
        {
            part(ItemSalesChart; SalesItemChartPage)
            {
                ApplicationArea = All;
            }
        }
    }
}