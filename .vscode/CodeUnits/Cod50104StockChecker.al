codeunit 50104 "Stock Checker"
{
    /// <summary>
    /// Checks item stock levels against the configured threshold and sends notification emails if necessary.
    /// </summary>
    procedure CheckStock()
    var
        Item: Record Item;
        Setup: Record "Webshop Setup";
        LowStockEmail: Codeunit "Low Stock Email Mgt";
        Body: Text;
        HasLowStock: Boolean;
    begin
        Setup.Get('SETUP');

        Body := 'Følgende varer er lav på lager:\n\n';

        if Item.FindSet() then
            repeat
                if Item.Inventory < Setup."Low Stock Threshold" then begin
                    HasLowStock := true;

                    Body += StrSubstNo(
                        '- %1 (%2): %3 på lager\n',
                        Item."No.",
                        Item.Description,
                        Item.Inventory
                    );
                end;
            until Item.Next() = 0;

        if HasLowStock then
            LowStockEmail.SendLowStockEmail(Body);
    end;
}