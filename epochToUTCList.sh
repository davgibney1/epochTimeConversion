#!/bin/bash

###############################
#epochToUTCList.sh
#blame gibney@
#
#Bash shell script that accepts one integer argument (unix epoch timestamp) and then prints out a list (27 lines) of human-readable datetime objects based on that argument, with UTC offsets from -12:00 to +14:00.

# limitations: requires at least a certain bash version. This was programmed and tested in the following version...: GNU bash, version 4.3.42(1)-release (x86_64-redhat-linux-gnu)


# ideas for future revision changes: 
# 1) if script is called without an argument, prompt for user input with read command
# 2) make script more configurable; let user choose how many UTC offsets to display. Currently, the assignment was to specifically have 27 values returned by the script, but it is bad practice to hard code a specific number like that into the conditional statements
# 3) package script into a .deb or .rpm, give it a GUI
# 4) revise script to use idioms from older bash versions, so that script can run on older versions of Linux
# 5) publish a wiki page to document the script, and link to it in Usage() function
###############################

# regex that matches integers, negative or positive
matchInts="^-?[0-9]+([0-9]+)?$"

# provide help usage (this also works if user calls script with '--help'
if ! [[ $1 && $1 =~ $matchInts ]]
	then
		echo "Usage: epochToUTCList.sh [ number ]"
		echo "Description: script needs to be called with an integer argument; i.e., an epoch timestamp. Script tested in GNU Bash ver 4.3.42"	
		echo "Example:"
		echo "./epochToUTCList.sh 1325358001"
		echo "Sunday January 1, 00:00:01 2012 +0000"
	
		exit 1
fi # future revision: might change this block of code to a Usage() function


# example of date function:
# date -d '@1441740175' +'%A %B %-d, %H:%M:%S %Y'

# date -d @$1 +'%A %B %-d, %H:%M:%S %Y'


#declare array to hold offsets
declare -a offsets
# declare variable for accessing array index
a=0


# calculate the 27 different UTC offsets (e.g. +1200)
for i in `seq -w 0 26`; do 
  
  # doing this gets us list -12 to +14
  offset=`expr $i - 12` 
  
  # if the number is negative, make it positive
  if [ $offset -lt 0 ]; then offset=`expr 0 - $offset`; fi 
  
  # need to append '00' to end of offset, to make it 4 digits
  offset="$offset 00"
  
  
  # left-zero-pad the offset, eg 700 becomes 0700
  # and transition to using offsets[] array to hold the offsets
  offsets[$a]=`printf %02d $offset`

  # add back the negative sign to the first 12 offsets
  if [ $i -lt 12 ]; then offsets[$a]="-${offsets[$a]}"

  # prepend positive sign to offsets that come after 12    
  else offsets[$a]="+${offsets[$a]}" 
  fi
  
  ((a++)); # increment the array index
done



# calculate time -1200 UTC, used in next for loop
time=`expr $1 - 43200` # subtract 12 hours, or 43200 seconds
# declare mydates array, to hold final products
declare -a mydates
# reset array index var to zero
a=0
# will want to know max length of longest array element
max=0

for i in {0..26}; do 
  
  # get the special-formatted datetime
  mydate=`date -d @$time +'%A %B %-d, %H:%M:%S %Y'`
  
  # assign to array element the datetime with appropriate offset appended
  mydates[$a]="$mydate ${offsets[$i]}"

  # length of current array element
  eleLength=${#mydates[$a]}
  
  if [ $eleLength -gt $max ]; then
    max=$eleLength
  fi
  

  time=`expr $time + 3600`; # increment time to next hour

  ((a++)); # increment the array index
done



# add spaces
difference=0
spaces=" "
for i in {0..26}; do
  
  eleLength=${#mydates[$i]}
  if [ $eleLength -lt $max ]; then
  difference=`expr $max - $eleLength`

  spaces=$(printf "%0.s " {`seq 2 $difference`})
   echo "$spaces ${mydates[$i]}"

  else
  echo "${mydates[$i]}"
  fi

done



# le print
#for i in {0..26}; do echo "${mydates[$i]}"; done



