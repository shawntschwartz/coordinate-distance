%
% By Shawn T. Schwartz
% <shawnschwartz@ucla.edu>
% Castel Lab, 2019
%

%% Clean Up Workspace
clc;
clear all;
close all;
home;

%% Import Data from CSV
all_data = readtable('alex_coords.csv');

%% Separate Desired Columns into Vars
username = all_data(:,{'Username'});
trial_num = all_data(:,{'Trial'});
valence = all_data(:,{'Valence'});
prescoord_row = all_data(:,{'PresCoord_Row'});
prescoord_col = all_data(:,{'PresCoord_Col'});

%% Sort Through Rows
total_length = height(valence);
num_subtrials = 12;

net_row = [];
net_col = [];
net_valen = {};

row = NaN(1,12);
col = NaN(1,12);

num_sets = total_length/12;

for i = 1:num_sets % num neutral per trial set
    % first get the neutral item
    for j = 1:12
        if (strcmp(valence.Valence{j},'Net'))
            net_row = [net_row prescoord_row.PresCoord_Row(j)];
            net_col = [net_col prescoord_col.PresCoord_Col(j)];
            net_valen{i} = valence.Valence(i);
        else
            row(j) = prescoord_row.PresCoord_Row(j);
            col(j) = prescoord_col.PresCoord_Col(j);
        end
    end
end

%% Preallocate Memory for Storage Matrices 
counter = 0;
counts = [];
valences_compiled = {}; % cell array for strings
neutral_coords_row_compiled = [];
neutral_coords_col_compiled = [];
other_coords_row_compiled = [];
other_coords_col_compiled = [];
distances_bw_neuts = [];

for i = 1:length(net_row)
    for j = 1:12
        if (~isnan(row(j)))
        counter = counter + 1;
        fprintf('%d: Connection between neutral->(%d,%d) and [%s]: (%d,%d)\n',counter,net_row(i),net_col(i),net_valen{j}{1},row(j),col(j));
        tmp_dist = sqrt(((row(j) - net_row(i))*(row(j) - net_row(i))) + ((col(j) - net_col(i))*(col(j) - net_col(i))));
        fprintf('%d: CACL DIST: %f\n', counter, tmp_dist);
        
        % gather individual calculations for export to CSV file
        counts(counter) = counter;
        valences_compiled{counter} = net_valen{j};
        neutral_coords_row_compiled(counter) = net_row(i);
        neutral_coords_col_compiled(counter) = net_col(i);
        other_coords_row_compiled(counter) = row(j);
        other_coords_col_compiled(counter) = col(j);
        distances_bw_neuts(counter) = tmp_dist;
        end
    end
end

%% Prepare Data for Export to CSV
%%% Cast each cell/matrix to a table
counts = array2table(counts', 'VariableNames',{'Count'});
valences_compiled = cell2table(valences_compiled', 'VariableNames',{'Valence'});
neutral_coords_row_compiled = array2table(neutral_coords_row_compiled', 'VariableNames',{'NetRow'});
neutral_coords_col_compiled = array2table(neutral_coords_col_compiled', 'VariableNames',{'NetCol'});
other_coords_row_compiled = array2table(other_coords_row_compiled', 'VariableNames',{'ValenceRow'});
other_coords_col_compiled = array2table(other_coords_col_compiled', 'VariableNames',{'ValenceCol'});
distances_bw_neuts = array2table(distances_bw_neuts', 'VariableNames',{'Distance'});

%% Concatenate Individual Tables Into One
concated_data = [counts valences_compiled neutral_coords_row_compiled neutral_coords_col_compiled other_coords_row_compiled other_coords_col_compiled distances_bw_neuts];
writetable(concated_data, 'ALEXcoords_CALCULATED_net_distances.csv');

fprintf('\nCSV file successfully written!\n');
