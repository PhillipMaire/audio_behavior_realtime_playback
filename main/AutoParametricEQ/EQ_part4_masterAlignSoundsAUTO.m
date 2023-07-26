%% master align sounds

%% load the OG audio 
s = struct
cd(['/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/OGbarcodeAudio'])

[y,Fs] = audioread('30SecSweepBarcode.wav');
s.x1 = y;% original
%% load in audio data recorded

dateFolderName = '190718_2234'% SET THIS 
cd(['/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/FILTERING_PROCESS',...
    filesep, dateFolderName]);
% cd('C:\Users\maire\Dropbox\HIRES_LAB\AUDIO_BEHAVIOR\AudioCheckDotNet');
[y,fs] = audioread('AF_30SecSweepBarcode.wav');
s.x2 = y;% recorded
%% #### 
%% USER DEFINED VARIABLES 

alignRegionInds = 7000:22000; % THE BARCODE REGION IN THE OG WAV FILE USED TO ALIGNED SOUNDS
knownSigOnset = 25*fs;% TIME WHEN THE SIGNAL OF INTEREST IS ONSET 
sigLength = 30*fs;% LENGTH OF TIME THE SIGNAL OF INTEREST PERSISTS

%% USER SELECT BASELINE PERIOD for the recorded signal
% % % figure;plot(s.x2)
% % % tmp = round(ginput(2));
% % % close
% % % bl = min(tmp(1,:)):max(tmp(1,:));
% % % bl = bl(bl>0);
bl = 1:fs; %just take the 1st sec
s.bl = s.x2(bl);
%% get spectrogram data 

timeRes = 0.0256/4;
% figure
[P1,F1,T1] = pspectrum(s.x1,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875); %OG sound file

% figure
[P2,F2,T2] = pspectrum(s.x2,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);% recorded sound (based on idex I used above)

