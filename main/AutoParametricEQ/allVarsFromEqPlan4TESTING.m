%%
clear all
load('allVarsFromEqPlan4.mat')

%%

r = S{k}.audiodata_shifted;% recored audio (newest) 
og = TESTING_AUDIOog; 

%%
figure;plot(og);hold on; plot(r)
%%
  %% create spectrogram
    [P_r,F4,T4] = pspectrum(r,Fs,'spectrogram', ...
        'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);% recorded sound signal portion
    
    [P_og,F5,T5] = pspectrum(og,Fs,'spectrogram', ...
        'TimeResolution',timeRes,'Overlap',86,'Leakage',0.875);% signal portion OG sound

%%
P_r_DB = pow2db(P4);
P_og_DB = pow2db(P5);

figure;imagesc(P_r_DB)
colorbar
figure;imagesc(P_og_DB)
colorbar
%%
freq_r = mean(P_r_DB, 2);
freq_og = mean(P_og_DB, 2);

%%
figure;hold on 
plot(freq_r); plot( freq_og)

  %% plot with yule walk fitting
  numCoeffs = 40
    S{k}.freqSetNorm = F1.freqSet / max(F1.freqSet);
    S{k}.freqSetNorm = [0;S{k}.freqSetNorm(:)];
    [S{k}.b,S{k}.a] = yulewalk(numCoeffs,S{k}.freqSetNorm(:),S{k}.filter(:));

     figure;[h,w] = freqz(S{k}.b,S{k}.a,length(S{k}.freqSetNorm));
        plot(S{k}.freqSetNorm(:),S{k}.filter(:), '.',w/pi,abs(h))
        xlabel 'Radian frequency (\omega/\pi)', ylabel Magnitude
        legend('Ideal','Yule-Walker'), legend boxoff
%%

f = fit((1:length(freq_r))',freq_r,'smoothingspline','SmoothingParam',0.07);
%%
newestFIlt.newFIlt(