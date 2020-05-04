%% getTechFromPath.m
% Return the technique used in the given path. The technique is supposed to
% be the second subfolder in the HDF5 file arborescence.

function tech = getTechFromPath(path)
% Return the used technique given the path
    splitted = strsplit(path, '/');
    tech = splitted{3};
end

