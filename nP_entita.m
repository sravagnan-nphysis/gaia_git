function nP_entita(ji)
% Il seguente modulo gestisce l'elaborazione dei dati delle singole
% entita
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
%------- Associazione dell'etichetta meteo e dell url per l'icona
        ji.PG.pg.Tables = AltitudeStructTables.Result(j).Data;
        AltitudeStructTables.Result(j).Data = LabelAssociation(ji).Result;
%------- Calcolo del Comfort
        ji.T2A = AltitudeStructTables.Result(j).Data;
        AltitudeStructTables.Result(j).Data = Fuzzy_Algorithm(ji).Result;
%------- Smooth dei dati        
        for v = [2,3,5,10,13,14,15]
            AltitudeStructTables.Result(j).Data.(v) = smoothdata(AltitudeStructTables.Result(j).Data.(v),'rloess',8);
        end
%------- Arrotondamento a 2 cifre
        ji.numRound = 2;
        ji.Table = AltitudeStructTables.Result(j).Data;
        AltitudeStructTables.Result(j).Data = RoundUpTable(ji).Result;   
%------- Calcolo della overview
        if strcmp(ji.Algorithm, "entita") && strcmp(ji.Obj, "line")
            j=j+1;
            continue
        else
           AltitudeStructTables.Result(j).Overview = overview(AltitudeStructTables.Result(j).Data).Result;
        end
        j=j+1;
    end
%--- Estrazione delle entita
    entita = ji.entita;
%--- Conversione in dataframe per aumentare la velocità di filtraggio
    AltitudeStructTables.Result = struct2table(AltitudeStructTables.Result);
    if strcmp(ji.Obj,'point')
        ji_ptn.e = entita;
        ji_ptn.AST = AltitudeStructTables;
        entita = point_ent(ji_ptn).Result;
    elseif strcmp(ji.Obj,'line')
        ji_ln.e = entita;
        ji_ln.AST = AltitudeStructTables;
        entita = line_ent(ji_ln).Result;
    end
    AltitudeStructTables.Result = table2struct(entita);
%--- Scrittura del file di output nel Blob.
    ji.VMpath = "samtsk00.blob.core.windows.net";
    ji.Token = "?sv=2019-12-12&ss=b&srt=sco&sp=rwdlacx&se=9999-09-09T14:46:23Z&st=2020-09-09T06:46:23Z&spr=https&sig=bb47rO0g38Hk6uiTsBhVDe218ETWqTeEIxgWdZb2c38%3D&comp=appendblock";
    if strcmp(ji.Obj,'point')
        ji.blobPath = string(ji.pathEP);
    elseif strcmp(ji.Obj,'line')
        ji.blobPath = string(ji.pathEL);
    end
    for i = 1:numel(AltitudeStructTables.Result)
        ji.Id = string(AltitudeStructTables.Result(i).Idloc) + "_" + string(AltitudeStructTables.Result(i).osm_id);
        if i == 1
           CreateJsonToBlob(string(ji.blobPath));
           ji.json2append = "[" + jsonencode(AltitudeStructTables.Result(i)) + ",";
        elseif i == numel(AltitudeStructTables.Result)
           ji.json2append = jsonencode(AltitudeStructTables.Result(i)) + "]";
        else
           ji.json2append = jsonencode(AltitudeStructTables.Result(i)) + ",";
        end
        AppendJsonToBlob(ji);
    end
%--- Scrittura su Influxdb.
    ji.Server.IP = ji.VM.ip;
    ji.Server.Port = ji.VM.port;
    ji.Server.Token = ji.VM.token;
    ji.Server.Org = ji.VM.org;
    ji.Measurement = "Name";
    ji.Tag = ["Idloc","osm_id","Altitude"];
    ji.ChTimeRef = "Time";
   
    for i = 1:numel(AltitudeStructTables.Result)
        ji.Id = string(AltitudeStructTables.Result(i).Idloc) + "_" + string(AltitudeStructTables.Result(i).osm_id);
        ji.Table2Write = AltitudeStructTables.Result(i);
        ji.Data = "Data";
        if strcmp(ji.Obj,'point')
            ji.Bucket = "entita_points";
        elseif strcmp(ji.Obj,'line')
            ji.Bucket = "entita_lines";
        end
        tic
        WriteInflux(ji);
        toc
        if strcmp(ji.Obj,'point')
            ji.Data = "Overview";
            ji.Bucket = "entita_points_overview";
            WriteInflux(ji);
        end
    end

catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end


% figure(1)
% set(gcf,'color','w');
% for j = 1:size(entita,1)
%     geoplot(entita.Geom{j,1}.lat,entita.Geom{j,1}.lon,'--');
%     hold on
%     geobasemap satellite
% end