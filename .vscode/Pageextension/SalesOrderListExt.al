pageextension 50102 SalesOrderListExt extends "Sales Order List"
{
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