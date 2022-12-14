% Obtain CPH of DEAM1802 dataset -- Final Routine, we obtain 1 x 300 Probability Feature
% Vector

clear;clc;
% Output of CPH code, contains 1x625 chordHist for each song
load('MirSysDb_DEAM1802.mat');
% 1802 songs, 300 bin CPH
DEAM1802_CPH = zeros(1802,300); 

% Indices of interest: no Intra Chord transitions; "almost" Symmetric
transitIndicat = triu(ones(25,25),1);
transitIndicat = transitIndicat';
transitIndicat2 = transitIndicat;
transitIndicat = transitIndicat(:);
idx = find(transitIndicat==1);

for songID = 1:1802
    dbFeat = audioInfoDb(1,songID).chordHist; % This song's chord progressions
    % We want to convert this to a probability vector of 1 x 300
    % Since matrix is "almost" symmetric, we dont take values as is. Modify:
    % Taking max of A->B and B->A progressions and then find CPH
    dbFeat = reshape(dbFeat,25,25);
    dbFeat2 = zeros(25,25);
    for i = 1:25
        for j = 1:25
            if j >= i || i==25 || j==25 
                % ignore progressions to 'N' key
                % we are interested in major and minor keys for now
                % j > i is ignored due to "almost" symmetric
                continue;
            else
                dbFeat2(i,j) = max(dbFeat(i,j), dbFeat(j,i));
            end
        end
    end
    
    % CPH is values at indices of interest (we have taken max as above for
    % "almost" symmetric consideration
    CPH_Song = dbFeat2(idx);
    
    % Normalize the CPH --> convert to probability vector
	CPH_Song = CPH_Song/sum(CPH_Song);
    
    % Save the CPH
    DEAM1802_CPH(songID,:) = CPH_Song'; % 1 x 300 CPH probability vector
end
save('DEAM1802_CPH.mat','DEAM1802_CPH');