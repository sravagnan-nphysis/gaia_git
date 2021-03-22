function Response = point_ent(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    entita = ji.e;
    AltitudeStructTables = ji.AST;
%--- Calcolo del passo di atitudine        
    Passo = [500 1000 1500 2000 2500 3000 3500];
    [~,PosPasso] = min(abs(Passo-entita.ele),[],2);
    entita.Altitude = Passo(PosPasso)';
%--- Calcolo il riferimento superiore e inferiore di altitudine per la
%--- preparazione all'iterpolazione dei dati
    entita.conf = entita.Altitude >= entita.ele;
    entita.idx_sup(entita.conf == 1) = entita.Altitude(entita.conf == 1);
    entita.idx_inf(entita.conf == 1) = entita.Altitude(entita.conf == 1)-500;
    entita.idx_sup(entita.conf == 0) = entita.Altitude(entita.conf == 0)+500;
    entita.idx_inf(entita.conf == 0) = entita.Altitude(entita.conf == 0);
%--- Unione dei dataframe         
    entita = innerjoin(entita, AltitudeStructTables.Result);
    entita.osm_id = str2double(entita.osm_id);
%--- Interpolazione dei dati meteo per altitudine         
    for i = 1:size(entita,1)
%------- Interpolazione di particolari variabili
%------- ATTENZIONE: HARD CODING!!!!
        for v = [2,3,5,6,7,10,13,14,15]
%----------- nome della variabile
            var_name = entita.Data{i,1}.Properties.VariableNames{v};
            if isnumeric(entita.Data{i,1}.(var_name))
%--------------- Interpolazione pesata per altitudine                    
                filtro_idloc = AltitudeStructTables.Result(AltitudeStructTables.Result.Idloc == entita.Idloc(i),:);
                pos_inf = find(strcmp(filtro_idloc.Altitude,string(entita.idx_inf(i)))==1);
                pos_sup = find(strcmp(filtro_idloc.Altitude,string(entita.idx_sup(i)))==1);
                y1 = filtro_idloc.Data{pos_inf,1}.(var_name);
                y2 = filtro_idloc.Data{pos_sup,1}.(var_name);
                Y = [y1(:) y2(:)].';
                ym = interp1([entita.idx_inf(i) entita.idx_sup(i)], Y, entita.ele(i));
%                     x = entita.Data{i,1}.Time;
%                     figure(v)
%                     plot(x, y1, 'b-', x, y2, 'r-', x, ym, 'k--');
%                     title(var_name)
                entita.Data{i,1}.(var_name) = ym';
            else
%--------------- Se la variabile non deve essere interpolata la mantengo invariata                    
                filtro_idloc = AltitudeStructTables.Result(AltitudeStructTables.Result.Idloc == entita.Idloc(i),:); 
                pos = find(strcmp(filtro_idloc.Altitude,string(entita.Altitude(i)))==1);
                pos_inf = find(strcmp(filtro_idloc.Altitude,string(entita.idx_inf(i)))==1);
                pos_sup = find(strcmp(filtro_idloc.Altitude,string(entita.idx_sup(i)))==1);
                entita.Data{i,1}.(var_name) = filtro_idloc.Data{pos,1}.(var_name);
            end
        end
%------- Ricalcolo del colore dopo l'interpolazione            
        colore = entita.Data{i,1}.Colore;
        colore(entita.Data{i,1}.Comfort_Assoluto >= 0.6) = "Verde";
        colore(entita.Data{i,1}.Comfort_Assoluto > 0.35 & entita.Data{i,1}.Comfort_Assoluto<0.6) = "Giallo";
        colore(entita.Data{i,1}.Comfort_Assoluto <= 0.35)="Rosso";
        entita.Data{i,1}.Colore = colore;
%------- Arrotondamento a 2 cifre        
        ji.numRound = 2;
        ji.Table = entita.Data{i,1};
        entita.Data{i,1} = RoundUpTable(ji).Result;            
    end
%--- Sostituisco i dataframe delle località con quelli delle entitA        
    AltitudeStructTables.Result = entita(:,{'Idloc','osm_id','Data','Overview'});
%--- Aggiungo informazioni aggiuntive        
    for i = 1:size(entita,1)
        AltitudeStructTables.Result.Name{i,1} = table2array(entita(i,{'name'}));
%------- Aggiungo a Meta solo specifiche variabili
        AltitudeStructTables.Result.Meta{i,1} = entita(i,{'lat','lon','Location','Country','State','Continent','ele'});
%------- Aggiungo a Meta tutte le variabili tranne quelle specificate            
%             AltitudeStructTables.Result.Meta{i,1} = entita(i,ismember(entita.Properties.VariableNames,{'Idloc','osm_id','Data','Overview','name'})==0);
        AltitudeStructTables.Result.Altitude{i,1} = AltitudeStructTables.Result.Meta{i,1}.ele;
        AltitudeStructTables.Result.Meta{i,1}.ele = [];
    end
    AltitudeStructTables.Result = movevars(AltitudeStructTables.Result, 'Name', 'Before', 'Idloc');
    AltitudeStructTables.Result = movevars(AltitudeStructTables.Result, 'Altitude', 'Before', 'osm_id');
%--- Scrittura Risposta    
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result  = AltitudeStructTables.Result;
catch
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

