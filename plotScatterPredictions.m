botsStartInd = find(redTable.Labels == 1, 1);
realUsersTable = redTable(1:botsStartInd-1,:);
botUsersTable = redTable(botsStartInd:end,:);

top2Features = [3 14];

numRealChoose = randperm(length(realUsersTable.Labels));
numRealChoose = numRealChoose(1:2000);
numBotChoose = randperm(length(botUsersTable.Labels));
numBotChoose = numBotChoose(1:2000);

incorr = [];
correct = [];

j = 0;
labelVarInd = size(redTable,2);
for i = 1:1000
    botNumber = numBotChoose(i);
    realNumber = numRealChoose(i);
    j = j+1;
    
    botPrediction = predict(SVMModel, redTable(botNumber,1:labelVarInd-1));
    realPrediction = predict(SVMModel, redTable(realNumber, 1:labelVarInd-1));
    
    if botPrediction ~= redTable.(labelVarInd)(botNumber)
        incorr = [incorr; redTable.(top2Features(1))(botNumber), redTable.(top2Features(2))(botNumber)];
    else
        correct = [correct; redTable.(top2Features(1))(botNumber), redTable.(top2Features(2))(botNumber)];
    end
    
    if realPrediction ~= redTable.(labelVarInd)(realNumber)
        incorr = [incorr; redTable.(top2Features(1))(realNumber), redTable.(top2Features(2))(realNumber)];
    else
        correct = [correct; redTable.(top2Features(1))(realNumber), redTable.(top2Features(2))(realNumber)];
    end
end

incorr(:,1) = incorr(:,1)*normFacts(ftRank(top2Features(1)));
incorr(:,2) = incorr(:,2)*normFacts(ftRank(top2Features(2)));
correct(:,1) = correct(:,1)*normFacts(ftRank(top2Features(1)));
correct(:,2) = correct(:,2)*normFacts(ftRank(top2Features(2)));

plot(correct(:,1), correct(:,2), 'g.')
hold on
plot(incorr(:,1), incorr(:,2), 'r.')
xlabel('Favorites Count')
ylabel('Number of Tweets & Retweets')
xlim([0 200])
ylim([0 100000])
legend('Correct', 'Incorrect')
title('Classification vs Twitter Account Productivity')
