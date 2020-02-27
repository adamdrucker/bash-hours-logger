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
leap_year(){            
  year=$1
  (( !(year % 4) && ( year % 100 || !(year % 400) ) )) &&
    echo 1 || echo 0
}

# Check for valid date entry
date_check(){
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

# /////////// Input & Prompts ///////////
# //////////////////////////////////////

printf "Welcome to the Timecard Logging System.\nHere you will enter the dates and hours you've worked.\nTasks should be separated and itemized with dates/hours recorded for each entry.\n"

echo -n "Enter your username: "
read NAME
echo -n "Are you an intern? (Y/N):"
read THREE

# Scrub intern question input
while [ $THREE != "Y" ] &&  [ $THREE != "y" ] && [ $THREE != "N" ] && [ $THREE != "n" ]; do
  echo "You must enter either 'Y' or 'N'."
  echo -n "Are you an intern? (Y/N):"
  read THREE
done

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
fi

# /////// STARTING ///////

# Prompt to enter start date
printf "PLEASE BE ADVISED: Dates must be entered in the following format MM-DD-YYYY.\nEnter the date of the START of your shift: "
read INPUT
IN_DATE=$(check_date_format $INPUT)     # This var equals the formatted date

# Break dates into variables
IN_MONTH=$(echo $IN_DATE | awk -F'-' '{print $1}')
IN_DAY=$(echo $IN_DATE | awk -F'-' '{print $2}')
IN_YEAR=$(echo $IN_DATE | awk -F'-' '{print $3}')
IN_LEAP_DATE=$(leap_year $IN_YEAR)    	# 1 = yes, 0 = no

IN_FUNC_TEST=$(date_check $IN_MONTH $IN_DAY $IN_LEAP_DATE)

while [[ $IN_FUNC_TEST -eq 1 ]]; do
  echo "That day doesn't exist in that month. Try again."
  printf "PLEASE BE ADVISED: Dates must be entered in the following format MM-DD-YYYY.\nEnter the date of the START of your shift: "
  read INPUT
  IN_DATE=$(check_date_format $INPUT) 	# This var equals the formatted date

  IN_MONTH=$(echo $IN_DATE | awk -F'-' '{print $1}')
  IN_DAY=$(echo $IN_DATE | awk -F'-' '{print $2}')
  IN_YEAR=$(echo $IN_DATE | awk -F'-' '{print $3}')
	IN_LEAP_DATE=$(leap_year $IN_YEAR)    	# 1 = yes, 0 = no

  IN_FUNC_TEST=$(date_check $IN_MONTH $IN_DAY $IN_LEAP_DATE)
done

# Prompt to enter start time
printf "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM.\nEnter START time for $IN_DATE: "
read INPUT
IN_TIME=$(check_time_format $INPUT)

# Break up time and combine
INHOUR=$(echo $IN_TIME | awk -F: '{print $1}')
INMIN=$(echo $IN_TIME | awk -F: '{print $2}')
CMBN=$INHOUR$INMIN

# Check combineid IN value
while [ $CMBN -ge 2400 ]; do
  echo "The time you enter cannot exceed 23:59. Try again."
  echo "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM."
	echo "Enter START time for $IN_DATE: "
  read INPUT
  IN_TIME=$(check_time_format $INPUT)
  INHOUR=$(echo $IN_TIME | awk -F: '{print $1}')
  INMIN=$(echo $IN_TIME | awk -F: '{print $2}')
  CMBN=$INHOUR$INMIN
done

# /////// ENDING ///////

# Prompt to enter end date
printf "PLEASE BE ADVISED: Dates must be entered in the following format MM-DD-YYYY.\nEnter the date of the END of your shift: "
read INPUT
OUT_DATE=$(check_date_format $INPUT) # This var equals the formatted date

OUT_MONTH=$(echo $OUT_DATE | awk -F'-' '{print $1}')
OUT_DAY=$(echo $OUT_DATE | awk -F'-' '{print $2}')
OUT_YEAR=$(echo $OUT_DATE | awk -F'-' '{print $3}')
OUT_LEAP_DATE=$(leap_year $OUT_YEAR)  # 1 = yes, 0 = no

OUT_FUNC_TEST=$(date_check $OUT_MONTH $OUT_DAY $OUT_LEAP_DATE)

while [[ $OUT_FUNC_TEST -eq 1 ]]; do
  echo "That day doesn't exist in that month. Try again."
  printf "PLEASE BE ADVISED: Dates must be entered in the following format MM-DD-YYYY.\nEnter the date of the END of your shift: "
  read INPUT
  OUT_DATE=$(check_date_format $INPUT) # This var equals the formatted date

  OUT_MONTH=$(echo $OUT_DATE | awk -F'-' '{print $1}')
  OUT_DAY=$(echo $OUT_DATE | awk -F'-' '{print $2}')
  OUT_YEAR=$(echo $OUT_DATE | awk -F'-' '{print $3}')
	OUT_LEAP_DATE=$(leap_year $OUT_YEAR)  # 1 = yes, 0 = no

  OUT_FUNC_TEST=$(date_check $OUT_MONTH $OUT_DAY $OUT_LEAP_DATE)
done

# Prompt eo enter end time
printf "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM.\nEnter END time for $OUT_DATE: "
read INPUT
OUT_TIME=$(check_time_format $INPUT)

OUTHOUR=$(echo $OUT_TIME | awk -F: '{print $1}')
OUTMIN=$(echo $OUT_TIME | awk -F: '{print $2}')
COMBN=$OUTHOUR$OUTMIN

# Check combined OUT value
while [ $COMBN -ge 2400 ]; do
  echo "The time you enter cannot exceed 23:59. Try again."
  echo "PLEASE BE ADVISED: Times must be formatted in 24-hour notation as HH:MM."
	echo -n "Enter END time for $OUT_DATE: "
  read INPUT
  OUT_TIME=$(check_time_format $INPUT)
  OUTHOUR=$(echo $IN_TIME | awk -F: '{print $1}')
  OUTMIN=$(echo $IN_TIME | awk -F: '{print $2}')
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

echo "$NAME|$IN_DATE $IN_TIME|$OUT_DATE $OUT_TIME|$TOTAL|${PAYCODE^^}|${BILLABLE^^}|${EMERGENCY^^}|$DESC_INPUT"

