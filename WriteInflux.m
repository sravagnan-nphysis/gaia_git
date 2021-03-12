function Response = WriteInflux(ji)
Response.Status  = '';
Response.Error   = '';
Response.Message = '';
Response.Result  = [];
try
    Table2Write = ji.Table2Write;
    if size(ji.Tag,1)<size(ji.Tag,2)
        ji.Tag = ji.Tag';
    end
%--- Setup HTTP Message 
    import matlab.net.*
    import matlab.net.http.*
    r = matlab.net.http.RequestMessage;
    r.Header = matlab.net.http.HeaderField('Content-Type','application/json', 'Accept','application/json', 'Authorization', 'Token ' + ji.Server.Token);
    body = matlab.net.http.MessageBody;
%--- Inizializzo il LineProtocol
    LP = "";
%--- Estraggo la colonna della data secondo l'input: ChTimeRef      
    Time = Table2Write.Data.Time;
%--- Lunghezza tabella        
    m = size(Table2Write.(ji.Data),1);
%--- Inizio a scrivere il Line Protocol di InfluxDB aggiungendo il "measurement" e la ","   
    if strcmp(Table2Write.(ji.Measurement),"")
        LineProtocol = repelem(regexprep(string(Table2Write.osm_id), '\s+', '_'),m,1);
    else
        LineProtocol = repelem(regexprep(string(Table2Write.(ji.Measurement)), '\s+', '_'),m,1);
    end
    LineProtocol = append(LineProtocol,repelem(",",m,1));
%--- Se ci sono Aggiungo i Tag
    if isfield(ji,'Tag') && isempty(ji.Tag)==0
%------- Aggiungo i tag susseguiti da virgole e con lo spazio finale            
        for j = 1:numel(ji.Tag)
            if j == numel(ji.Tag)
                LineProtocol = append(LineProtocol,repelem(string(ji.Tag(j)),m,1),"=",string(Table2Write.(ji.Tag(j)))," ");
            else
                LineProtocol = append(LineProtocol,repelem(string(ji.Tag(j)),m,1),"=",string(Table2Write.(ji.Tag(j))),",");
            end                    
        end
    else
%------ Aggiungo solo lo spazio
       LineProtocol = append(LineProtocol,repelem(" ",m,1));
    end
%--- Elimino le variabili che non mi servono
    Table2Write.(ji.Data) = removevars(Table2Write.(ji.Data),convertStringsToChars([ji.ChTimeRef]));
%--- Aggiungo le variabili        
    for t=1:size(Table2Write.(ji.Data),2)
        if isnumeric(Table2Write.(ji.Data).(t)) && t == size(Table2Write.(ji.Data),2)
           LineProtocol = append(LineProtocol,repelem(string(Table2Write.(ji.Data).Properties.VariableNames{t}),m,1),"=",string(Table2Write.(ji.Data).(t))," "); 
        elseif isnumeric(Table2Write.(ji.Data).(t)) && t ~= size(Table2Write.(ji.Data),2)
           LineProtocol = append(LineProtocol,repelem(string(Table2Write.(ji.Data).Properties.VariableNames{t}),m,1),"=",string(Table2Write.(ji.Data).(t)),","); 
        elseif t==size(Table2Write.(ji.Data),2)
           LineProtocol = append(LineProtocol,repelem(string(Table2Write.(ji.Data).Properties.VariableNames{t}),m,1),"=",'"',string(Table2Write.(ji.Data).(t)),'"'," "); 
        else
           LineProtocol = append(LineProtocol,repelem(string(Table2Write.(ji.Data).Properties.VariableNames{t}),m,1),"=",'"',string(Table2Write.(ji.Data).(t)),'"',","); 
        end
    end
%--- Questa data serve SOLO per ricavare l'offset!!!
    UTCdate = datetime(datetime(Time,'TimeZone','Europe/Rome','Format','uuuu-MM-dd HH:mm Z'));
%--- Il quale viene tolto dalla GIA' ora locale per scrivere gli UTC in Influxdb
    LineProtocol = append(LineProtocol,string(posixtime(datetime(Time)) - seconds(tzoffset(UTCdate))));
%--- Compongo in un'unica stringa      
    LP = vertcat(LP,LineProtocol); 
    LP(1)=[];
    LP = strjoin(LP,'\n');
%--- Invio dei dati    
    body.Payload = LP;
    r.Body = body;
    r.Method = 'POST';
    uri = matlab.net.URI('http://' + string(ji.Server.IP) + ':' + string(ji.Server.Port) + '/api/v2/write?bucket=' + string(ji.Bucket) + '&org=' + string(ji.Server.Org) + '&precision=s');
    resp = send(r,uri);
%--- Scrittura della risposta
    if strcmp(resp.StartLine.ReasonPhrase,"No Content")
        Response.Status  = 'OK';
        Response.Error   = 'False';
        Response.Message = resp.StartLine.ReasonPhrase + ": InfluxDB Succesfully Written in the Bucket: " + string(ji.Bucket) + " for id: " + string(ji.Id) ;
        Response.Result  = [];
    else
        Response.Status  = 'OK';
        Response.Error   = 'False';
        Response.Message = resp.StartLine.ReasonPhrase + ": InfluxDB has problems to write in the Bucket: " + string(ji.Bucket) + " for id: " + string(ji.Id) ;
        Response.Result  = [];
    end
        display(jsonencode(Response))
catch EX
    Response.Status  = 'NOT OK';
    Response.Error   = 'True';
    Response.Message = EX;
    Response.Result  = [];
    display(jsonencode(Response))
end
end