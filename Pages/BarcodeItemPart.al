page 60124 "Barcode Item Part"
{
    PageType = CardPart;
    SourceTable = Item;
    Caption = 'Barcode';

    layout
    {
        area(content)
        {
            field(Barcode; Rec.Barcode)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
            }
        }
    }
}