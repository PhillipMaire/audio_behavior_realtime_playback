%% this program is just for initializing the og filter made from part 1 



%% plot smoothed filter(s) 
clear all
% LOCAITON OF THE AUDIO FILES YOU WANT TO FILTER (must bew wav files) 
loc1 = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/ALL_SOUNDS/finalSoundsForBehavior/untitled folder';
toGoTo = [loc1];
cd([toGoTo]);
wavDirList = dir('*wav');
sREC = {};
for k = 1:length(wavDirList)
    sREC{k, 1} = wavDirList(k);
    [sREC{k, 1}.y,sREC{k,1}.Fs] = audioread(sREC{k,1}.name);
    sREC{k,2} = sREC{k,1}.name;
end

sREC
% get the proper filter to use


%% load A and B from previous filter 
% for pole up also see       FINAL_POLE_UP_FILTER_190730.mat
% for pole down see          poleDownFINAL_S2_4_190807_1.mat
tmp1 = load('/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/Svalues/sweepBalanced_FINAL_BEST_S2.mat')
tmp2 = tmp1.S2{1}
b = tmp2.b
a = tmp2.a


%% ORRR start from allF variable 


%% load allF 
load('/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/speakerBiasMatFiles/190723_0018/allF_190723_0018.mat')
%%
indexToUse = 4; % select the filter you want to use ( for which threshold you use) 
F = allF{indexToUse};
F.setThresh
%%
filter1 = F.F.gainCAPPED(:);



smoothBy = 10 ;
pad1 = ones(smoothBy,1);
filter2 = smooth([pad1*filter1(1);filter1;pad1*filter1(end)], smoothBy);
filter2 = filter2(smoothBy+(1:length(filter1)));

filter2 = [filter2(1); filter2(:)];
plotX = linspace(1, 4800, length(filter2));
figure; plot(plotX, filter2)
% save the the info to the origina date num directory 
toGoTo = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/FILTERING_PROCESS/'
addDir = F.dateTime1;
newDir = [toGoTo, filesep, addDir];
mkdir(newDir);
cd(newDir);
%% plot with yule walk fitting 
freqSetNorm = F.freqSet / max(F.freqSet);
freqSetNorm = [0;freqSetNorm(:)];
numCoeffs =100;
[b,a] = yulewalk(numCoeffs,freqSetNorm(:),filter2(:));
% fitlm(freqSetNorm(:), filter2(:))

close all
figure
[h,w] = freqz(b,a,length(freqSetNorm))
plot(freqSetNorm(:),filter2(:), '.',w/pi,abs(h))
xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
legend('Ideal','Yule-Walker'), legend boxoff


%% making the new wav files after filtering labeling them AF 
close all
sFILT = {};
for k = 1:size(sREC, 1)
 
sFILT{k,1}.y = filter(b, a, sREC{k,1}.y);
sFILT{k,1}.y = sFILT{k,1}.y  - mean(sFILT{k,1}.y);

% sFILT{k,1}.y = normalize(sFILT{k,1}.y, 'range')*2;


% sFILT{k,1}.y = sFILT{k,1}.y-1;
scaleBy = 0.95 / max(abs(sFILT{k,1}.y));
sFILT{k,1}.y = sFILT{k,1}.y * scaleBy;


figure;plot(sFILT{k,1}.y)

% figure;plot(1, 'YDataSource', 'sFILT{k,1}.y')
%  linkdata on
%  keyboard
end
%% saveing the new filtered audio
% % % toGoTo = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR/FILTERING_PROCESS_2/'
try 
addDir = F.dateTime1;
catch 
    addDir = datestr(now,'yymmdd_HHMM');
end
newDir = [loc1, filesep, addDir];
mkdir(newDir);
cd(newDir);


close all
dateTime1= datestr(now,'HHMMFFF');

for k = 1:size(sREC, 1)
audiowrite(['AF_', sREC{k,1}.name],sFILT{k,1}.y,sREC{k,1}.Fs);
pause(2)
end

% save([dateTime1, '_XandYfilter'], 'newFIltX', 'newFIltY', 'a', 'b') 

