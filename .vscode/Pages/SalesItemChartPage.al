page 50101 SalesItemChartPage
{
    PageType = CardPart; // Small UI part used in FactBox
    ApplicationArea = All;
    Caption = 'Items Sold Chart';

    layout
    {
        area(content)
        {
            // Business Central chart control
            usercontrol(Chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                // Triggered when chart is ready → load data
                trigger AddInReady()
                begin
                    BuildChart();
                end;

                // Triggered when user clicks a data point (bar in chart)
                trigger DataPointClicked(Point: JsonObject)
                var
                    ItemNo: Code[20];
                    ItemRec: Record Item;
                    Token: JsonToken;
                begin
                    // Extract clicked value (Item No.)
                    // Different BC versions use XValue or Label
                    if Point.Get('XValue', Token) or Point.Get('Label', Token) then begin
                        ItemNo := Token.AsValue().AsText();

                        // Open the Item Card for the selected product
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
        // Clear previous chart data
        ChartBuffer.Reset();
        ChartBuffer.DeleteAll();

        // Define a measure (Y-axis)
        // 'Quantity' is the name shown in legend
        ChartBuffer.AddMeasure('Quantity', 0, ChartBuffer."Data Type"::Decimal, 0);

        // Open query to read aggregated sales data
        SalesQuery.Open();

        Index := 0;

        // Loop through each item result from query
        while SalesQuery.Read() do begin
            Index += 1;

            ItemNo := SalesQuery.ItemNo;
            Qty := SalesQuery.TotalQuantity;

            // Add a column (X-axis label = Item No.)
            ChartBuffer.AddColumn(ItemNo);

            // Assign value to the column (Y-axis value)
            // Uses index because chart requires numeric positioning
            ChartBuffer.SetValue('Quantity', Index, Qty);
        end;

        SalesQuery.Close();

        // Send prepared data to chart UI
        ChartBuffer.Update(CurrPage.Chart);
    end;
}