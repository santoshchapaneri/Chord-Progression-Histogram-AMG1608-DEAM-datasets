function CPKeys = myGetChordProgfromChordHist(song_ChordHist)

% Indices mapping of 1x625 to 1x300 for CPH and is Common for All songs
CHMask = zeros(25,25);
CHMask(2:end,1) = 1:24; CHMask(3:end,2) = 25:47; CHMask(4:end,3) = 48:69;
CHMask(5:end,4) = 70:90; CHMask(6:end,5) = 91:110; CHMask(7:end,6) = 111:129;
CHMask(8:end,7) = 130:147; CHMask(9:end,8) = 148:164; CHMask(10:end,9) = 165:180;
CHMask(11:end,10) = 181:195; CHMask(12:end,11) = 196:209; CHMask(13:end,12) = 210:222;
CHMask(14:end,13) = 223:234; CHMask(15:end,14) = 235:245; CHMask(16:end,15) = 246:255;
CHMask(17:end,16) = 256:264; CHMask(18:end,17) = 265:272; CHMask(19:end,18) = 273:279;
CHMask(20:end,19) = 280:285; CHMask(21:end,20) = 286:290; CHMask(22:end,21) = 291:294;
CHMask(23:end,22) = 295:297; CHMask(24:end,23) = 298:299; CHMask(25,24) = 300;
idxCHMask = find(CHMask~=0);

% Ok, now which keys are present in HPA?
idxCH = find(song_ChordHist~=0);
locKeys = zeros(24,length(find(idxCH~=25)));
for i = 1:length(idxCH)
    if idxCH(i) == 25 % We ignore the 'N' chord
        continue;
    end
    keyMask = zeros(25,25);
    keyMask(idxCH(i),:) = 1; keyMask(:,idxCH(i)) = 1;
    keyMask = keyMask.*CHMask;
    locKeys(:,i) = keyMask(keyMask~=0);
end

% Take union ==> these are the chord progressions of interest!
CPKeys = [];
for i = 1:length(find(idxCH~=25))
    CPKeys = [CPKeys union(CPKeys, locKeys(:,i))']; 
end
CPKeys = unique(CPKeys); % These are unique keys now
