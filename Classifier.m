function Classifier(record)
    t=cputime();

    annotationsFileName = sprintf("%s.txt", record);
    [beats, count] = readannotationsMITBIH(annotationsFileName);

    Fs = 360; % 250 for LTST, 360 for MIT-BIH
    % classificatior using 1. strategy for initial threshold
    % classifications = QRSClassify1(record, beats, Fs);
    % classificatior using 2. strategy for initial threshold
    classifications = QRSClassify2(record, beats, Fs);
    
    fprintf('Running time: %f\n', cputime() - t);

    if isnan(classifications)
        fprintf("Skip this record %s\n", record);
    end

    asciName = sprintf('%s.cls',record);
    fid = fopen(asciName, 'wt');
    for i=1:size(beats,1)
        if isnan(classifications)
            % don't use this record for comparison because no normal beat
            % in learning process
            fprintf(fid,'0:00:00.00 %d X 0 0 0\n', beats(i,1)); 
        elseif classifications(i) == 0
            fprintf(fid,'0:00:00.00 %d N 0 0 0\n', beats(i,1));
        else
            fprintf(fid,'0:00:00.00 %d V 0 0 0\n', beats(i,1));
        end
    end
    fclose(fid);
    
end

