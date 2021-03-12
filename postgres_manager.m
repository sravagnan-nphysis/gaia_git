function Response = postgres_manager(season)

% La seguente funzione gestisce le chiamate verso PostgreSQL delle
% variabili necessarie allo svolgimento dell'algoritmo.
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    if strcmp(season,'Meteoski')
        PG_Variable={'altezzanuvole_copertura','anagrafica_comprensori',...
                 'codici_meteo','copertura_precipitazionineve',...
                 'esposizionepista_direzionevento','copertura_precipitazionipioggia',...
                 'esposizionepista_esposizionesole','intensistavento_precipitazionineve',...
                 'intensitavento_precipitazionipioggia','mappa_variabili',...
                 'temperatura_intensitavento','temperatura_umidita'};
    elseif strcmp(season,'Meteoalpe')
        PG_Variable={'altezzanuvole_copertura','anagrafica_comprensori',...
                 'codici_meteo','copertura_precipitazionineve',...
                 'esposizionepista_direzionevento','copertura_precipitazionipioggia',...
                 'esposizionepista_esposizionesole','intensistavento_precipitazionineve',...
                 'intensitavento_precipitazionipioggia','mappavariabili_meteoalpe',...
                 'temperatura_intensitavento_meteoalpe','temperatura_umidita_meteoalpe'};
    end
 %--- Loop esterno di chiamate a PostgreSQL
    for i=1:length(PG_Variable)
        clear ji
        ji.Server.Variable = PG_Variable(i);
        ji.Server.IP = "52.178.32.64";
        ji.Server.Port = "3000";
        ResponsePG = QueryPostgreSQL(jsonencode(ji));
        Response.Result.(PG_Variable{i}) = struct2table(ResponsePG.Result);
    end
%--- Adattamento dei dati     
    Response.Result.anagrafica_comprensori.Location = string(Response.Result.anagrafica_comprensori.Location);
    Response.Result.anagrafica_comprensori.Location = strrep(Response.Result.anagrafica_comprensori.Location, ' ', '');
    Response.Result.anagrafica_comprensori.Idloc = categorical(Response.Result.anagrafica_comprensori.Idloc);
    Response.Result.anagrafica_comprensori.Location = strrep(Response.Result.anagrafica_comprensori.Location, 'è', 'e');
    Response.Result.('intensitavento_precipitazionineve') = Response.Result.('intensistavento_precipitazionineve');
    Response.Result = rmfield(Response.Result,{'intensistavento_precipitazionineve'});
    if strcmp(season,'Meteoalpe')
        Response.Result.('temperatura_intensitavento')=Response.Result.('temperatura_intensitavento_meteoalpe');
        Response.Result=rmfield(Response.Result,{'temperatura_intensitavento_meteoalpe'});
        Response.Result.('temperatura_umidita')=Response.Result.('temperatura_umidita_meteoalpe');
        Response.Result=rmfield(Response.Result,{'temperatura_umidita_meteoalpe'});
    elseif strcmp(season,'Meteoski')
    else
        display("Please write the rigth Season")
    end
%--- Distinzione delle superfici di risposta
    Superfici = array2table(string(fields(Response.Result)));
    Superfici(Superfici.Var1=="codici_meteo" | Superfici.Var1=="anagrafica_comprensori" ...
                       | Superfici.Var1=="mappa_variabili",:)=[];
    Response.Superfici = Superfici;
%--- Normalizzazione delle superfici di risposta               
    for i = 1:size(Superfici,1)
        Massimi.(Superfici{i,1}) = max(table2array(Response.Result.(Superfici{i,1})),[],'all');
        Minimi.(Superfici{i,1}) = min(table2array(Response.Result.(Superfici{i,1})),[],'all');
        Medi.(Superfici{i,1}) = mean2(table2array(Response.Result.(Superfici{i,1})));
    end
%--- Scrittura della risposta
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Massimi = struct2table(Massimi);
    Response.Minimi = struct2table(Minimi);
    Response.Medi = struct2table(Medi);
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

