pageextension 60123 "Item Card Ext" extends "Item Card"
{
    layout
    {
        addbefore(ItemPicture)
        {
            part(Barcode; "Barcode Item Part")
            {
                Visible = IsVisible;
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        InStr: InStream;
        BarcodeSetup: Record "Barcode Setup";
    begin
        IsVisible := false;

        Helper.GetBarcodeFromAzure(Rec."No.", InStr);
        if BarcodeSetup.Get() then
            if BarcodeSetup.IsActive then begin
                Rec.Barcode.ImportStream(InStr, Rec."No.", 'image/gif');
                Rec.Modify();
                IsVisible := true;
            end;
    end;

    var
        Helper: Codeunit Helper;
        IsVisible: Boolean;

}