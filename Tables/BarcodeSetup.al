table 60121 "Barcode Setup"
{

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Value; Text[250])
        {
            Caption = 'Value';
        }
        field(3; ImageWidth; Integer)
        {
            Caption = 'Image Width';
            InitValue = 250;
        }
        field(4; ImageHeight; Integer)
        {
            Caption = 'Image Height';
            InitValue = 100;
        }
        field(5; ImageMargin; Integer)
        {
            Caption = 'Image Margin';
            InitValue = 100;
        }
        field(6; BarcodeFormat; Option)
        {
            Caption = 'Barcode Format';
            OptionMembers = AZTEC,CODE_39,CODE_93,CODE_128,DATA_MATRIX,QR_CODE;
        }

        field(7; Picture; Media)
        {
            Caption = 'Picture';
        }
        field(8; "URL Azure Function"; Text[200])
        {
            Caption = 'URL Azure Function';
            ExtendedDatatype = URL;
        }
        field(9; "Token Azure Function"; Text[200])
        {
            Caption = 'Token Azure Function';
            ExtendedDatatype = URL;
        }
        field(10; IsActive; Boolean)
        {
            Caption = 'Is Active';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = false;
        }
    }

    procedure InsertIfNotExists()
    var
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;

}

