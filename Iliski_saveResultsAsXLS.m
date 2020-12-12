function Iliski_saveResultsAsXLS(outputStruct, filename)


header = outputStruct.Header;
input = outputStruct.InputData;
computed = outputStruct.Computed;

%% Header
% First two columns are for the initial TF shape
xlswrite(filename, {'Initial TF - X' 'Initial TF - Y' }, 'Header', 'A1');
if ~isempty(header.InitialTF)
    xlswrite(filename, header.InitialTF, 'Header', 'A2');
else
    xlswrite(filename, {'No initial TF to start with.'}, 'Header', 'A2');
end

% 4th and 5th columns are for all the parameters
xlswrite(filename, {'Pre-treatment parameters'}, 'Header', 'D1');
xlswrite(filename, {'Iterations' header.Iterations}, 'Header', 'D2');
xlswrite(filename, {'Median filter - From' header.MedianFilterFrom}, 'Header', 'D3');
xlswrite(filename, {'SGolay filter - From' header.SGolayFilterFrom}, 'Header', 'D4');
xlswrite(filename, {'Median filter - To' header.MedianFilterTo}, 'Header', 'D5');
xlswrite(filename, {'SGolay filter - To' header.SGolayFilterTo}, 'Header', 'D6');
xlswrite(filename, {'Interpolation method' header.InterpolationMethod}, 'Header', 'D7');
xlswrite(filename, {'Sampling time' header.SamplingTime}, 'Header', 'D8');
xlswrite(filename, {'Time interval' header.TimeIntervalRawData(1) ...
    header.TimeIntervalRawData(2)}, 'Header', 'D9');

xlswrite(filename, {'Optimization parameters'}, 'Header', 'D11')
xlswrite(filename, {'TF duration' header.DurationTF}, 'Header', 'D12');
xlswrite(filename, {'Optimization algorithm' header.Algorithm}, 'Header', 'D13');

if isa(header.Function, 'function_handle')
    xlswrite(filename, {'FMinUncAfterSimulAnl' header.FMinUncAfterSimulAnl}, 'Header', 'D14');
    xlswrite(filename, {'Function' func2str(header.Function)}, 'Header', 'D15');
    xlswrite(filename, {'Initial parameters'}, 'Header', 'D16');
    xlswrite(filename, {'Lower bounds'}, 'Header', 'D17');
    xlswrite(filename, {'Upper bounds'}, 'Header', 'D18');
    for i=1:length(header.InitialParameters)
        xlswrite(filename, header.InitialParameters(i), 'Header', [char(68+i) '16']);
        xlswrite(filename, header.LowerBoundParameters(i), 'Header', [char(68+i) '17']);
        xlswrite(filename, header.UpperBoundParameters(i), 'Header', [char(68+i) '18']);
    end
else
    xlswrite(filename, {'Function' header.Function}, 'Header', 'D14');
end

%% Input Data
% First 5 columns are for From and To
xlswrite(filename, {'From - X' 'From - Y' }, 'Input', 'A1');
xlswrite(filename, {'To - X' 'To - Y' }, 'Input', 'D1');
xlswrite(filename, input.From, 'Input', 'A2');
xlswrite(filename, input.To, 'Input', 'D2');

% 7th and 8th columns are for the paths
if isfield(input, 'fileFrom')
    xlswrite(filename, {'Path - From' input.fileFrom}, 'Input', 'G1');
    xlswrite(filename, {'Path - To' input.fileTo}, 'Input', 'G2');
end
if isfield(input, 'pathFrom') % if HDF5
    xlswrite(filename, {'HDF5 Path - From' input.pathFrom}, 'Input', 'G3');
    xlswrite(filename, {'HDF5 Path - To' input.pathTo}, 'Input', 'G4');
end

%% Computed data
% First 5 columns are for treated form of data
xlswrite(filename, {'Treated From - X' 'Treated From - Y' }, 'Computed', 'A1');
xlswrite(filename, {'Treated To - X' 'Treated To - Y' }, 'Computed', 'D1');
xlswrite(filename, computed.FromTreated, 'Computed', 'A2');
xlswrite(filename, computed.ToTreated, 'Computed', 'D2');

% Only the first one of the computed TF is saved (in case there are
% multiples runs)
xlswrite(filename, {'TF - X' 'TF - Y' }, 'Computed', 'G1');
xlswrite(filename, {'Prediction - X' '1st Prediction - Y' }, 'Computed', 'J1');
xlswrite(filename, computed.TF(:, :, 1), 'Computed', 'G2');
xlswrite(filename, computed.Prediction(:, :, 1), 'Computed', 'J2');
xlswrite(filename, {'RSS' computed.ResidualSumSquare(1)}, 'Computed', 'M1');
xlswrite(filename, {'Pearson' computed.Pearson(1)}, 'Computed', 'M2');

if isa(header.Function, 'function_handle')
    xlswrite(filename, {'Only the TF showing the best RSS is written in this file. Find all the computed parameters in the next tab.'}, 'Computed', 'P1')
end

%% Computed parameters
if isa(header.Function, 'function_handle')
    xlswrite(filename, {'Rank' 'RSS' 'Pearson' 'Parameters'}, 'Computed Parameters', 'A1');
    xlswrite(filename, [[1:length(computed.Pearson)]' computed.ResidualSumSquare' ...
        computed.Pearson' computed.Parameters'], 'Computed Parameters', 'A2');
end
end

