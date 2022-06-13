page 60122 BarcodeSetup
{
    PageType = Card;
    SourceTable = "Barcode Setup";
    Caption = 'Barcode Setup';
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.BarcodeFormat)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
            }
            group(Azure)
            {
                Caption = 'Azure';
                field("URL Azure Function"; Rec."URL Azure Function")
                {
                    ApplicationArea = All;
                }
                field("Token Azure Function"; Rec."Token Azure Function")
                {
                    ApplicationArea = All;
                }
            }

            group(Options)
            {
                Caption = 'Options';
                group(Barcode)
                {
                    field(Width; Rec.ImageWidth)
                    {
                        ApplicationArea = All;
                    }
                    field(Height; Rec.ImageHeight)
                    {
                        ApplicationArea = All;
                    }
                    field(Border; Rec.ImageMargin)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        area(FactBoxes)
        {
            part(BarcodePicture; "Barcode Setup Part")
            {
                ApplicationArea = All;
                SubPageLink = Code = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateBarcode)
            {
                Caption = 'Create Barcode (Test)';
                Image = BarCode;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;
                trigger OnAction();
                var
                    InStr: InStream;
                begin
                    Helper.GetBarcodeFromAzure(Rec.Value, InStr);

                    BarcodeSetup.Get();
                    BarcodeSetup.Picture.ImportStream(InStr, BarcodeSetup.Value, 'image/gif');
                    BarcodeSetup.Modify();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        InStr: InStream;
    begin
        Rec.DeleteAll();
        Rec.InsertIfNotExists;

        if Rec.Value <> '' then begin
            Helper.GetBarcodeFromAzure(Rec.Value, InStr);

            BarcodeSetup.Get();
            BarcodeSetup.Picture.ImportStream(InStr, BarcodeSetup.Value, 'image/gif');
            BarcodeSetup.Modify();
        end;
    end;

    var
        Helper: Codeunit Helper;
        BarcodeSetup: Record "Barcode Setup";
        TempBlob: Codeunit "Temp Blob";
}