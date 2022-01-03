function [classifications] = QRSClassify(record, beats, Fs)
    signalFileName = sprintf("%sm.mat", record);
    S = load(signalFileName);
    sig = S.val(1,:);
    Fc = 2;
    fsig = HPFilter(sig, Fc, 1/Fs);

    averageBeat =  getAverageBeat(fsig ,beats, Fs);
    plot(averageBeat); hold on; plot(averageBeat .* 0.5);
    limLower = floor(Fs*0.06);
    limUpper = round(Fs*0.1);
    fpPoints = beats(:,1);
    classifications = [];
    for i = 1:length(fpPoints)
        currFp = fpPoints(i);
        if currFp+limUpper <= length(fsig)
            currBeat = fsig(currFp-limLower:currFp+limUpper);
            currLabel = classifyBeat(currBeat, averageBeat);
            classifications = [classifications, currLabel];
        else
            currBeat = fsig(currFp-limLower:end);
            tempAverageBeat = averageBeat(1:length(currBeat));
            currLabel = classifyBeat(currBeat, tempAverageBeat);
            classifications = [classifications, currLabel];
        end
        break
    end
end

function [averageBeat] = getAverageBeat(sig, beats, Fs)
    maxSample = Fs*300;
    fpPointsAll = beats(:,1);
    fpPoints = fpPointsAll(fpPointsAll<=maxSample);
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

function [class] = classifyBeat(currBeat, averageBeat)
    %plot(averageBeat); hold on; plot(currBeat);
    N = length(averageBeat);
    d1 = (1/N) * sum(abs(currBeat-averageBeat));
    disp(d1);
    d2 = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2);
    dInf = max(abs(currBeat-averageBeat));
    if d1 >= 24
        class = 1;
    else
        class = 0;
    end
end
