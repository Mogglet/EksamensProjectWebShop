table 50101 "Woo Order Link"
{
    /// <summary>
    /// This table links sales orders in Business Central to corresponding orders in the WooCommerce webshop.
    /// It stores the WooCommerce Order ID, the associated Sales Order No. in BC,
    /// and the date/time when the order was processed. This allows for tracking and synchronization
    /// between the two systems.
    Caption = 'Woo Order Link';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Order ID"; Integer)
        {
            Caption = 'Order ID';
        }
        field(3; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
        }
        field(4; "Processed DateTime"; DateTime)
        {
            Caption = 'Processed DateTime';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(OrderID; "Order ID")
        {
        }
    }
}
