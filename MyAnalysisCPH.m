clc;clear;
load('AMG1608AnnotatorsConsensusCIWM.mat');
load('AMG1608_CPH.mat');
load('AMG1608_Chord_Histogram.mat'); % To check with HPA chord histogram

% negVal = find(AMG1608AnnotatorsConsensusCIWM.YValence<0);
% posVal = find(AMG1608AnnotatorsConsensusCIWM.YValence>=0);

negVal = find(AMG1608AnnotatorsConsensusCIWM.YValence<-0.2);
posVal = find(AMG1608AnnotatorsConsensusCIWM.YValence>=0.4);

if 0
% posVal_1 = find(AMG1608AnnotatorsConsensusCIWM.YValence>=-0.6 & AMG1608AnnotatorsConsensusCIWM.YValence<-0.5);
% posnegVal = find(AMG1608AnnotatorsConsensusCIWM.YValence>=0.5 | AMG1608AnnotatorsConsensusCIWM.YValence<-0.5);
% posperm_1 = randperm(length(posVal_1));
% s = [posVal_1(posperm_1(1)),posVal_1(posperm_1(2))]; % Songs to compare

% posnegperm = randperm(length(posnegVal));
% s = [posnegVal(posnegperm(1)),posnegVal(posnegperm(2))]; % Songs to compare

negperm = randperm(length(negVal));
posperm = randperm(length(posVal));
s = [negVal(negperm(1)),posVal(posperm(1))]; % Songs to compare
% s = [posVal(posperm(1)),posVal(posperm(2))]; % Songs to compare
% s = [negVal(negperm(1)),negVal(negperm(2))]; % Songs to compare

% s = [955 1480];
% s = [366 1130];
% s = [1081 1124];
% s = [170 522];
% s = [560 559];
% s = [1579 1160];
strTitle1 = sprintf('SongID: %d, Valence: %1.4f',s(1),AMG1608AnnotatorsConsensusCIWM.YValence(s(1)));
strTitle2 = sprintf('SongID: %d, Valence: %1.4f',s(2),AMG1608AnnotatorsConsensusCIWM.YValence(s(2)));
subplot(211);bar(AMG1608_CPH(s(1),:),'r','LineWidth',2); title(strTitle1,'FontSize',14);grid on; 
subplot(212);bar(AMG1608_CPH(s(2),:),'b','LineWidth',2); title(strTitle2,'FontSize',14);grid on; 
set(gcf,'color','white'); 
% figure;
% strTitle1 = sprintf('CH Valence: %f',AMG1608AnnotatorsConsensusCIWM.YValence(s(1)));
% strTitle2 = sprintf('CH Valence: %f',AMG1608AnnotatorsConsensusCIWM.YValence(s(2)));
% subplot(211);bar(AMG1608_CPH_CH(s(1),:),'r','LineWidth',2); title(strTitle1,'FontSize',14);grid on; 
% subplot(212);bar(AMG1608_CPH_CH(s(2),:),'b','LineWidth',2); title(strTitle2,'FontSize',14);grid on; 
% set(gcf,'color','white'); 
end

% imagesc(AMG1608_CPH);figure;imagesc(AMG1608_CPH_CH);
% Dominant bins of +ve Valence
allPosVal_CPH = AMG1608_CPH(posVal,:);
allNegVal_CPH = AMG1608_CPH(negVal,:);
allPosVal_CPH_CH = AMG1608_CPH_CH(posVal,:);
allNegVal_CPH_CH = AMG1608_CPH_CH(negVal,:);

if 0
startIdx = 20; total = 40;
subplot(211);imagesc(allPosVal_CPH(startIdx:startIdx+total-1,:));
title('Positive Valence Dominant CPs','FontSize',14);
subplot(212);imagesc(allNegVal_CPH(startIdx:startIdx+total-1,:));
title('Negative Valence Dominant CPs','FontSize',14);
set(gcf,'color','white');

% figure;
% subplot(211);imagesc(allPosVal_CPH_CH(startIdx:startIdx+total-1,:));
% title('Positive Valence Dominant CPs with CH');
% subplot(212);imagesc(allNegVal_CPH_CH(startIdx:startIdx+total-1,:));
% title('Negative Valence Dominant CPs with CH');
end

% 25 possible chords
Chords = {'C','C#','D','D#','E','F', 'F#','G','G#','A','A#','B', ...
          'c','c#','d','d#','e','f', 'f#','g','g#','a','a#','b','N'};
