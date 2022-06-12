pageextension 60123 "Item Card Ext" extends "Item Card"
{
    layout
    {
        addbefore(ItemPicture)
        {
            part(Barcode; "Barcode Item Part")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        InStr: InStream;
    begin
        Helper.GetBarcodeFromAzure(Rec."No.", InStr);
        Rec.Barcode.ImportStream(InStr, Rec."No.", 'image/gif');
        Rec.Modify();
    end;

    var
        Helper: Codeunit Helper;

}