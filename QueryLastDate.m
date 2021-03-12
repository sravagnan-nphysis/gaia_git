function Response = QueryLastDate(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    ji = jsondecode(ji);
    r         = matlab.net.http.RequestMessage;
    r.Header  = matlab.net.http.HeaderField('Content-Type','application/csv');        
    uri       = matlab.net.URI(ji.Server.UrlLastdate);
    resp      = send(r,uri);
    UTCdate   = datetime(resp.Body.Data,'TimeZone','Europe/Rome','Format','uuuu-MM-dd HH:mm Z');
    StartDate = datetime(resp.Body.Data,'Format','uuuu-MM-dd HH:mm') + tzoffset(UTCdate);
%--- Scrittura della risposta   
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result.oraelaborazioneUTC = UTCdate;
    Response.Result.oraelaborazione = StartDate;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

