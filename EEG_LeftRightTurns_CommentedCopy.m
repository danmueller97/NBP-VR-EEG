%---------------Compare Gaze Before Left and Right Turns------------------- 

sourcepath = 'D:\v.kakerbeck\Tracking\';%path to tracking folder
%- previously 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\' --> we
%- were not able to find this folder on the PC, but in our opinion the path
%- now should be the corresponding path leading to the files we want
%- HOWEVER: We can't find the equivalent for Shap.ALotOfStuff :(
IntervalLength = 10;%Significant turn +_Interval Length = Interval of gazes counted for turn
%- defines how big the interval is in which we look for a signiticant turn
%- and how many gazes count as a turn
%- at 10, we would look if the rotation btw time step t-10 to timestep t
%- (t+10??) was significant and then count the gazes in these 10 frames as
%- gazes that were made during a turn
TurnSignificance = 20;%amount of rotation degree change for something to classified as turn
%- In this case, something is classified as a turn, when it is 20 degrees (or more?)
%- sets by how many degrees the rotation at t-IntervalLength has to differ
%- from the rotation at t to count as a turn

%--------------------------------------------------------------------------

%%Load data
Condition = "VR"; %Options: VR, VR-belt,All
Repeated = false;%Options: true, false
%- here we set which condition we want to look at

%--------------------------------------------------------------------------

