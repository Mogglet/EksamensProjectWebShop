page 50101 SalesItemChartPage
{
    PageType = CardPart;
    SourceTable = "Integer";
    ApplicationArea = All;
    Caption = 'Items Sold Chart';

    layout
    {
        area(content)
        {
            usercontrol(Chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    LoadChart();
                end;

                trigger DataPointClicked(Point: JsonObject)
                var
                    ItemNo: Code[20];
                    Item: Record Item;
                begin
                    // Get item no from clicked point
                    Point.GetValue('XValue', ItemNo);

                    if Item.Get(ItemNo) then
                        Page.Run(Page::"Item Card", Item);
                end;
            }
        }
    }

    var
        SalesQuery: Query SalesItemChartQuery;

    local procedure LoadChart()
    var
        Labels: List of [Text];
        Values: List of [Decimal];
        ItemNo: Code[20];
        Qty: Decimal;
    begin
        SalesQuery.Open();

        while SalesQuery.Read() do begin
            ItemNo := SalesQuery.ItemNo;
            Qty := SalesQuery.Quantity;

            Labels.Add(ItemNo);
            Values.Add(Qty);
        end;

        SalesQuery.Close();

        CurrPage.Chart.SetXAxis(Labels);
        CurrPage.Chart.AddSeries('Items Sold', Values);
    end;
}