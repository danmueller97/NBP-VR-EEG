%--------------------------PositionAnalysis--------------------------------
% sourcepath = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
sourcepath = 'D:\CommonFolder\Seahaven_VR_EEG\SCRIPTS\Turning\';
%--------------------------------------------------------------------------
files = dir('positions_VP*.txt');%Analyzes all subjectfiles in your positions directory
Number = length(files);%length(PartList);
map = imread('map5.png'); 
map = imresize(map,[500 450]);
% image(map);
mapC = map;
lineLength = 50;

for ii = 1:Number
    %Read in map and positions
    suj_num = files(ii).name(13:16);
    data = fopen(files(ii).name);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
%     disp(data);
    data = table2array(cell2table(data));
    len = int64(length(data));
    %format and sort the raw data
    x = zeros(1,len);
    y = zeros(1,len);
    r = zeros(1,len);
    path = zeros(2,len);
    
    for a = 1:double(len) %-1 was here before, but it gives us a weird end value when using diff(r)later on
        line = textscan(data{a},'%s','delimiter', ',');
        line = line{1};
        % get single values in all lines
        x(a) = str2num(cell2mat(line(1)))-180;
        % why -180?
        y(a) = str2num(cell2mat(line(3)))-535;
        % we want the z values since we want to look at the data points in
        % the xz plain
        % why -535?
        r(a) = str2num(cell2mat(line(5)));
        %ry - what we actually want
        path(1,a)=x(a);
        % first row of path matrix is the x values
        path(2,a)=y(a);
        % second row of path matrix is the y values (=z)
    end
%     disp(path);
    
    derivR = abs(diff(r)*100);
    % r is rotation data matrix
    % diff(X) calculates differences between adjacent elements of X along the first array dimension whose size does not equal 1
    % looking at the data, the difference makes sense since it is very
    % small
    % *100 gives us what we would expect from /100 (0.04 turns to 0.0004)
    % oka so somehow if we simply display derivR, we get the weird 0.0004
    % values
    % but if we display it using a for-loop, we get the right 4.0000 values
%     for i=1:len-1
%         disp(derivR(i));
%     end
%     disp(derivR);
    
    for a = 1:double(len)-1
        color = derivR(a);
        % WTF
        % this now gives us the 4 we would actually expect from *100 
        % WTF
%         disp(color);
        map(int16(x(a)),int16(y(a)),1) = 0;
        % no path
        map(int16(x(a)),int16(y(a)),2) = color*3;
        map(int16(x(a)),int16(y(a)),3) = color*10; %draw line colored by change in rotation (light blue = much change)
    end
%     image(map);
    
    %-----------------------Individual North-------------------------------
    n=length(r)-1;
    angle = r(n);
    xp(1) = y(n); yp(1) = x(n);
    xp(2) = xp(1) + lineLength * cosd(angle);
    yp(2) = yp(1) + lineLength * sind(angle);
    north={xp,yp,angle}; %save x and y of line + rotation of player
    
    %-----------------------------Save-------------------------------------
    current_name = strcat(sourcepath,'Position/','Map_','VP_',num2str(suj_num),'.mat');
    save(current_name,'map')
    current_name = strcat(sourcepath,'Position/','North_','VP_',num2str(suj_num),'.mat');
    save(current_name,'north')
    current_name = strcat(sourcepath,'Position/','Path_','VP_',num2str(suj_num),'.mat');
    save(current_name,'path')
end

clear all;