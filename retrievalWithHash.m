%Copyright 2012, Yi Yu <yi.yu.yy@gmail.com> <yuy@comp.nus.edu.sg> 
%This program is free: 
%you can redistribute it and/or modify
%it under the terms of the GNU General Public License.

%%%% actual retrieval by exploiting LSH
load('MirSysDb');
load('MirSysQr');
load('hashTable2');

numOfQueryInUse = min( 1072, length(audioInfoQuery));
numOfDbInUse    = min(74055, length(audioInfoDb));

statTotalRelevance  = 0;
statTotalGroundTruth= 0;
statRecall          = zeros(numOfQueryInUse,1);
statAverPrecision   = zeros(numOfQueryInUse,1);
statQrCompCost      = zeros(numOfQueryInUse, 1);


% SelectCond_k = [ 3];       % Final result: relevance=10548, groundtruth=14452, compcost=0.186
% SelectCond_k = [ 3 5];     % Final result: relevance=10490, groundtruth=14452, compcost=0.089
% SelectCond_k = [ 3 5 10];  % Final result: relevance=10490, groundtruth=14452, compcost=0.056

% SelectCond_k = [ 5];     % Final result: relevance=10505, groundtruth=14452, compcost=0.090
% SelectCond_k = [ 5 10];  % Final result: relevance=10533, groundtruth=14452, compcost=0.040

SelectCond_k = [ 3   5  10   15   20];
SelectCond_n = [10  15  30   45   60];
%probe_limit  = [12  25  77  160  200];
probe_limit  = [12  25  75  150  250];


transitIndicatForLSH = triu(ones(25,25),1);
transitIndicatForLSH = transitIndicatForLSH';
transitIndicatForLSH = transitIndicatForLSH(:);

fid = fopen(mirParam.logFile, 'wt');
for qrIdx=1:numOfQueryInUse
	fprintf(2,'Now with <GID=%04d, VID=%02d, SID=%05d>, querying ..., ', audioInfoQuery(qrIdx).groupId, ...
		audioInfoQuery(qrIdx).coverVerId, audioInfoQuery(qrIdx).songId);

	%%%% start actual retrieval with one query song
	switch mirParam.featType
	case {mirParam.Feat_LocalChordSum, mirParam.Feat_HistogramChroma}
		qrFeat = audioInfoQuery(qrIdx).chordHist;
		if mirParam.useTransitOnly ~= 0
			qrFeat = qrFeat .* mirParam.transitIndicat;
		end;
		[featSort, majorHist] = sort(qrFeat .* transitIndicatForLSH);
		qrMajorBin = majorHist(end:-1:1);
% 		qrMjHist = repmat(false, 1, length(qrMajorBin));
% 		qrMjHist(qrMajorBin(1:SelectCond_n1)) = repmat(true, 1, SelectCond_n1);
    end;

 
    %%%%% find buckets
    candidateSet = [];
    for bktIdx=1:length(hashTable)
        keyLen = length(hashTable(bktIdx).key);
        index = find(keyLen == SelectCond_k);
        topn = SelectCond_n(index);
        prlimit = probe_limit(index);

        [flag, orders] = ismember(hashTable(bktIdx).key, qrMajorBin(1:topn));
        if sum(flag)==keyLen && sum(orders)<=prlimit
            candidateSet = [candidateSet [hashTable(bktIdx).dbIndex; 
                            repmat(bktIdx, 1, length(hashTable(bktIdx).dbIndex))]];
        end;
    end;

    
	%%%% check similarity with matching info
	similarity = zeros(numOfDbInUse,1);
    
	for cIdx=1:size(candidateSet,2) % 1:numOfDbInUse
        dbIdx = candidateSet(1,cIdx);
        bktIdx= candidateSet(2,cIdx);
        switch mirParam.featType
		case {mirParam.Feat_LocalChordSum, mirParam.Feat_HistogramChroma}
			dbFeat = audioInfoDb(dbIdx).chordHist;
			if mirParam.useTransitOnly ~= 0
				dbFeat = dbFeat .* mirParam.transitIndicat;
			end;

