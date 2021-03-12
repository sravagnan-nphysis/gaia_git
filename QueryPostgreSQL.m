function Response = QueryPostgreSQL(ji)
% Input:
% ji.Server.IP
% ji.Server.Port
% ji.Server.Variable
% Output:
% Table
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    ji = jsondecode(ji);
    r = matlab.net.http.RequestMessage;
    r.Header = matlab.net.http.HeaderField('Content-Type','application/json', 'Accept','application/json', 'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoid2ViX2NsaWVudCJ9.Z2uw9fzVXez-KHaYVaEJJB623QUngHRSy4faQkVBTLE');
    uri = matlab.net.URI('http://' + string(ji.Server.IP) + ':' + string(ji.Server.Port) + '/' + string(ji.Server.Variable));
    resp = send(r,uri);
%--- Scrittura della risposta     
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result  = resp.Body.Data;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end
