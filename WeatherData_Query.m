function Response = WeatherData_Query(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    ji = jsondecode(ji);
    StartDate = datetime(ji.date_start,'Format','uuuu-MM-dd HH:mm');
    url = ji.Server.url_weather;
    options  = weboptions('RequestMethod','get','ArrayFormat','csv','ContentType','table');
    Response.Result = webread(url,options);
%--- Associazione dei datetime    
    Response.Result.oraelaborazione = StartDate+hours(Response.Result.oraelaborazione)-hours(1);
    Response.Result(:,2:end) = filloutliers(Response.Result(:,2:end),'nearest','mean','ThresholdFactor',5);
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful'; 
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end    
end

