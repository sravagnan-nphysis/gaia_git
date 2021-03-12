function Response = RoundUpTable(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    n=1;
    if isfield(ji,'Contain')
       IdConvers = find(contains(ji.Table.Properties.VariableNames,ji.Contain)==1);
        while n < size(ji.Table,2)
            if isnumeric(ji.Table.(ji.Table.Properties.VariableNames{n})) && all(n ~= IdConvers)
               ji.Table.(ji.Table.Properties.VariableNames{n}) = round(ji.Table.(ji.Table.Properties.VariableNames{n}),ji.numRound);
            elseif isnumeric(ji.Table.(ji.Table.Properties.VariableNames{n})) && any(n == IdConvers)
               ji.Table.(ji.Table.Properties.VariableNames{n}) = round(ji.Table.(ji.Table.Properties.VariableNames{n}),ji.numRound);
            end
            n = n+1;
        end
    else
        while n < size(ji.Table,2)
            if isnumeric(ji.Table.(ji.Table.Properties.VariableNames{n}))
               ji.Table.(ji.Table.Properties.VariableNames{n}) = round(ji.Table.(ji.Table.Properties.VariableNames{n}),ji.numRound);
            end
            n = n+1;
        end   
    end
%--- Scrittura della Risposta
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful';
    Response.Result = ji.Table;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

