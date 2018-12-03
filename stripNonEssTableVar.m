%Strip Table of variables we don't care about
%Can eliminate 1

load MasterTableAllAccounts.mat

newMastTable = masterTableN; 
h = height(newMastTable);


%%%IMPORTANT: All Variables THAT NEED TO BE DELETED DO AT END

%% Stuff we can probably delete
% Column #1: All contributors are Null or empty
% Column #12: Can eliminate acct id
% Column #17 & 32: can eliminate name (unless we look for names containing all
% number or something and assign binary)
% Columns 20, 21, 23, 24, 25: all urls, delete
% Column 35: timestamp not sure what it is so delete it



%% Convert complex string variables to informative numeric values
%Columns needing more complex numeric conversions, 
% **Add to numericVariables when done**
% Column#2:  created at -> need to convert that date to epoch time or something
% Column#5:  Probably a binary for if description is present or not
% Column 36: 0 or 1 for presence of URL attached to account
compCols = [5 14 16 19 26 27 28 34 36];

%% Change all non-complex variables from strings to numerics
% Change all of these variables from strings to numeric
numCols = [3 4 6 8 10 11 13 15 22 29 30 31 33 37 38];
for i = numCols
    newMastTable.(i) = convertSimpleStr2Num(newMastTable.(i));
end

%% Convert unique strings to unique integers
uniqueCols = [14 16 19 26 27 28 34];
varNames = newMastTable.Properties.VariableNames;
listLookupStruct = struct();
for k = uniqueCols
    varNm = string(varNames(k));
    [newMastTable.(k), listLookupStruct.(varNm).strr, listLookupStruct.(varNm).intt] = convertCompStr2Num(newMastTable.(k));
    newMastTable.(k) = double(newMastTable.(k));
end



%% Convert Time Stamps to numeric
% for Q = 1:length(aa.(2))
%     aa.(2)(Q) = formatDate(aa.(2)(Q));
% end
%% Convert Profile Bio and URL attached to account to binary
presenceCols = [5 36];
for s = presenceCols
    newMastTable.(s) = convertPresenceStr2Num(newMastTable.(s));
    newMastTable.(s) = double(newMastTable.(s));
end

%% Delete unneeded variable columns in masterTable
delCols = [1 2 7 9 12 13 17 18 20 21 23 24 25 32 35];

for e = sort(delCols, 'Descend')
    newMastTable.(e) = [];
end    


%% Normalize the whole table by max values in each column
numVars = size(newMastTable.Properties.VariableNames, 2);
normFacts = [];
for f = 1:numVars
    array = newMastTable.(f);
    normFacts = [normFacts max(array(:))];
    if max(array(:)) ~= 0
        array(:) = array(:)./max(array(:));
    end
    newMastTable.(f) = array;
end

%% Divide table into binary and non-binary matrices
convBinSize = 1:size(newMastTable.Properties.VariableNames,2)-1; %separate everything except label col
binMat = newMastTable.Labels; %initialize matrices with label data so we don't lose track of it
nonBinMat = newMastTable.Labels;
allVarsMat = newMastTable.Labels;
allVarsMatBT = [];
nonBinMatBT = [];
binMatBT = [];
for i = convBinSize 
    allVarsMatBT = [allVarsMatBT newMastTable.(i)];
    if isempty(find(newMastTable.(i) ~= 1 & newMastTable.(i) ~= 0)) == 1
        binMatBT = [binMatBT newMastTable.(i)];
    else
        nonBinMatBT = [nonBinMatBT newMastTable.(i)];
    end
end
binMat = [binMatBT binMat];
nonbinMat = [nonBinMatBT nonBinMat];
allVarsMat = [allVarsMatBT allVarsMat];


%% Check Correlation of all variables

varsCorr = corr(allVarsMatBT(:,1:end-1));
varsLabelsCorr = corr(allVarsMatBT(:,1:end-1),allVarsMatBT(:,end));
threshold = 0.8; 
numHighCorrelation = size(find(abs(varsCorr)>threshold));
%% Check to make sure we're covering all columns
%allColsCovered = sum(delCols)+ sum(compCols)+ sum(numCols) == sum(1:38);

%% Clear All Variables except output table and Binary/non-Binary matrices
clearvars -except binMat nonBinMat newMastTable allVarsMat listLookupStruct normFacts

%% Needed Functions

function outTableCol = convertSimpleStr2Num(inTableCol)
    inTableCol = double(inTableCol);
    inTableCol(isnan(inTableCol)) = 0;
    inTableCol(isinf(inTableCol)) = -1;
    outTableCol = inTableCol;
end


function [outTableCol,strings, numerics] = convertCompStr2Num(inTableCol)
%Takes a column with non-numeric string data and assigns an integer to each
%unique string
    strings = [""; ""];
    numerics = [0; 0];
    h = length(inTableCol);
    integ = 1;
    for i = 1:h
       if inTableCol(i) == "" || ismissing(inTableCol(i)) == 1 || double(inTableCol(i)) == 0 || inTableCol(i) == "NULL" %if empty assign 0
           inTableCol(i) = 0;
       else
           exist = find(strings == inTableCol(i));
           if isempty(exist) == 1 % if not in dictionary assign it a number
              strings = [strings; inTableCol(i)];
              numerics = [numerics; integ];
              inTableCol(i) = double(integ);
              integ = integ +1;
           else
               inTableCol(i) = double(numerics(exist)); % if in dictionary assign it assoc integer
           end
           
       end
    end
    outTableCol = inTableCol;

end

function outTableCol = convertPresenceStr2Num(inTableCol)
%Takes a column with non-numeric complex string data and assigns a binary
%for presence or not
    h = length(inTableCol);
    for z = 1:h
        if isstring(inTableCol(z)) == 1
            if inTableCol(z) == ""
                inTableCol(z) = 0;
            else
                inTableCol(z) = 1;
            end
        end
    end
    outTableCol = inTableCol;
   
end
