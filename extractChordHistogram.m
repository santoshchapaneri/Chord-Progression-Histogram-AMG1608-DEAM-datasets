%Copyright 2012, Yi Yu <yi.yu.yy@gmail.com> <yuy@comp.nus.edu.sg> 
%This program is free: 
%you can redistribute it and/or modify
%it under the terms of the GNU General Public License.


function extractChordHistogram(mirParam)

if exist('MirSysInfo.mat', 'file')
	load('MirSysInfo.mat');
else
	fprintf('error, MirSysInfo.mat not exist\n');
	return;
end;

%%%% generate local summary by spectral coorelations
if exist('MirSysDb.mat', 'file')
	thisDb = load('MirSysDb');
	if length(thisDb.audioInfoDb) ~= mirParam.numOfDb
		clear thisDb
	else
		audioInfoDb = thisDb.audioInfoDb;
	end;
end;
if exist('MirSysQr.mat', 'file')
	thisQr = load('MirSysQr');
	if length(thisQr.audioInfoQuery) ~= mirParam.numOfQuery
		clear thisQr
	else
		audioInfoQuery = thisQr.audioInfoQuery;
	end;
end;


model = 15;
use100 = modelparams_svm(model,2);      %flag, if <>0 then add in the 12 chroma features centred at 100 Hz
train12fold = modelparams_svm(model,3); %flag, if <>0 then use 12-fold rotations of training data 
nflag  = modelparams_svm(model,4);       %number of fwd frames to use
pflag  = modelparams_svm(model,5);       %number of prev frames to use
qflag  = modelparams_svm(model,6);       %quad features
maxframes = 0;


for dbIdx=1:length(audioInfoDb)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% process database
	fprintf(2,'Calculating chord histogram for Db[%d] %s\n', ...
		dbIdx, audioInfoDb(dbIdx).origChromaFile);
	filename = [mirParam.METADATA_ROOT  audioInfoDb(dbIdx).origChromaFile];
    tstf{1} = [filename '-400.mat'];
	if ~exist(tstf{1}, 'file')
		fprintf(2, '%s not exist\n', tstf{1});
		continue;
	end;
    X_test = loadftrs_mirex_svm(tstf,use100,nflag,pflag,qflag,train12fold,maxframes);
    testSeq = X_test{1}';

    chromaSeq = testSeq;
 	if mirParam.useHMM==0 && mirParam.useSVM==0
        [path, state, chordHist, majBinHist] = getChordHist(mirParam, chromaSeq, mirParam.numMaxProbe);
    elseif mirParam.useHMM~=0 && mirParam.useSVM==0
        [path, state, chordHist, majBinHist] = viterbi_Nbest(mirParam, chromaSeq, mirParam.numMaxProbe);
    elseif mirParam.useHMM~=0 && mirParam.useSVM~=0
 		[path, state, chordHist, majBinHist] = viterbi_svm_Nbest(mirParam, chromaSeq, mirParam.numMaxProbe);
    else
        fprintf(2, 'Error, undefined parameter\n');
    end;
 
    if mirParam.featType == mirParam.Feat_LocalChordSum
        audioInfoDb(dbIdx).chordHist = chordHist;
    elseif mirParam.featType == mirParam.Feat_HistogramChroma
        audioInfoDb(dbIdx).chordHist = majBinHist;
    else
        fprintf(2, 'Error, undefined feature\n');
    end;
	audioInfoDb(dbIdx).numFrmOrig = size(chromaSeq,2);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% process query
	qrIdx = dbIdx;
	if qrIdx > mirParam.numOfQuery
		continue;
	end;
	if mirParam.testQrLen == 0
		pStart = audioInfoQuery(qrIdx).startFrmNo;
		pEnd   = audioInfoQuery(qrIdx).endFrmNo;
	else
		pStart = 1;
		pEnd   = min(mirParam.queryLen, 1.0)*size(testSeq,2);
	end;
	fprintf(2,'Calculating chord histogram for Qr[%d] %s\n', ...
		qrIdx, audioInfoQuery(qrIdx).origChromaFile);

    chromaSeq = testSeq(:,pStart:pEnd);
	if mirParam.useHMM==0 && mirParam.useSVM==0
        [path, state, chordHist, majBinHist] = getChordHist(mirParam, chromaSeq, mirParam.numMaxProbe);
	elseif mirParam.useHMM~=0 && mirParam.useSVM==0
        [path, state, chordHist, majBinHist] = viterbi_Nbest(mirParam, chromaSeq, mirParam.numMaxProbe);
	elseif mirParam.useHMM~=0 && mirParam.useSVM~=0
        [path, state, chordHist, majBinHist] = viterbi_svm_Nbest(mirParam, chromaSeq, mirParam.numMaxProbe);
    else
        fprintf(2, 'Error, undefined parameter\n');
	end;
	if mirParam.featType == mirParam.Feat_LocalChordSum
        audioInfoQuery(qrIdx).chordHist = chordHist;    
    elseif mirParam.featType == mirParam.Feat_HistogramChroma
        audioInfoQuery(qrIdx).chordHist = majBinHist;
    else
        fprintf(2, 'Error, undefined feature\n');
	end;
	audioInfoQuery(qrIdx).numFrmOrig = size(chromaSeq,2);
end;

save('MirSysDb', 'audioInfoDb');
save('MirSysQr', 'audioInfoQuery');
return;
