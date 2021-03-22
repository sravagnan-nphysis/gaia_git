function nP_gaia(ji)
% nP_gaia è un'interfaccia di pre elaborazione: a seconda dei meta dati
% presenti in input scarica le informazioni necessarie allo svolgimento dei
% calcoli.
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];

try
    ji = jsondecode(ji);
%--- A seconda della specificazione scarico le superfici di risposta
%--- associate a meteoalpe o a meteoski e le salvo nella struttura di passaggio
%--- "ji".
    if strcmp(ji.Specification,'Meteoski')
        ji.PG = postgres_manager(ji.Specification);
    elseif strcmp(ji.Specification,'Meteoalpe')
        ji.PG = postgres_manager(ji.Specification);
    else
        disp('The Specification must be <Meteoski> or <Meteoalpe> capital sensitive. Please check the spelling');
    end
%--- Scarico la tabella che contiene gli url per le icone meteo e le immagazziono 
%--- nella struttura di passaggio "ji".  
    ji.PG.pg.Server.Variable = "Url_Meteoski";
    ji.PG.pg.Server.IP = "52.178.32.64";
    ji.PG.pg.Server.Port = "3000";
    ji.PG.pg.Var = ["EtichettaMeteo","UrlMeteo"];
    ji.PG.pg.removevars = ["FontMeteoski","ms"];
    ji.PG.pg.url = struct2table(QueryPostgreSQL(jsonencode(ji.PG.pg)).Result);
%--- Immagazzino le info necessarie a raggiungere le nostre VMs.
    if strcmp(ji.VirtualM,"testing")
        ji.VM.ip = "52.232.68.205";
        ji.VM.token = "EQCDNRToULeQSrmiJvoCm_L0eBiSaGxHWaWCzfcE-v2XPUHP4XYzZp4aQDgrt3SkPvrpJVOmKWQMCHTkb0O-Jw==";
        ji.VM.port = "8086";
        ji.VM.org = "nphysis";
    elseif strcmp(ji.VirtualM,"deployment")
        ji.VM.ip = "52.178.32.64";
        ji.VM.port = "9999";
        ji.VM.token = "d4rDqpU8-68Cdo--T6tiffcA7lfwYof2oG5_5hmioupRSf3XMR1ECs7jWbYgooHgun4pp8x_LgwHC3F39COB_A==";
        ji.VM.org = "meteoski";
    end
%--- A seconda del tipo di algoritmo usato (localita o entita) si dividono i percorsi 
    if strcmp(ji.Algorithm,"localita")
        nP_localita(ji);
    elseif strcmp(ji.Algorithm,"entita")
%------- Check dell'oggetto (point o line) dell'algoritmo entita        
        if  strcmp(ji.Obj,"point")
            en.Server.Variable = ji.FileName;
            en.Server.IP = "52.232.68.205";
            en.Server.Port = "3000";
            en.Resp = QueryPostgreSQL(jsonencode(en));
            ji.entita = struct2table(en.Resp.Result);
            ji.entita.ele = str2double(ji.entita.ele);
            ji.entita.osm_id = string(cellfun(@num2str, ji.entita.osm_id, 'un', 0));
            ji.entita.osm_id = string(ji.entita.osm_id);
            ji.entita.name = string(cellfun(@num2str, ji.entita.name, 'un', 0));
        elseif strcmp(ji.Obj,"line")
            en.Server.Variable = ji.FileName;
            en.Server.IP = "52.232.68.205";
            en.Server.Port = "3000";
            en.Resp = QueryPostgreSQL(jsonencode(en));
            en.Resp.Result = struct2table(en.Resp.Result);
            en.Resp.Result.osm_id = categorical(en.Resp.Result.osm_id);
            for j = 1:size(en.Resp.Result,1)
                en.Resp.Result.geom(j,1).coordinates = array2table(en.Resp.Result.geom(j,1).coordinates,'VariableNames',{'lon','lat','ele'});
                en.Resp.Result.geom(j,1).coordinates.ele = smoothdata(en.Resp.Result.geom(j,1).coordinates.ele,'rloess',8);
            end
%             ji.entita = downsample(en.Resp.Result).Result;
            ji.entita = en.Resp.Result;
        else
            disp('The Algorithm must be <entita> or <localita> capital sensitive. Please check the spelling');
        end
        nP_entita(ji);
    end
  
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    disp(jsonencode(Response))
end

end