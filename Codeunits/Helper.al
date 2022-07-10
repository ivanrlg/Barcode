codeunit 60123 Helper
{
    var
        BaseUrlAzure: Text;
        BarcodeSetup: Record "Barcode Setup";

    procedure GetBarcodeFromAzure(Value: text): Text
    var
        httpClient: HttpClient;
        httpContent: HttpContent;
        httpResponse: HttpResponseMessage;
        Result: Text;
        IsSuccess: Boolean;
        Message: Text;
        OutPut: Text;
        JsonObject: JsonObject;
        InStream: InStream;
        ParamsJToken: JsonToken;
        BarcodeSetup: Record "Barcode Setup";
        Url: Text;
        JsonRequest, FileArrayBase64 : Text;
    begin
        BarcodeSetup.Get();
        if not BarcodeSetup.IsActive then begin
            exit;
        end;

        Url := GetURL();
        JsonRequest := GetJsonRequest(Value);

        httpContent.WriteFrom(JsonRequest);
        httpClient.Post(Url, httpContent, httpResponse);

        httpResponse.Content().ReadAs(OutPut);

        if (httpResponse.HttpStatusCode <> 200) then begin
            Error('The data could not be published. Unable to execute httpclient request: (HttpStatusCode: '
            + Format(httpResponse.HttpStatusCode) + ' - Output' + OutPut + ')');
            Exit;
        end;

        JsonObject.ReadFrom(OutPut);

        FileArrayBase64 := GetJsonToken(JsonObject, 'result').AsValue().AsText();

        exit(FileArrayBase64);
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    local procedure GetURL(): Text;
    var
        Url: Text;
    begin
        BarcodeSetup.Get();
        BarcodeSetup.TestField("URL Azure Function");
        BarcodeSetup.TestField("Token Azure Function");

        BaseUrlAzure := BarcodeSetup."URL Azure Function";
        Url := BaseUrlAzure + 'api/BarcodeGenerator' + '?code=' + BarcodeSetup."Token Azure Function";

        exit(Url);
    end;

    procedure GetJsonRequest(Value: Text): Text
    var
        jsonRequestJO: JsonObject;
        jsonRequestText: Text;
    begin
        BarcodeSetup.Get();

        jsonRequestJO.Add('value', Value);
        jsonRequestJO.Add('imageHeight', BarcodeSetup.ImageHeight);
        jsonRequestJO.Add('imageWidth', BarcodeSetup.ImageWidth);
        jsonRequestJO.Add('margin', BarcodeSetup.ImageMargin);
        jsonRequestJO.Add('symbology', Format(BarcodeSetup.BarcodeFormat));

        jsonRequestJO.WriteTo(jsonRequestText);

        exit(jsonRequestText);
    end;
}