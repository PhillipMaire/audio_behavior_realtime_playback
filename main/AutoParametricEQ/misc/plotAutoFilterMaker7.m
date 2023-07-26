%%
figure;
for iter = 2:length(S)
    text(10000, .8, num2str(iter));
    pause(0.01);
    plot(S{iter}.filtXVals, S{iter}.diffFreqInterp(:), '-');
    ylim([-.5 .5]);
    pause(0.01)
    %     if round(iter./changeAlphaOnIter)==iter./changeAlphaOnIter
    %         hold on; plot(S{iter}.filtXVals,S{iter}.diffFreqInterp(:)+S{iter}.filtFreqInterp(:, 1), '-');hold off
    %         pause(.3)
    %     end
end
%%


%%
close all
clear F
figure;
S2 = S(2:end);
xValsBasic = linspace(1 , 48000+0.00000000001, length(S{2}.ogFreq))
for iter = 1:length(S2)
    hold off
%         pause(0.03);
    plot(S2{iter}.filtXVals, S2{iter}.diffFreqInterp(:), '-k', 'LineWidth',1.5);
    
    hold on
    plot(xValsBasic, S2{iter}.ogFreq./max(S2{iter}.ogFreq), 'b', 'LineWidth',.5);
    plot(xValsBasic, S2{iter}.recFreq./max(S2{iter}.ogFreq) , 'r', 'LineWidth',.5);
    ylim([-.1 1]);
    %     pause(0.03)
    text(40000, .1, ['Iteration ', num2str(iter)],'fontsize',18 );

    
    yyaxis right; % Create a second y-axis on the right
    hold off
    plot(S2{iter}.filtXVals(:), S2{iter}.newFiltAutoTesting(:), '-m', 'LineWidth',1.5);
    hold on 

    
    [h,w] = freqz(S2{iter}.b,S2{iter}.a,length(S2{iter}.filtXVals2));
    plot(w/pi.*48000,abs(h), '-c', 'LineWidth',1.5);
    ylim([0 20]); % Set the limits of the second y-axis

    drawnow
    
    yyaxis left; % Switch back to the left y-axis for the legend
    legend({'difference of signals', 'OG sound', 'Modified sound recording', 'Ideal filter', 'Yule-Walker actual fitted filter'}, 'fontsize',18);



    
% % % % % % % % % % %     %     if round(iter./changeAlphaOnIter)==iter./changeAlphaOnIter
% % % % % % % % % % %     %         hold on; plot(S{iter}.filtXVals,S{iter}.diffFreqInterp(:)+S{iter}.filtFreqInterp(:, 1), '-');hold off
% % % % % % % % % % %     %         pause(.3)
% % % % % % % % % % %     %     end
%     
%     plot(S2{iter}.filtXVals(:), S2{iter}.newFiltAutoTesting(:), '-m', 'LineWidth',1.5);
%     [h,w] = freqz(S2{iter}.b,S2{iter}.a,length(S2{iter}.filtXVals2));
%     %         plot(x1(:),y1(:), '.',w/pi,abs(h), '.')
%     plot(w/pi.*48000,abs(h), '-c', 'LineWidth',1.5);
%     
%     
%     
%     legend({'difference of signals', 'OG sound', 'Modified sound recording', 'Ideal filter', 'Yule-Walker actual fitted filter'}, 'fontsize',18 )
%     
% % % % % % % % % % %     %                     legend('og', 'rec' , 'BL', 'filter', 'diffCenteredAtFilt','newFIlt', 'Yule-Walker')
% % % % % % % % % % %     %      F(iter) = getframe(gcf) ;
    
    drawnow
    
end
%%

writerObj = VideoWriter('pole up example of bad filter goal 2');
writerObj.FrameRate = 30;
% set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F)
    convert the image to a frame
    frame = F(i) ;
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
%%
% figure; plot

S2 = S(2:end);
limErroTo = [10000];%remove less than this 
keepThese = find(S2{2}.filtXVals>=limErroTo);
limErroTo = [30000];% remove greater than this 
keepThese2 = find(S2{2}.filtXVals<=limErroTo);

keepThese3 = intersect(keepThese, keepThese2);

meanSquaredError = cellfun(@mean, cellfun(@(x) x.^2 , cellfun(@(x) x.diffFreqInterp(keepThese3), S2, 'UniformOutput', false), 'UniformOutput', false ));

figure;plot(1:length(S2),meanSquaredError)
ylim([0, .01])
%%
S{iter}.filtFreqInterp(:, 1)
%%

S{1}.RuleToUse = 2
S{k}.alpha1 = .01

%%

resetTo = 26

k = resetTo
S = S(1:resetTo);

%%

makeZero = intersect(find(S{k}.filtXVals2>2000),  find(S{k}.filtXVals2<30000));
S{k}.filter(makeZero) = .001



%
figure;plot( S{k}.filter)

%%
%% change filter
filter2 = S{k}.filter;
S{k}.filtXVals2,S{k}.filter(:)


good1 = find(S{k}.filtXVals2>=39000);
good2 = find(S{k}.filtXVals2<=49000);
goodall = intersect(good2, good1);

filter2(goodall) = filter2(goodall).*2;
%
figure;plot(S{k}.filtXVals2,filter2, '.')
%%
S{k}.filter=filter2;







%%
if length(S)>=3
    allMatdiff = [];
    allMatFilt = [];
    for iter = 3:length(S)
        
        allMatdiff(:, iter) = S{iter}.diffFreqInterp(:);
        allMatFilt(:, iter) = S{iter}.filter(:);
        
    end
    figure;
    imagesc(allMatdiff);
    
    [minVals, MinInds] = min(allMatdiff, [], 2);
    MinInds = MinInds;
    figure;plot(MinInds)
end
newFiltINds = sub2ind(size(allMatFilt), (1:length(MinInds))', MinInds);
S{k}.filter(2:end-1) = allMatFilt(newFiltINds);
%% reset perfect filter to equal dyule walk fitted fitler FRESH START
L4 = length(S{k}.filter);

x4 = w/pi.*48000;
y4 = abs(h);

interpX = linspace(0, 48000+.00000001, L4);
newFIlt4 = interp1(x4,y4, interpX, 'spline', 'extrap');
figure;plot(interpX , newFIlt4)

%{

S{k}.filter = newFIlt4

%}







