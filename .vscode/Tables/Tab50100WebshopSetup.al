table 50100 "Webshop Setup"
{
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