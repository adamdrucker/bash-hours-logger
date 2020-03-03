#!/bin/bash

# /////////////////////////////////////
# /// Script for time card format ////
# ///////////////////////////////////

# /////////// Functions ///////////
# ////////////////////////////////

# /////// DATES ///////

# Check date formatting
check_date_format() {    
	input=$1
	while [[ ! $input =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
	do
  	read -p "Wrong date format, try again. Enter the date of your shift: " input
	done
	echo $input
}

# Check if year is a leap year
leap_year() {            
  year=$1
  (( !(year % 4) && ( year % 100 || !(year % 400) ) )) &&
    echo 1 || echo 0
}

# Check for valid date entry
date_check() {
	month=$1
	day=$2
	leap_date=$3

	## 31 days in Jan,Mar,May,July,Aug,Oct,Dec
	if [ "$month" -eq "01" ] || [ "$month" -eq "03" ] || [ "$month" -eq "05" ] || [ "$month" -eq "07" ] || [ "$month" -eq "08" ] || [ "$month" -eq "10" ] || [ "$month" -eq "12" ]; then
  	if [ $((10#$day)) -lt 0 ] || [ $((10#$day)) -gt 31 ]; then
    	echo 1
  	else
    	echo 0
  	fi
	fi

	## 30 days in Apr,June,Sept,Nov
	if [ $month -eq "04" ] || [ $month -eq "06" ] || [ $month -eq "09" ] || [ $month -eq "11" ]; then
  	if [ $((10#$day)) -lt "0" ] || [ $((10#$day)) -gt "30" ]; then
    	echo 1
  	else
    	echo 0
  	fi
	fi

	## 28-29 days in Feb
	if [ $month -eq "02" ]; then
  	if [ $leap_date -eq "1" ]; then
    	if [ $((10#$day)) -lt "0" ] || [ $((10#$day)) -gt "29" ]; then
      	echo 1
			fi
  	elif [ $leap_date -eq "0" ]; then
    	if [ $((10#$day)) -lt "0" ] || [ $((10#$day)) -gt "28" ]; then
      	echo 1
			fi	
  	else
    	echo 0
  	fi
	fi
}

# //////// TIMES ////////

# Check time input format
function check_time_format() {
	input=$1
	while [[ ! $input =~ ^[0-9]{2}:[0-9]{2}+$ ]]
	do
  	read -p "Incorrect format, try again. Enter the time for your shift: " input
	done
	echo "$input"
}

# Convert minutes into decimal format for submission
convert_base_sixty() {
	min=$((10#$1))
	if [ $min -ge 0 ] && [ $min -le 14 ]; then
  	baseten=0
	elif [ $min -ge 15 ] && [ $min -le 29 ]; then
  	baseten="25"
	elif [ $min -ge 30 ] && [ $min -le 44 ]; then
  	baseten="50"
	elif [ $min -ge 45 ] && [ $min -le 59 ]; then
  	baseten="75"
	fi
	echo $baseten
}


# /////// MAIN & INPUTS ///////
# ////////////////////////////

# Main function
main() {

	# Static variables
	NAME=$(echo $USER)
	PAYCODE="MGHPCC/INTERN"
	BILLABLE="Y"
	EMERGENCY="N"
	
	# /////// STARTING ///////

	# Date advisement
	printf "PLEASE BE ADVISED: Each entry must be for the same date,\nand entered in the following format MM-DD-YYYY.\nEnter the date of your shift: "
	read INPUT
	SHIFT_DATE=$(check_date_format $INPUT)     # This var equals the formatted date

	# Break dates into variables
	S_MONTH=$(echo $SHIFT_DATE | awk -F'-' '{print $1}')
	S_DAY=$(echo $SHIFT_DATE | awk -F'-' '{print $2}')
	S_YEAR=$(echo $SHIFT_DATE | awk -F'-' '{print $3}')
	S_LEAP_DATE=$(leap_year $S_YEAR)    	# 1 = yes, 0 = no

	S_FUNC_TEST=$(date_check $S_MONTH $S_DAY $S_LEAP_DATE)

	while [[ $S_FUNC_TEST -eq 1 ]]; do
		echo "That day doesn't exist in that month. Try again."
		printf "PLEASE BE ADVISED: Dates must be entered in the following format MM-DD-YYYY.\nEnter the date of the START of your shift: "
		read INPUT
		SHIFT_DATE=$(check_date_format $INPUT) 	# This var equals the formatted date

		S_MONTH=$(echo $SHIFT_DATE | awk -F'-' '{print $1}')
		S_DAY=$(echo $SHIFT_DATE | awk -F'-' '{print $2}')
		S_YEAR=$(echo $SHIFT_DATE | awk -F'-' '{print $3}')
		S_LEAP_DATE=$(leap_year $S_YEAR)    	# 1 = yes, 0 = no

		S_FUNC_TEST=$(date_check $S_MONTH $S_DAY $S_LEAP_DATE)
	done

	# Prompt to enter start time
	printf "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM.\nEnter START time for $SHIFT_DATE: "
	read INPUT
	SIN_TIME=$(check_time_format $INPUT)

	# Break up time and combine
	INHOUR=$(echo $SIN_TIME | awk -F: '{print $1}')
	INMIN=$(echo $SIN_TIME | awk -F: '{print $2}')
	CMBN=$INHOUR$INMIN

	# Check combineid IN value
	while [ $CMBN -ge 2400 ]; do
		echo "The time you enter cannot exceed 23:59. Try again."
		echo "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM."
		echo "Enter START time for $SHIFT_DATE: "
		read INPUT
		SIN_TIME=$(check_time_format $INPUT)
		INHOUR=$(echo $SIN_TIME | awk -F: '{print $1}')
		INMIN=$(echo $SIN_TIME | awk -F: '{print $2}')
		CMBN=$INHOUR$INMIN
	done

	# /////// ENDING ///////

	# Prompt to enter end time
	printf "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM.\nEnter END time for $SHIFT_DATE: "
	read INPUT
	SOUT_TIME=$(check_time_format $INPUT)

	OUTHOUR=$(echo $SOUT_TIME | awk -F: '{print $1}')
	OUTMIN=$(echo $SOUT_TIME | awk -F: '{print $2}')
	COMBN=$OUTHOUR$OUTMIN

	# Check combined OUT value
	while [ $COMBN -ge 2400 ]; do
		echo "The time you enter cannot exceed 23:59. Try again."
		echo "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM."
		echo -n "Enter END time for $SHIFT_DATE: "
		read INPUT
		SOUT_TIME=$(check_time_format $INPUT)
		OUTHOUR=$(echo $SOUT_TIME | awk -F: '{print $1}')
		OUTMIN=$(echo $SOUT_TIME | awk -F: '{print $2}')
		COMBN=$OUTHOUR$OUTMIN
	done

	# /////////// Some calculations ///////////
	# ////////////////////////////////////////

	MINSUB=$(((10#$OUTMIN)-(10#$INMIN)))

	# Convert to positive if minutes are negative
	if [ $MINSUB -lt 0 ]; then
		let MINSUB=$(($MINSUB+60))  # Changed this from *-1 to +60
		else let MINSUB=$MINSUB
	fi

	# Convert hours to base ten
	FIRSTIN=$((10#$INHOUR))
	FIRSTOUT=$((10#$OUTHOUR))
	# Convert minutes to base ten
	SECONDIN=$((10#$INMIN))
	SECONDOUT=$((10#$OUTMIN))

	HOURS=$(($FIRSTOUT-$FIRSTIN))
	# Hours offset for overnight
	if [ $FIRSTIN -gt $FIRSTOUT ]; then HOURS=$(((24-$FIRSTIN) + $FIRSTOUT)); fi

	# If punch in and out are not whole hours adjust by one hour
	if [ $SECONDIN -gt $SECONDOUT  ]; then
		HOURS=$(($HOURS-1))
	 # else HOURS=$HOURS
	fi

	MINCALC=$(($(convert_base_sixty $MINSUB)))

	# Format total as a float
	TOTAL=$HOURS"."$MINCALC

	#
	# Prompt for description of work
	echo -n "Enter a description: "
	read DESC_INPUT
	#

	# /////////// Output ///////////

	OUTPUT="$NAME|$SHIFT_DATE $SIN_TIME|$SHIFT_DATE $SOUT_TIME|$TOTAL|${PAYCODE^^}|${BILLABLE^^}|${EMERGENCY^^}|$DESC_INPUT"
	echo $OUTPUT
	echo -n "Is the preceding information correct? (Y/N) "
	read CORRECT

	if [ $CORRECT == "Y" ] || [ $CORRECT == "y" ]; then
		echo $OUTPUT >> "/home/$USER/Documents/Timecards/timecard_$DATE_LOGGED.txt"
	fi

	while [ $CORRECT == "N" ] || [ $CORRECT == "n" ]; do
		echo "Please start over then."
		break
	done

	while [ $CORRECT == "Y" ] || [ $CORRECT == "y" ]; do
		echo "Do you want to submit another entry?"
		break
	done

	echo -n "Press [ENTER] to start another entry or 'q' to quit. "
	read START

}

# /////////// Prompts ///////////
# //////////////////////////////

printf "Welcome to the Timecard Logging System.\nHere you will enter the dates and hours you've worked.\nTasks should be separated and itemized with dates/hours recorded for each entry.\n"

echo -n "Press [ENTER] to start, press 'q' to quit. "
read START

test -d "/home/$USER/Documents/Timecards"
if [ $? == 1 ]; then
	mkdir "/home/$USER/Documents/Timecards"
fi

DATE_LOGGED=$(date +%m-%d-%Y)
test -e "/home/$USER/Documents/Timecards/"timecard_$DATE_LOGGED.txt""
	if [ $? == "1" ]; then
		$(touch /home/$USER/Documents/Timecards/"timecard_$DATE_LOGGED.txt")
	fi

while [[ $START != 'q' ]]; do
	main
done

