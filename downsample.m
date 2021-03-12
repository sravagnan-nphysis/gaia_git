function Response = downsample(ji)
Response.Status = '';
Response.Error = '';
Response.Message = '';
Response.Result = [];
try
    down_rate = 0.75; % 75%
    osm_id = unique(ji.osm_id);
    num_ent = numel(osm_id);
    down_ent = [];
    for i=1:num_ent
       ds = ji(ji.osm_id==osm_id(i),:);
       m = size(ds,1);
       down_ent = vertcat(down_ent,ds(1:m-round(m*down_rate):m,:));
    end
    Response.Status = 'OK';
    Response.Error = 'False';
    Response.Message = 'Succesful';
    Response.Result = down_ent;
catch EX
    Response.Status = 'NOT OK';
    Response.Error = 'True';
    Response.Message = EX;
    Response.Result = [];
end    
end

