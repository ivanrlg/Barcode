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
                field(IsActive; Rec.IsActive)
                {
                    ApplicationArea = All;
                }
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
                    TaskParameters: Dictionary of [Text, Text];
                begin
                    if Rec.Value <> '' then begin

                        TaskParameters.Add('Value', Rec.Value);

                        CurrPage.EnqueueBackgroundTask(WaitTaskId, Codeunit::PBTProcessWS, TaskParameters, 10000, PageBackgroundTaskErrorLevel::Warning);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        TaskParameters: Dictionary of [Text, Text];
    begin
        Rec.InsertIfNotExists;

        if Rec.Value <> '' then begin

            TaskParameters.Add('Value', Rec.Value);

            CurrPage.EnqueueBackgroundTask(WaitTaskId, Codeunit::PBTProcessWS, TaskParameters, 10000, PageBackgroundTaskErrorLevel::Warning);

        end;
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        PBTNotification: Notification;
        TempBlob: codeunit "Temp Blob";
        Base64Convert: codeunit "Base64 Convert";
        FileArrayBase64: text;
        OutStream: OutStream;
        InStream: InStream;
        BarcodeSetup: Record "Barcode Setup";
        Message: Label 'Updated barcode image with background time of %1 ms';
    begin
        if (TaskId = WaitTaskId) then begin

            Evaluate(FileArrayBase64, Results.Get('fileArrayBase64'));
            Evaluate(durationtime, Results.Get('durationtime'));

            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(FileArrayBase64, OutStream);
            TempBlob.CreateInStream(InStream);

            if BarcodeSetup.Get() then
                if BarcodeSetup.IsActive then begin
                    BarcodeSetup.Picture.ImportStream(InStream, BarcodeSetup.Value, 'image/gif');
                    BarcodeSetup.Modify();
                end;

            PBTNotification.Message(StrSubstNo(Message, durationtime));
            PBTNotification.Send();
        end;
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        PBTErrorNotification: Notification;
    begin
        if (ErrorCode = 'ChildSessionTaskTimeout') then begin
            IsHandled := true;
            PBTErrorNotification.Message(StrSubstNo('Something went wrong. %1\ Error Calls Stack: %2', ErrorText, ErrorCallStack));
            PBTErrorNotification.Send();
        end

        else
            if (ErrorText = 'Child Session task was terminated because of a timeout.') then begin
                IsHandled := true;
                PBTErrorNotification.Message('It took too long to get results. Try again.');
                PBTErrorNotification.Send();
            end
    end;

    var
        WaitTaskId: Integer;
        durationtime: Text;
}