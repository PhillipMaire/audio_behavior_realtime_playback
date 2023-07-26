

%%
PsychPortAudio('Close')

InitializePsychSound(1);
%
nrchannels = 1;
freqSound = 96000 ;
soundDriver = PsychPortAudio('Open', [], [], 1, freqSound, nrchannels);%the 4th input is 1 for low latency??? i think this is correct
% for the audio recording
freq = 96000*2;
numChannels = 1;
bufferSize = 20; %buffer size in seconds
minSecToRec  =4.6;%in sec
pahandle = PsychPortAudio('Open', [], 2, 0, freq, numChannels);
PsychPortAudio('GetAudioData', pahandle, bufferSize, [], [], 0);

%
Fs = freqSound;
Amp= 1 ;
ts=1/Fs;
T=.1;
t=0:ts:T;
%%
dateTime1= datestr(now,'yymmdd_HHMM')
freqSet = logspace(log10(1000), log10(48000./2), 10);

% freqSet = logspace(log10(1000), log10(48000), 3);
setErr = 0.1;
setThresh = 0.05;
close all
timeLimit1 = 5
clear F ;
AudioRec = {};
clc
for kk = 1:length(freqSet);
    gainVarSet = logspace(log10(.1), log10(15), 20);
    y1=sin(2*pi*freqSet(kk)*t);
    trigger1 = 0;
    tic;
    while trigger1 == 0 & toc<timeLimit1
        % modulate the gain
        ampMeas = [];
        for k = 1:length(gainVarSet)
            gainVar = gainVarSet(k);
            y2 = y1*gainVar;
            % play and record
            PsychPortAudio('FillBuffer', soundDriver, y2(:)');%load sound into buffer
            PsychPortAudio('Start', pahandle);% start audio rec
            t1 = PsychPortAudio('Start', soundDriver, 1, 0, 1);%play sound
            PsychPortAudio('Stop', soundDriver, 1);%1 is to wait until audio is done playing
            PsychPortAudio('Stop', pahandle);
            [audiodata, offset, overflow, wrongTimeInfo] = PsychPortAudio('GetAudioData', pahandle);
            ADoriginal = audiodata(end-1000:end);
            AD = ADoriginal - mean(ADoriginal);
            % change the
            AD = abs(AD);
            ADsort = sort(AD);
            ampInds= round([.8*length(ADsort), .85*length(ADsort)]);
            ampMeas(k) = mean(ADsort(ampInds(1):ampInds(2)));
            if isempty(ampMeas(k))
                keyboard
            end
            
            if ampMeas(k)>=setThresh
                if setThresh*setErr >= abs(setThresh-ampMeas(k))
                    trigger1 = 1;
                end
                try
                    start1 =  gainVarSet(k-1);
                catch
                    start1 = gainVarSet(k)./2;
                end
                try
                    end1 = gainVarSet(k+1);
                catch
                    end1 = gainVarSet(k)*2;
                end
                gainVarSet = linspace(start1, end1, 30);
                break
            end
        end
    end
    if trigger1 == 1
        F.gain(kk) = gainVar;
        F.freq(kk) = freqSet(kk);
        AudioRec{kk} = ADoriginal;
        disp([num2str(kk), ' success!!'])
    else
        
        F.gain(kk) = nan;
        F.freq(kk) =nan ;
        AudioRec{kk} = ADoriginal;
        trigger1 = 1;
        disp([num2str(kk), ' failed!!'])
    end
end
disp('done')
F.AudioRec = AudioRec;
%%
close all

figure; tmp = plot(F.freq, F.gain);
hold on
set(gca, 'XScale', 'log')
xlim([min(freqSet), 48000])
%%
% % close all
% % figure;
% % for k = 1:length(AudioRec)
% %     plot(AudioRec{k}(:))
% %     pause(.8)
% % end
%%
close all
P1 = {};
for k = 1:length(AudioRec)
    timeRes = 0.001;
    % figure
    yTMP = AudioRec{k}(:);
    [P1{k},F1,T1] = pspectrum(yTMP,freq,'spectrogram', ...
        'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875); %OG sound file
    
    
end
%% MAC VOLUME AT 9 TICKS
%% bad at freq of 31288 for level threshol = 0.4
%% bad at freq of 40291 for level threshol = 0.2
%% bad at freq of 43551 for level threshol = 0.1
%% bad at freq of 42712 for level threshol = 0.1 again
%% bad at freq of 44407 for level threshol = 0.05
%% bad at freq of 43988 for level threshol = 0.05 again


figure
for k = 1:length(AudioRec)
    disp(k)
    disp(round(freqSet(k)));
    fprintf('\n')
    p1b = pow2db(P1{k});
    tmp = imagesc(p1b);
    tmp.Parent.YDir = 'normal';
    colorbar
    title([num2str(round(freqSet(k))), ' Hz']) 
    pause(1.5)
    
end
%%
%% save everything
cd('/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ')
save([dateTime1, '_speakerBiasTuning']) ;