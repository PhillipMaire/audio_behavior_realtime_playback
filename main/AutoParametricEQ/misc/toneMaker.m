%%

allALLf = {}
for k = 1:100000
    
    sampling_frequency = 96000;
    amplitudes = 0.5;
    phases = 0;
    
    duration = 100;%of sound(ms)
    spaceBetween_sec = .02;%sec
    totalLengthInSecs = 5.5;
    padBeginingInSecs = 0.25;
    
    SB = zeros(1, round(spaceBetween_sec.*sampling_frequency));
    
    basedONtotalLength = floor(totalLengthInSecs./(spaceBetween_sec+(duration./1000)));
    allF = linspace(1000, 48000, basedONtotalLength);
    allF = allF(randperm(length(allF)));
    
    allALLf{k} = allF;
end
%%

[sorted1, sortInds] = sort(cellfun(@(x) x(1), cellfun(@sort, (cellfun(@abs, cellfun(@diff, allALLf, 'UniformOutput', false), 'UniformOutput', false)), 'UniformOutput', false)))


%%
useLastXvals = 5;
goodInds = sortInds(end+1-useLastXvals:end);

for kk = 1:useLastXvals
    y = [];
    allF = allALLf{goodInds(kk)};
    
    for k = 1:length(allF)
        
        
        frequencies = allF(k);
        [ tone, time ] = tone_generator( sampling_frequency, duration, amplitudes, frequencies, phases);
        y = [y(:)',  tone(:)',SB(:)'];
        
        
    end
    y = [zeros(1, padBeginingInSecs.*sampling_frequency), y];
    

    audiowrite(['TONES_' num2str(kk) '.wav'],y,sampling_frequency)
    
end
TONES_FREQ_KEY = allALLf(goodInds);
save('TONES_FREQ_KEY', 'TONES_FREQ_KEY');
%%
