function initializeAllSoundsFINAL(nameOfMouseAndDate)
%{


nameOfMouseAndDate = 'AH1133x200326_part2';  initializeAllSoundsFINAL(nameOfMouseAndDate)

nameOfMouseAndDate = 'test1';  initializeAllSoundsFINAL(nameOfMouseAndDate)



%}
try
    beep off
    doDeleteTrigger = 0;%Dont delete trigger unless the folder is created
    prompt = 'MAKE SURE THAT THE MIDI SETTING AND AUDIO OUTPUT ARE SET TO THE CORRECT SETTINGS, are they? press Y to continue.';
    str = input(prompt,'s');
    if ~(lower(str) == 'y')
        error('ok then do that now')
    end
    
    %% show the current space on the HD for user reference
    clc
    FileObj      = java.io.File('/Users/phil/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR');%any directory in the recording drive goes here
    % free_GB   = FileObj.getFreeSpace./(10^9);
    total_GB  = FileObj.getTotalSpace./(10^9);
    usable_GB = FileObj.getUsableSpace./(10^9);
    
    formatSpec = ['\n\na TOTAL of %5.1f GB of space is AVAILABLE FOR RECORDING or %2.1f %% of the HD\n'...
        'It is recommended that you have at least 5%% plus what you need to record, which is about '...
        '3GB of space.\n'...
        'For this computer, this means %6.1f GB plus what is needed to record.\n\n'];
    % I print this later
    
    %% notes:
    % as of now mac is set to full volume along with speaker
    dateTime1= datestr(now,'yymmdd_HHMM');
    
    baseDir = '/Users/phil/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR/BehaviorData/';
    baseDir = [baseDir,nameOfMouseAndDate, filesep];
    saveFolder = [baseDir, nameOfMouseAndDate, '_', dateTime1, filesep];
    mkdir(saveFolder);
    audDir = [saveFolder, 'AudioWithDiary'];
    mkdir(audDir);
    doDeleteTrigger = 1;% in case we dont start recording delete
    %the directory so it doesnt get cluttered. this will turn off when you
    %enter the while loop recording stage
    %%
    StartUpDir = [saveFolder, 'StartUpFile'];
    mkdir(StartUpDir);
    %% make. delete. then make again the diary. do it this way so I dont get any warnings about deletinging something that isn't there.
    cd(audDir);
    system(['osascript -e ''', 'tell application "Finder" to close windows'''])
    macopen(pwd)
    diary('myDiaryFile');delete('myDiaryFile'); diary('myDiaryFile');
    %% select files
    wavFileDir ='/Users/phil/Dropbox/HIRES_LAB/AUDIO_BEHAVIOR_FINAL/ALL_SOUNDS/finalSoundsForBehavior';
    %% the below list only make these available. the struct below 'soundIndexForEachTrialType'
    %% with numbers referenceing this list will make these play so you dont have to edit this
    %% cell array of strings to change things. please dont manipulate this section unless you need to
    
    wavfilenames = {...
        ...% pole up sounds
        'UP1.wav'... %1
        'UP2.wav'... %2
        'UP3.wav'... %3
        'UP4.wav'... %4
        'UP5.wav'... %5
        'UP1_wait1point5S_UP1.wav'...%6
        ...% pole down sounds
        'DOWN1.wav'...%7
        'DOWN2.wav'...%8
        'DOWN3.wav'...%9
        'DOWN4.wav'...%10
        'DOWN5.wav'...%11
        ...% soundTrials
        'AF_TONES_1.wav'...%12
        'AF_TONES_2.wav'...%13
        'AF_TONES_3.wav'...%14
        'AF_TONES_4.wav'...%15
        'AF_TONES_5.wav'...%16
        'click6_upNoclick6_zabe_linUp_zabe_linDown_zabe.wav'...%17
        };
    %% add delays to the audio only presentations indexed the same as the above cell array
    soundOnlyDelays = [.5 .5 .5 .5 .5 .5 ...
        2.5 2.5 2.5 2.5 2.5 ...
        0 0 0 0 0 0 ...
        ];
    
    
    %% for accurate recall later set which files you will use
    %% it matches the names for the files in wavfilenamesabove
    %% you can make certain sounds repeat more oftern by putting more of the same numbers in there
    %% these trials will repeat though so not pobabalistic presentation basically just ordered
    %% if more than one sound has been presented equal times and they are the ones presented the least
    %% then it will be random for picking among them but only in this case.
    soundIndexForEachTrialType.fakePoleUp = [1 6 6];
    soundIndexForEachTrialType.fakePoleDown = [7 8 9 10 11];
    soundIndexForEachTrialType.sounds =[1,6,6,6,7,8,9,10, 12,13,14,17, 17, 17];
    soundIndexForEachTrialType.sounds = ...
        randsample(soundIndexForEachTrialType.sounds, length(soundIndexForEachTrialType.sounds));
    Sind = soundIndexForEachTrialType;
    SindNames = fieldnames(Sind);
    %% close any open ports if they are open
    try
        PsychPortAudio('Close')
    catch
    end
    try
        fclose(instrfind);
    catch
    end
    try
        delete(instrfind);
    catch
    end
    %% open device set baud rate
    tryTheseDevices = {...
        '/dev/cu.usbmodem1421'...
        '/dev/tty.usbmodem14101'...
        '/dev/tty.usbmodem14201'...
        '/dev/cu.usbmodem14201'...
        };
    knamesToTry = 0;
    trig1 = true;
    while trig1
        knamesToTry = knamesToTry+1;
        s = serial(tryTheseDevices{knamesToTry}) ;
        set(s,'BaudRate', 9600);
        set(s,'DataBits', 8);
        set(s,'StopBits', 1);
        try
            fopen(s);
            trig1 = false;
        catch ME
            if knamesToTry >= length(tryTheseDevices)
                rethrow(ME)
            end
        end
    end
    % % % s.Timeout = 0.1; %can use this with program 'READ_AUDIO_TRIGdummyTrig' it will print a bunch of 0's
    % % % % so that this time out doesnt occur unless there is read error which means
    % % % % the connection is faulty. this is a good thing to do if for some reason
    % % % % the system is prone to disconnecting temporarily. use a try loop and
    % % % % restart the program to be ready for the next trial even after a temporary
    % disconnect.
    s.Timeout =60*60*10; %10 hours (in seconds)set time out to be very long because we may stop behavior for some
    % time to do things and we want this to keep running
    %
    %% Perform basic initialization of the sound driver:
    InitializePsychSound(1);
    %% for each file load it and initalize it
    for k = 1:length(wavfilenames)
        cd(wavFileDir)
        [y, freq] = psychwavread(wavfilenames{k});
        wavName = wavfilenames{k};
        tmpName = wavName(1:strfind(wavName, '.') - 1);
        %     tmpName = strrep(tmpName, ' ', '_');
        waveNameALL{k} = tmpName;
        if freq ~= 96000
            error(' only wav files with sampling rate of 96000 are accepted, if you need to get  around this see detailing at this line in the program')
            %     can use this     eval(['sound', num2str(k),  '= PsychPortAudio(''Open'', [], [], 0, freq, nrchannels)']);
            %     which you can see commented out below to iteratively make a driver
            %     for each file or you can jsut make one driver for each different
            %     sampling rate.
        end
        wavedata = y';
        nrchannels = size(wavedata,1);
        % make sure we have stereo
        if nrchannels < 2
            wavedata = [wavedata ; wavedata];
            nrchannels = 2;
        end
        eval([waveNameALL{k} ' = wavedata;'])
        eval(['audioFiles.', waveNameALL{k},'= wavedata;']);
        % % %     eval(['sound', num2str(k),  '= PsychPortAudio(''Open'', [], [], 0, freq, nrchannels)']);
        % Fill the audio playback buffer with the audio data 'wavedata':
        %     eval(['PsychPortAudio(''FillBuffer'', sound', num2str(k), ', wavedata)'])
    end
    %% for the playback
    
    nrchannels = 2;
    freq = 96000 ;
    soundDriver = PsychPortAudio('Open', [], [], 1, freq, nrchannels);%the 4th input is 1 for low latency??? i think this is correct
    %% for the audio recording
    AR.freq = 96000;
    AR.numChannels = 2;
    AR.bufferSize = 10; %buffer size in seconds
    AR.minSecToRec  =4.9;%in sec
    AR.pahandle = PsychPortAudio('Open', [], 2, 0, AR.freq, AR.numChannels);
    PsychPortAudio('GetAudioData', AR.pahandle, AR.bufferSize, [], [], 0);
    
    
    %%
    
    trialInfo = {};
    trialType = 0;
    trialTypeString = '';
    trialStart = 0;
    newTrial = 0;
    trialNumber = 1;
    % format shortg % format the clock output
    
    datavar = [];
    audioSelect = nan( 1050 , 1);%1024 is the max number of trials in a session
    selectAudioType = 0;
    currectTrialSelect = zeros(1,length(SindNames));
    soundNumberUsed  = nan;
    saveAudDataNow = 0;
    recStarted = 0;
    AR.timeRecStart = inf; % this is used to stop audio recording this way it doesn't
    % stop the first recording before it even starts
    % % for k = 1:length(SindNames) %populate select audio type with first set of audio
    % %
    % %     tmp = eval(['Sind.' , SindNames{k}]);
    % %     currectTrialSelect(end+1) = tmp(ceil(rand(1)*length(tmp)));
    % %     % audioSelect(1, k) = tmp(ceil(rand(1)*length(tmp)));
    % % end
    % try
    %%
    %% check to make sure the the UMC202HD 192k is plugged in and the default device and save start up text
    fprintf(formatSpec, usable_GB, 100*usable_GB/total_GB, 0.05*total_GB)
    fprintf('Please wait managing startup files...\n\n');
    cd(audDir);
    
    [~, AudioInfoMAC] = ...
        system(sprintf('system_profiler -listDataTypes | grep Audio\nSPAudioDataType\nsystem_profiler SPAudioDataType'));
    sprintf(AudioInfoMAC);
    diary('myDiaryFile')
    
    startUp.startUpText = evalc('type myDiaryFile'); % put in start up to save info
    indAudInterface = strfind(startUp.startUpText, 'UMC202HD 192k');
    
    startFindHZ = strfind(startUp.startUpText, 'Real samplerate');
    endFindHZ = strfind(startUp.startUpText, 'Hz.');
    
    PTB_HZ_output = str2num(startUp.startUpText(startFindHZ(1)+16:endFindHZ(1)-2));
    PTB_HZ_input = str2num(startUp.startUpText(startFindHZ(1)+16:endFindHZ(1)-2));
    
    
    %% find the default audio input/output and sampling rate in the mac
    
    returnSpaces = regexp(AudioInfoMAC, '[\n]');
    returnSpaces = returnSpaces(returnSpaces>strfind(AudioInfoMAC , 'Devices:'));
    returnSpaces = returnSpaces(find(diff(returnSpaces) == 1));
    %         returnSpaces = returnSpaces(2:end-1)
    macDevices = {};
    for chunkAudioDevices = 1:length(strfind(AudioInfoMAC , 'Manufacturer:'))
        % all devices have manufacturer fileds so use it to count them
        ind1 = ((chunkAudioDevices-1)*2)+1;
        macDevices{chunkAudioDevices} = ...
            AudioInfoMAC(returnSpaces(ind1):returnSpaces(ind1+2));
    end
    % index the input and output devices we want
    dev_BEHRINGER = macDevices{find(contains(macDevices, 'UMC202HD 192k'))};
    dev_mac_output = macDevices{find(contains(macDevices, 'Built-in Output:'))};
    
    
    
    contains(dev_BEHRINGER, 'Default Input Device: Yes'); % correct input device
    contains(dev_BEHRINGER, '96000'); % correct sampling rate
    
    contains(dev_mac_output, 'Default Output Device: Yes'); % correct output device
    contains(dev_mac_output, '96000'); % correct sampling rate
    
    %%
    if isempty(indAudInterface) || isempty(dev_BEHRINGER)
        error('PLUG IN THE UMC202HD 192k AUDIO INTERFACE!!!!!!')
    elseif PTB_HZ_output~=PTB_HZ_input
        error('Input and output sampling rate do not match')
    elseif prod([PTB_HZ_output, PTB_HZ_input] == 96000)~=1
        error('sampling rates are not 9600Hz')
    elseif  ~contains(dev_BEHRINGER, 'Default Input Device: Yes') % correct input device
        error('input device isn''t UMC202HD 192k');
    elseif  ~contains(dev_BEHRINGER, '96000') % correct sampling rate
        error('input device doesnt have sampling rate of 96000');
    elseif ~contains(dev_mac_output, 'Default Output Device: Yes') % correct output device
        error('default output device isn''t ''Built-in Output''');
    elseif ~contains(dev_mac_output, 'Output Source: Headphones') % correct output device
        error('Output device AUX cord not plugged in');
    elseif ~contains(dev_mac_output, '96000'); % correct sampling rate
        error('output device doesn''t have sampling rate of 96000');
    end
    
    %%
    
    delete('myDiaryFile')
    %% save all startup variables including the audio files (made startUp variable to indicate what is important)
    startUp.audioFiles = audioFiles;
    save([StartUpDir,filesep, nameOfMouseAndDate, '_', dateTime1, '_startUpVariables'])
    
    %% we got to the beginning, do not delete the directory on error now
    doDeleteTrigger = 0;
    %% listen forever until user stops it
    fprintf('ok im ready when you are!!!!\n\n');
    
    while true
        % choose a random but equally sampled trial
        %%
        if prod(currectTrialSelect) == 0
            diary('myDiaryFile');% start recording all text displayed on the screen
            for selAudIter = 1:length(currectTrialSelect)
                tmp = eval(['Sind.' , SindNames{selAudIter}]);
                numOfEachType = [];
                [uniqTmp, ggg ] = unique(tmp);
                for kk = 1:length(uniqTmp)
                    numOfEachType(kk) =  sum(audioSelect == uniqTmp(kk)) / sum(tmp == uniqTmp(kk));
                end
                loc = find(numOfEachType == min(numOfEachType));
                currectTrialSelect(selAudIter) =  tmp(ggg(loc(ceil(rand(1)*length(loc)))));
            end
        end
        %%
        datavar(end+1) = fscanf(s, '%d');
        %     disp(datavar(:)')
        
        %% start recording high quality audio bit code is .08
        if datavar(end)>= 73 && datavar(end)<= 87
            PsychPortAudio('Start', AR.pahandle);
            AR.timeRecStart = now;
            
            AR.tCaptureStart = datestr(AR.timeRecStart,'yymmdd_HHMMSS_FFF');
            disp('RECORDING STARTED######################')
            recStarted = 1;
        end
        
        %% FAKE POLE UP sound selection based on pulse trigger 0.020 length is trigger
        if datavar(end)>= 15 && datavar(end)<= 27  && length(datavar)>=11
            soundNumberUsed = currectTrialSelect(1);
            soundSTIM = eval(eval('waveNameALL{soundNumberUsed}'));
            trialTypeString = 'pole up';
            disp(trialTypeString)
            PsychPortAudio('FillBuffer', soundDriver, soundSTIM);
            while datavar(end)~=1
                datavar(end+1) = fscanf(s, '%d');
            end
            t1 = PsychPortAudio('Start', soundDriver, 1, 0, 1);
            % %             PsychPortAudio('Stop', soundDriver, 1, 1);%wait for stop of playback
            trialType = 2;
            newTrial = 1;
            trialStart = datestr(now,'yymmdd_HHMMSS_FFF');
            %% JUST SOUND sound selection based on pulse trigger 0.035 length is trigger
        elseif  datavar(end)>= 28 && datavar(end)<= 42 && length(datavar)>=11 % only sound presentation
            soundNumberUsed = currectTrialSelect(3);
            soundSTIM = eval(eval('waveNameALL{soundNumberUsed}'));
            % % %         %###### sound1_waveData is temporary
            % % %         delayTimeForTrig = 0.100; % ephus and cam trig are triggered later
            % % %         % for this section in the statematrix in matlab so we must
            % % %         % delay it 100 ms this is intentional
            % % %         playDelay = 0.090; % it takes time to play audio so we want timing
            % % %         % to be optimal, this has been measured
            % % %         toWait = delayTimeForTrig - playDelay;
            
            trialTypeString = 'sound presentation';
            disp(trialTypeString)
            PsychPortAudio('FillBuffer', soundDriver, soundSTIM);
            while datavar(end)~=1
                datavar(end+1) = fscanf(s, '%d');
            end
            % % %         WaitSecs(toWait);
            WaitSecs(soundOnlyDelays(soundNumberUsed));
            t1 = PsychPortAudio('Start', soundDriver, 1, 0, 1);
            % %               PsychPortAudio('Stop', sound2, 1, 1);%wait for stop of playback
            trialType = 3;
            newTrial = 1;
            trialStart = datestr(now,'yymmdd_HHMMSS_FFF');
            %% FAKE POLE DOWN sound selection based on pulse trigger 0.050 length is trigger
        elseif  datavar(end)>= 43 && datavar(end)<= 57 && length(datavar)>=11
            soundNumberUsed = currectTrialSelect(2);
            soundSTIM = eval(eval('waveNameALL{soundNumberUsed}'));
            trialTypeString = 'pole down';
            disp(trialTypeString)
            PsychPortAudio('FillBuffer', soundDriver, soundSTIM);
            while datavar(end)~=1
                datavar(end+1) = fscanf(s, '%d');
            end
            
            t1 = PsychPortAudio('Start', soundDriver, 1, 0, 1);
            % %               PsychPortAudio('Stop', soundDriver, 1, 1);%wait for stop of playback
            trialType = 1;
            newTrial = 1;
            trialStart = datestr(now,'yymmdd_HHMMSS_FFF');
            %% NORMAL TRIAL for this trial based in pulse trigger (no sound needed)trigger 0.065 length is trigger
        elseif  datavar(end)>= 58 && datavar(end)<= 72  && length(datavar)>=11
            trialStart = datestr(now,'yymmdd_HHMMSS_FFF');
            
            trialTypeString = 'no sound skip';
            disp(trialTypeString)
            trialType = 0;
            newTrial = 1;
        elseif  datavar(end)>= 93 && datavar(end)<= 107  && length(datavar)>=11
            trialStart = datestr(now,'yymmdd_HHMMSS_FFF');
            
            trialTypeString = 'light only trial';
            disp(trialTypeString)
            trialType = 0;
            newTrial = 1;
            %% sending the bit code the trigger length is 9ms
        elseif  datavar(end)>= 5 && datavar(end)<= 14
            datavar = [];
            
        end
        
        if newTrial
            
            %             disp(datavar);
            try % just in case it fails for some reason dont want to stop the whole program.
                trialNumber =bin2dec(num2str(flip(datavar(1:10))));
            catch
                disp('something went wrong with interpreting the bitcode from the behavior PC');
                trialNumber = nan;
            end
            disp(['for trial number ', num2str(trialNumber)]);
            audioSelect(size(trialInfo, 2)+1) = soundNumberUsed;
            
            %         trialInfo = SaveTrialInfo(newTrial, trialType, trialTypeString, trialStart, trialInfo, saveFolder, trialNumber);
            [trialInfo] = SaveTrialInfo(newTrial, trialType, trialTypeString, trialStart, trialInfo, ...
                saveFolder,trialNumber, wavFileDir, wavfilenames,Sind,audioSelect, nameOfMouseAndDate);
            newTrial = 0;
            datavar = [];
            
            currectTrialSelect = currectTrialSelect*0;%reset this
            %% retreive data and stop audio recording
            %     disp(num2str(((now - AR.timeRecStart)*24*60*60)))
            if recStarted == 1; % stop recording and save
                
                while ((now - AR.timeRecStart)*24*60*60)<(AR.minSecToRec)  % if enough time has passed then collect data and stop recording
                    pause(0.005);
                end
                
                PsychPortAudio('Stop', AR.pahandle);
                [AR.audiodata, AR.offset, AR.overflow, AR.wrongTimeInfo] = PsychPortAudio('GetAudioData', AR.pahandle);
                plot(AR.audiodata')
                if isempty(AR.audiodata)
                    for k = 1:30
                        warning('sound file is empty!!!!');
                    end
                    beep
                end
                %             disp(length(AR.audiodata))
                pause(0.005)
                disp('RECORDING STOPPED######################')
                
                fprintf('\n\n');
                
                diary('myDiaryFile');%
                AR.diaryTMP = evalc('type myDiaryFile');
                AR.trialNum = trialNumber;
                trialNumStr = sprintf('%04d',trialNumber);
                fileName = [audDir, filesep,nameOfMouseAndDate, '_',trialNumStr];
                save(fileName, 'AR');
                delete('myDiaryFile')
                AR.timeRecStart = inf;
                recStarted = 0;
                
            end
        end
    end
    
    %% corresponding arduino code named READ_AUDIO_TRIG
    %{

////////////////////////////////////////////////////////////////////////////
const int inPin = 7;                   // the number of the input pin
//const int BitPin = 4;                   // the number of the input pin
static unsigned long startTime = 0;  // the time the switch state change was first detected
static boolean state;                // the current state of the switch
unsigned long trig = 0; // length of signal (for detecting trial type
const int bitPulseLength = 2;
const int bitbreakLength = 5;
static unsigned long REFRESH_INTERVAL = 7; // ms ...set later by sum of above;
static unsigned long lastRefreshTime = 0;
static unsigned long bitCounter = 0;
int bitArray[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
//int currentBit = 0;
int i ;


void setup()
{
  pinMode(inPin, INPUT);
  digitalWrite(inPin, LOW); // turn on pull-up resistor
  Serial.begin(9600);
}
void loop()
{
  if (digitalRead(inPin) != state) // check to see if the switch has changed state
  {
    state = ! state;
    if (state == HIGH)
    {
      Serial.println(1);// trigger for sound only when it follows a trial type number so 20 35 50 or
      //65 ms withing 5ish ms error and 80 for sound recording trigger
      startTime = millis();  // start time
    }
    if (state == LOW)
    {
      trig = (millis() - startTime); // length signal was high
      Serial.println(trig);
      startTime = 0; // reset start time
    }
  }
  lastRefreshTime = millis();
  if ((trig >= 6) && (trig <= 14)) // start listening to bit code BIT CODE INIT IS 9 MS PULSE
  {
    while (bitCounter < 10)
    {
      //      Serial.println(7);//


      if (digitalRead(inPin) != state) // check to see if the switch has changed state
      {
        //        bitArray[bitCounter] = 1;
        //        Serial.println(3);//
        state = ! state;
        if (state == LOW) // ADD DEBOUNCER HERE!!!
        {
          bitArray[bitCounter] = 1;
          //                    Serial.println(3);//
        }

      }
      //      Serial.println(millis() - lastRefreshTime);//
      if (millis() - lastRefreshTime >= REFRESH_INTERVAL) // if time interval has been reached
      {
        //         Serial.println(lastRefreshTime);//
        //        Serial.println(state);
        //                Serial.println(bitArray[bitCounter]);//
        //        lastRefreshTime += REFRESH_INTERVAL;
        lastRefreshTime = millis();
        bitCounter += 1;
        //        Serial.println(bitCounter);//
        //                recordBits();
      }
      //      else
      //      {
      //        Serial.println(5);//
      //      }



    }
    for (i = 0; i <= 9; i++)
    {
      Serial.println(bitArray[i]);
    }
    trig = 0;
    bitCounter = 0;
    memset(bitArray, 0, sizeof(bitArray)); // clear bit array
  }
  //        Serial.println(bitArray);//

}

///////////////////////////////////////////////////////////////////////////////////////////////
    %}
    
catch ME
    if doDeleteTrigger
        close all
        recycle('off');
        system(['osascript -e ''', 'tell application "Finder" to close windows'''])%close windwos
        cd(saveFolder)% go to save folder
        cd('..') % go up one folder
        rmdir(saveFolder, 's')
        disp('Recycling the directory because we never started recording')
    end
    rethrow(ME)
end
