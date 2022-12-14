function [MajorMajorIdx,MajorMinorIdx,MinorMinorIdx] = getMajorMinorIndices()

% Major Minor Indices in range [1, 300]

tr = tril(ones(25,25),-1);
idxToKeep = find(tr==1);

MajorIdx = 1:12;
MinorIdx = 13:24;

k = 1;
for i = MajorIdx
    for j = MajorIdx
        if j > i || i==j
            continue;
        end
        linIdx(k) = sub2ind(size(tr),i,j);
        k = k + 1;
    end
end
MajorMajorIdx_1 = sort(linIdx);
MajorMajorIdx = [];
for k = 1:length(MajorMajorIdx_1)
    MajorMajorIdx = [MajorMajorIdx find(idxToKeep==MajorMajorIdx_1(k))];
end

clear linIdx;

k = 1;
for i = MinorIdx
    for j = MajorIdx
        linIdx(k) = sub2ind(size(tr),i,j);
        k = k + 1;
    end
end
MajorMinorIdx_1 = sort(linIdx);
MajorMinorIdx = [];
for k = 1:length(MajorMinorIdx_1)
    MajorMinorIdx = [MajorMinorIdx find(idxToKeep==MajorMinorIdx_1(k))];
end

clear linIdx;

k = 1;
for i = MinorIdx
    for j = MinorIdx
        if j > i || i==j
            continue;
        end
        linIdx(k) = sub2ind(size(tr),i,j);
        k = k + 1;
    end
end
MinorMinorIdx_1 = sort(linIdx);
MinorMinorIdx = [];
for k = 1:length(MinorMinorIdx_1)
    MinorMinorIdx = [MinorMinorIdx find(idxToKeep==MinorMinorIdx_1(k))];
end

clear linIdx;

% % Just checking...
% tr2 = zeros(25,25);
% tr2(MajorMajorIdx_1) = 100;
% tr2(MajorMinorIdx_1) = 200;
% tr2(MinorMinorIdx_1) = 300;
% imagesc(tr2); 
% grid on;