files = [];
if Condition ~= "All"
%- ~= should be equal to != so means not
    for line = 1:height(Seahavenalingmentproject)
    %- goes through each line in Seahavenalignmentproject => Shap, which btw we
    %- cannot find
        if lower(cellstr(Seahavenalingmentproject.Training(line)))==lower(Condition) && Seahavenalingmentproject.Discarded(line) ==""
        %- lower(): converts a string into lowercase
        %- cellstr(): converts a string array into a cell array of
        %- character vectors
        %- Two if-conditions must be true to get into this part:
        %- If-condition1: Whatever is written in Shap.Training in the current line of the forloop (starting with 1 until the full height of Shap) must be the same as our chosen Condition from Load data
        %- If-condition2: Nothing should be written in Shap.Discarded in
        %- the current line of the for loop.
        %- remaining Qs: What is Shap, Training, and Discarded?? Where? -->
        %- CHECK sourcepath on top of file, admin needed :(
        %- maybe at this point, we distinguish btw VR and VR-belt
        %- conditions, and check if anything has been discarded
            if Repeated == false && Seahavenalingmentproject.Measurement(line)==1
            %- if we got into the first if-condition, we check if:
            %- If-condition1: Not a repeated measurement - written in load
            %- data section
            %- If-condition2: At the position (line) in shap.measurement we
            %- need a 1
                files = [files, Seahavenalingmentproject.Subject(line)];
                %- fill 'files' recursively with Shap.Subject at the
                %- position (line)
                %- 'Add' the content of Shap.Subject at (line) to the
                %- existing array files and its alreadz existing contents
                %- if could be that Shap.Subject only holds the relevant
                %- subjectnumber. This would make sense when we take the
                %- next section into account where we only check for the
                %- subjectnumber in Condition 'All' and files in the other
                %- Conditions seems to only hold the subjectnumber already
            end
            if Repeated == true && Seahavenalingmentproject.Measurement(line)==3
            %- if we got into the first if-condition, we check if:
            %- If-Condition1: this is a repeated measurement
            %- If-Condition2: at the position (line) in sha0p.measurement
            %- we need a 3
                str = char(Seahavenalingmentproject.Comments(line));
                %- str => name convention for string
                %- char(): transposes integers according to the ASCII code into a character array
                %- str is a character array filled with what is written in
                %- Shap.Comments at (line)
                i = strfind(Seahavenalingmentproject.Comments(line),'#');
                %- strfind(): finds in the file Shap.comments(line) how many occurences of the char '#' there are. 
                %- it returns the index of each occurence in a cell array
                %- of vectors of type double
                Mes = [str2num(str(i(1)+1:i(1)+4));str2num(str(i(2)+1:i(2)+4));(Seahavenalingmentproject.Subject(line))];
                %- str2num() converts a char-array or string scalar to a
                %- numeric matrix = array. 
                
                %- Now we go through str
                %- since we do +1, we start after the occurance of '#'
                %- since we do +4, we might be expecting something that has
                %- a length of 4 (or 3 depending on calculations)
                
                %- so, in the first array within Mes, we look at what is
                %- written up to 4 spaces after the first occurence of # in
                %- Shap.Comments at (line)
                
                %- after that we use str2num function to transfer those string scalars to numeric matrices 
                %- -> this is the first line in the Mes-Array
                
                %- Then we do the same thing for what is written after the
                %second '#' in str, whose position we saved in i(2)
                
                %- in the 3rd line of Mes, Shap.Subject(line) is written
                
                files = [files, Mes];
                %- recursively Mes is written to files
                %- Why do we put Mes in files?
                
            end
        end
    end
else
%- if Condition == 'All':
    files = dir('EyesOnScreen_VP*.txt');%Analyzes all subjectfiles in your ViewedHouses directory
    %- fill files with the content of the folder EyesOnScreen_VP*
    %- * typically means all, so maybe all different VPs that are saved in
    %- the directory?
    %- found D:\v.kakerbeck\Tracking\EyesOnScreen 
end

%Analyze ------------------------------------------------------------------

Number = length(files);
%- create Number and set it to the length of our array files which we have
%- filled in the sction above this
rightpX = [];rightpY = [];
leftpX = [];leftpY = [];
normpX = [];normpY = [];
%- create a bunch of empty arrays
%- if we are right that we look at ET data, these might refer to:
%- X and Y coordinates of right eye, X/Y of left eye, and the mean of both 
for ii = 1:Number
%- for loop over index-variable ii which goes from 1 to Number (= length of files)
    if Condition == "All"
    %- if we are looking at All conditions (so no distinction btw VR/VR-belt)
        suj_num = files(ii).name(16:19);
        %- we initiate a variable suj_num and fill it with what we find at
        %- this position in the files array 
        %- If what we write into files is of the type File (which should be the case logically, but I can't find it explicitly in the code)
        %- then .name could refer to the name of the File (w/o the extension)
        %- in this case, name(16:19) would correspond to
        %- EyesOnScreen_VP1 >>>234.<<< txt --> HOWEVER, if we start counting at 1 instead of 0 if would correspond to
        %- EyesOnScreen_VP >>>1234<<< .txt, which would make sense as
        %- something that you write in a variable called suj_num
        %- Stackoverflow says matlab has 1-based indexing, so this may not
        %- be that far off!
    else
    %- if we are not looking at All condition --> i.e. we care about either
    %- the VR conditon or the VR-belt condition
        suj_num = files(ii);
        %- the subjectnumber is already saved in files at position (ii) 
        %- so in the section above, in the condition VR & not repeated f.e.
        %- we only add Seahavenalingmentproject.Subject(line) to [files]
    end
    %- ends with the checking of the Condition, but we're still within the
    %- for loop
    
    disp(suj_num);
    %- disp(X): displays an array X w/o printing the array name or 
    %- additional description information such as the size and class name
    %- we with this, we display the contents of suj_num --> theoretically,
    %- would this only be one subjectnumber per for-loop iteration, or
    %- would there be several subjectnumbers within suj_num?
    turnsright = [];
    turnsleft = [];
    rightI = [];
    leftI = [];
    %- create empty arrays for turing right or left and for rightI/leftI (whatever that may be?)
    data = fopen(['EyesOnScreen_VP' suj_num,'.txt']);
    %- fopen(FILENAME): opens the file FILENAME for read access
    %- fill a field called data with whatever you get when you open the
    %- EyesOnScreen_VP with the corresponding suj_num from this for-loop
    %- iteration
    data = textscan(data,'%s','delimiter', '\n'); 
    %- C = textscan(FID,'FORMAT','PARAM',VALUE) accepts one or more comma-separated
    %- parameter name/value pairs. For a list of parameters and values, see "Parameter
    %- Options."
    %- FID is fileID, so the file we are looking at, which is data
    %- 'FORMAT' is a typespecifier: %s denotes Text: Returns text array containing the data up to the next delimiter, or end-of-line character
    %- We specify the delimiter as \n, which is a paragraph
    %- So we use textscan to go through what is written in data and order
    %- its contents
    data = data{1};
    %- we look at the cell array at position 1 in data
    %- does this correspond to the first pair of coordinates in the file??
    data = table2array(cell2table(data));
    %- cell2table(): converts a cell array into a table
    %- So first we make data into a table
    %- table2array(): converts a table into a homogenous array
    %- And then we make this table of data into an array and save it in
    %- data
    len = int16(length(data));
    %- make a new variable len
    %- in len we save the length of the array data as a 16-bit integer
    %- value
    X = zeros(1,len);
    %- In X we write as many 0s as the length of data which we saved in len
    %- would give us a one dimensional matrix looking like (0 0 0 0 0 0)
    Y = zeros(1,len);
    %- In Y we write as many 0s as len
    %- would give us a one dimensional matrix looking like (0 0 0 0 0 0)
    
    %cut out certain part
    try
        %- rdata might refer to the rotationdata we get from the Position
        %- files
        rdata = fopen(strcat(sourcepath,'Position\positions_VP',suj_num,'.txt'));
        %- strcat(): Concatenates strings horizontally --> here we get a
        %- sourcepath of '...\Position\positions_VP1234.txt'
        %- the variable sourcepath itself is set at the very top of the
        %- program
        %- open this file in rdata by using fopen
        rdata = textscan(rdata,'%s','delimiter', '\n');
        %- C = textscan(fileID,formatSpec) reads data from an open text file into a cell array, C.
        %- The text file is indicated by the file identifier, fileID. Use
        %- fopen to open the file and obtain the fileID value -> in our case: saved in
        %- previous instance of rdata
        %- textscan attempts to match the data in the file to the conversion specifier in formatSpec.
        %- fromatSpec: Format of the data fields, specified as a character vector or a string of one or more conversion specifiers. 
        %- The number of conversion specifiers determines the number of cells in output array, C
        %- Since we only have %s as a conversion specifier, our output cell
        %- array will only have one cell
        %- Conversion specifier %s has the input type of a text array,
        %- which makes sense since we are working with a .txt file
        %- %s Reads the text array as a cell array of character vectors.
        %- 'delimiter', '\n' is an extra name and value pair with which we
        %- tell the function to treat \n as a delimiter.
        %- A delimiter is a sequence of one or more characters for specifying the boundary between separate, independent regions in plain text or other data streams.
        
        %- --> We use textscan to go through what is written in rdata and order
        %- its contents
        %- more in detail, see above when we do the same for data
        rdata = rdata{1};
        %- we look at the cell array at position 1 in data
        %- does this correspond to the first 8-tuple of data in the file??
        %- --> we think this should be the case
        rdata = table2array(cell2table(rdata));
        %- Convert rdata from a cell to a table and from a table to an
        %- array
        rlen = int16(length(rdata)/9);
        %- rlen saved a 16-bit integer that corresponds to 1/9th of the length of
        %- rdata --> WHY 1/9??
    catch
    %- if an error is thrown, catch it and:
        continue
        %- passes control to next iteration of the for-loop
    end
    %- end try-catch block
    r = zeros(1,rlen);
    %- zeros(M,N) or zeros([M,N]) is an M-by-N matrix of zeros.
    %- make and fill a vector called r with as many zeros as rlen
    %- 1-lined matrix (so a vector) filled with a bunch of zeros
    %- this should look like: (0 0 0 0 0 0 0 0) or so
    
    %extract rotation information------------------------------------------
    for a = 1:double(len)-1
    %- a used as counter to do the following from 1 to len (= the length of
    %- the array data) which is cast as a double(before it was saved as a 16-bit integer)
    %- and reduced by one
    %- we we go through 
        liner = textscan(rdata{a},'%s','delimiter', ',');liner = liner{1};
        %- We use textscan to go through each position of a in rdata.
        %- '%s' Reads up to w characters or to the next delimiter (seems to
        %- be ',' here). And as has been written above this all seems to be
        %- written into a large cell array. 
        %- afterwards, liner is set to its first entry of its cell array
        %- (Does that make sense tho?). As we are in a for loop, we do this
        %- a-times.
        r(a) = str2num(cell2mat(liner(4)));
        %- r is a variable which stores the 4th position of liner in each run of the loop in a
        %- numeric matrix. Probably the turning angle is written in
        %- liner(4), as we use it when looking for significant turns.
        %- Maybe it is also rx.
    end
    %clear rdata;
    
    %look for significant turns--------------------------------------------
    for a = IntervalLength+1:double(rlen)
    %- a is an index variable set from intervalLength (set to 10) +1 to
    %- the rlen which is type double. rlen is 1/9th of rdata 
        if r(a)-r(a-IntervalLength)>TurnSignificance
        %- if now r at the position a minus r at position a-IntervalLength [= a-10
        %- for now] is greater than TurnSignificance (=20)
            turnsright(end+1) = a-IntervalLength;
            %- then turnsright (which we have initialized as an empty array
            %- before) is, at the position after the last position, set to
            %- a-IntervalLength. --> Concatination
        end
        if r(a)-r(a-IntervalLength)<-TurnSignificance
        %- if it were the case that the result of r(a)-(a-IntervalLength)
        %- is smaller than the negative TurnSignificance (=-20),
            turnsleft(end+1) = a-IntervalLength;
            %- we'll add to the position after the last position of
            %- turnsleft, what a-IntervalLength is. 
        end
    end
    %take out multiple detections of same turn-----------------------------
    for i=length(turnsright):-1:2
    %- for index = start_value : increment_value : end_value
    %- use i to go through turnsright in steps of -1 until we reach 2
        if turnsright(i)-turnsright(i-1)==1
        %- if this is the same turn
        %- we're not sure why substracting the turns must equal 1, but our
        %- current guess is, that the 1 could represent one rotational
        %- degree difference.
        %- So basically we compare two neighbouring elements in turnright
        %- and if they only differ by one, the second turn is a
        %- continuation fo the first turn, so they actually denote the same
        %- turn
           turnsright(i)=0; 
           %- change what is written at position i of turnsright to zero
        end
    end
    
    for i = length(turnsleft):-1:2
    %- do the same thing as above with turnsleft
        if turnsleft(i)-turnsleft(i-1)==1
           turnsleft(i)=0; 
        end
    end
    turnsright = turnsright(turnsright~=0);%take multiple turns out of list
    %- take out what we have made 0 (since these are multiple turns) from
    %- the right turns
    turnsleft = turnsleft(turnsleft~=0);
    %- take out what we have made 0 (since these are multiple turns) from
    %- the left turns
    
    %define intervals------------------------------------------------------
    for e = 1:length(turnsright)
    %- define interval for right turns
        rightI = [rightI turnsright(e)-IntervalLength:turnsright(e)+IntervalLength];
        %- at the first use, rightI is still an empty array
        %- an empty space in an array separates two elements
        %- so the first element in rightI is what is already written in
        %- rightI (recursive)
        %- the other elements are filled with the values from what is
        %- written in turnsright at e - the previously defined IntervalLength
        %(=10) until what is what is written at e + the IntervalLength
        %- We don't understand why exactly we do this
        %- From our understanding, turnsright should contain numbers that
        %- represent the turning angle at which a turn was made. In how far
        %- does it help us to substract 10 from that number and go until 10
        %- more?
        %- ex.: if our turn was 60 degrees we save the numbers from 50
        %- until 70 - WHY?
    end
    for e = 1:length(turnsleft)
    %- do the same for the left turns
        leftI = [leftI turnsleft(e)-IntervalLength:turnsleft(e)+IntervalLength];
        %- same principle as above, same questions remain
    end
    
    %Sort view points into 3 categories------------------------------------
    for a = 1:len-1
    %- len is the length of data
    %- here we go from 1 until the length of data minus 1
       X(a) = str2double(data{a}(2:9));
       %- X is the zero matrix
       %- data at this point is an array
       %- smooth parenthesis help us to access certain elements in a cell
       %- of a cell array
       %- So first we access the a-th cell of data
       %- then we only actually look at the elements of the a-th cell of
       %- data at the positions 2 until 9
       %- and THEN we convert the string that is written there into a
       %- double by using str2double
       %- looking at the structure of the EyesOnScreen_VP1234.txt files:
       %- ex. of one line: (0.519614, 0.398645)
       %- somehow this is originally saved as a string (why?), but we need
       %- it as a number (specifically: double)
       %- so basically this would be what is written in data{a}
       %- At position 2 to 9 would be the actual number (position 1 is the parenthesis)
       %- --> So in X we save the first number of the pair in EyesOnScreen,
       %- which would correspond to the X-coordinate (wow this makes sense!)
       Y(a) = str2double(data{a}(12:19));
       %- We use the same technique to write the Y-coordinate in Y
    end
    %- so after this for loop we have filled X and Y with the corresponding
    %- coordinates of the eyes on the screen
    
    meanX = mean(X(X~=0));meanY = mean(Y(Y~=0));
    %- set the mean of X as the mean of X (function) for non-zero x's
    %- do the same for the mean of Y
    %X = X-meanX;Y = Y-meanY;
    X = X-0.5;Y = Y-0.5;
    %- Set X as X-0.5 and Y as Y-0.5
    %- 0.5 could represent the middle of a section
    %- by doing this, we will also have negative numbers
    X = X(abs(Y)<0.4);Y = Y(abs(Y)<0.4);
    %- only put those values in X that have an absolute value of Y smaller
    %- than 0.4
    %- only put those values in Y that have an absolute value of Y smaller
    %- than 0.4
    %- First we go through the Y values and check if any of them are faulty
    %- i.e. do not comply with our threshold -> if they are faulty, we do not
    %- take the corresponding X-value into our array
    %- after that we need to delete these entries in Y as well since we
    %- need two arrays that have the same length so that we can confidently
    %- assign the positions
    X = X(abs(X)<0.4);Y = Y(abs(X)<0.4);
    %- only put those values in X that have an absolute value of X smaller
    %- than 0.4
    %- only put those values in Y that have an absolute value of X smaller
    %- than 0.4
    %- so these two lines basically set borders as to how big/small X and Y
    %- values are that are of interest to us
    %- After we 'cleaned' the arrays regarding faulty Y-values, we do the
    %- same for faulty X-values by first deleting faulty values in X and then
    %- deleting these same values in Y
    len = int16(length(X));
    %- redefine len within the big for loop as the length of X, so how many
    %- X-coordinates are 'valid' after we performed our cut-off
    
    for a = 50:len-100 
    %- we go from 50 to the new len -100 - Why? Cutoff?
       if(X(a)~=0 &&X(a-1)~=0 &&Y(a)~=0 &&Y(a-1)~=0 &&X(a)>-0.5&&Y(a)>-0.5&&X(a)<0.5&&Y(a)<0.5)%cut out false/uncertain recordings
       %- in the cases that the current value is not 0, the previous value
       %- is not 0, for both X and Y values, and also the current and
       %- previous X and Y values are between -0.5 and 0.5, then these
       %- recordings are categorized as 'good' -> the recodrings that do not
       %- comply with this are categorized as false and will not be saved
           if ismember(a,rightI)
           %- ismember checks if the element a is contained in rightI, if
           %it is:
               rightpX(end+1) = X(a);rightpY(end+1) = Y(a);
               %- at first rightpX/Y are empty arrays
               %- make a new entry (at position end + 1)
               %- fill this entry with the X value at this position a
               %- do the same for Y
           elseif ismember(a,leftI)
           %- check if a is a member of leftI
               leftpX(end+1) = X(a);leftpY(end+1) = Y(a);
               %- add X value in a to leftpX same for Y
           else
           %- if the value of a is not false but cannot be found in either
           %- roghtI or leftI,
               normpX(end+1) = X(a);normpY(end+1) = Y(a);
               %- we add it to normpX/Y
           end
       end
    end
    fclose('all');
    %- close all opened files
end
%- ends the bigass for loop

scatter(normpX,normpY);hold;scatter(rightpX,rightpY);scatter(leftpX,leftpY);
[n,c] = hist3([normpX', normpY']);
contour(c{1},c{2},n',12,'-','LineWidth',2);colorbar;
legend('Standard','Right Turn','Left Turn');
title('Gaze During Left and Right Turns');
xlabel('X');ylabel('Y');
plot(mean(rightpX),mean(rightpY),'k.','MarkerSize',35)
plot(mean(rightpX),mean(rightpY),'r.','MarkerSize',30)
plot(mean(leftpX),mean(leftpY),'k.','MarkerSize',35)
plot(mean(leftpX),mean(leftpY),'y.','MarkerSize',30)
plot(mean(normpX),mean(normpY),'k.','MarkerSize',35)
plot(mean(normpX),mean(normpY),'b.','MarkerSize',30)
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeLeftRight' num2str(Number) 'SJs_' 'itv' num2str(IntervalLength) 'Tsig' num2str(TurnSignificance) '.jpeg']));
%- saves the plot 
%% Make Heatmaps-----------------------------------------------------------
size = 50;
HMNorm = hist3([[normpX -0.3 0.3]', [normpY -0.3 0.3]'],[size,size]);
HMNormN = HMNorm/norm(HMNorm);
HMRight = hist3([[rightpX -0.3 0.3]', [rightpY -0.3 0.3]'],[size,size]);
HMRightN = HMRight/norm(HMRight);
HMLeft = hist3([[leftpX -0.3 0.3]', [leftpY -0.3 0.3]'],[size,size]);
HMLeftN = HMLeft/norm(HMLeft);
figure;
subplot(2,2,1);hold;
title('Gaze During No Turn');
h=pcolor(HMNormN);colorbar;hold off;
set(h, 'EdgeColor', 'none');
subplot(2,2,3);hold;
title('Gaze During Right Turn');
h2=pcolor(HMRightN);colorbar;
set(h2, 'EdgeColor', 'none');
subplot(2,2,4);hold;
title('Gaze During Left Turn');
h3=pcolor(HMLeftN);colorbar;
set(h3, 'EdgeColor', 'none');
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['HeatMapLeftRight' num2str(Number) 'SJs_' 'itv' num2str(IntervalLength) 'Tsig' num2str(TurnSignificance) '.jpeg']));
%ttest the three distributions (left, right, normal)-----------------------
[hn pn] = ttest(normpX,0,'Alpha',0.01);
[hl pl] = ttest(leftpX,0,'Alpha',0.01);
[hr pr] = ttest(rightpX,0,'Alpha',0.01);
ttests = table([hn;pn],[hl;pl],[hr;pr]);
ttests.Properties.VariableNames = {'Normal','Left','Right'};
ttest.Properties.RowNames = {'Hypothesis Rejected','P-Value'};
save([sourcepath 'EyesOnScreen\Results\TTestLR' num2str(Number) 'SJs_' 'itv' num2str(IntervalLength) 'Tsig' num2str(TurnSignificance) '.mat'],'ttests');
clear all;