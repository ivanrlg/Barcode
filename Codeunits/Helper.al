codeunit 60123 Helper
{
    var
        BaseUrlAzure: Text;
        BarcodeSetup: Record "Barcode Setup";

    procedure GetBarcodeFromAzure(Value: text; var InStr: InStream)
    var
        httpClient: HttpClient;
        httpContent: HttpContent;
        httpResponse: HttpResponseMessage;
        httpHeader: HttpHeaders;
        Result: Text;
        IsSuccess: Boolean;
        Message: Text;
        OutPut: Text;
        JsonObject: JsonObject;
        ParamsJToken: JsonToken;
        BarcodeSetup: Record "Barcode Setup";
        Url: Text;
        JsonRequest: Text;
    begin
        BarcodeSetup.Get();
        if not BarcodeSetup.IsActive then begin
            exit;
        end;

        Url := GetURL();
        JsonRequest := GetJsonRequest(Value);

        httpContent.WriteFrom(JsonRequest);
        httpContent.GetHeaders(httpHeader);
        httpHeader.Remove('Content-Type');
        httpHeader.Add('Content-Type', 'application/json');
        httpClient.Post(Url, httpContent, httpResponse);

        httpResponse.Content().ReadAs(OutPut);

        if (httpResponse.HttpStatusCode <> 200) then begin
            Error('The data could not be published. Unable to execute httpclient request: (HttpStatusCode: '
            + Format(httpResponse.HttpStatusCode) + ' - Output' + OutPut + ')');
            Exit;
        end;

        GetImage_FromResponse(httpResponse, InStr);
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

    local procedure GetImage_FromResponse(var Response: HttpResponseMessage; var InStr: InStream)
    begin
        Response.Content().ReadAs(InStr);
    end;
}