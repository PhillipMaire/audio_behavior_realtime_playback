%%
tmp1  = load('poleDownbestAtBegining to 30000.mat')
%%
f2 = tmp1.S2{end}
%%

%%
tmp1 = load('poleDownGoodBefore15000Hz.mat')
%%
f1 = tmp1.S{24}

figure;hold on
plot(f1.filter, '.')

plot(f2.filter, '.')

% %% find intersect point 
% diff1 = f1.filter - f2.filter;
% [sorted1, inds1]=sort(diff1);
% [bestMatched, bestMatchInd] = sort(abs(inds1 - 30000));
% 
% test1 = sorted1(inds1(bestMatchInd));
% figure;plot(test1)



%%
userDefinedIntersect = 30000
clear S2
S2{1}.filter = [...
    f1.filter(1:userDefinedIntersect); ...
    f2.filter(userDefinedIntersect+1:end)...
    ];
S2{1}.filter = S2{1}.filter(2:end-1);
S2{1}.filtXVals2 = f1.filtXVals2(2:end-1);

figure;plot(S2{1}.filtXVals2 , S2{1}.filter)
%%

x1 = normalize(S2{1}.filtXVals2', 'range');
y1 = S2{1}.filter;
[S2{1}.b,S2{1}.a] = yulewalk(60,x1,y2');
S2{1}.filter = y2;
%%
smoothBy = 1000 ;
pad1 = ones(smoothBy,1);
filt2 = smooth([pad1*y1(1);y1;pad1*y1(end)], smoothBy);
filt2 = filt2(smoothBy+(1:length(y1)));
filt2 = filt2 
figure; plot(filt2)
% goodPointsX = find(abs(filt2)< thresholdMatch)
%%
y2 = filt2;

%%

save('bestPoleDOwnCombinedFIlter_1_S2', 'S2')




