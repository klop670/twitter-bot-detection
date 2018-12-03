function [redTable] = reduceFeatTable(featTable, cutOffPerc, ftRank)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

cutoffThreshold = ceil(cutOffPerc*length(ftRank));
varsInd2Del = ftRank(cutoffThreshold:end);
varsInd2Del = sort(varsInd2Del, 'Descend');
redTable = featTable;
for i = varsInd2Del
    redTable.(i) = [];
end

end

