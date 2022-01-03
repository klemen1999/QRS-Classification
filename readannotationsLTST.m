function [beats, count] = readannotations(file)
  % example use which returns table and number of heart beats
  % [beats, count] = readannotations('s20011.txt');
  
  % file must contain the full filename of the text file that was created
  % using rdann (e.g. rdann -r s20011 -a atr -p N V >s20011.txt)
  beats = []; count = 0;
  
  fid = fopen(file);
  
  while (~feof(file))
    count = count + 1;
    line = fgetl(file);
    z = textscan(line, '[%s %s] %d %s %d %d %d');

    idx = z(3){1};        % extract the sample index
    if (strcmp(z(4),'N')) 
      typ = 0;            % normal (N) heart beats will be returned as 0
    else 
      typ = 1;            % PVC (V) heart beats will be returned as 1
    end;
    
    % add row to heart beat matrix that will be returned
    beats = [beats; [idx,typ]];    
  end
  
  % close the input file
  fclose(file);
end
