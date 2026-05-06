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
                    // Try both (depends on BC version)
                    if Point.Get('XValue', Token) or Point.Get('Label', Token) then begin
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
        Index: Integer;
    begin
        ChartBuffer.Reset();
        ChartBuffer.DeleteAll();

        // Define measure
        ChartBuffer.AddMeasure('Quantity', 0, ChartBuffer."Data Type"::Decimal, 0);

        SalesQuery.Open();

        Index := 0;

        while SalesQuery.Read() do begin
            Index += 1;

            ItemNo := SalesQuery.ItemNo;
            Qty := SalesQuery.TotalQuantity;

            // ✅ THIS is the correct way in your version
            ChartBuffer.AddColumn(ItemNo);

            // Use index internally
            ChartBuffer.SetValue('Quantity', Index, Qty);
        end;

        SalesQuery.Close();

        ChartBuffer.Update(CurrPage.Chart);
    end;
}