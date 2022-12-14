songID = 1200;

load('MirSysDb.mat');
aa = audioInfoDb(1,songID).chordHist;
% load('MirSysQr.mat');
% aa = audioInfoQuery(1,songID).chordHist;
aa = reshape(aa,25,25);

for i = 1:25
    tmp = sum(aa(i,:));
    aa_prob(i,:) = aa(i,:)/tmp;
    if tmp == 0
        aa_prob(i,:) = 0;
    end
end

t = tril(ones(25,25),-1);
aa_prob = aa_prob.*t;

idx = find(t==1);
CPH_Song = aa_prob(idx);
CPH_Song = CPH_Song'; % 1 x 300 CPH probability vector
figure;plot(CPH_Song);