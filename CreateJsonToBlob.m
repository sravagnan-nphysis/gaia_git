function Response = CreateJsonToBlob(blobPath)
warning off
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    r = matlab.net.http.RequestMessage;
    r.Header = matlab.net.http.HeaderField('x-ms-date', datestr(datetime('now')),...
    'x-ms-version', '2019-12-12',...
    'x-ms-blob-type', 'AppendBlob');

    uri = matlab.net.URI('https://samtsk00.blob.core.windows.net/' +  blobPath + '?sv=2019-12-12&ss=b&srt=sco&sp=rwdlacx&se=9999-09-09T14:46:23Z&st=2020-09-09T06:46:23Z&spr=https&sig=bb47rO0g38Hk6uiTsBhVDe218ETWqTeEIxgWdZb2c38%3D');
    r.Method = 'PUT';
    resp = send(r,uri);
    status = resp.StatusCode;
    
    if(status == 201)
        Response.Status  = 'OK';
        Response.Error   = 'False';
        Response.Message = 'Blog Succesfully Written';
        Response.Result = [];
        display(jsonencode(Response))
    else
        Response.Status  = 'OK';
        Response.Error   = 'True';
        Response.Message = string(status) + '_' + resp.StatusLine.ReasonPhrase;
        Response.Result = [];
        display(jsonencode(Response))
    end
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end