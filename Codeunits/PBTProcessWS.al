codeunit 60124 PBTProcessWS
{
    trigger OnRun()
    var
        Result: Dictionary of [Text, Text];
        StartTime: Time;
        WaitParam: Text;
        EndTime: Time;
        Helper: Codeunit Helper;
        Value: text;
        FileArrayBase64: Text;
    begin
        if not Evaluate(Value, Page.GetBackgroundParameters().Get('Value')) then
            Error('Could not parse parameter ValueParam');

        StartTime := System.Time();

        FileArrayBase64 := Helper.GetBarcodeFromAzure(Value);

        EndTime := System.Time();

        Result.Add('durationtime', Format(EndTime - StartTime));

        Result.Add('fileArrayBase64', Format(FileArrayBase64));

        Page.SetBackgroundTaskResult(Result);
    end;
}