[P3,F3,T3] = pspectrum(s.bl,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);% baseline period based on idex above (to subtract out noise

%% make spectrograms of the signals and BL subtracted signal

SPout = SPmaker(2,2);
SPout = SPmaker(SPout);
p1b = pow2db(P1);
tmp = imagesc(p1b);
tmp.Parent.YDir = 'normal';
colorbar
% recorded signal
SPout = SPmaker(SPout);
p2b = pow2db(P2);
tmp = imagesc(p2b);
tmp.Parent.YDir = 'normal';
colorbar
% noise
% figure

SPout = SPmaker(SPout);
p3b = pow2db(P3);
tmp = imagesc(p3b);
tmp.Parent.YDir = 'normal';
colorbar
p3bmean = mean(p3b,2);

% recorded signal - noise
SPout = SPmaker(SPout);
% shft = log10(p3bmean -min(p3bmean));
shft = p3bmean/1;
p2c = p2b-shft;
tmp = imagesc(p2c);
tmp.Parent.YDir = 'normal';
colorbar

%% auto choose align sig region


%% choose align sig for recorded (bottom right) CHOOSE BARCODE REGION ONLY INSIDE THE BLANK PERIODS
% tmp = round(ginput(2));
% bl = min(tmp(:,1)):max(tmp(:,1));
% recInds = bl(bl>0);
% recInds = bl;


%%



%% show aligned traces to check for alignment 
[~, s.x1max]=max(p1b);
[~, s.x2max]=max(p2c);
[acor,lag] = xcorr(s.x2max,s.x1max);
[~,I] = max(abs(acor));
lagDiff = lag(I);
figure;plot(circshift(s.x1max, lagDiff)); hold on; plot(s.x2max)


%% chose align sig for original audio (top left)
% tmp = round(ginput(2));
% bl = min(tmp(1,:)):max(tmp(1,:));
% recInds = bl(bl>0);
% alignRegionInds = bl;
% %% align these signals using Xcorr
% close all
% [~, s.x1max]=max(p1b(:,alignRegionInds));
% [~, s.x2max]=max(p2c(:,recInds));
% [acor,lag] = xcorr(s.x2max,s.x1max);
% [~,I] = max(abs(acor));
% lagDiff = lag(I);
% lag2 = recInds(1) - alignRegionInds(1);
% lagDiff = lagDiff+lag2;
% [~, s.x1maxTot]=max(p1b);
% [~, s.x2maxTot]=max(p2c);
% figure; hold on; plot(s.x1maxTot);plot(s.x2maxTot((lagDiff):end));
%% get the actual indice in actual recorded time
x3INDS = round(T2(lagDiff)*fs);
s.x3 = s.x2(x3INDS:(knownSigOnset+sigLength+x3INDS ));
[P4,F4,T4] = pspectrum(s.x3,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);% baseline period based on idex above (to subtract out noise
%% cut out the signals that we care about ( the linear sweep portion) 
s.x3sweep = s.x3((knownSigOnset):(knownSigOnset+sigLength));% make a new variable of the recorded linear sweep with the portion we care about
[P5,F5,T5] = pspectrum(s.x3sweep,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);
NORMALp5 = P5;% for just the amplitude difference on the -1 to 1 scale
s.x1sweep = s.x1((knownSigOnset):(knownSigOnset+sigLength));% same for the OG signal 
[P6,F6,T6] = pspectrum(s.x1sweep,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);
%% plot the aligned signals
SPout = SPmaker(3,1);
SPout = SPmaker(SPout);
p1b = pow2db(P1);
tmp = imagesc(p1b);
tmp.Parent.YDir = 'normal';
colorbar

SPout = SPmaker(SPout);
p4 = pow2db(P4);
tmp = imagesc(p4);
tmp.Parent.YDir = 'normal';
colorbar


L1 = size(p1b,2);
L2 = size(p4,2);
shifted1 = L1-L2
if L1>L2
    p4 = [p4, zeros(size(p4,1), L1-L2)];
elseif L2>L1
    p1b = [p1b, zeros(size(p1b,1), L2-L1)];
end

SPout = SPmaker(SPout);
tmp = imagesc(p1b-p4);
tmp.Parent.YDir = 'normal';
colorbar
%% plot just the signals of interest
SPout = SPmaker(2,1);
SPout = SPmaker(SPout);
p5 = pow2db(P5);
tmp = imagesc(p5);
tmp.Parent.YDir = 'normal';
colorbar

SPout = SPmaker(SPout);
p6 = pow2db(P6);
tmp = imagesc(p6);
tmp.Parent.YDir = 'normal';
colorbar

%% fit the line
close all
spreadBy =5;
shiftSpreadBy = 0;
knownSigOnset = 25*fs;% TIME WHEN THE SIGNAL OF INTEREST IS ONSET 



[~, y] = max(p6);
% start1 = round(1.2*((size(s.x1maxTot,2)/ (length(s.x1)))*(knownSigOnset)));
% end1 = round(0.8*((size(s.x1maxTot,2)/ (length(s.x1)))*(knownSigOnset + sigLength)));

% y = s.x1maxTot(start1:end1);% choose a random segment of the good signal within the lin sweep to fit line
x = 1:length(y);
% % Then get a fit
coeffs = polyfit(x, y, 1);

% tmp = floor(-1*(coeffs(2)./coeffs(1)));

% Get fitted values
%  x = ((tmp-fs):(tmp+size(p6,2)+fs))+tmp;
fittedY_A = polyval([coeffs(1),coeffs(2)+spreadBy], x)+shiftSpreadBy;
fittedY_B = polyval([coeffs(1),coeffs(2)-spreadBy], x)+shiftSpreadBy;

% Plot the fitted line
%{
figure
hold on;
plot(x, fittedY_A, 'r-', 'LineWidth', .1);
plot(x, fittedY_B, 'r-', 'LineWidth', .1);
%}



%%%
filtLog = zeros(size(p6));
fittedY_A2 = round(fittedY_A);
fittedY_B2 = round(fittedY_B);


allY = arrayfun(@colon, fittedY_B2, fittedY_A2, 'Uniform', false);
allY = vertcat(allY{:})';
allY(allY<1) = 1;
allY(allY>size(filtLog,1)) = 1;

allX = repmat(x, [size(allY,1), 1]);
allX(allX<1) = 1;
allX(allX>size(filtLog, 2)) = 1;


getFiltInds = sub2ind(size(filtLog),allY(:), allX(:));
filtLog(getFiltInds) = 1;
% figure;
% tmp = imagesc(filtLog);tmp.Parent.YDir = 'normal';

figure
tmp = imagesc(p5);
tmp.Parent.YDir = 'normal';
colorbar
hold on;
plot(x, fittedY_A, 'w-', 'LineWidth', 1);
plot(x, fittedY_B, 'w-', 'LineWidth', 1);
%% cut out the points of interest
% close all
alignedAndSubtracted = normalize(normalize(p6, 'range') - normalize(p5, 'range'), 'range');% 
% alignedAndSubtracted = p6 - p5;
% % % % alignedAndSubtracted = alignedAndSubtractedTEST;
p5cut = p5;
p5cut(~filtLog) = nan;
p5cut = nanmean(p5cut, 2);
p6cut = p6;
p6cut(~filtLog) = nan;
p6cut = nanmean(p6cut, 2);


alignedAndSubtracted(~filtLog) = nan;
figure
tmp = imagesc(meanNorm(alignedAndSubtracted));
tmp.Parent.YDir = 'normal';
colorbar

filt1 = nanmean(alignedAndSubtracted,2);
filt1(1) = filt1(2);
% glitchCheck = diff(filt1)./std(filt1);
% filt1(glitchCheck>1) = 11111;
filt1ForAdjustingSig = filt1;
filt1 = normalize(filt1, 'range');

%%
filt1 = p6cut - p5cut;
filt1 = normalize(filt1, 'range');

%%
figure;hold on; plot(filt1);
plot(normalize(p5cut, 'range'));
plot(normalize(p6cut, 'range'));

legend(...
    'aligned and subtracted', ...
    'recordede linear sweep', ...
    'OG signal '...
    )
%% 
close all
NORMALp5_2 = NORMALp5;
NORMALp5_2(~filtLog) = nan;
NORMALp5_2 = nanmean(NORMALp5_2, 2);
xtoPLot = linspace(1, 48000, length(NORMALp5_2));
figure;plot(xtoPLot, NORMALp5_2);

%%
close all
differenceFilter = NORMALp5_2;
cd('/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/FILTERING_PROCESS/diffFilts')
dateTime1= datestr(now,'yymmdd_HHMM');
save([dateTime1, '_differenceFilter'], 'differenceFilter')

%% the sibtraction does almost nothing becasue the OG sound is flat 
%% in power except at the ends where it is a bit weird 


%% select the part you want to nan out if any 
figure;tmp = plot(filt1);
linkdata on

%% edit the filter how you want and then plot again 
close all
figure; plot(filt1)
%%
%%% then I use a brush tool to make the high pitch dips form subtracting out the motor sound into NAN values
%make sure to link your plot to you data in tools then link then use brush tool and right click and make into nans
smoothBy = 1;
nanInds = find(isnan(filt1));
filt1(nanInds) = nan;
filt2 = smooth(filt1, smoothBy);

figure; plot(filt2)
%% no need to flip now it is already the correct direction
% figure;plot(filt2);
% filt3 = normalize(filt2*-1, 'range'); %normalize so that yule walk will fit (only positiv enumbers) 
% hold on; plot(filt3);
% legend('smooths freq diff','flipped ')








%%  rename filter and  set magnifiy value ( sometimes it's too quiet) 
increaseOverallFilterBy = 5;
% filt4 = filt2;filt4(101:end) = 0;filt4 = normalize(filt4, 'range');
filt3 = filt2;
%% edit overal filter size so to change in gain isnt too much in either direction  OPTIONAL 
shiftAllUpBy = 0.003;
minVal = .05

filt4 = normalize(flip(exp(0:1/60:3)), 'range'); filt4 = (filt4*.05);

filt3 = filt3.^2.5;; 
% filt3(1:length(filt4)) = filt4+filt3(length(filt4)+1);
% filt3(filt3<shiftAllUpBy) = shiftAllUpBy;

filt3(1:150) = filt3(150);
filt3 = normalize(filt3, 'range');

filt3 = filt3+shiftAllUpBy;
filt3(filt3<minVal) = minVal;
% % % % % % reduceBy = .95;
% % % % % % filt3 = filt3.*reduceBy +(1-reduceBy)
figure; plot(F1, filt3); hold on; axis tight;ylim([0 1])
% % % % % % % % % %% draw your own filter
% % % % % % % % % figure; plot(filt3,F1 ); hold on; axis tight;xlim([0 1])
% % % % % % % % % yourFIlter = ginput();
% % % % % % % % % 
% % % % % % % % % 
% % % % % % % % % %%
% % % % % % % % % clear yourFIlter2
% % % % % % % % % yourFIlter2(:, 2) = normalize(yourFIlter(:,2), 'range');
% % % % % % % % % yourFIlter2(:,1) = yourFIlter(:,1);
% % % % % % % % % %%
% % % % % % % % % figure;plot(yourFIlter2(:,2), yourFIlter2(:,1))
% % % % % % % % % %%
% % % % % % % % % 
% % % % % % % % % figure;plot(yourFIlter2(:,1), yourFIlter2(:,2))
% % % % % % % % % m = yourFIlter2(:,1)*increaseOverallFilterBy;
% % % % % % % % % f=yourFIlter2(:,2);
% % % % % % % % % 
% % % % % % % % % [b,a] = yulewalk(numCoeffs,f(:),m(:));
% % % % % % % % % 
% % % % % % % % % [h,w] = freqz(b,a,1024)
% % % % % % % % % plot(f,m,w/pi,abs(h))
% % % % % % % % % xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
% % % % % % % % % legend('Ideal','Yule-Walker'), legend boxoff

%% test 
%{
shiftAllUpBy2=  0.95
filt3(filt3>shiftAllUpBy2) = shiftAllUpBy2;

%}
%% fit the filter to a yulewalk function and plot 
close all
figure;plot(F1, filt3);% freq vs power to adujust

numCoeffs = 20;
m = filt3*increaseOverallFilterBy;
%  m = [filt3(1:10); filt3; filt3(end-9:end)];

f=linspace(0,1,length(m));

[b,a] = yulewalk(numCoeffs,f(:),m(:));

[h,w] = freqz(b,a,1024)
plot(f,m,w/pi,abs(h))
xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
legend('Ideal','Yule-Walker'), legend boxoff

%% plot the modified sounds (in the power time domain) 
 z = s.x3sweep; % this is th recorded linear sweep portion 

bfil=fft(z); %fft of input signal
% % % % % % % % % % % % % % % % wn=[4000 8000]/(fs/2);   %bandpass
% % % % % % % % % % % % % % % % [b,a]=butter(6,wn);
figure
% fvtool(b,a);
f2=filter(b,a,z); % filter z which is ...
afil=fft(f2);
subplot(2,1,1);plot(real(bfil));
title('frequency respones of input signal');
xlabel('frequency');ylabel('magnitude');
subplot(2,1,2);plot(real(afil));
title('frequency respones of filtered signal');
xlabel('frequency');ylabel('magnitude');

 %%
% % afilSIG = ifft(afil);
% afilSIG = f2;
% figure;plot(normalize(afilSIG, 'range'), 'r');hold on;plot(normalize(z, 'range'), 'b')
% legend('after filter','before filter')
% 
% figure;plot(normalize(z, 'range'), 'b');hold on;plot(normalize(afilSIG, 'range'),'r')
% legend('before filter','after filter')
%%
% afilSIG = ifft(afil);
afilSIG = f2;
figure;plot(afilSIG, 'r');hold on;plot(z, 'b')
legend('after filter','before filter')

figure;plot(z, 'b');hold on;plot(afilSIG,'r')
legend('before filter','after filter')
%%
[P7,F7,T7] = pspectrum(afilSIG,fs,'spectrogram', ...
    'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);
%%
figure
pModified = pow2db(P7);
tmp = imagesc(pModified);
tmp.Parent.YDir = 'normal';
colorbar

%% write audio file with the new filter
modifiedOG=filter(b,a,s.x1);
dateTime1= datestr(now,'yymmdd_HHMM');
cd('/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/FilteredAudioTestingWAVs')
audiowrite([dateTime1, '_newWaveLinSweep.wav'],modifiedOG,96000);
save([dateTime1, '_afilSIG'], 'afilSIG', 'a', 'b', 'h','w')

%% now record the new audio signal check if the signal 
%% looks correct in audacity spectrogram first

%% if it does, go through this entire process again and make sure it is 
%% ok in matlab. making sure you save the filter first

%% if this looks good then use 








