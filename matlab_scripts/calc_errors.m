%Takes in the catalogue generated by IR_cataloguer.m and calculates the
%absolute errors between the ground truth IRs found in folder 'test_B'. 

clear all
filename = 'catalogue.txt';
data = readtable(filename,'Delimiter',',');
data.Properties.VariableNames = {'SourceFolder','Index1','Index2','IO', 'RT' ,'DRR' ,'CTE', 'CFS1','CFS2','CFS3','CFS4','CFS5','CFS6','EDT'};
dheight = height(data);
dwidth = width(data);
truth_table = data(ismember(data.SourceFolder,'test_B'),:);
listing = dir;
n_items = length(listing);
compare_tables = {};

for i = 1:n_items
    if listing(i).isdir && (length(listing(i).name) > 3) && ~strcmp(listing(i).name,'test_B')
        compare_tables = vertcat(compare_tables, {listing(i).name, {data(ismember(data.SourceFolder,listing(i).name),:)}});
    end
end
compare_tables = compare_tables';
compare_tables = struct(compare_tables{:});
folder_names = fields(compare_tables);
error_struct = {};
for k = 1:length(folder_names)
    temp_table = getfield(compare_tables,folder_names{k});
    errors = [];
    for i = 1:height(temp_table)
        if(~isnan(temp_table.RT(i)))
            for j = 1:height(truth_table)
                if(~isnan(truth_table.RT(j))&& ~isinf(truth_table.RT(j)))
                    if(temp_table.Index1(i) == truth_table.Index1(j) && temp_table.Index2(i) == truth_table.Index2(j))
                        % Calculating absolute errors for this specific IR
                        rt_er = abs(temp_table.RT(i) - truth_table.RT(j));
                        drr_er = abs(temp_table.DRR(i) - truth_table.DRR(j));
                        cte_er = abs(temp_table.CTE(i) - truth_table.CTE(j));
                        edt_er = abs(temp_table.EDT(i) - truth_table.EDT(j));
                        errors = [errors; rt_er, drr_er, cte_er, edt_er];
                    end
                end
            end
        end
    end
    %Calculating the mean, max, min, and median for all of the errors
    mae = mean(errors);
    max_e = max(errors);
    min_e = min(errors);
    median_e = median(errors);
    error_struct{end+1} = {};
    error_struct{end}.name = temp_table.SourceFolder{1};
    error_struct{end}.errors = errors;
    error_struct{end}.mae = mae;
    error_struct{end}.max = max_e;
    error_struct{end}.min = min_e;
    error_struct{end}.median = median_e;
end
%%
% Writing all the errors into a csv file along with the source folder that
% indicates the model.
filename = 'errors.txt';
mean_str = {'RT-mean' ,'DRR-mean' ,'CTE-mean', 'EDT-mean'};
mean_p_str = {'RTp-mean' ,'DRRp-mean' ,'CTEp-mean', 'EDTp-mean'};

max_str = {'RT-max' ,'DRR-max' ,'CTE-max', 'EDT-max'};
max_p_str = {'RTp-max' ,'DRRp-max' ,'CTEp-max', 'EDTp-max'};

min_str = {'RT-min' ,'DRR-min' ,'CTE-min', 'EDT-min'};
min_p_str = {'RTp-min' ,'DRRp-min' ,'CTEp-min', 'EDTp-min'};

median_str = {'RT-median' ,'DRR-median' ,'CTE-median', 'EDT-median'};
median_p_str = {'RTp-medi an' ,'DRRp-median' ,'CTEp-median', 'EDTp-median'};
A = {'SourceFolder', mean_str{:}, max_str{:}, min_str{:}, median_str{:}}; 
writecell(A, filename,'FileType','text','WriteMode','overwrite');
for i = 1:length(error_struct)
    A = {error_struct{i}.name, error_struct{i}.mae, error_struct{i}.max, error_struct{i}.min, error_struct{i}.median};
    writecell(A, filename,'FileType','text','WriteMode','append');
end
