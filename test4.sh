#!/bin/bash

echo -n "Press [ENTER] to start, press 'q' to quit. "
read START

while [[ $START != 'q' ]]; do

	echo -n "Enter your username: "
	read NAME
	echo -n "Are you an intern? (Y/N): "
	read INTERN
	echo -n "Enter the date: "
	read DATTE
	echo -n "Pick a number: "
	read NUMBER

	echo "Is the following information correct? (Y/N)"
	read CORRECT
	echo "$NAME|$INTERN|$DATTE|$NUMBER"

	while [ $CORRECT == "N" ] || [ $CORRECT == "n" ]; do
		echo "Please start over then."
		break
	done
	
	while [ $CORRECT == "Y" ] || [ $CORRECT == "y" ]; do
		echo "Do you want to submit another entry?"
		break
	done

	if [ $CORRECT == "Y" ] || [ $CORRECT == "y" ]; then
		# Send info to output file?

	echo -n "Press [ENTER] to continue or 'q' to quit. "
	read START
done


