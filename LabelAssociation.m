function Response = LabelAssociation(ji)
Response.Status = '';
Response.Error = '';
Response.Message = '';
Response.Result = [];
try
%--- Dataframe degli url    
    Input = ji.PG.pg.url;
%--- Dataframe da associare    
    Tables = ji.PG.pg.Tables;
%--- Fields
    i=1;
    while i <= numel(ji.PG.pg.Var)
       Input.(ji.PG.pg.Var(i)) = string(Input.(ji.PG.pg.Var(i)));
       i = i+1;
    end

    Inner = innerjoin(Tables,Input);
    if isfield(ji.PG.pg,'removevars')
       Inner = removevars(Inner,cellstr(ji.PG.pg.removevars));
    end
    Inner = sortrows(Inner,1,'ascend');
    
    Response.Result = Inner;
    Response.Status = 'OK';
    Response.Error = 'False';
    Response.Message = 'Succesful';
catch EX
    Response.Status = 'NOT OK';
    Response.Error = 'True';
    Response.Message = EX;
    Response.Result = [];
end
end

