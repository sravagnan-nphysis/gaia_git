function Response = SR2ent(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    Variabili = ji.Variabili;
    PG = ji.PG;
    WDF = ji.Table2Analyze;
    osm_id = unique(string(WDF.osm_id));
%--- Verifica dell'algoritmo in uso e dello stato della SnowFlag
    if strcmp(ji.Specification,"Meteoski")
        if ji.SnowFlag == 0
%---------- Cancellazione delle variabili sovrabbondanti
           Variabili(Variabili.Var1=="codici_meteo" | Variabili.Var1=="anagrafica_comprensori" ...
           | Variabili.Var1=="intensitavento_precipitazionineve" | Variabili.Var1=="esposizionepista_direzionevento" | Variabili.Var1=="esposizionepista_esposizionesole" ...
           | Variabili.Var1=="copertura_precipitazionineve" | Variabili.Var1=="mappa_variabili",:)=[];
           Prec = "precipitazionipioggia";
        elseif ji.SnowFlag == 1
%------ Se ci sono SnowFlag = 1 ripeto il calcolo con le superfici di risposta corrispondenti            
           Variabili=array2table(string(fields(PG.Result)));
           Variabili(Variabili.Var1=="codici_meteo" | Variabili.Var1=="anagrafica_comprensori" ...
           | Variabili.Var1=="intensitavento_precipitazionipioggia" | Variabili.Var1=="esposizionepista_direzionevento" | Variabili.Var1=="esposizionepista_esposizionesole" ...
           | Variabili.Var1=="copertura_precipitazionipioggia" | Variabili.Var1=="mappa_variabili",:)=[];
           Prec = "precipitazionineve";
        end
    elseif strcmp(ji.Specification,"Meteoalpe")
       if ji.SnowFlag == 0    
            Variabili(Variabili.Var1=="codici_meteo" | Variabili.Var1=="anagrafica_comprensori" ...
               | Variabili.Var1=="intensitavento_precipitazionineve" | Variabili.Var1=="esposizionepista_direzionevento" | Variabili.Var1=="esposizionepista_esposizionesole" ...
               | Variabili.Var1=="copertura_precipitazionineve" | Variabili.Var1=="mappavariabili_meteoalpe",:)=[];
           PG.Result.('mappa_variabili') = PG.Result.('mappavariabili_meteoalpe');
           PG.Result = rmfield(PG.Result,'mappavariabili_meteoalpe');
           Prec = "precipitazionipioggia";
       elseif ji.SnowFlag == 1
            Variabili(Variabili.Var1=="codici_meteo" | Variabili.Var1=="anagrafica_comprensori" ...
               | Variabili.Var1=="intensitavento_precipitazionipioggia" | Variabili.Var1=="esposizionepista_direzionevento" | Variabili.Var1=="esposizionepista_esposizionesole"...
               | Variabili.Var1=="copertura_precipitazionipioggia" | Variabili.Var1=="mappavariabili_meteoalpe",:)=[];
           PG.Result.('mappa_variabili') = PG.Result.('mappavariabili_meteoalpe');
           PG.Result = rmfield(PG.Result,'mappavariabili_meteoalpe');
           Prec = "precipitazionineve";           
       end
    end
%--- Inizio Associazione
    for v=1:size(Variabili,1)
       NomiVar=strsplit(Variabili.Var1(v),'_');
       idVar1=find(strcmpi(PG.Result.mappa_variabili.Properties.VariableNames,NomiVar(1))==1);
       idVar2=find(strcmpi(PG.Result.mappa_variabili.Properties.VariableNames,NomiVar(2))==1);
       if contains(Prec,NomiVar(1))
          NomiVar(1)='precipitazioni';
       elseif contains(Prec,NomiVar(2))
          NomiVar(2)='precipitazioni';
       end
%------ Identificazione delle posizioni per estrarre il valore corrispondente dalle Superfici di Risposta Fuzzy           
       idCod1=find(strcmpi(WDF.Properties.VariableNames,NomiVar(1))==1);
       idCod2=find(strcmpi(WDF.Properties.VariableNames,NomiVar(2))==1);
       [~,closestIndexX] = min(abs(PG.Result.mappa_variabili.(idVar1)-WDF.(idCod1)'),[],1);
       [~,closestIndexY] = min(abs(PG.Result.mappa_variabili.(idVar2)-WDF.(idCod2)'),[],1);
       ComfortPunto.(Variabili.Var1(v)) = diag(table2array(PG.Result.(Variabili.Var1(v))(closestIndexY,closestIndexX)));
%        ComfortPunto.(Variabili.Var1(v)) = diag(table2array(PG.Result.(Variabili.Var1(v))(closestIndexY(1:size(WDF,1)),closestIndexX(1:size(WDF,1)))));
       ComfortAssoluto.(Variabili.Var1(v))=(ComfortPunto.(Variabili.Var1(v))-PG.Minimi.(Variabili.Var1(v)))/(PG.Massimi.(Variabili.Var1(v))-PG.Minimi.(Variabili.Var1(v)));
    end
    Comfort=struct2array(ComfortAssoluto);
    WDF.Comfort_Assoluto = mean(Comfort,2);

    idx = contains(Variabili.Var1,'precipitazioni');
    Variabili.Var1(idx)=["copertura_precipitazioni";"intensitavento_precipitazioni"];

    Comfort = array2table(Comfort);
    Comfort.Properties.VariableNames='Comfort_'+ Variabili.Var1;
    Comfort.Comfort_Assoluto = WDF.Comfort_Assoluto;
%--- Calcolo degli indici di Comfort (Visivo, Termico) a  partire dagli indici di Comfort estrapolati dalle diverse superfici di risposta               
    WDF.Comfort_Visivo = mean([Comfort.Comfort_altezzanuvole_copertura Comfort.Comfort_copertura_precipitazioni Comfort.Comfort_intensitavento_precipitazioni],2);
    WDF.Comfort_Termico = mean([Comfort.Comfort_temperatura_intensitavento Comfort.Comfort_temperatura_umidita],2);
%--- Assegnazione del colore a partire dal punteggio totalizzato
    colore = strings(size(WDF,1),1);
    colore(WDF.Comfort_Assoluto >= 0.6) = "Verde";
    colore(WDF.Comfort_Assoluto > 0.35 & WDF.Comfort_Assoluto<0.6) = "Giallo";
    colore(WDF.Comfort_Assoluto <= 0.35)="Rosso";
    WDF.Colore = colore;
%---  Conversione Nodi --> Km/h
    WDF.IntensitaVento = 1.852 * WDF.IntensitaVento;    
%--- Scrittura della risposta     
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result  = WDF;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end
% A = PG.Result.(Variabili.Var1(v));
% x=closestIndexX(1:size(WDF,1)); y=closestIndexY(1:size(WDF,1));
% WDF.osm_id=str2double(string(WDF.osm_id));
% mm=str2double(unique(string(WDF.osm_id)));
% m=numel(mm);
% i=1;
% step=1000;
% mds=0;
% while 1     
%     FWDF = WDF(1:step:size(WDF,1),:);
%     mds = numel(unique(FWDF.osm_id));
%     if mds-m==0
%         break
%     else
%         i=i+1;
%         step=step-10;
%     end
% end
% B=WDF(1:step:size(WDF,1),:);
% x=closestIndexX(1:size(B,1)); y=closestIndexY(1:size(B,1));
% tic
% d = diag(table2array(A(y,x)));
% toc
% s = table2array(PG.Result.(Variabili.Var1(v)));
% surf(s)
% ge