if 0
CP = cell(25,25);
for i=1:25
    for j=1:25
        tmp = [Chords(i),Chords(j)];
        CP{i,j} = strjoin(tmp,'->');
    end
end
CP = CP';
tr = tril(ones(25,25),-1);
idxToKeep = find(tr==1);
CP = reshape(CP,1,625);
ChordProg = CP(idxToKeep'); % 1 x 300 chord progressions

% [MajorMajorIdx,MajorMinorIdx,MinorMinorIdx] = getMajorMinorIndices();
% These are in range 1 to 625.
% allPosVal_CPH is N x 300
% Mapping needed for indices
idxCPToCheck = 1;

for i = 1:size(allPosVal_CPH,1)
    tmp=allPosVal_CPH(i,:);
    [val,idx] = sort(tmp,'descend');
    idxPosDominant(i) = idx(idxCPToCheck);
    valPosDominant(i) = val(idxCPToCheck);
    CP_PosDominant{i,1} = ChordProg{idx(idxCPToCheck)};
    
%     valMajMaj(i,:) = allPosVal_CPH(1,MajorMajorIdx);
%     valMajMin(i,:) = allPosVal_CPH(1,MajorMinorIdx);
%     valMinMin(i,:) = allPosVal_CPH(1,MinorMinorIdx);
    
end
uniqueCP_PosValence = unique(idxPosDominant);
[countPosDominant, binsPosDominant] = hist(idxPosDominant,uniqueCP_PosValence);
% hist(idxPosDominant,uniqueCP_PosValence)

for i = 1:size(allNegVal_CPH,1)
    tmp=allNegVal_CPH(i,:);
    [val,idx] = sort(tmp,'descend');
    idxNegDominant(i) = idx(idxCPToCheck);
    valNegDominant(i) = val(idxCPToCheck);
    CP_NegDominant{i,1} = ChordProg{idx(idxCPToCheck)};
end
uniqueCP_NegValence = unique(idxNegDominant);
[countNegDominant, binsNegDominant] = hist(idxNegDominant,uniqueCP_NegValence);
% hist(idxNegDominant,uniqueCP_NegValence)

[allPos, allNeg, allIdx] = myUnionCPH(uniqueCP_PosValence, countPosDominant, uniqueCP_NegValence, countNegDominant);
% CP_Dominant = union(ChordProg(uniqueCP_PosValence),ChordProg(uniqueCP_NegValence),'stable');
% figure;
allMax = max(max(allPos),max(allNeg));
subplot(211);
% bar(countPosDominant);
bar(allPos);
set(gcf,'color','white');
% ax = axis; % Current axis limits
% axis(axis); % Set the axis limit modes (e.g. XLimMode) to manual
% Yl = ax(3:4); % Y-axis limits
Yl = [0 allMax];
set(gca,'XTickLabel','');
% Xt = 1:length(uniqueCP_PosValence);
% t = text(Xt,Yl(1)*ones(1,length(Xt)),ChordProg(uniqueCP_PosValence));
Xt = 1:length(allIdx);
t = text(Xt-0.5,(Yl(1)-1)*ones(1,length(Xt)),ChordProg(allIdx));
set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
    'Rotation',90, 'Fontsize', 12);
grid on;
ylim([0 allMax]);
title('Positive Valence Dominant CPs','FontSize',14);
        
% figure;
subplot(212);
% bar(countNegDominant);
bar(allNeg);
set(gcf,'color','white');
% ax = axis; % Current axis limits
% axis(axis); % Set the axis limit modes (e.g. XLimMode) to manual
% Yl = ax(3:4); % Y-axis limits
Yl = [0 allMax];
set(gca,'XTickLabel','');
% Xt = 1:length(uniqueCP_NegValence);
% t = text(Xt,Yl(1)*ones(1,length(Xt)),ChordProg(uniqueCP_NegValence));
Xt = 1:length(allIdx);
t = text(Xt-0.5,(Yl(1)-1)*ones(1,length(Xt)),ChordProg(allIdx));
set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
    'Rotation',90, 'Fontsize', 12);
grid on;
ylim([0 allMax]);
title('Negative Valence Dominant CPs','FontSize',14);

end

