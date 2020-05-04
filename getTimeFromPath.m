%% getTimeFromPath.m
% Function that will return the time vector from a given path in the
% database.
% DB should be like this :
% BOLD/fUS/Ca/RBCs folders inside Delta/DeltaOvB/Raw
% BOLD/fUS => time folder and time vector inside
% Ca => time vector inside CC folders for Delta & DeltaOvB, trial-specific
%   time vector for Raw.
% RBCs => to be defined


function [time] = getTimeFromPath(file, path)
splitted = strsplit(path, '/');

if contains(file, 'steps')
    splitted(end) = {'time'};
else
    tech = getTechFromPath(path);
    
    if strcmp(tech, 'BOLD')% | strcmp(tech, 'FUS')
        splitted(end) = {'time'};
    elseif strcmp(tech, 'FUS')
        splitted(end) = {'time'};
    else% strcmp(tech, 'RBC') | strcmp(tech, 'Ca')
        %         if strcmp(splitted{end}, 'avg') | strcmp(splitted{2}, 'Delta') | ...
        %                 strcmp(splitted{2}, 'DeltaOvB')
        if strcmp(splitted{2}, 'Raw')
            tmp = split(splitted{end}, '');
            splitted{end} = strjoin({tmp{2}, '_t', tmp{end-1}}, '');
        else
            splitted(end) = {'time'};
        end
        %         else
        %             trial = strsplit(splitted{end}, '_');
        %             splitted{end} = strjoin({trial{1}, ['t', trial{2}]}, '_');
        %         end
    end
end

path = strjoin(splitted, '/');
time = h5read(file, path);
end

