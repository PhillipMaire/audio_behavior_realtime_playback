function EQ_part1_tuning_speaker_FUNCTION

%%
runTrigger = 0;
close all
f = figure;
hold on
c = uicontrol('style','pushbutton',...
    'units','normalized',...
    'position',[0 .4 1 .4],...
    'FontUnits', 'normalized',...
    'FontSize', .4);
c.String = 'Pause audio';
c.Callback = @pauseForLoop;
%

c2 = uicontrol('style','pushbutton',...
    'units','normalized',...
    'position',[0 0 1 .4],...
    'FontUnits', 'normalized',...
    'FontSize', .4);
c2.String  = 'Resume audio';
c2.Callback = @playForLoop;
title('Running...', 'FontUnits', 'normalized','FontSize', .2)
%%
dateTime1= datestr(now,'yymmdd_HHMM');
saveDir = ['/Users/phil/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/AutoParametricEQ/speakerBiasMatFiles/', dateTime1]
mkdir(saveDir);
cd(saveDir);

pause(.5)
PsychPortAudio('Close')

InitializePsychSound(1);
%
nrchannels = 1;
freqSound = 96000 ;
soundDriver = PsychPortAudio('Open', [], [], 1, freqSound, nrchannels);%the 4th input is 1 for low latency??? i think this is correct
% for the audio recording
freq = 96000;
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
%{
becasue we know the frequency of the wave we can use the period length to
fin the min and max for each period in steps this will give a much better
amplitude
%}
%%
thesholdsALL = .1:.05:.4;
thesholdsALL = flip(thesholdsALL);%start with the largest one to make sure it isnt too loud
notes = ''
method1 = 2; %2 is using period of wave to find amp
for kkk = 1:length(thesholdsALL)
    freqSet = logspace(log10(1000), log10(48000), 1024.*2);
    
    % freqSet = logspace(log10(1000), log10(48000), 3);
    setErr = 0.05;
    setThresh = thesholdsALL(kkk);
    %     close all
    timeLimit1 = 15;
    clear F ;
    AudioRec = {};
    clc
    for kk = 1:length(freqSet);
        pause(0.01)
        gainVarSet = logspace(log10(.1), log10(30), 100);
        y1=sin(2*pi*freqSet(kk)*t);
        period1 = inv(freqSet(kk))*Fs;
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
                
                if method1 ==1
                    % get teh approx amplitude
                    AD = ADoriginal - mean(ADoriginal);
                    AD = abs(AD);
                    ADsort = sort(AD);
                    ampInds= round([.8*length(ADsort), .85*length(ADsort)]);
                    ampMeas(k) = mean(ADsort(ampInds(1):ampInds(2)));
                elseif method1 ==2;
                    %get approx amp way 2 using the period
                    HOWmany = floor(length(ADoriginal)./period1);
                    period2 = floor(mean(diff(((1:HOWmany)*period1))));
                    divInto = ceil((1:HOWmany)*period2);
                    tmp = (1:divInto(end));
                    tmp = reshape(tmp,[], length(divInto));
                    AD2 = ADoriginal(tmp);
                    ampMeas(k) = mean(max(AD2) - min(AD2));
                end
                
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
    %     %%
    %     close all
    %
    %     figure; plot(F.freq, F.gain);
    %     hold on
    %     set(gca, 'XScale', 'log')
    %     xlim([min(freqSet), 48000])
    %%
    %{
close all
figure;
for k = 1:length(AudioRec)
    plot(AudioRec{k}(:))
    pause(.8)
end
    %}
    %%
    %     close all
    P1 = {};
    for k = 1:length(AudioRec)
        timeRes = 0.001;
        % figure
        yTMP = AudioRec{k}(:);
        [P1{k},F1,T1] = pspectrum(yTMP,freq,'spectrogram', ...
            'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875); %OG sound fil
        
    end
    %% MAC VOLUME AT 9 TICKS
    %% bad at freq of 31288 for level threshol = 0.4
    %% bad at freq of 40291 for level threshol = 0.2
    %% bad at freq of 43551 for level threshol = 0.1
    %% bad at freq of 42712 for level threshol = 0.1 again
    %% bad at freq of 44407 for level threshol = 0.05
    %% bad at freq of 43988 for level threshol = 0.05 again
    
    %{
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
    %}
    %%
    %% save everything
    crush
    cd(saveDir);
    save(['Thresh_of_', num2str(setThresh), '_speakerBiasTuning.mat']) ;
end
    function pauseForLoop(src,event)
        
        title('Paused...')
        runTrigger = 0;
        while runTrigger == 0;
            pause(.3)
        end
        title('Running')
    end
    function  playForLoop(src,event)
        runTrigger = 1;
    end

end
%%

%{

allF = {};


allF{end+1} = load('190312_2237_speakerBiasTuning.mat')
% this is for threshold of 0.53 which is about the size of the signal
% withoutfiltering for all frequencies
% 37221.5738632825	1.08136452733721 is where it failsindex 897
% 37071.6241694417	0.82461067218811 is good which is idex 896
allF{end+1} = load('190312_2259_speakerBiasTuning.mat')
allF{end+1} = load('190312_2322_speakerBiasTuning.mat')
allF{end+1} = load('190312_2342_speakerBiasTuning.mat')
allF{end+1} = load('190313_0003_speakerBiasTuning.mat')
allF{end+1} = load('190313_0025_speakerBiasTuning.mat')
allF{end+1} = load('190313_0047_speakerBiasTuning.mat')
%%
% next check the 0.05 one to see where that breaks down.
%%
close all
figure; hold on;
leg1 = cell(length(allF),1);
for ii = 1:length(allF)
    tmp = allF{ii};
    plot(tmp.F.freq, tmp.F.gain)
    leg1{ii} = ['Amp Thresh of ', num2str(tmp.setThresh)];
end
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'linear')

xlim([1000, 48000])

legend(leg1)

%%

ADoriginal = tmp.AudioRec{end-101};
figure;plot(ADoriginal)
AD = ADoriginal - mean(ADoriginal);
% change the
AD = abs(AD);
ADsort = sort(AD);
ampInds= round([.8*length(ADsort), .85*length(ADsort)]);
ampMeas = mean(ADsort(ampInds(1):ampInds(2)))
%}