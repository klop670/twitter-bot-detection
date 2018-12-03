%% Determine correlation of variables, and determine number exceeding 
%  specified threshold 
%https://www.analyticsvidhya.com/blog/2016/12/introduction-to-feature-selection-methods-with-an-example-or-how-to-select-the-right-variables/
%https://www.mathworks.com/matlabcentral/fileexchange/50701-feature-selection-with-svm-rfe
%https://www.csie.ntu.edu.tw/~cjlin/libsvm/
load allVarsMat.mat


addpath(genpath('SVM-RFE-CBR-v1.3'));
addpath(genpath('libsvm-3.23'));

varsCorr = corr(allVarsMat(:,1:end-1));
varsLabelsCorr = corr(allVarsMat(:,1:end-1),allVarsMat(:,end));
threshold = 0.8; 
numHighCorrelation = size(find(abs(varsCorr)>threshold));


%% Run the SVM-RFE Method on the variable matrix and obtain the variable 
% ranking 
featureVect = allVarsMat(:,1:end-1);
labelVect = allVarsMat(:,end);
param = {};
param.kerType = 2;
param.rfeC = 1;
param.rfeG = 1/size(featureVect,2);
param.useCBR = 0;
param.Rth = 0.9;
param.nstopChunk = Inf;
[ftRank,ftScore] = ftSel_SVMRFECBR(featureVect,labelVect, param);

%% Modify Table to include top n variables from ftRank [new table: red(uced)MastTable]

redTable = reduceFeatTable(newMastTable, 0.75, ftRank);


% varsInd2Del = ftRank(cutoffThreshold:end);
% varsInd2Del = sort(varsInd2Del, 'Descend');
% redMastTable = newMastTable;
% for i = varsInd2Del
%     redMastTable.(i) = [];
% end
%% Train/Cross-Validate SVM model using reduced Feature Vector

SVMModel = fitcsvm(redTable, 'Labels', 'Standardize',true,'KernelFunction','RBF', 'KernelScale','auto');

CVSVMModel = crossval(SVMModel);

classLoss = kfoldLoss(CVSVMModel)



%% Find Classification error on your own with small subset
randZ = randperm(height(redTable));
testSet = randZ(1:5000);
numIncorrect = 0;
for i = testSet
    userDataLabel = redTable(i,end);
    userData = redTable(i,1:end-1);
    predResult = predict(SVMModel, userData);
    if predResult ~= userDataLabel.(1)
        numIncorrect = numIncorrect+1;
    end
end

save('twitterSVMClassifier', 'SVMModel')
