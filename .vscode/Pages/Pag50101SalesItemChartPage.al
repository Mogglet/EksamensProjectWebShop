page 50101 SalesItemChartPage
{
    PageType = CardPart; // Small UI part used in FactBox
    ApplicationArea = All;
    Caption = 'Items Sold Chart';

    /// <summary>
    /// This page part displays a chart of the top-selling items based on sales order data.
    /// It uses a query to aggregate sales quantities by item and visualizes the data in a
    /// column chart. Users can click on a bar in the chart to navigate to the corresponding item card.
    /// </summary>
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
                    if Point.Get('XValueString', Token) then begin
                        ItemNo := Token.AsValue().AsText();

                        if ItemRec.Get(ItemNo) then
                            Page.RunModal(Page::"Item Card", ItemRec);
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

        ChartBuffer.Initialize();

        ChartBuffer.SetXAxis(
            'Items',
            ChartBuffer."Data Type"::String);

        ChartBuffer.AddMeasure(
            'Quantity',
            1,
            ChartBuffer."Data Type"::Decimal,
            ChartBuffer."Chart Type"::Column);

        SalesQuery.Open();

        Index := 0;

        while SalesQuery.Read() do begin
            ItemNo := SalesQuery.ItemNo;
            Qty := SalesQuery.TotalQuantity;

            ChartBuffer.AddColumn(ItemNo);

            // IMPORTANT:
            // MeasureIndex = 0
            // ColumnIndex = Index
            ChartBuffer.SetValueByIndex(0, Index, Qty);

            Index += 1;
        end;

        SalesQuery.Close();

        ChartBuffer.Update(CurrPage.Chart);
    end;
}