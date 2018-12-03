%% Get missclassification rate on independent set of verified Users
load newMastTable.mat
load featureRank.mat
load 'twitterSVMClassifier.mat' 
load verified100.mat
load listLookupStruct
load normFacts.mat

sum = 0;
for i = 2:length(verified100)
    userName = verified100(i);
    handle = strsplit(userName,'@');
    handle = handle(2);
    [Prediction, Score] = predictUserBotOrNot(handle ,newMastTable, ftRank, SVMModel, listLookupStruct, normFacts);
    sum = sum + Prediction;
end

