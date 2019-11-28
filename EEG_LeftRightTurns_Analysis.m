%&& We modified this script to be able to analyse the existing data from Position.txt to see how many turns there are and if we could use them as triggers

%---------------Compare Gaze Before Left and Right Turns------------------- 
%& Set the sourcepath and the values for IntervalLength and
%& TurnSignificance

sourcepath = 'D:\v.kakerbeck\Tracking\';
%path to tracking folder

IntervalLength = 10;
%Significant turn +_Interval Length = Interval of gazes counted for turn
%- defines how big the interval is in which we look for a signiticant turn
%- and how many gazes count as a turn
%- at 10, we would look if the rotation btw time step t-10 to timestep t
%- (t+10??) was significant and then count the gazes in these 10 frames as
%- gazes that were made during a turn

TurnSignificance = 20;
%amount of rotation degree change for something to classified as turn
%- In this case, something is classified as a turn, when it is 20 degrees (or more?)
%- sets by how many degrees the rotation at t-IntervalLength has to differ
%- from the rotation at t to count as a turn

%--------------------------------------------------------------------------

%%Load data
Condition = "VR"; %Options: VR, VR-belt,All
Repeated = false;%Options: true, false
%- here we set which condition we want to look at

%--------------------------------------------------------------------------
%& DELETED
%& In this section, we decide (depending on the chosen Condition) which
%& files we want to look at. This would correspond to EyesOnScreen.txt for
%& 'All' and to parts of Seahavenalignmentproject for 'NotAll'
%& so Shap should contain similar information to EyesOnScreen i.e.
%& information about the gaze
%& --> we don't need this section

%Analyze ------------------------------------------------------------------
%& 


%p length of files denotes how many files we look at
%p as a substitute, we could count all the files of 'type' Position.txt
%p in principle, this should also be equal in length to counting all the
%p files of 'type' EyesOnScreen.txt as in the deleted section

Number = length(files);
%- we need the length of an array files that was created in the deleted
%- section above.
%- 
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
    
    
    
    %& HERE it gets interesting for us: now we look at the rotation data
    %& saved in Positions.txt
    
    %& use a try catch block to open the files Position.txt of the VPs that
    %& we want and we specify that we only look at the X values (the very first value in each row)
    %& also we define rlen as an integer with the value length(rdata)/9
    
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
        %- Position.txt contains in each line: x,y,z,rx,ry,rz,timestamp
        %- (sec), PupiltimeStamp
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
        %- !!! rdata{1} will look at the first cell and according to the
        %- documentation of the textscan function, rdata{1} would hold all
        %- the first values of each row
        rdata = table2array(cell2table(rdata));
        %- Convert rdata from a cell to a table and from a table to an
        %- array
        rlen = int16(length(rdata)/9);
        %- rlen saved a 16-bit integer that corresponds to 1/9th of the length of
        %- rdata --> WHY 1/9??
        %- maybe a very complicated way to jump into the next cell/line?
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
    %- len does not have the same value as rlen!
    
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
        %- we're not sure why substracting the turns muse equal 1, but our
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







%& How to plot different things
%& Scatterplot showing the distribution of gazes -> DELETED
%& Heatmaps that show the distribution of gazes in different conditions ->
%& DELETED
%& T-test for the three heatmap distributions -> DELETED


%p We want: A map that shows us the turns
%p something like this can be found in PositionAnalysis (according to vkakerbeck's ScriptOverview)
%p it could be a nice idea to illustrate the turns using this