function Response = AltitudeStruct(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    numstr = regexp(string(ji.Table2Write.Result.Properties.VariableNames'),'\d*','match');
    for i=1:numel(numstr)
        if isempty(numstr{i,1})
           numstr{i,1} = "";
        end
    end
    Passo = unique(string(numstr));
    Passo(Passo=="")=[];
    idloc = sort(unique(ji.Table2Write.Result.idloc),'ascend');
    p = 1;
    for i=idloc(1):idloc(end)
        for j = 1:numel(Passo)
            id_data = ji.Table2Write.Result(ji.Table2Write.Result.idloc == i,:);
            id_data = sortrows(id_data,1,'ascend');
            T2W(p).Idloc = i;
            T2W(p).Altitude = Passo(j);
            T2W(p).Data = [id_data(:,1) id_data(:,matches(string(numstr),Passo(j))==1) id_data(:,52)];
            T2W(p).Data.Properties.VariableNames = {'Time','Temperatura','Umidita','DirezioneVento','IntensitaVento','VentoRaffica','Precipitazioni','Copertura','CodiceMeteo','SnowFlag','AltezzaNuvole'};
            T2W(p).Data.VentoRaffica = [];
            p = p+1;
        end
    end
%--- Scrittura della risposta 
    Response.Status  = 'OK';
    Response.Error   = 'False';
    Response.Message = 'Succesful' ;
    Response.Result  = T2W;
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end

