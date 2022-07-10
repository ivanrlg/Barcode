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
        TaskParameters: Dictionary of [Text, Text];
    begin
        TaskParameters.Add('Value', Rec."No.");

        IsVisible := true;

        CurrPage.EnqueueBackgroundTask(WaitTaskId, Codeunit::PBTProcessWS, TaskParameters, 10000, PageBackgroundTaskErrorLevel::Warning);
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
                    Rec.Barcode.ImportStream(InStream, BarcodeSetup.Value, 'image/gif');
                    Rec.Modify();
                    IsVisible := true;
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
        IsVisible: Boolean;
        WaitTaskId: Integer;
        starttime: Text;
        durationtime: Text;
        endtime: Text;

}