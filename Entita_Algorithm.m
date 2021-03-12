function Response = Entita_Algorithm(ji)
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
           Resp{sn+1,1} = ValuesFromSurfResp(ji).Result;
        end
    end
    DB_Out.(ji.RefName) = vertcat(Resp{:,1});
%--- Round up dei valori
    Fi = fields(DB_Out);
    ji.numRound = 2;
    ji.Contain = "Comfort";
    for i =1:numel(Fi)
        ji.Table = DB_Out.(Fi{i,1});
        DB_Out.(Fi{i,1}) = RoundUpTable(ji).Result;
    end
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

