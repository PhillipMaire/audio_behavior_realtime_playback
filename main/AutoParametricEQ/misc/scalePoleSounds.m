%%



%%

% LOCAITON OF THE AUDIO FILES YOU WANT TO FILTER (must bew wav files) 
putInthisDir = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/ALL_SOUNDS/finalSoundsForBehavior/untitled folder';
mkdir(putInthisDir);

wavFileDir = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/ALL_SOUNDS/finalSoundsForBehavior/untitled folder';
toGoTo = [wavFileDir];
cd([toGoTo]);
wavDirList = dir('*wav');
sREC = {};
for k = 1:length(wavDirList)
    sREC{k, 1} = wavDirList(k);
    [sREC{k, 1}.y,sREC{k,1}.Fs] = audioread(sREC{k,1}.name);
    sREC{k,2} = sREC{k,1}.name;
end

wavfilenames = sREC(:, 2)


%%
ratioScale = .7
%%
A = {}

for k = 1:length(wavfilenames)
    cd(wavFileDir)
    [y, freq] = psychwavread(wavfilenames{k});
    wavName = wavfilenames{k};
    waveNameALL{k} = wavName(1:strfind(wavName, '.') - 1);
    if freq ~= 96000
        disp(' only wav files with sampling rate of 96000 are accepted, if you need to get  around this see detailing at this line in the program')
        %     can use this     eval(['sound', num2str(k),  '= PsychPortAudio(''Open'', [], [], 0, freq, nrchannels)']);
        %     which you can see commented out below to iteratively make a driver
        %     for each file or you can jsut make one driver for each different
        %     sampling rate.
    end
    wavedata = y(:,1) * ratioScale;
%     nrchannels = size(wavedata,1);
%     % make sure we have stereo
%     if nrchannels < 2
%         wavedata = [wavedata ; wavedata];
%         nrchannels = 2;
%     end
    %     eval([waveNameALL{k} ' = wavedata;'])
    cd(putInthisDir)
    audiowrite(wavName,wavedata,freq)

    A{k} = wavedata;
    % % %     eval(['sound', num2str(k),  '= PsychPortAudio(''Open'', [], [], 0, freq, nrchannels)']);
    % Fill the audio playback buffer with the audio data 'wavedata':
    %     eval(['PsychPortAudio(''FillBuffer'', sound', num2str(k), ', wavedata)'])
end


%%

%%
scaleDown = 0.3;
wavFileDir ='/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR/FINAL_SOUNDS';
putInthisDir = '/Users/phillipmaire/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR/FINAL_SOUNDS/otherAMPED';
mkdir(putInthisDir);
wavfilenames = {...
    'pinkNoise_600ms.wav'...
    'hdchirp_log.wav'...
    'REVERSE_hdchirp_log.wav'...
    'pinkNoise_300ms.wav'...
    };


%%%
A = {}

for k = 1:length(wavfilenames)
    cd(wavFileDir)
    [y, freq] = psychwavread(wavfilenames{k});
    wavName = wavfilenames{k};
    waveNameALL{k} = wavName(1:strfind(wavName, '.') - 1);
    if freq ~= 96000
        disp(' only wav files with sampling rate of 96000 are accepted, if you need to get  around this see detailing at this line in the program')
        %     can use this     eval(['sound', num2str(k),  '= PsychPortAudio(''Open'', [], [], 0, freq, nrchannels)']);
        %     which you can see commented out below to iteratively make a driver
        %     for each file or you can jsut make one driver for each different
        %     sampling rate.
    end
    wavedata = y(:,1) * scaleDown;
%     nrchannels = size(wavedata,1);
%     % make sure we have stereo
%     if nrchannels < 2
%         wavedata = [wavedata ; wavedata];
%         nrchannels = 2;
%     end
    %     eval([waveNameALL{k} ' = wavedata;'])
    cd(putInthisDir)
    audiowrite(wavName,wavedata,freq)

    A{k} = wavedata;
    % % %     eval(['sound', num2str(k),  '= PsychPortAudio(''Open'', [], [], 0, freq, nrchannels)']);
    % Fill the audio playback buffer with the audio data 'wavedata':
    %     eval(['PsychPortAudio(''FillBuffer'', sound', num2str(k), ', wavedata)'])
end


