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
        j=j+1;
    end
    entita = ji.entita;
    AltitudeStructTables.Result = struct2table(AltitudeStructTables.Result);
    if strcmp(ji.Obj,'point')
        Passo = [500 1000 1500 2000 2500 3000 3500];
        [~,PosPasso] = min(abs(Passo-str2double(entita.ele)),[],2);
        entita.Altitude = string(Passo(PosPasso)');
        entita = innerjoin(entita, AltitudeStructTables.Result);
        entita.osm_id = str2double(entita.osm_id);
        AltitudeStructTables.Result = entita(:,{'Idloc','osm_id','Data','Overview'});
        for i = 1:size(entita,1)
            AltitudeStructTables.Result.Name{i,1} = table2array(entita(i,{'name'}));
            AltitudeStructTables.Result.Meta{i,1} = entita(1,ismember(entita.Properties.VariableNames,{'Idloc','osm_id','Data','Overview','name'})==0);
            AltitudeStructTables.Result.Meta{i,1}.ele = str2double(AltitudeStructTables.Result.Meta{i,1}.ele);
            AltitudeStructTables.Result.Altitude{i,1} = AltitudeStructTables.Result.Meta{i,1}.ele;
        end
        AltitudeStructTables.Result = movevars(AltitudeStructTables.Result, 'Name', 'Before', 'Idloc');
        AltitudeStructTables.Result = movevars(AltitudeStructTables.Result, 'Altitude', 'Before', 'osm_id');
    elseif strcmp(ji.Obj,'line')
        Passo = [500 1000 1500 2000 2500 3000 3500];
        [~,PosPasso] = min(abs(Passo-entita.geom(32,1).coordinates(:,3)),[],2);
        
        for i = 1:size(entita,1)
            Entita.Idloc{i,1} = table2array(entita(i,{'idloc'}));
            Entita.Name{i,1} = table2array(entita(i,{'name'}));
            Entita.osm_id{i,1} = table2array(entita(i,{'osm_id'}));
            Entita.geom{i,1} = entita.geom(i,1).coordinates;
%             Entita.Passo{i,1} = unique(Passo(PosPasso)');
%             Entita.Meta{i,1} = Meta{i,1} = entita(1,ismember(entita.Properties.VariableNames,{'Idloc','osm_id','Data','Overview','name'})==0);
%             AltitudeStructTables.Result.Altitude{i,1} = AltitudeStructTables.Result.Meta{i,1}.ele;
        end
        
        
        entita = innerjoin(entita, AltitudeStructTables.Result);
        geoscatter(entita.geom(32,1).coordinates(:,2),entita.geom(32,1).coordinates(:,1),[],entita.geom(32,1).coordinates(:,3),'.')
        geobasemap satellite
        colorbar
        caxis([min(entita.geom(32,1).coordinates(:,3)), max(entita.geom(32,1).coordinates(:,3))])

    end
    AltitudeStructTables.Result = table2struct(AltitudeStructTables.Result);
    
%--- Scrittura del file di output nel Blob.
    ji.VMpath = "samtsk00.blob.core.windows.net";
    ji.Token = "?sv=2019-12-12&ss=b&srt=sco&sp=rwdlacx&se=9999-09-09T14:46:23Z&st=2020-09-09T06:46:23Z&spr=https&sig=bb47rO0g38Hk6uiTsBhVDe218ETWqTeEIxgWdZb2c38%3D&comp=appendblock";
    ji.blobPath = string(ji.pathEP);
    for i = 1:numel(AltitudeStructTables.Result)
        ji.Id = string(AltitudeStructTables.Result(i).Idloc) + "_" + string(AltitudeStructTables.Result(i).osm_id);
        if i == 1
           CreateJsonToBlob(string(ji.pathEP));
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
        ji.Bucket = "entita_points";
        WriteInflux(ji);
        ji.Data = "Overview";
        ji.Bucket = "entita_points_overview";
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