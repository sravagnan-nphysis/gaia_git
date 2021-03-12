function Meteoski_Wrapping()
try
    Lista_Run = struct2table(dir("Run_Meteoski_Comprensori_*.json"));
    for i = 1:size(Lista_Run.name,1)
        if size(Lista_Run.name,1) == 1
            fname = Lista_Run.name(i,:);
            Run{i,1} = jsondecode(fileread(fname));
        else
            fname = Lista_Run.name{i};
            Run{i,1} = jsondecode(fileread(fname)).Result;
        end
    end
%--- Concatenazione
    Cat_Run = vertcat(Run{:});
    dati_comprensori.AltitudineMax  = struct2table(vertcat(Cat_Run.AltitudineMax));
    dati_comprensori.AltitudineMean = struct2table(vertcat(Cat_Run.AltitudineMean));
    dati_comprensori.AltitudineMin  = struct2table(vertcat(Cat_Run.AltitudineMin));
    dati_comprensori.Overview       = struct2table(vertcat(Cat_Run.Overview));
    dati_comprensori = jsonencode(dati_comprensori);
%--- Scritture del file json di output       
    fid      = fopen('dati_comprensori.json', 'w');
    if fid == -1, error('Cannot create JSON file'); end
    fwrite(fid, dati_comprensori, 'char');
    fclose(fid);
%--- Caricamento tramite ftp
    ftpobj = ftp('185.81.4.186','stefano@meteoski.it','import1455,');
    mget(ftpobj,'dati_comprensori.json');
%--- Eliminiìazione dei file json
    delete('Run_Meteoski_Comprensori_*.json')
%--- Scrittura messaggio di risposta   
    Meteoski_Wrapping.Message = "Done: Files have been wrapped and loaded through ftp succesfully";
    display(jsonencode(Meteoski_Wrapping))
catch EX
    Meteoski_Wrapping.Error   = 'true';
    Meteoski_Wrapping.Message = EX;
    display(jsonencode(Meteoski_Wrapping))    
end
end

% fname = 'queryOverPass.json';
% val = jsondecode(fileread(fname));
