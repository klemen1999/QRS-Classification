function [beats, count] = readannotationsMITBIH(file)
  % example use which returns table and number of heart beats
  % [beats, count] = readannotations('100.txt');
  
  % file must contain the full filename of the text file that was created
  % using rdann (e.g. rdann -r 100 -a atr -p N V >100.txt)
  beats = []; count = 0;

  fid = fopen(file);

  while (~feof(fid))
    count = count + 1;
    line = fgetl(fid);
    z = textscan(line, '%s %d %s %d %d %d');
    temp = z(2);        % extract the sample index
    idx = temp{1};
    temp2 = z(3);
    type = temp2{1};
    if (strcmp(type,'N')) 
      typ = 0;            % normal (N) heart beats will be returned as 0
    else 
      typ = 1;            % PVC (V) heart beats will be returned as 1
    end
    
    % add row to heart beat matrix that will be returned
    beats = [beats; [idx,typ]];    
  end
  
  % close the input file
  fclose(fid);
end
