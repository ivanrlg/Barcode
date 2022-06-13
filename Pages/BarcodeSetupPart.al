page 60123 "Barcode Setup Part"
{
    PageType = CardPart;
    SourceTable = "Barcode Setup";
    Caption = 'Barcode';

    layout
    {
        area(content)
        {
            field(Picture; Rec.Picture)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
            }
        }
    }
}