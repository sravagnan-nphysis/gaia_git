function Response = line_ent(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    entita = ji.e;
    AltitudeStructTables = ji.AST;
    Passo = [500 1000 1500 2000 2500 3000 3500];
%--- per ogni percorso
    for i = 1:size(entita,1)
        % trovo altitudine di riferimento per i punti che compongono il percorso 
        [~,PosPasso] = min(abs(Passo-entita.geom(i,1).coordinates.ele),[],2);
        entita.geom(i,1).coordinates.Altitude = Passo(PosPasso)';
        entita.geom(i,1).coordinates.conf = entita.geom(i,1).coordinates.Altitude >= entita.geom(i,1).coordinates.ele;
        entita.geom(i,1).coordinates.idx_sup(entita.geom(i,1).coordinates.conf == 1) = entita.geom(i,1).coordinates.Altitude(entita.geom(i,1).coordinates.conf == 1);
        entita.geom(i,1).coordinates.idx_inf(entita.geom(i,1).coordinates.conf == 1) = entita.geom(i,1).coordinates.Altitude(entita.geom(i,1).coordinates.conf == 1)-500;
        entita.geom(i,1).coordinates.idx_sup(entita.geom(i,1).coordinates.conf == 0) = entita.geom(i,1).coordinates.Altitude(entita.geom(i,1).coordinates.conf == 0)+500;
        entita.geom(i,1).coordinates.idx_inf(entita.geom(i,1).coordinates.conf == 0) = entita.geom(i,1).coordinates.Altitude(entita.geom(i,1).coordinates.conf == 0);
        % filtro per idloc prima di fare il join
        filtro_idloc = AltitudeStructTables.Result(AltitudeStructTables.Result.Idloc == entita.idloc(i),:);
        %join
        entita.geom(i,1).coordinates = innerjoin(entita.geom(i,1).coordinates, filtro_idloc);
        % interpolazione
        for j = 1:size(entita.geom(i,1).coordinates,1)
            for v = [2,3,5,6,7,10,13,14,15]
%--------------- nome della variabile
                var_name = entita.geom(i,1).coordinates.Data{j,1}.Properties.VariableNames{v};
%--------------- Interpolazione pesata per altitudine
                if entita.geom(i,1).coordinates.idx_inf(j)==0
                   entita.geom(i,1).coordinates.Data{j,1}.('Idpnt') = repelem(j,size(entita.geom(i,1).coordinates.Data{j,1},1),1); 
                    continue
                end
                pos_inf = find(strcmp(filtro_idloc.Altitude,string(entita.geom(i,1).coordinates.idx_inf(j)))==1);
                pos_sup = find(strcmp(filtro_idloc.Altitude,string(entita.geom(i,1).coordinates.idx_sup(j)))==1);
                y1 = filtro_idloc.Data{pos_inf,1}.(var_name);
                y2 = filtro_idloc.Data{pos_sup,1}.(var_name);
                Y = [y1(:) y2(:)].';
                ym = interp1([entita.geom(i,1).coordinates.idx_inf(j) entita.geom(i,1).coordinates.idx_sup(j)], Y, entita.geom(i,1).coordinates.ele(j));
                x = entita.geom(i,1).coordinates.Data{j,1}.Time;
                entita.geom(i,1).coordinates.Data{j,1}.('Idpnt') = repelem(j,size(entita.geom(i,1).coordinates.Data{j,1},1),1);
%                     figure(v)
%                     plot(x, y1, 'b-', x, y2, 'r-', x, ym, 'k--');
%                     title(var_name)
                entita.geom(i,1).coordinates.Data{j,1}.(var_name) = ym';
            end
%----------- Ricalcolo del colore dopo l'interpolazione            
            colore = entita.geom(i,1).coordinates.Data{j,1}.Colore;
            colore(entita.geom(i,1).coordinates.Data{j,1}.Comfort_Assoluto >= 0.6) = "Verde";
            colore(entita.geom(i,1).coordinates.Data{j,1}.Comfort_Assoluto > 0.35 & entita.geom(i,1).coordinates.Data{j,1}.Comfort_Assoluto<0.6) = "Giallo";
            colore(entita.geom(i,1).coordinates.Data{j,1}.Comfort_Assoluto <= 0.35)="Rosso";
            entita.geom(i,1).coordinates.Data{j,1}.Colore = colore;
%----------- Arrotondamento a 2 cifre        
            ji.numRound = 2;
            ji.Table = entita.geom(i,1).coordinates.Data{j,1};
            entita.geom(i,1).coordinates.Data{j,1} = RoundUpTable(ji).Result;
        end
        entita.Data{i,1} = vertcat(entita.geom(i,1).coordinates.Data{:,1});
        entita.geom(i,1).coordinates = removevars(entita.geom(i,1).coordinates,...
            {'conf','Altitude','Idloc','idx_sup','idx_inf','Data'});
        entita.Meta{i,1} = entita(i,{'sac_scale','surface','ref','location','country','state','continent'});
        entita.Geom{i,1} = entita.geom(i,1).coordinates;
    end
    entita = removevars(entita,...
            {'id','geom','full_id','osm_type','idloc_comp','highway','trail_visi','sac_scale',...
            'surface','ref','location','country','state','continent','skiResort'});
    entita = movevars(entita, 'Geom', 'Before', 'Data');   
%     mymap = [1 0 0
%              1 1 0
%             0 1 0];
%     colormap(mymap)
%     sz = 100;
%     figure(1)
%     set(gcf,'color','w');
%     for j = 1:size(entita.geom(i,1).coordinates,1)          
%         A=vertcat(entita.geom(j,1).coordinates.Data{:,1});      
% %             subplot(2,2,1)
%         var = "Comfort_Assoluto";
%         C = A.(var)(A.Time.Hour==9 & A.Time.Day==15,:);
%         geoscatter(entita.geom(j,1).coordinates.lat,entita.geom(j,1).coordinates.lon,sz,C,'.');
%         title(var)
%         colorbar
%         geobasemap satellite
%     end
%--- Scrittura Risposta
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result  = entita;
catch
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end



