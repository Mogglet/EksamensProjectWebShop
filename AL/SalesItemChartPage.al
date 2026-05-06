page 50101 SalesItemChartPage
{
    PageType = CardPart;
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
                    BuildChart();
                end;

                trigger DataPointClicked(Point: JsonObject)
                var
                    ItemNo: Code[20];
                    ItemRec: Record Item;
                    Token: JsonToken;
                begin
                    // Extract X value (Item No.)
                    if Point.Get('XValue', Token) then begin
                        ItemNo := Token.AsValue().AsText();

                        if ItemRec.Get(ItemNo) then
                            Page.Run(Page::"Item Card", ItemRec);
                    end;
                end;
            }
        }
    }

    var
        SalesQuery: Query SalesItemChartQuery;
        ChartBuffer: Record "Business Chart Buffer" temporary;

    local procedure BuildChart()
    var
        ItemNo: Code[20];
        Qty: Decimal;
    begin
        ChartBuffer.Reset();
        ChartBuffer.DeleteAll();

        // Setup chart
        ChartBuffer.AddMeasure('Quantity', 0, ChartBuffer."Data Type"::Decimal, 0);

        SalesQuery.Open();

        while SalesQuery.Read() do begin
            ItemNo := SalesQuery.ItemNo;
            Qty := SalesQuery.TotalQuantity;

            ChartBuffer.AddColumn(ItemNo);
            ChartBuffer.SetValue('Quantity', ItemNo, Qty);
        end;

        SalesQuery.Close();

        // Apply buffer to chart
        ChartBuffer.Update(CurrPage.Chart);
    end;
}