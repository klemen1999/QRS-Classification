function [classifications] = QRSClassify1(record, beats, Fs)
    signalFileName = sprintf("%sm.mat", record);
    S = load(signalFileName);
    sig = S.val(1,:);
    Fc = 2;
    fsig = HPFilter(sig, Fc, 1/Fs);

    averageBeat =  getAverageBeat(fsig ,beats, Fs);
    if isnan(averageBeat)
        classifications = NaN;
        return
    end
    
    threshold = max(abs(averageBeat-(averageBeat*0.5)));
    
    limLower = floor(Fs*0.06);
    limUpper = round(Fs*0.1);
    fpPoints = beats(:,1);
    classifications = [];
    for i = 1:length(fpPoints)
        currFp = fpPoints(i);
        if currFp+limUpper <= length(fsig)
            currBeat = fsig(currFp-limLower:currFp+limUpper);
            currLabel = classifyBeat(currBeat, averageBeat, threshold);
            classifications = [classifications, currLabel];
        else
            currBeat = fsig(currFp-limLower:end);
            tempAverageBeat = averageBeat(1:length(currBeat));
            currLabel = classifyBeat(currBeat, tempAverageBeat, threshold);
            classifications = [classifications, currLabel];
        end
    end
end

function [averageBeat] = getAverageBeat(sig, beats, Fs)
    maxSample = Fs*300;
    fpPointsAll = beats(:,1);
    fpPointsAll = fpPointsAll(beats(:,2)==0);
    fpPoints = fpPointsAll(fpPointsAll<=maxSample);
    if isempty(fpPoints) % couldn't learn a representation of normal beat
        averageBeat = NaN;
        return
    end
    averageBeat = zeros(1,round(Fs*0.16));
    limLower = floor(Fs*0.06);
    limUpper = round(Fs*0.1);
    for i=1:length(fpPoints)
        currFp = fpPoints(i);
        currBeat = sig(currFp-limLower:currFp+limUpper);
        averageBeat = averageBeat + currBeat;
    end
    averageBeat = averageBeat ./ length(fpPoints);
end

function [class] = classifyBeat(currBeat, averageBeat, threshold)
    N = length(averageBeat);
    %dist = (1/N) * sum(abs(currBeat-averageBeat)); %d1
    %dist = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2); %d2
    dist = max(abs(currBeat-averageBeat)); %dInf
    if dist > threshold
        class = 1; % V
    else
        class = 0; % N
    end
end
