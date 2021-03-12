function nP_localita(ji)
% Il seguente modulo gestisce l'elaborazione dei dati delle singole
% località per tutti i livelli di altitudine.
% Scrive lo storico dei dati processati nel Blob.
% Scrive lo storico dei dati processati in Influxdb.

Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    ji.date_end = datestr(datetime(ji.date_start,'InputFormat','yyyy-MM-dd HH:mm','Format','uuuu-MM-dd HH:mm') + days(ji.Num_days),'yyyy-mm-dd HH:MM');
%--- Preparazione struttura per altitudine    
    AltitudeStructTables = WorkFlow(jsonencode(ji));
    j=1;
    while j<=numel(AltitudeStructTables.Result)
        ji.PG.pg.Tables = AltitudeStructTables.Result(j).Data;
        AltitudeStructTables.Result(j).Data = LabelAssociation(ji).Result;
        ji.T2A = AltitudeStructTables.Result(j).Data;
        AltitudeStructTables.Result(j).Data = Fuzzy_Algorithm(ji).Result;
        for v = [2,3,5,10,13,14,15]
            AltitudeStructTables.Result(j).Data.(v) = smoothdata(AltitudeStructTables.Result(j).Data.(v),'rloess',8);
        end
        ji.numRound = 2;
        ji.Table = AltitudeStructTables.Result(j).Data;
        AltitudeStructTables.Result(j).Data = RoundUpTable(ji).Result;
        
        AltitudeStructTables.Result(j).Overview = overview(AltitudeStructTables.Result(j).Data).Result;
        AltitudeStructTables.Result(j).Meta = ji.PG.Result.anagrafica_comprensori(ji.PG.Result.anagrafica_comprensori.Idloc == ...
            num2str(AltitudeStructTables.Result(j).Idloc),{'Location','Latitude','Longitude','Country'});
        j=j+1;
    end
%--- Scrittura del file di output nel Blob.
    ji.VMpath = "samtsk00.blob.core.windows.net";
    ji.Token = "?sv=2019-12-12&ss=b&srt=sco&sp=rwdlacx&se=9999-09-09T14:46:23Z&st=2020-09-09T06:46:23Z&spr=https&sig=bb47rO0g38Hk6uiTsBhVDe218ETWqTeEIxgWdZb2c38%3D&comp=appendblock";
    ji.blobPath = string(ji.pathL);
    for i = ji.id_loc_start:ji.id_loc_end
        ji.Id = i;
        if i == ji.id_loc_start
           CreateJsonToBlob(string(ji.pathL));
           ji.json2append = "[" + jsonencode(AltitudeStructTables.Result([AltitudeStructTables.Result.Idloc] == i)) + ",";
        elseif i == ji.id_loc_end
           ji.json2append = jsonencode(AltitudeStructTables.Result([AltitudeStructTables.Result.Idloc] == i)) + "]";
        else
           ji.json2append = jsonencode(AltitudeStructTables.Result([AltitudeStructTables.Result.Idloc] == i)) + ",";
        end
        AppendJsonToBlob(ji);
    end
%--- Scrittura su Influxdb.
    ji.Server.IP = ji.VM.ip;
    ji.Server.Port = ji.VM.port;
    ji.Server.Token = ji.VM.token;
    ji.Server.Org = ji.VM.org;
    ji.Measurement = "Idloc";
    ji.Tag = "Altitude";
    ji.ChTimeRef = "Time";
    
    for i = 1:numel(AltitudeStructTables.Result)
        ji.Id = string(i) + "_" + string(AltitudeStructTables.Result(i).Altitude);
        ji.Table2Write = AltitudeStructTables.Result(i);
        ji.Data = "Data";
        ji.Bucket = "GAIA";
        WriteInflux(ji);
        ji.Data = "Overview";
        ji.Bucket = "overview";
        WriteInflux(ji);
    end
    
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end
