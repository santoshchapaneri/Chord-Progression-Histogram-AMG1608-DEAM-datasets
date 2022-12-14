function [allPos, allNeg, allIdx] = myUnionCPH(P, PV, N, NV)

% P = [1 2 5 7 9 13];
% N = [1 2 3 6 7 10 11];
% PV = [4 10 1 5 6 8];
% NV = [1 5 20 12 8 9 15];

A = union(P,N);
PL = ismember(A,P);
NL = ismember(A,N);
allPos = zeros(1,length(A));
k=1;
for i=1:length(A)
    if PL(i)~=0
        allPos(i) = PV(k);
        k = k+1;
    end
end
allNeg = zeros(1,length(A));
k=1;
for i=1:length(A)
    if NL(i)~=0
        allNeg(i) = NV(k);
        k = k+1;
    end
end
allIdx = A;