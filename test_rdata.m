file = 'D:\v.kakerbeck\Tracking\Position\positions_VP1002.txt';
IntervalLength = 33;
% originally 10
TurnSignificance = 60;
% previously 20

try
    rdata = fopen(file);
%     disp(rdata);
    rdata = textscan(rdata,'%s','delimiter', '\n');
    rdata = rdata{1};
    rdata = table2array(cell2table(rdata));
%     disp(rdata);
    %rlen = int16(length(rdata)/9);
    rlength = length(rdata);
    % made this as a replacement for len(data) in the next loop
catch
    disp('error');
end
%Original: r = zeros(1,rlen);
r = zeros(1, rlength);
% there seems to be no difference in the amount of turns found if we use
% this instead of the original with rlen
% Since we don't understand the purpose of rlen, we decided to use this
% instead
% maybe this will change after talking to Viviane about our questions

for a = 1:double(rlength)-1
% are we allowed to just exchange len to rlength here??
    %disp(a);
    line_r = textscan(rdata{a},'%s','delimiter', ',');
    line_r = line_r{1};
    %disp(line_r);
    %disp(line_r(4));
    r(a) = str2num(cell2mat(line_r(5)));
    %disp(r(a));
    %disp(class(r(a)));
end

%disp(rdata);
%disp(class(rdata));
%disp(rlen);
%rlen is 229
%disp(r);
% disp('R an der Stelle a minus interval ');
% disp(r(11177));
% % disp(r(7659));
% disp('R an der Stelle a  ');
% disp(r(11210));

%look for significant turns--------------------------------------------

turnsright = [];
turnsleft = [];
% in turnright and turnsleft we only save the indices of our turns
% so we added truetunright/left to save the value of the rotations
trueturnright = [];
trueturnleft = [];
counter_right = 0;
counter_left = 0;
count = 0;

for a = IntervalLength+1:double(rlength -1)
% a starts at 11 and goes until rlen = 229
rotation = r(a)-r(a-IntervalLength);
% Check if the turn is only significant because we are comparing a 350+
% degree angle with an angle around 5 or less.
% To control for these cases, we substract the rotation from a full 360
% degrees and then check for significance with the resulting value
    if rotation > 180
%         disp("Original turn:" + rotation);
%         disp("r(a)" + r(a));
%         disp("10 davor: " + r(a-IntervalLength));
        rotation = 360 - rotation;
        %rotation = abs(rotation); we need this if we calculate rotation -
        %360, but with 360 - rotation we don't need it
    end
    
    % we need to do this as well to correct for "bad" left turns
    if rotation < -180
        rotation = 360 + rotation;
    end
    

%     if rotation > 60 || rotation <-60
%         disp("Turn:" + rotation);
%         count = count +1;
%         fprintf('We have %d turns over 60 \n',count);
%     end
    
    if rotation > TurnSignificance
        %disp("Turn if rightturn: " + rotation);
        turnsright(end+1) = a-IntervalLength;
        % we fill turnsright with the indeces of the start of each turn we
        % find
        trueturnright(end+1) = rotation;
        %disp("Values in true turn right: " + trueturnright);
        counter_right = counter_right + 1;
        % increment counter with each found turn
    end
    
    if rotation < -TurnSignificance 
       %disp("a " + r(a));
       %disp("a-10 " + r(a-IntervalLength));
       %disp("Turn if leftturn: " + rotation);
       
       turnsleft(end+1) = a-IntervalLength;
       trueturnleft(end+1) = rotation;
       %disp("Values in true turn left: " + trueturnleft);

       counter_left = counter_left + 1;
    end   
end
counter_all = counter_right + counter_left;
% disp("Right "+counter_right);
% disp("Left "+counter_left); 


%take out multiple detections of same turn-----------------------------
% fprintf('TTR: %d',trueturnright>60);

for i=length(turnsright):-1:2
% for index = start_value : increment_value : end_value -> von hinten nach
% vorne durchgehen
   if turnsright(i)-turnsright(i-1)==1
   % if two saved indices belong to the same turn 
       % Also just change trueturn at this index
       turnsright(i)=0;
       trueturnright(i)=0;
       % get ready to be deleted
   end
end
turnsright = turnsright(turnsright~=0);
trueturnright = trueturnright(trueturnright~=0);
% fprintf('TR: %d \n', length(turnsright));
% fprintf('TTR: %d \n', length(trueturnright));


for i = length(turnsleft):-1:2
    if turnsleft(i)-turnsleft(i-1)==1
%        disp(turnsleft(i));
%        disp(turnsleft(i-1));
       turnsleft(i)=0;
       trueturnleft(i)=0;
    end
end
turnsleft = turnsleft(turnsleft~=0);
trueturnleft=trueturnleft(trueturnleft~=0);
% fprintf('TL: %d \n', length(turnsleft));
% fprintf('TTL: %d \n', length(trueturnleft));

% if trueturnleft<-60
%     disp("Left ueber 60");
%     disp("Index of true turn over 60"+turnsleft);
% end

count_cut = 0;
count_cut_r = 0;
count_cut_l = 0;

% 
for i=length(trueturnright):-1:1
    if trueturnright(i)>60
        count_cut = count_cut+1;
        count_cut_r= count_cut_r+1;
        fprintf('At index: %d                   We find rotation value: %d \n', i, trueturnright(i));
        %         fprintf('We have %d rightturns over 60 after cut\n',count_cut);
    end    
end
% fprintf('We found %d right turns \n', count_cut_r);

for i=length(trueturnleft):-1:1
   if trueturnleft(i)<-60
        count_cut = count_cut+1;
        count_cut_l = count_cut_l+1;
        fprintf('At index: %d                   We find rotation value: %d \n', i, trueturnleft(i));

   end 
%     fprintf('We have %d left turns over 60 after cut\n',count_cut);

end
% fprintf('We found %d left turns \n', count_cut_l);

fprintf('We have %d total turns over 60 after cut \n',count_cut);

% if rotation > 60 || rotation <-60
%     disp("Turn:" + rotation);
%     count = count +1;
%     fprintf('We have %d turns over 60 \n',count);
% end

% disp(trueturnright>60);
% fprintf('TTR: %d',trueturnright>60);

counter_all_cut = length(turnsleft) + length(turnsright);
disp("-------- Total number of significant turns: " + counter_all_cut);

%----------------------------------------------------------------------------

% rdata{1} has all the lines in the file, but each line is saved as
% a separate string

% table2array(cell2table) shows no immediate difference to what we saved in rdata{1}
% but we suspect that now it is saved in an array 
% BUT running class(rdata) says that it is still in the form of a cell

% rlen correcsponds to the number of lines in the file divided by 9 and
% rounded to an integer value
% We don't change the values in rdata at all. We only divide the file
% length by 9

% a goes from 1 to 2061 which is the length of rdata-1
% line_r goes through 3every single line in r, each of them being a 8x1
% cell

% line_r{1} contains the values of each line in our file. The values are all
% saved as individual strings stacked vertically in one cell 
 
% line_r(4) represents the rotated-xvalues in our 8-tuple which first have
% the class cell

% str2num cell2mat made the values at (4), so the rx-values into doubles

% Another possibility to control for the 360 - 0.5 jump situation:
%         if (r(a)>350 && r(a-IntervalLength)<10)
%             %disp('Nope');
%         end
%         if (r(a)<350 && r(a-IntervalLength)>10)
%             %disp('SIGNIFICANT');
%             turnsright(end+1) = a-IntervalLength;
%         end
