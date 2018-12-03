%% Get new User Data
function [Prediction, Score] = predictUserBotOrNot(userScreenName,newMastTable, ftRank, CVSVMModel, listLookupStruct, normFacts)

    %userScreenName = 'mattpias';
    tableFields = newMastTable;
    twitterUserTable = getTwitterUserData(userScreenName,tableFields);

    %% Apply variable conversion methods (string -> numeric/logical)
    convPresc = [3 21];
    covUnique = [8 10 11 13 14 15 16 20];
    convDoub = [1 2 4 5 6 7 9 12 17 18 19 23];
    conv2Num = [22];
    varNames = twitterUserTable.Properties.VariableNames;


    %% Convert Presence Variables
    for i = convPresc
        twitterUserTable.(i) = convertPresenceStr2Num(twitterUserTable.(i));
    end

    %% Convert unique categorical strings to unique ints using lookupStruct
    for j = covUnique
        varName = char(varNames(j));
        tableCol = twitterUserTable.(j);
        if isstring(tableCol) == 0
            twitterUserTable.(j) = 0;
        elseif isfield(listLookupStruct, varName) == 1 % ensure it's a var contained in lookup structure, if not, run the unique method again
            cnt = 1;
            found = false;
            while cnt < length(listLookupStruct.(varName).strr)
                z = listLookupStruct.(varName).strr(cnt);
                if z == tableCol
                    twitterUserTable.(j) = listLookupStruct.(varName).intt(cnt);
                    found = true;
                    break
                end
                cnt = cnt+1;
            end
            if found == false
                % if not found in the struct list, add it as an entry and
                % convert to new highest entry in norm vector
                listLookupStruct.(varName).strr(end+1) = twitterUserTable.(j);
                listLookupStruct.(varName).intt(end+1) = listLookupStruct.(varName).intt(end)+1;
                twitterUserTable.(j) = listLookupStruct.(varName).intt(end);
                normFacts(j) =  twitterUserTable.(j);
            end

        else
            %if the variable not in lookup struct, well....I guess run the
            %process of assigning it as a new str->numeric variable...but this
            %shouldn't happen
            twitterUserTable.(j) = convertCompStr2Num(twitterUserTable.(j));
        end
    end

    %% Ensure all variables that present as numeric are actually numeric
    for k = convDoub
        twitterUserTable.(k) = double(twitterUserTable.(k));
    end

    %% Convert simple strings 
    for m = conv2Num
        twitterUserTable.(m) = convertStr2Num(twitterUserTable.(m));
    end


    %% Normalize all variables

    for p = 1:size(twitterUserTable, 2)
        twitterUserTable.(p)=double(twitterUserTable.(p));
    end

    for p = 1:size(twitterUserTable, 2)
        %disp('NormFactor '+ string(normFacts(p)))
        %disp(twitterUserTable.(p))
        %disp(p)
        twitterUserTable.(p) = double(twitterUserTable.(p))/normFacts(p);
    end

    %% Reduce features using ftrank from svm RFE method
    cutOffPerc = 0.5;

    [redTwitterTable] = reduceFeatTable(twitterUserTable, cutOffPerc, ftRank);




    %% Predict what twitter user is
    [Prediction, Score] = predict(CVSVMModel, redTwitterTable);

    %% Functions
    function outTableCol = convertStr2Num(inTableCol)
        if isstring(inTableCol) == 1
            if inTableCol == ""
                inTableCol = 0;
            else
                inTableCol = double(inTableCol);
            end
        end
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
end