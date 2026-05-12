codeunit 50102 "Order Confirmation Mgt"
{
    procedure SendOrderConfirmation(SalesHeader: Record "Sales Header")
    var
        Email: Codeunit "Email";
        EmailMessage: Codeunit "Email Message";
        Recipients: List of [Text];
        Body: Text;
        Customer: Record Customer;
    begin
        Customer.Get(SalesHeader."Sell-to Customer No.");

        if Customer."E-Mail" = '' then
            exit;

        Recipients.Add(Customer."E-Mail");

        Body :=
            '<h2>Tak for din ordre!</h2>' +
            '<p>Vi har modtaget din ordre.</p>' +
            '<br>' +
            '<b>Ordrenummer:</b> ' + SalesHeader."No." + '<br>' +
            '<b>Ordredato:</b> ' + Format(SalesHeader."Order Date");

        EmailMessage.Create(
            Recipients,
            'Ordrebekræftelse',
            Body,
            true
        );

        Email.Send(
            EmailMessage,
            Enum::"Email Scenario"::"Order Confirmation"
        );
    end;
}