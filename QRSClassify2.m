function [classifications] = QRSClassify2(record, beats, Fs)
    signalFileName = sprintf("%sm.mat", record);
    S = load(signalFileName);
    sig = S.val(1,:);
    Fc = 2;
    fsig = HPFilter(sig, Fc, 1/Fs);

    [averageBeat, threshold] =  getAverageBeat(fsig, beats, Fs);
    % for majority voting
    % [averageBeat, thresholds] = getAverageBeatMV(fsig, beats, Fs); 
    if isnan(averageBeat)
        classifications = NaN;
        return
    end

    limLower = floor(Fs*0.06);
    limUpper = round(Fs*0.1);
    fpPoints = beats(:,1);
    classifications = [];
    for i = 1:length(fpPoints)
        currFp = fpPoints(i);
        if currFp+limUpper <= length(fsig)
            currBeat = fsig(currFp-limLower:currFp+limUpper);
            % for static threshold
            %currLabel = classifyBeat(currBeat, averageBeat, threshold);
            % for adaptive threshold
            [currLabel, threshold] = classifyBeatAdaptiveT(currBeat, averageBeat, threshold);
            % for majority voting
            %[currLabel, thresholds] = classifyBeatMVAdaptiveT(currBeat, averageBeat, thresholds);
            classifications = [classifications, currLabel];
        else
            currBeat = fsig(currFp-limLower:end);
            tempAverageBeat = averageBeat(1:length(currBeat));
            % for static threshold
            %currLabel = classifyBeat(currBeat, tempAverageBeat, threshold);
            % for adaptive threshold
            [currLabel, threshold] = classifyBeatAdaptiveT(currBeat, tempAverageBeat, threshold);
            % for majority voting
            %[currLabel, thresholds] = classifyBeatMVAdaptiveT(currBeat, tempAverageBeat, thresholds);
            classifications = [classifications, currLabel];
        end
    end
end

function [averageBeat, threshold] = getAverageBeat(sig, beats, Fs)
    maxSample = Fs*300;
    fpPointsAll = beats(:,1);
    fpPointsAll = fpPointsAll(beats(:,2)==0);
    fpPoints = fpPointsAll(fpPointsAll<=maxSample);
    if isempty(fpPoints) % couldn't learn a representation of normal beat
        averageBeat = NaN;
        threshold = NaN;
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

    threshold = 0;
    N = length(averageBeat);
    for i=1:length(fpPoints)
        currFp = fpPoints(i);
        currBeat = sig(currFp-limLower:currFp+limUpper);
        % currDist = (1/N) * sum(abs(currBeat-averageBeat)); %d1
        currDist = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2); %d2
        % currDist =  max(abs(currBeat-averageBeat)); %dInf
        threshold = threshold + currDist;
    end
    threshold = threshold / length(fpPoints);
    % Best threshold multiplicators:
    % 2.5 for d1, 2.5 for d2, 2.2 for dInf
    threshold = threshold * 2.5;
end


function [class] = classifyBeat(currBeat, averageBeat, threshold)
    N = length(averageBeat);
    dist = (1/N) * sum(abs(currBeat-averageBeat)); %d1
    % dist = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2); %d2
    % dist = max(abs(currBeat-averageBeat)); %dInf
    if dist > threshold
        class = 1; % V
    else
        class = 0; % N
    end
end

function [class, newThreshold] = classifyBeatAdaptiveT(currBeat, averageBeat, threshold)
    N = length(averageBeat);
    % dist = (1/N) * sum(abs(currBeat-averageBeat)); %d1
    dist = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2); %d2
    % dist = max(abs(currBeat-averageBeat)); %dInf
    % for d1 and d2 best alpha: 0.005, for dInf best alpha 0.0005
    alpha = 0.005;
    if dist > threshold
        class = 1; % V
        newThreshold = threshold;
    else
        class = 0; % N
        % 2.5 for d1, 2.5 for d2, 2.2 for dInf
        newThreshold = alpha*2.5*dist + (1-alpha)*threshold;
    end
end


% FUNCTIONS FOR MAJORITY VOTING
function [averageBeat, thresholds] = getAverageBeatMV(sig, beats, Fs)
    maxSample = Fs*300;
    fpPointsAll = beats(:,1);
    fpPointsAll = fpPointsAll(beats(:,2)==0);
    fpPoints = fpPointsAll(fpPointsAll<=maxSample);
    if isempty(fpPoints) % couldn't learn a representation of normal beat
        averageBeat = NaN;
        thresholds = NaN;
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

    thresholds = [0,0,0];
    N = length(averageBeat);
    for i=1:length(fpPoints)
        currFp = fpPoints(i);
        currBeat = sig(currFp-limLower:currFp+limUpper);
        currDist1 = (1/N) * sum(abs(currBeat-averageBeat)); %d1
        currDist2 = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2); %d2
        currDist3 =  max(abs(currBeat-averageBeat)); %dInf
        thresholds = thresholds + [currDist1, currDist2, currDist3];
    end
    thresholds = thresholds / length(fpPoints);
    % Best threshold multiplicators:
    % 2.5 for d1, 2.5 for d2, 2.2 for dInf
    thresholds = thresholds .* [2.5, 2.5, 2.2];
end

function [class, newThresholds] = classifyBeatMVAdaptiveT(currBeat, averageBeat, thresholds)
    N = length(averageBeat);
    dist1 = (1/N) * sum(abs(currBeat-averageBeat)); %d1
    dist2 = sqrt((1/N)*sum(abs(currBeat-averageBeat)).^2); %d2
    dist3 = max(abs(currBeat-averageBeat)); %dInf
    distances = [dist1, dist2, dist3];
    voteResult = sum(distances>thresholds);
    
    alpha = 0.0001;
    if voteResult >= 2 
        class = 1;
        newThresholds = thresholds;
    else
        class = 0;
        newThresholds = [alpha*2.5*dist1+(1-alpha)*thresholds(1),...
            alpha*2.5*dist1+(1-alpha)*thresholds(2), alpha*2.2*dist1+(1-alpha)*thresholds(3)];
    end
end
