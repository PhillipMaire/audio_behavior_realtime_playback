
%%

clear all
loadDir = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/speakerBiasMatFiles/190723_0018';
allF ={};
tmpDir = dir([loadDir, filesep, '*.mat']);
for  k = 1:size(tmpDir,1)
    allF{k} = load([loadDir, filesep, tmpDir(k).name]);
end
%%
% allF_ALL = allF;
% 
% %%
% allF = allF_ALL(3)


%%
for  k = 1:size(tmpDir,1)
    
    sortThese(k) = allF{k}.setThresh;
end

[~, sorted1]= sort(sortThese)
close all
%%
% next check the 0.05 one to see where that breaks down.
%%
% close all
figure; hold on;
leg1 = cell(length(allF),1);
for iii = 1:length(allF)
    ii = sorted1(iii);
    tmp = allF{ii};
    plot(tmp.F.freq, tmp.F.gain)
    leg1{iii} = ['Amp Thresh of ', num2str(tmp.setThresh)];
end
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')

xlim([1000, 48000])

legend(leg1)


%%
close all
indexVar = 7
tmp = allF{indexVar};

figure
for k = 1950:length(tmp.AudioRec)
    disp(k)
    disp(round(tmp.freqSet(k)));
    fprintf('\n')
    p1b = pow2db(tmp.P1{k});
    tmp2 = imagesc(p1b);
    tmp2.Parent.YDir = 'normal';
    colorbar
    title([num2str(round(tmp.freqSet(k))), ' Hz'])
    pause(1)
    
end
%% only run after you test and then input it directly yourself
allF{indexVar}.BreakFreq.index = 1969;
allF{indexVar}.BreakFreq.freq = tmp.freqSet(allF{indexVar}.BreakFreq.index);

%% here we cap all the frquencies at where we think they produce doubling of any frequencies
for k = 1:length(allF)
%     capGAIN = allF{k}.F.gain(allF{k}.BreakFreq.index);
    setGAIN = nan;
    counter = 0;
    while isnan(setGAIN)
        counter = counter +1;
        setGAIN = allF{k}.F.gain(allF{k}.BreakFreq.index-counter);
    end
    %     allF{k}.F.freqCAPPED = allF{k}.F.freq;
    allF{k}.F.gainCAPPED = allF{k}.F.gain;
    if isnan(setGAIN)
    keyboard
    end
    allF{k}.F.gainCAPPED(allF{k}.F.gainCAPPED>=setGAIN) = setGAIN;
    %    allF{k}.F.gainCAPPED(allF{k}.BreakFreq.index : end) = allF{k}.F.gain(allF{k}.BreakFreq.index - 1);
end
%% replot with the capped frequecnies

% close all
figure; hold on;
leg1 = cell(length(allF),1);
for iii = 1:length(allF)
    ii = sorted1(iii);
    tmp = allF{ii};
    max(tmp.F.gainCAPPED)
    plot(tmp.F.freq, tmp.F.gainCAPPED)
    leg1{iii} = ['Amp Thresh of ', num2str(tmp.setThresh), ' Capped at ', num2str(tmp.F.gain(allF{k}.BreakFreq.index))];
end
set(gca, 'XScale', 'linear')
set(gca, 'YScale', 'linear')

xlim([1000, 48000])

legend(leg1)
%% save the new Variable with everything in it
tic
save([allF{1}.saveDir,filesep, 'allF_', allF{1}.dateTime1], 'allF', '-v7.3')
toc


%%
ADoriginal = tmp.AudioRec{end-101};
figure;plot(ADoriginal)
AD = ADoriginal - mean(ADoriginal);
% change the
AD = abs(AD);
ADsort = sort(AD);
ampInds= round([.8*length(ADsort), .85*length(ADsort)]);
ampMeas = mean(ADsort(ampInds(1):ampInds(2)))