%% 4 quadrant analysis
if 0
posValposAro = find(AMG1608AnnotatorsConsensusCIWM.YValence>=0 & AMG1608AnnotatorsConsensusCIWM.YArousal>=0);
posValnegAro = find(AMG1608AnnotatorsConsensusCIWM.YValence>=0 & AMG1608AnnotatorsConsensusCIWM.YArousal<0);
negValposAro = find(AMG1608AnnotatorsConsensusCIWM.YValence<0 & AMG1608AnnotatorsConsensusCIWM.YArousal>=0);
negValnegAro = find(AMG1608AnnotatorsConsensusCIWM.YValence<0 & AMG1608AnnotatorsConsensusCIWM.YArousal<0);

posValposAro_CPH = AMG1608_CPH(posValposAro,:);
posValnegAro_CPH = AMG1608_CPH(posValnegAro,:);
negValposAro_CPH = AMG1608_CPH(negValposAro,:);
negValnegAro_CPH = AMG1608_CPH(negValnegAro,:);

posValposAro_CPH_perm = randperm(size(posValposAro_CPH,1));
posValnegAro_CPH_perm = randperm(size(posValnegAro_CPH,1));
negValposAro_CPH_perm = randperm(size(negValposAro_CPH,1));
negValnegAro_CPH_perm = randperm(size(negValnegAro_CPH,1));

subplot = @(m,n,p) subtightplot (m, n, p, [0.07 0.05], [0.01 0.05], [0.03 0.01]);
idxPerm = 10;
subplot(2,2,2);imagesc(posValposAro_CPH(posValposAro_CPH_perm(1:idxPerm),:));title('(+V, +A)','FontSize',14);
subplot(2,2,1);imagesc(posValnegAro_CPH(posValnegAro_CPH_perm(1:idxPerm),:));title('(+V, -A)','FontSize',14);
subplot(2,2,3);imagesc(negValposAro_CPH(negValposAro_CPH_perm(1:idxPerm),:));title('(-V, +A)','FontSize',14);
subplot(2,2,4);imagesc(negValnegAro_CPH(negValnegAro_CPH_perm(1:idxPerm),:));title('(-V, -A)','FontSize',14);
figtitle('CPH Analysis','FontSize',14);
set(gcf,'color','white');

end


%% Now check with Chord Histogram
% if 0
% load('AMG1608_CPH2.mat'); % TO BE IGNORED
% allPosVal_ChordHist = AMG1608_Chord_Histogram(posVal,:);
% allNegVal_ChordHist = AMG1608_Chord_Histogram(negVal,:);
% 
% % Lets see what this song is like here in this space:
% songID = 178;
% song_ChordHist = AMG1608_Chord_Histogram(songID,:);
% % Which keys are present in HPA?
% idx = find(song_ChordHist~=0);
% 
% % Track only these keys chord progressions in CPH?
% KeysRetain = [];
% t = tril(ones(25,25),-1);
% ti = find(t==1);
% for i = 1:length(idx)
%     idxkey = idx(i);
%     loc_idxkey = idxkey;
%     tmp = (idxkey-1)*25 + idxkey;
%     for j = 1:23
%         if idxkey+j*25 <= (idxkey-1)*25        
%             loc_idxkey = [loc_idxkey idxkey+j*25];
%         else
%             loc_idxkey = [loc_idxkey tmp+1];
%         end
%     end
%     for kk=1:24 
%         keys(kk)=find(ti==loc_idxkey(kk)); 
%     end
%     KeysRetain = [KeysRetain keys];
% end
% 
% song_CPH = AMG1608_CPH(songID,:);
% song_CPH2 = AMG1608_CPH2(songID,:);
% bar(1:25,song_ChordHist);
% set(gcf,'color','white');
% ax = axis; % Current axis limits
% axis(axis); % Set the axis limit modes (e.g. XLimMode) to manual
% Yl = ax(3:4); % Y-axis limits
% set(gca,'XTickLabel','');
% Xt = 1:25;
% t = text(Xt,Yl(1)*ones(1,length(Xt)),Chords);
% set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
%     'Rotation',0, 'Fontsize', 10);
% grid on;
% all_loc = 1:300;
% song_CPH(find(all_loc~=KeysRetain)) = 0;
% song_CPH2(find(all_loc~=KeysRetain)) = 0;
% % figure;bar(1:300,song_CPH(KeysRetain));figure;bar(1:300,song_CPH2(KeysRetain));
% figure;bar(song_CPH);figure;bar(song_CPH2);
% 
% 
% x=2;
% end


