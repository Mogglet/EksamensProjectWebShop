pageextension 50102 SalesOrderListExt extends "Sales Order List"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(ItemSalesChart; SalesItemChartPage)
            {
                ApplicationArea = All;
            }
        }
    }
}