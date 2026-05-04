page 50100 "Webshop Setup"
{
    PageType = Card;
    SourceTable = "Webshop Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Low Stock Threshold"; Rec."Low Stock Threshold") { }
                field("Notification Email"; Rec."Notification Email") { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.IsEmpty() then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec.Insert();
        end;
    end;
}