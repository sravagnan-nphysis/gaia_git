%------------------------------------------------------------------------%
%                               GAIA SCRIPT                              %
%------------------------------------------------------------------------%
% Il seguente script simula l'ambiente esterno a Matlab che chiama gli
% algoritmi di elaborazione di gaia
%------------------------------------------------------------------------%

% Inizializzazione:
clear
clc
tic
% Creazione della ji per Query_LastDate.
ji.Server.UrlLastdate = 'https://model.3bmeteo.com/104/MAPPEWEB/WRF/CTL1/lastdate_meteomedsnow.txt';
% La funzione QueryLastDate recupera la data di ultimo aggiornamento del file dei dati grezzi di 3B.
Response = QueryLastDate(jsonencode(ji));
% Controllo sullo stato della chiamata
if strcmp(Response.Status,'OK')
   clear ji
%-- Creazione della struttura di input per il calcolo dell'algoritmo.
   ji.id_loc_start = 83;
   ji.id_loc_end = 84;
%    ji.id_loc_step = 2;
   ji.Num_days = 10;
%-- Creazione della struttura di specificazione dell'algoritmo   
   ji.Specification = "Meteoski"; % "Meteoski" o "Meteoalpe"
   ji.Algorithm = "entita"; % "localita" o "entita"
   ji.FileName = "paths_grignone";
   ji.Obj = "line"; % "point" o "line"
   ji.VirtualM = "testing"; % "testing" o "deployment"
%-- Path per Blob
   ji.pathL = "test/localita.json";
   ji.pathEP = "test/entita_points.json";
   ji.pathEL = "test/entita_lines.json"; 
%-- Calcolo
   ji.date_start = datestr(Response.Result.oraelaborazione,'yyyy-mm-dd HH:MM');
%-- Inizio Algoritmo   
   nP_gaia(jsonencode(ji))
else
   display(jsonencode(Response))
end
toc   


