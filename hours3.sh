#!/bin/bash

# /////////////////////////////
# Script for time card format
# ///////////////////////////

printf "Welcome to the Timecard Logging System.\nHere you will enter the dates and hours you've worked.\nTasks should be separated and itemized with dates/hours recorded for each entry.\n" 

echo -n "Enter your username: "
read NAME
echo -n "Are you an intern? (Y/N):"
read THREE  # --> This needs better scrubbing <--
if [ $THREE == "Y" ] || [ $THREE == "y" ]; then
  PAYCODE="MGHPCC/INTERN"
  BILLABLE="Y"
  EMERGENCY="N"
elif [ $THREE == "N" ] || [ $THREE == "n" ]; then
  echo -n "Enter your paycode: "
  read PAYCODE
  echo -n "Are these billable hours? (Y/N): "
  read BILLABLE
  echo -n "Did you work during an emergency? (Y/N): "
  read EMERGENCY
else
	echo "You must enter either 'Y' or 'N'."
	echo -n "Are you an intern? (Y/N):"
	read THREE
fi



# /////////// DATES ///////////
# ////////////////////////////
function check_date_format() {
input=$1
while [[ ! $input =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
do
	read -p "Wrong date format, try again. Enter the date of your shift: " input
done
echo $input
}

# INSERT func for month/day check


# /////// STARTING DATE ///////
printf "PLEASE BE ADVISED: Dates must be entered in the following formay MM-DD-YYYY.\nEnter the date of the start of your shift: "
read INPUT
IN_DATE=$(check_date_format $INPUT)

# /////// ENDING DATE ///////
printf "PLEASE BE ADVISED: Dates must be entered in the following formay MM-DD-YYYY.\nEnter the date of the end of your shift: "
read INPUT
OUT_DATE=$(check_date_format $INPUT)

# Break dates into variables
# --> Turn into func? <--
MONTH=$(echo $IN_DATE | awk -F'-' '{print $1}')
DAY=$(echo $IN_DATE | awk -F'-' '{print $2}')
YEAR=$(echo $IN_DATE | awk -F'-' '{print $3}')

function leap_year(){
input=$1
if [ $(($input % 4)) = 0 ]; then
	if [ $(($input % 100)) = 0 ]; then
		if [ $(($input % 400)) = 0 ]; then
			LEAP_DATE=1
		else
			LEAP_DATE=0
		fi
	else
		LEAP_DATE=1
	fi
else
	LEAP_DATE=0
fi
echo $LEAP_DATE
}

LEAP_DATE=$(leap_year $YEAR)

# Do these need to be while loops in a func?
# 31 days in Jan,Mar,May,July,Aug,Oct,Dec
if [ $MONTH -eq "01" ] || [ $MONTH -eq "03" ] || [ $MONTH -eq "05" ] || [ $MONTH -eq "07" ] || [ $MONTH -eq "08" ] || [ $MONTH -eq "10" ] || [ $MONTH -eq "12" ]; then
	if [ $((10#$DAY)) -lt "0" ] || [ $DAY -gt "31" ]; then
		echo "That day doesn't exist in that month."
	fi
fi

# 30 days in Apr,June,Sept,Nov
if [ $MONTH -eq "04" ] || [ $MONTH -eq "06" ] || [ $MONTH -eq "09" ] || [ $MONTH -eq "11" ]; then
	if [ $((10#$DAY)) -lt "0" ] || [ $DAY -gt "30" ]; then
		echo "That day doesn't exist in that month."
	fi
fi

# 28-29 days in Feb
if [ $MONTH -eq "02" ]; then
	if [ $LEAP_DATE -eq "1" ]; then
		if [ $((10#$DAY)) -lt "0" ] || [ $DAY -gt "29" ]; then
			echo "That day doesn't exist in that month."
		fi	
	elif [ $LEAP_DATE -eq "0" ]; then
		if [ $((10#$DAY)) -lt "0" ] || [ $DAY -gt "28" ]; then
			echo "That day doesn't exist in that month."
		fi
	fi
fi



# /////////// TIMES ///////////
# ////////////////////////////

# Function to check time input format
function check_time_format() {
input=$1
while [[ ! $input =~ ^[0-9]{2}:[0-9]{2}+$ ]]
do	
	read -p "Incorrect format, try again. Enter the time for your shift: " input
done
echo "$input"
}

# /////// STARTING TIMES ///////
# Prompt to enter start time
printf "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM\nEnter START time for $IN_DATE: "
read INPUT
IN_TIME=$(check_time_format $INPUT)

# Break up time and combine
INHOUR=$(echo $IN_TIME | awk -F: '{print $1}')
INMIN=$(echo $IN_TIME | awk -F: '{print $2}')
CMBN=$INHOUR$INMIN

# /////////// ############ ///////////
# This will have to be converted into a function 
# so it can be called with the out time func

# Check combined value
while [ $CMBN -ge 2400 ]; do
  echo "The time you enter cannot exceed 23:59"
  echo -n "Try again: "
  read INPUT
  IN_TIME=$(check_time_format $INPUT)
  INHOUR=$(echo $IN_TIME | awk -F: '{print $1}')
  INMIN=$(echo $IN_TIME | awk -F: '{print $2}')
  CMBN=$INHOUR$INMIN
done 

# /////////// ############ ///////////


# /////// ENDING TIMES ///////
# Prompt for end time
printf "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM\nEnter END time for $IN_DATE: "
read INPUT
OUT_TIME=$(check_time_format $INPUT)

OUTHOUR=$(echo $OUT_TIME | awk -F: '{print $1}')
OUTMIN=$(echo $OUT_TIME | awk -F: '{print $2}')
COMBN=$OUTHOUR$OUTMIN  # This needs to be passed into the same func as IN

# Inserting here, will need to be converted to func as specified above
# Check combined value
while [ $COMBN -ge 2400 ]; do
  echo "The time you enter cannot exceed 23:59"
  echo -n "Try again: "
  read INPUT
  OUT_TIME=$(check_time_format $INPUT)
  OUTHOUR=$(echo $IN_TIME | awk -F: '{print $1}')
  OUTMIN=$(echo $IN_TIME | awk -F: '{print $2}')
  COMBN=$OUTHOUR$OUTMIN
done 


# /////////// ############ ///////////


# Function to convert minutes in/out
# into decimal format for submission
# ////////////////////////////////////
CONVERT_BASE_SIXTY() {
MIN=$((10#$1))
if [ $MIN -ge 0 ] && [ $MIN -le 14 ]; then
  BASETEN=0
elif [ $MIN -ge 15 ] && [ $MIN -le 29 ]; then
  BASETEN="25"
elif [ $MIN -ge 30 ] && [ $MIN -le 44 ]; then
  BASETEN="50"
elif [ $MIN -ge 45 ] && [ $MIN -le 59 ]; then
  BASETEN="75"
fi
echo $BASETEN
}


# Subtract minute out value from minute in value
# MINCALC=$(($(CONVERT_BASE_SIXTY $OUTMIN)-$(CONVERT_BASE_SIXTY $INMIN)))

MINSUB=$(((10#$OUTMIN)-(10#$INMIN)))

# If minutes calc comes out as negative,
# convert to positive
if [ $MINSUB -lt 0 ]; then
  let MINSUB=$(($MINSUB+60))  # Changed this from *-1 to +60
  else let MINSUB=$MINSUB
fi

MINCALC=$(($(CONVERT_BASE_SIXTY $MINSUB)))

# Convert hours to base ten
FIRSTIN=$((10#$INHOUR))
FIRSTOUT=$((10#$OUTHOUR))
HOURS=`echo $(($FIRSTOUT-$FIRSTIN))`

# Calculate hours working overnight
# if [ $FIRSTIN -gt $FIRSTOUT ]; then HOURS=$(((24-$FIRSTIN) + $FIRSTOUT)); fi

SECONDIN=$((10#$INMIN))
SECONDOUT=$((10#$OUTMIN))

# If punch in and out are not
# whole hours adjust by one hour
if [ $SECONDIN -gt $SECONDOUT  ]; then
  let HOURS=$(($HOURS-1))
  else let HOURS=$HOURS
fi

# Format total as a float
TOTAL=$HOURS"."$MINCALC

# Prompt for description of work
echo -n "Enter a description: "
read DESC_INPUT

echo "out min: $OUTMIN"
echo "in min: $INMIN"
echo "Minsub: $MINSUB"
echo "Mincalc: $MINCALC"
echo "$NAME|$IN_DATE $IN_TIME|$OUT_DATE $OUT_TIME|$TOTAL|${PAYCODE^^}|${BILLABLE^^}|${EMERGENCY^^}|$DESC_INPUT"
