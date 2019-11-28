#Turning in Seahaven

Here you will find the crucial Seahaven scripts that we want to use to define a turn.

##LeftRightTurns
There are 4 versions of LeftRightTurns:
###LeftRightTurns
The original script which was developed by V. Clay in 2017
Input: positions_VP*.txt
       EyesOnScreen_VP*.txt
Output: 1 Scatter Plot and 3 Heat maps

###EEG_LeftRightTurns_CommentedCopy
The script after Carla and Daniel commented it in order to understand it.
Input: positions_VP*.txt
       EyesOnScreen_VP*.txt
Output: 1 Scatter Plot and 3 Heat maps

###EEG_LeftRightTurns_Analysis
The script that will be used for reading out, where a head turn was performed
Input: positions_VP*.txt
Output: none yet

###test_rdata
The script which we use to go through the data sets acquired so far to see how many turns are performed
Input: positions_VP*.txt
none yet (should output an array with number of turns for different TurnSignificance and IntervalLength)

##PositionAnalysis
there are 2 versions

###PositionAnalysis_original
Original by V.Clay(2017)
Input: positions_VP*.txt
Output: path_VP_*.mat
map_VP_*.mat
north_VP_*.mat

###PositionAnalysis_test
Version where we test how it works
Input: positions_VP*.txt
Output: path_VP_*.mat

##Analysis_Map
There are 2 versions:

###Analysis_Map_original
Original by V. Clay (2017)
Input: path_VP_*.mat
map_VP_*.mat
north_VP_*.mat
map5.png
Output: Map of Seahaven displaying in a colour-coded manner where people turned their heads the most

###Analysis_Map_commented
Commented version of the original, where Carla and Daniel tried to understand how it works
Input: path_VP_*.mat
map_VP_*.mat
north_VP_*.mat
map5.png
Output: Map of Seahaven displaying in a colour-coded manner where people turned their heads the most


#Next up:
Combine PositionAnalysis_test and Analysis_Map in such a way that we get the triangulated trajectories
Edit EEG_LeftRightTurns_Analysis in such a way that we get a file which can be applied to the XDF-data
