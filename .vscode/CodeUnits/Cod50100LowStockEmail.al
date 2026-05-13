codeunit 50100 "Low Stock Email Mgt"
{
    /// <summary>
    /// Sends a low stock notification email to the configured recipient.
    /// </summary>
    /// <param name="Body">The body of the email.</param>
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