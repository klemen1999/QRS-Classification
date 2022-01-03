function Classifier(record)
    t=cputime();

    annotationsFileName = sprintf("%s.txt", record);
    [beats, count] = readannotationsMITBIH(annotationsFileName);

    Fs = 360; % 250 for LTST, 360 for MIT-BIH
    classifications = QRSClassify(record, beats, Fs);

    fprintf('Running time: %f\n', cputime() - t);
    
    asciName = sprintf('%s.cls',record);
    fid = fopen(asciName, 'wt');
    for i=1:length(beats)
        if classifications(i) == 0
            fprintf(fid,'0:00:00.00 %d N 0 0 0\n', beats(i,1));
        else
            fprintf(fid,'0:00:00.00 %d V 0 0 0\n', beats(i,1));
        end
    end
    fclose(fid);
end

