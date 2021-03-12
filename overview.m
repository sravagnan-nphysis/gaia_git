function Response = overview(ji)
%------------------------------------------------------------------------%
%                   METEOSKI COMPRENSORI ALGORITHM                       %
%------------------------------------------------------------------------%
% La seguente funzione calcola l'overview delle Località
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    T2A = ji;
    T2A.Datanumerica = posixtime(T2A.Time);
    T2A.Time = datetime(T2A.Time,'InputFormat','yyyy-MM-dd HH:mm','Format','yyyy-MM-dd HH:mm');
%     T2A.Idloc = str2double(T2A.Idloc);
    T2A.Colore = categorical(T2A.Colore);
    T2A.Overview = strings(size(T2A,1),1);
%-- Suddivisione delle fascie orarie    
    T2A.Overview(hour(T2A.Time) >=5 & hour(T2A.Time) <=12,:) = "Mattina";
    T2A.Overview(hour(T2A.Time) >=13 & hour(T2A.Time) <=18,:) = "Pomeriggio";
    T2A.Overview(hour(T2A.Time) >=19 & hour(T2A.Time) <=24,:) = "Sera";
    T2A.Overview(hour(T2A.Time) >=0 & hour(T2A.Time) <=4,:) = "Notte";
%-- Eliminazione delle restanti ore
    T2A(T2A.Overview == "",:)=[];
    T2A=table2timetable(T2A);
%-- Per non embeddare proprietà come le seguenti si dovrebbe aggiungere la
%-- struttura a livelli web in Posgres e chiamarla tramite query per associare
%-- idloc ad idcomp.
%     ji.Server.Variable = 'Struttura_Livelli_Web';
%     ji.Server.IP = "52.178.32.64";
%     ji.Server.Port = "3000";
%     ResponsePG = QueryPostgreSQL(jsonencode(ji));
%     idx(:,1) = (1000:1018)';
%     idx(:,2) = [13 37 9 47 73 42 79 60 26 5 16 43 53 17 64 3 8 78 31]';
%     T2A.Comprensorio=sum(idx(:,1)'.*(T2A.Idloc==idx(:,2)'),2);
%     T2A.Comprensorio(T2A.Comprensorio==0)=T2A.Idloc(T2A.Comprensorio==0);
%-- Calcolo per gruppi di tabelle 
    G = groupsummary(T2A,{'Datanumerica','Overview'},'mean',{'Temperatura','Umidita','IntensitaVento','AltezzaNuvole','Precipitazioni','Copertura','Comfort_Assoluto','Comfort_Visivo','Comfort_Termico'});
    G = removevars(G,'GroupCount');
    G1 = groupsummary(T2A,{'Datanumerica','Overview'},'mode',{'CodiceMeteo','SnowFlag'});
    G1 = removevars(G1,{'Datanumerica','Overview','GroupCount'});
    G2 = groupsummary(T2A,{'Datanumerica','Overview'},@(x)CircularMean(x),{'DirezioneVento'});
    G2 = removevars(G2,{'Datanumerica','Overview','GroupCount'});
%-- Concatenazione della Overview
    Overview = [G G1 G2];
    Overview.Datanumerica=datetime(Overview.Datanumerica,'ConvertFrom','epochtime','Format','yyyy-MM-dd');
    Overview.Properties.VariableNames = {'Time','EtichettaGiorno','Temperatura','Umidita','IntensitaVento','AltezzaNuvole','Precipitazioni','Copertura','ComfortAssoluto','ComfortVisivo','ComfortTermico','CodiceMeteo','SnowFlag','DirezioneVento'};
    Overview = movevars(Overview,'CodiceMeteo','Before',4); Overview = movevars(Overview,'DirezioneVento','Before',8);
    Overview = movevars(Overview,'SnowFlag','Before',12); Overview = movevars(Overview,'ComfortAssoluto','Before',13);
    colore = strings(size(Overview,1),1);
    colore(Overview.ComfortAssoluto>=0.6)="Verde"; 
    colore(Overview.ComfortAssoluto>0.35 & Overview.ComfortAssoluto<0.6)="Giallo";
    colore(Overview.ComfortAssoluto<=0.35)="Rosso";
    Overview.Colore=categorical(colore);
%--- Round up dei valori
    clear ji
    ji.numRound = 2;
    ji.Contain = "Comfort";
    ji.Table = Overview;
    Overview = RoundUpTable(ji).Result;
%--- Scrittura della Risposta    
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result  = Overview;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

