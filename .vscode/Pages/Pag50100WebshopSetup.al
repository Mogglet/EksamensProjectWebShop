page 50100 "Webshop Setup"
{
    PageType = Card;
    SourceTable = "Webshop Setup";

    /// <summary>
    /// This page allows users to configure settings for the webshop application, such as low stock thresholds
    /// and notification email addresses. It serves as the central location for managing webshop-related configurations.
    /// </summary>
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