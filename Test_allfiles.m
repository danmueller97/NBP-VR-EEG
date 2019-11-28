% sourcepath = 'D:\v.kakerbeck\Tracking\Position\';
sourcepath = 'D:\CommonFolder\Seahaven_VR_EEG\SCRIPTS\Turning\';

IntervalLength = 60;
TurnSignificance = 20;

files = dir(strcat(sourcepath,'positions_VP*.txt'));

numberOfFiles = length(files);
tt_allfiles = 0;
average = 0;

for file=1:numberOfFiles
    % read each file ------------------------------------------------------
    suj_num = files(file).name(13:16);
    fprintf('Currently in file number %d \n',file);
    try
        rdata = fopen((strcat(sourcepath,'positions_VP',suj_num,'.txt')));
        rdata = textscan(rdata,'%s','delimiter', '\n');
        rdata = rdata{1};
        rdata = table2array(cell2table(rdata));
        rlength = length(rdata);
    catch
        disp('error');
    end
    r = zeros(1, rlength);
    
    % read each line ------------------------------------------------------
    
    for i = 1:double(rlength)-1
        line_r = textscan(rdata{i},'%s','delimiter', ',');
        line_r = line_r{1};
        r(i) = str2num(cell2mat(line_r(5)));
    end
    
    % look for significant turns in each line -----------------------------
    
    turnsright = [];
    turnsleft = [];
    trueturnright = [];
    trueturnleft = [];
    counter_right = 0;
    counter_left = 0;
    
    for a = IntervalLength+1:double(rlength-1)
        rotation = r(a)-r(a-IntervalLength);
        
        if rotation > 180
            rotation = 360 - rotation;
        end
        
        if rotation < -180
            rotation = 360 + rotation;
        end
        
        if rotation > TurnSignificance
            turnsright(end+1) = a-IntervalLength;
            trueturnright(end+1) = rotation;
            counter_right = counter_right + 1;
        end
        
        if rotation < -TurnSignificance
            turnsleft(end+1) = a-IntervalLength;
            trueturnleft(end+1) = rotation;
            counter_left = counter_left + 1;
        end
    end
%     fprintf('We have %d right turns \n',counter_right);
%     fprintf('And %d left turns \n',counter_left);
    
    
    counter_all = counter_right + counter_left;
    fprintf('Which gives us a total of --> %d turns \n',counter_all);
    
    %take out multiple detections of same turn --------------------------------
    
    for i=length(turnsright):-1:2
        if turnsright(i)-turnsright(i-1)==1
            turnsright(i)=0;
            trueturnright(i)=0;
        end
    end
    turnsright = turnsright(turnsright~=0);
    trueturnright = trueturnright(trueturnright~=0);
%     fprintf('Length of turnsright: %d\n', length(turnsright));
%     fprintf('Length of trueturnright: %d\n', length(trueturnright));

    
    for i = length(turnsleft):-1:2
        if turnsleft(i)-turnsleft(i-1)==1
            turnsleft(i)=0;
            trueturnleft(i)=0;
        end
    end
    turnsleft = turnsleft(turnsleft~=0);
    trueturnleft=trueturnleft(trueturnleft~=0);
    %     fprintf('Length of turnsleft: %d\n', length(turnsleft));
    %     fprintf('Length of trueturnleft: %d\n', length(trueturnleft));
    
    counter_all_cut = length(turnsleft) + length(turnsright);
    disp("-------- Total number of significant turns in this file: " + counter_all_cut);
    
    tt_allfiles = tt_allfiles + counter_all_cut;
    fprintf('Total number of significant turns in all %d files is: %d\n',numberOfFiles,tt_allfiles);
end

% Take average for one file -------------------------------------------


average = int16(tt_allfiles/numberOfFiles);
% fprintf('tt_allfiles: %d \n numberOfFiles: %d \n', tt_allfiles, numberOfFiles);
fprintf('The average number of turns in a single file is: %d \n\n',average);
