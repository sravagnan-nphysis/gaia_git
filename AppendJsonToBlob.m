function Response = AppendJsonToBlob(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    r = matlab.net.http.RequestMessage;
    r.Header = matlab.net.http.HeaderField('Content-Type','application/json',...
    'Accept','application/json',...
    'Connection', 'keep-alive',...
    'x-ms-date', datestr(datetime('now')),...
    'x-ms-version', '2019-12-12',...
    'x-ms-blob-type', 'AppendBlob');
    
    uri = matlab.net.URI('https://' + ji.VMpath + '/' + ji.blobPath + ji.Token);
    r.Method = 'PUT';
    body = matlab.net.http.MessageBody;
    body.Payload = ji.json2append;
    r.Body = body;
    resp = send(r,uri);
    status = resp.StatusCode;
    
    if(status == 201)
        Response.Status  = 'OK';
        Response.Error   = 'False';
        
        Response.Message = 'Blog Succesfully Written for id: '  + string(ji.Id);
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

