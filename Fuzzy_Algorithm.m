function Response = Fuzzy_Algorithm(ji)
%------------------------------------------------------------------------%
%                   METEOSKI COMPRENSORI ALGORITHM                       %
%------------------------------------------------------------------------%
% La seguente funzione calcola l'indice di Comfort a partire dai dati 
% grezzi 
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    PG = ji.PG;
    T2A = ji.T2A;
%--- Creazione di un array contenente la lista delle variabili        
    Variabili = array2table(string(fields(PG.Result)));
    Resp = cell(2,1);
    for sn = 0:1         
        ji.SnowFlag = sn;
        ji.Variabili = Variabili;
%------- Suddivisione per SnowFlag (0 or 1)
        ji.Table2Analyze = T2A(T2A.SnowFlag == sn,:);
        if isempty(ji.Table2Analyze)
           Resp{sn+1,1} = [];
        else
           Resp{sn+1,1} = SR2loc(ji).Result;
        end
    end
    DB_Out = vertcat(Resp{:,1});
    DB_Out = sortrows(DB_Out,1,'ascend');
%--- Round up dei valori
    ji.numRound = 2;
    ji.Contain = "Comfort";
    ji.Table = DB_Out;
    DB_Out = RoundUpTable(ji).Result;
    
%-- Scrittura della Risposta
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result = DB_Out;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

