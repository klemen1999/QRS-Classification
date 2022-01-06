function [classifications] = QRSCluster(record, beats, Fs)
    signalFileName = sprintf("%sm.mat", record);
    S = load(signalFileName);
    sig = S.val(1,:);
    Fc = 2;
    fsig = HPFilter(sig, Fc, 1/Fs);
    
    maxSample = Fs*300;
    fpPointsAll = beats(:,1);
    fpPointsAll = fpPointsAll(beats(:,2)==0);
    fpPoints = fpPointsAll(fpPointsAll<=maxSample);
    if isempty(fpPoints) % couldn't learn a representation of normal beat
        classifications = NaN;
        return
    end

    limLower = floor(Fs*0.06);
    limUpper = round(Fs*0.1);
    fpPoints = beats(:,1);
    
    X = [];
    addExtra = false;
    for i=1:length(fpPoints)
        currFp = fpPoints(i);
        if currFp+limUpper <= length(fsig)
            currBeat = fsig(currFp-limLower:currFp+limUpper);
            X = [X;currBeat];
        else
            addExtra = true;
        end
    end
    
    [idx1,c1] =kmeans(X, 1);
    WSS1 = 1/sum(idx1==1) * mean(max(abs(X-c1),[],2));

    [idx2,c2] = kmeans(X,2);
    WSS2 = [];
    for i=1:2
        currX = X(idx2==i,:);
        currC = c2(i,:);
        WSScurr = 1/sum(idx2==i) * mean(max(abs(currX-currC),[],2));
        WSS2 = [WSS2, WSScurr];
    end
    WSS2Mean = mean(WSS2);
    disp(WSS1);
    disp(WSS2);
    disp(WSS2Mean)
    if WSS1 < WSS2Mean
        disp("Stay at one cluster")
        classifications = idx1.' - 1;
    else
        classifications = idx2.' - 1;
    end

    if addExtra
        classifications = [classifications, 0]; % assumption
    end

end

