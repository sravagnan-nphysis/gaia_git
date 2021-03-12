function Response = WorkFlow(ji)
% il seguente modulo recupera i dati di 3B, li filtra secondo le
% indicazione presenti nei metadati secondo data e idloc.
% divide i dati meteo per livelli di altitudine.
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
%--- Conversione deti dati di input    
    ji  = jsondecode(ji);
    id_loc_start = ji.id_loc_start;
    id_loc_end = ji.id_loc_end;
    date_start = datetime(ji.date_start,'InputFormat','yyyy-MM-dd HH:mm','Format','yyyy-MM-dd HH:mm');
    date_end   = datetime(ji.date_end,'InputFormat','yyyy-MM-dd HH:mm','Format','yyyy-MM-dd HH:mm');
%--- Creazione della struttura di input per la query che recupera i file di 3B.   
    jiB.Server.url_lastdate = 'https://model.3bmeteo.com/104/MAPPEWEB/WRF/CTL1/lastdate_meteomedsnow.txt';
    jiB.Server.url_weather  = 'https://model.3bmeteo.com/104/MAPPEWEB/WRF/CTL1/meteomedsnow_special.csv';
    jiB.date_start = datetime(ji.date_start,'TimeZone','Europe/Rome','Format','uuuu-MM-dd HH:mm');
%--- Recupero dei dati grezzi
    Response = WeatherData_Query(jsonencode(jiB));
%--- Filtro dati per Data
    Response.Result = Response.Result(Response.Result.oraelaborazione >= date_start & Response.Result.oraelaborazione <= date_end,:);
%--- Filtro dati per Idloc 
    Response.Result = Response.Result(Response.Result.idloc >= id_loc_start & Response.Result.idloc <= id_loc_end,:);    
%--- Preparazione struttura per altitudine
    jiS.Table2Write = Response;
    if strcmp(ji.Algorithm,"localita")
        Response = AltitudeStruct(jiS);
    elseif strcmp(ji.Algorithm,"entita")
        Response = AltitudeStruct(jiS);
%         Response.Result.Raw = jiS.Table2Write.Result;
%         Response.Result.Raw.Properties.VariableNames{'idloc'} = 'Idloc';
    end
%-- Scrittura della Risposta
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result  = Response.Result;    
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    disp(jsonencode(Response))
end
end