% 			[featSort, majorHist] = sort(dbFeat .* transitIndicatForLSH);
% 			dbMajorBin = majorHist(end:-1:1);
% 			dbMjHist = repmat(false, 1, length(dbMajorBin));
% 			dbMjHist(dbMajorBin(1:SelectCond_k1)) = repmat(true, 1, SelectCond_k1);
% 
% 			%%%% check whether (reference's k=5 major bins) is a subset of (query's n=15 major bins)
% 			comMjHist1 = qrMjHist & dbMjHist;
% 			if ~(sum(comMjHist1)==SelectCond_k1)
% 				continue;
% 			end;
% 
% 			%%%% find the ranks of (reference's k=5 major bins) in (query's n=15 major bins)
% 			orders = zeros(1,SelectCond_k1);
% 			for k=1:SelectCond_k1
% 				orders(k) = find(qrMajorBin==dbMajorBin(k));
% 			end;
% 			if sum(orders)>probe_limit
% 				continue;
% 			end;
        end;
		statQrCompCost(qrIdx) = statQrCompCost(qrIdx)+1;

		corrCoef = sum(qrFeat .* dbFeat) / sqrt(sum(qrFeat.^2) * sum(dbFeat.^2)+1e-6);
		similarity(dbIdx) = corrCoef;
	end;


	%%%% output similar songs in a ranked list
	[simDegree, simIdx] = sort(similarity);
	len = length(audioInfoQuery(qrIdx).knnSet);
	resultSet = simIdx(length(simIdx):-1:length(simIdx)-len+1);
	simInRank = simDegree(length(simIdx):-1:length(simIdx)-len+1);
	%%%% remove self from result set
	indicator = (audioInfoQuery(qrIdx).songId == [audioInfoDb(resultSet).songId]);
	if sum(indicator) ~= 0
		resultSet = [resultSet(~indicator); simIdx(length(simIdx)-len)];
		simInRank = [simInRank(~indicator); simDegree(length(simIdx)-len)];
	end;
	audioInfoQuery(qrIdx).resultSet = resultSet;

	%%%% calculate evaluation metrics of the retrieval results
	correctSet = intersect(audioInfoQuery(qrIdx).knnSet, resultSet);
	statTotalRelevance = statTotalRelevance + length(correctSet);
	statTotalGroundTruth = statTotalGroundTruth + length(audioInfoQuery(qrIdx).knnSet);
	statRecall(qrIdx) = length(correctSet)/length(audioInfoQuery(qrIdx).knnSet);
	averp = 0;
	count = 0;
	for k=1:length(resultSet)
		if ismember(resultSet(k), audioInfoQuery(qrIdx).knnSet)
			count = count + 1;
			averp = averp + count / k;
		end;
	end;
	statAverPrecision(qrIdx) = averp/(count+1e-10);

	%%%% output retrieval result into logfile
	fprintf(2,  'match=%02d/%02d, statRecall=%5.3f, statAverPrecision=%5.3f, cost=%5.3f\n', ...
		length(correctSet), length(audioInfoQuery(qrIdx).knnSet), statRecall(qrIdx), ...
		statAverPrecision(qrIdx), statQrCompCost(qrIdx)/numOfDbInUse);
	fprintf(fid,'G%04d-V%02d-S%05d, ', audioInfoQuery(qrIdx).groupId, ...
		audioInfoQuery(qrIdx).coverVerId, audioInfoQuery(qrIdx).songId);
	fprintf(fid,'match=%02d/%02d, statRecall=%5.3f, statAverPrecision=%5.3f, ', ...
		length(correctSet), length(audioInfoQuery(qrIdx).knnSet), statRecall(qrIdx), statAverPrecision(qrIdx));
	for k=1:length(resultSet)
		fprintf(fid,'R[%05d]=%5.3f, ', resultSet(k), simInRank(k));
	end;
	fprintf(fid, '\n');
end;

fprintf(fid, '\n\nFinal result: relevance=%d, groundtruth=%d, compcost=%5.3f\n', ...
	statTotalRelevance, statTotalGroundTruth, mean(statQrCompCost)/numOfDbInUse);
fprintf(2,   '\n\nFinal result: relevance=%d, groundtruth=%d, compcost=%5.3f\n', ...
	statTotalRelevance, statTotalGroundTruth, mean(statQrCompCost)/numOfDbInUse);
fprintf(fid, 'Mean recall=%f, mean averPrecision=%f\n', mean(statRecall), mean(statAverPrecision));
fprintf(fid, '%s, %s, useHMM=%d, useSVM=%d, numProbe=(%d, %d)\n', ...
    mirParam.basicFeatStr, mirParam.FeatTypeStr{mirParam.featType}, ...
    mirParam.useHMM, mirParam.useSVM, mirParam.numMaxProbe);
fprintf(fid, '%s\n', mirParam.DATABASE_DESCRIBE_FILE);
fprintf(fid, '%s\n', mirParam.QUERY_DESCRIBE_FILE);
fprintf(fid, '%s\n', mirParam.METADATA_ROOT);
fclose(fid);

fprintf(2, '%s\n', mirParam.DATABASE_DESCRIBE_FILE);
fprintf(2, '%s\n', mirParam.QUERY_DESCRIBE_FILE);
fprintf(2, '%s\n', mirParam.METADATA_ROOT);
return;
