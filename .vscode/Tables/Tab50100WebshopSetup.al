table 50100 "Webshop Setup"
{
    /// <summary>
    /// This table stores configuration settings for the webshop application, such as low stock thresholds
    /// and notification email addresses. It is designed to hold a single record that can be accessed
    /// and updated through the Webshop Setup page.
    /// </summary>
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }

        field(2; "Low Stock Threshold"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Notification Email"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}