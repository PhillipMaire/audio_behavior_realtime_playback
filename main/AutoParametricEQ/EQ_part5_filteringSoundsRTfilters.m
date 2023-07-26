% LOCATION OF THE AUDIO FILES YOU WANT TO FILTER (must bew wav files) 
toGoTo = ...
    '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/ALL_SOUNDS/CUTsoundsTmp/';
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

indexToUse = 1; % select the filter you want to use ( for which threshold you use) 

F = allF{indexToUse};

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


numCoeffs = 50;
[b,a] = yulewalk(numCoeffs,freqSetNorm(:),filter2(:));


close all
figure
[h,w] = freqz(b,a,length(freqSetNorm))
plot(freqSetNorm(:),filter2(:), '.',w/pi,abs(h))
xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
legend('Ideal','Yule-Walker'), legend boxoff


%% initalize the original filter 
    newFIltX = freqSetNorm(:);
    newFIltY = filter2(:);
%% OPTIONAL create another filter to modulate the other one
close all
filterTEST = filt1ForAdjustingSig;

% figure;plot(1, 'XDataSource', 'newFiltToEditX', 'YDataSource', 'newFiltToEditY')
figure;plot(1, 'YDataSource','filterTEST')
linkdata on



mean1 =mean(filterTEST);
filterTEST = filterTEST - mean1;
filterTEST = filterTEST./4;
filterTEST = filterTEST+mean1;

filterTEST(1:52) = filterTEST(53);

filterTEST = smooth(filterTEST, 13)
filterTEST = filterTEST-.72;
% adjust to be the correct size
filterTEST = [filterTEST(1); filterTEST]
%% load old  hand drawn filter here just drag and drop 


%% make my own g input filter 
close all

% newFIlt = [newFIltX(2:end-1), newFIltY(2:end-1)]

newFIlt = [newFIltX, newFIltY];

newFiltToEdit = newFIlt;

newFiltToEditX = newFiltToEdit(:,1)*48000;
newFiltToEditY = newFiltToEdit(:,2);
figure;plot(1,'ko', 'XDataSource', 'newFiltToEditX', 'YDataSource', 'newFiltToEditY')
linkdata on
axis tight
hold on 

% plot(xtoPLot, normalize(NORMALp5_2, 'range'));
plot(xToPlot, NORMALp5_2*10);













%% only for after everything is load
crush
xToPlot = newFIltX*48000;
% plot(x,'XDataSource','real(x)','YDataSource','imag(x)')
figure;plot(xToPlot,newFIltY, 'ko')

% figure;plot(1, 'ok', 'XDataSource', 'xToPlot', 'YDataSource', 'newFIltY')
axis tight
ylim([0 1])
grid(gca,'minor')

grid on 

%%

trig1 = 0
counter = 0 
newFIlt = [];
hold on
plot(1, 'or', 'XDataSource', 'newFIlt(:,1)','YDataSource', 'newFIlt(:,2)')
while trig1 == 0
    counter = counter+1;
newFIlt(counter, :) = ginput(1);
refreshdata
end
newFIltbackup = newFIlt;
 save('newFIlt', 'newFIlt')

trig1 = 1
%%












%%
% newFIlt = ginput();
%  save('newFIlt', 'newFIlt')
% newFIltbackup = newFIlt;
%% edit it how you wish 
% select = 1:30
% addToo = .04
% newFiltToEdit(select, 2) = newFiltToEdit(select, 2) +addToo;
%%
newFIltbackup = newFIlt;
 save('newFIlt', 'newFIlt')
newFIlt = newFIlt(2:end-1, :);
%%
[~, newFIlt2ind] = sort(newFIlt(:,1));
newFIlt2 = newFIlt(newFIlt2ind, :);


newFIltX = newFIlt2(:,1);
newFIltX = [0; newFIltX; 1*48000];
newFIltX = normalize(newFIltX, 'range');

figure;plot(newFIltX)
%%

newFIltY = newFIlt2(:,2);

setStartLev = 0.04;

tmpMaxDiff = 1 - max(newFIltY)
newFIltY = newFIltY-setStartLev;
newFIltY = normalize(newFIltY, 'range')*(1-setStartLev);
newFIltY = newFIltY+setStartLev

newFIltY = [newFIltY(1); newFIltY; newFIltY(end)];
figure;plot(newFIltY)
%%
crush
xToPlot = newFIltX*48000;
% plot(x,'XDataSource','real(x)','YDataSource','imag(x)')
figure;plot(1, 'ok', 'XDataSource', 'xToPlot', 'YDataSource', 'newFIltY')
linkdata on
axis tight
ylim([0 1])

% newFIltY(1:56) = newFIltY(1:56) + .075
%%
numCoeffs = 35;
[b,a] = yulewalk(numCoeffs,newFIltX(:),newFIltY(:));


close all
figure
timeXvarBy = 48000;
[h,w] = freqz(b,a,length(freqSetNorm))
plot(newFIltX(:)*timeXvarBy,newFIltY(:),timeXvarBy*w/pi,abs(h))
xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
legend('Ideal','Yule-Walker'), legend boxoff
%% for adding another filter to the existing filter
setStartLev = 0.04;
newFilterAdded = abs(h) +filterTEST*16;
tmpMin = min(newFilterAdded);
tmpMaxDiff = 1 - max(newFilterAdded)
newFilterAdded = newFilterAdded-tmpMin;
newFilterAdded = normalize(newFilterAdded, 'range')*(1-setStartLev);
newFilterAdded = newFilterAdded+setStartLev;
figure;plot(newFilterAdded)
ylim([0 1])

newX = linspace(0,1,length(newFilterAdded))
figure;plot(newX*48000, newFilterAdded)

%% for fitting the new filter that was added above
close all
numCoeffs = 30;

[b,a] = yulewalk(numCoeffs,newX(:),newFilterAdded(:));

figure; hold on
timeXvarBy = 48000;

[h,w] = freqz(b,a,length(freqSetNorm))
plot(newX*timeXvarBy,newFilterAdded,timeXvarBy*w/pi,abs(h))
xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
legend('Ideal','Yule-Walker'), legend boxoff

newFIltX = newX;
newFIltY= newFilterAdded;
%%

%%

%% test which filter is being used before making fila audio 
figure
[h,w] = freqz(b,a,length(freqSetNorm))
plot(newX*timeXvarBy,newFilterAdded,timeXvarBy*w/pi,abs(h))
xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
legend('Ideal','Yule-Walker'), legend boxoff

%%
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
%%
toGoTo = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR/FILTERING_PROCESS_2/'
addDir = F.dateTime1;
newDir = [toGoTo, filesep, addDir];
mkdir(newDir);
cd(newDir);


close all
dateTime1= datestr(now,'HHMMFFF');

for k = 1:size(sREC, 1)
audiowrite([dateTime1, '_AF_', sREC{k,1}.name],sFILT{k,1}.y,sREC{k,1}.Fs);
pause(2)
end

save([dateTime1, '_XandYfilter'], 'newFIltX', 'newFIltY', 'a', 'b') 

