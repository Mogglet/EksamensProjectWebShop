codeunit 50100 "Low Stock Email Mgt"
{
    procedure SendLowStockEmail(Body: Text)
    var
        Email: Codeunit "Email";
        EmailMessage: Codeunit "Email Message";
        Recipients: List of [Text];
        Setup: Record "Webshop Setup";
    begin
        Setup.Get('SETUP');

        Recipients.Add(Setup."Notification Email");

        EmailMessage.Create(
            Recipients,
            'Low stock varer',
            Body,
            false
        );

        Email.Send(
            EmailMessage,
            Enum::"Email Scenario"::"Low Stock"
        );
    end;
}