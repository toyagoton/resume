#!/usr/bin/env bash
# Resume, version 1.0
# Copyright (c) Michael Armijo, 2015.
# This work is licensed under the Creative Commons Attribution-NoDerivs 4.0 International License. See http://creativecommons.org/licenses/by-nd/4.0/ for more details.
# Revision 090215-01

# Please note that this isn't pseudo-code! This is an actual GNU BASH shell script. Try it out!
# The script is split into four different parts: Variables, Small Functions, Main Functions, and the Runtime. Everything is documented to help you understand what's going on.

########################################################
# Variables                                            #
########################################################

# Here we define our values that will be used throughout the shell script.

# Terminal Width and Height
TERMWIDTH=`tput cols` # Uses tput to get the columns, or width
TERMHEIGHT=`tput lines` # Uses tput to get the lines, or height
RECWIDTH="80" # This is our recommended width,
RECHEIGHT="24" # and this is our recommended height.

# Here we define various strings that will be used throughout the shell script. This is used for easier translation into different languages as well as easier editing instead of having to go through the entire script and find each line one by one. Ideally a separate strings file would be used, but we're just consolidating everything into the script.

# Our header. The ASCII text is from FIGlet. It looks broken here because we have to escape certain characters.
HEADER="
           __  __ _      _                _     _                   _  _       
    /#### |  \/  (_) ___| |__   __ _  ___| |   / \   _ __ _ __ ___ (_)(_) ___  
   /##### | |\/| | |/ __| '_ \ / _\` |/ _ \ |  / _ \ | '__| '_ \` _ \| || |/ _ \ 
  /###### | |  | | | (__| | | | (_| |  __/ | / ___ \| |  | | | | | | || | (_) |
 /####### |_|  |_|_|\___|_| |_|\__,_|\___|_|/_/   \_\_|  |_| |_| |_|_|/ |\___/ 
                                                SHELL SCRIPT RESUME |__/       
"

# Our small header if we can't use the big one. Again, this looks broken compared to how it actually appears in a terminal due to the backslashes.
SMALL_HEADER="
--\\\\\\   MICHAEL  ARMIJO   //--
--// SHELL SCRIPT RESUME \\\\\\--
"

# Our contact information.
CONTACT_INFO="Michael Armijo
4410 E. Grandview Road
Phoenix, AZ 85032

toyagoton@yandex.com
(602) 980-5322"

# General text strings
GOBACK="Press ENTER to return to the previous menu."
PAUSE="Press ENTER to continue."

# Error text strings
ERROR_ROOT="Whoa, you shouldn't run this as root! Exiting."
ERROR_TERMSIZE="Psst, you're running this in a $TERMWIDTH by $TERMHEIGHT terminal! The script will run in a more compact mode, however, it's recommended to run this on a $RECWIDTH by $RECHEIGHT terminal."
ERROR_INV_OPT="Invalid option!"

# Main Menu text strings
MAIN_MENU_TITLE="MAIN MENU"
MAIN_MENU_SELECT="Please select an option."
MAIN_MENU_OPTION1="Objective"
MAIN_MENU_OPTION2="Summary"
MAIN_MENU_OPTION3="Past Work Experience"
MAIN_MENU_OPTION4="Education"
MAIN_MENU_OPTION5="Technical Skills"
MAIN_MENU_OPTION6="Interested?"
MAIN_MENU_OPTION7="Exit"

# Objective text strings
OBJECTIVE_TITLE="OBJECTIVE"
OBJECTIVE_CONTENTS="To seek an employment opportunity in a professional environment that will allow for the use of my skills to serve the company and establish a strong career."

# Summary text strings
SUMMARY_TITLE="SUMMARY"
SUMMARY_CONTENTS="Energetic, quick learner and problem solver with a strong level of communication skills. Works well alone or as part of a team. Able to fluently use, manage and maintain Microsoft Windows, Mac OS X, GNU/Linux, iOS and Android."

# Work Experience text strings
WORK_EXPERIENCE_TITLE="WORK EXPERIENCE"
WORK_EXPERIENCE_SELECT="Select an option to view its contents."
WORK_EXPERIENCE_OPTION1="IT Help Desk"
WORK_EXPERIENCE_OPTION2="Data Entry"
WORK_EXPERIENCE_OPTION3="Go Back"
JOB1_TITLE="IT Help Desk/PracticeMax"
JOB2_TITLE="Data Entry/Cornea Consultants of Arizona (Internship)"
JOB1_CONTENTS="• Provide internal technical support to employees both in-person and over the phone within a limited amount of time.
• Manage support tickets through ZenDesk, escalate support tickets to higher tiers if necessary.
• Manage several servers and workstations running a combination of Windows XP, 7, 8, 8.1, and Server 2008 + Server 2008 R2. Make sure they are up-to-date and functioning properly.
• Resolve any hardware issues locally in a timely manner. Set up new hardware for new employees. Configure and manage software for employee usage.
• Manage users and add/disable old users on Windows domains through Active Directory and all proprietary services used internally."
JOB2_CONTENTS="• Sort and pull medical records as requested.
• Convert documents into digital formats (most commonly Adobe PDF) by scanning them."

# Education text strings
EDUCATION_TITLE="EDUCATION"
COLLEGE_TITLE="Paradise Valley Community College"
EDUCATION_CONTENTS="• English 101 & 102
• Computer Information Systems 105
• Japanese 101"

# Technical Skills text strings
TECHNICAL_SKILLS_TITLE="TECHNICAL SKILLS"
TECHNICAL_SKILLS_CONTENTS="Familiar with Windows 95 to Windows 10, Mac OS X, as well as distributions of GNU/Linux used in professional environments. Able to easily use the latest versions of iOS and Android. Capable of using both Microsoft Office and LibreOffice. Able to manage Active Directory and Exchange Server."

# Interested text strings
INTERESTED_TITLE="INTERESTED?"
INTERESTED_CONTENTS="It's most likely not everyday that you get a resume received in this form. I encourage you to take a look at the script code (if you haven't already) as a small sample as to what I would be able to provide to your company. I look forward to hearing from you in due time."

# Close text strings
THANKS_MESSAGE="Thank you for taking the time to review my resume. If you are interested in contacting me, here is my contact information."

########################################################
# Small Functions                                      #
########################################################

# This simply displays the correct header defined above depending on what size the terminal is. $SMALLMODE is set by the termCheck function in Main Functions below.
header ()
{
	if [[ $SMALLMODE = "true" ]]
	then
		disp "$SMALL_HEADER"
	else
		disp "$HEADER"
	fi
}

# Simple function to avoid repeating these lines over and over. The header function is right above this function.
newPage ()
{
	clear
	header
}

# This is a very simple pause function designed to replicate the one available on the Windows command line.
pause ()
{
	read -p "$PAUSE"
}

# This is a special form of the "pause" command that reads a different message and runs the newPage function.
goback ()
{
	read -p "$GOBACK"
	newPage
}

# This is a special form of echo that adds in word wrapping, so that we don't have to manually add line breaks to our strings.
disp ()
{
	echo -e "$1" | fold -sw $TERMWIDTH
}

########################################################
# Main Functions                                       #
########################################################

# We don't want people to run this script as root. Running scripts as root, especially if they're from the internet in the form of a resume, is just no good. ;)
rootCheck ()
{
	if [ "$USER" = root ]
	then
		echo "$ERROR_ROOT"
		exit 1
	fi
}

# This function checks the terminal and warns if the size is below the recommended width and height. It also sets $SMALLMODE if that's the case, so that the smaller header is shown.
termCheck ()
{
	if [[ $TERMWIDTH < $RECWIDTH ]]
	then
		disp "$ERROR_TERMSIZE"
		pause
		SMALLMODE="true"
	elif [[ $TERMHEIGHT < $RECHEIGHT ]]
	then
		disp "$ERROR_TERMSIZE"
		pause
		SMALLMODE="true"
	fi
}

# This is the function that drives the main menu. It calls the newPage function which clears the page and prints the header, then prints the title and select strings, then gives us a list of available options. If you give an invalid option, it will print what's in $ERROR_INV_OPT.
mainMenu ()
{
	newPage
	disp "$MAIN_MENU_TITLE"
	disp "$MAIN_MENU_SELECT"
	options=("$MAIN_MENU_OPTION1" "$MAIN_MENU_OPTION2" "$MAIN_MENU_OPTION3" "$MAIN_MENU_OPTION4" "$MAIN_MENU_OPTION5" "$MAIN_MENU_OPTION6" "$MAIN_MENU_OPTION7")
	select opt in "${options[@]}"
	do
  		case $opt in
			"$MAIN_MENU_OPTION1")
				objective
				;;
			"$MAIN_MENU_OPTION2")
				summary
				;;
			"$MAIN_MENU_OPTION3")
				work_experience
				;;
			"$MAIN_MENU_OPTION4")
				education
				;;
			"$MAIN_MENU_OPTION5")
				technical_skills
				;;
			"$MAIN_MENU_OPTION6")
				interested
				;;
			"$MAIN_MENU_OPTION7")
				close
				;;
			*)
				echo "$ERROR_INV_OPT"
				;;
		esac
	done
}

# This is the Objective display. It calls the newPage function, displays the title and contents, and then calls the goback function. There are a few functions like these that are designed simply to give information and then wait for the user to press enter. These will be referred to as "generic" displays.
objective ()
{
	newPage
	disp "$OBJECTIVE_TITLE\n"
	disp "$OBJECTIVE_CONTENTS\n"
	goback
}

# This is the Summary display. This is a generic display.
summary ()
{
	newPage
	disp "$SUMMARY_TITLE\n"
	disp "$SUMMARY_CONTENTS\n"
	goback
}

# This is the Work Experience menu which leads to sub-displays. This is similar to the mainMenu function in that it calls the newPage function, prints the title/select strings and gives us a list of available options. The difference here is that some options here are basically its own generic display function without calling a separate one, with the exception of the one that calls for mainMenu to return to the menu.
work_experience ()
{
	newPage
	disp "$WORK_EXPERIENCE_TITLE"
	disp "$WORK_EXPERIENCE_SELECT"
	options=("$WORK_EXPERIENCE_OPTION1" "$WORK_EXPERIENCE_OPTION2" "$WORK_EXPERIENCE_OPTION3")
	select opt in "${options[@]}"
	do
  		case $opt in
			"$WORK_EXPERIENCE_OPTION1")
				newPage
				disp "$JOB1_TITLE\n"
				disp "$JOB1_CONTENTS\n"
				goback
				;;
			"$WORK_EXPERIENCE_OPTION2")
				newPage
				disp "$JOB2_TITLE\n"
				disp "$JOB2_CONTENTS\n"
				goback
				;;
			"$WORK_EXPERIENCE_OPTION3")
				mainMenu
				;;
			*)
				echo "$ERROR_INV_OPT"
				;;
		esac
	done
}

# This is the Education display. This is a generic display.
education ()
{
	newPage
	disp "$EDUCATION_TITLE\n"
	disp "$COLLEGE_TITLE\n"
	disp "$EDUCATION_CONTENTS\n"
	goback
}

# This is the Technical Skills display. This is a generic display.
technical_skills ()
{
	newPage
	disp "$TECHNICAL_SKILLS_TITLE\n"
	disp "$TECHNICAL_SKILLS_CONTENTS\n"
	goback
}

# This is the Interested display. As in, for the "Interested" part of the resume. The display itself is not interested, I promise! This is a generic display.
interested ()
{
	newPage
	disp "$INTERESTED_TITLE\n"
	disp "$INTERESTED_CONTENTS\n"
	disp "$CONTACT_INFO\n"
	goback
}

# This is our close function that shows our thanks to the hiring professional and our contact info, should they be interested. This is similar to a generic display in that it calls the function newPage and displays two strings. However, since this is our closing function, we don't want to call mainMenu, we want to exit the script. This function is also called if you hit CTRL-C or if the script otherwise receives SIGINT or SIGTERM. That saves us from having to go back to the main menu and close it from there in order to get it to run the close function.
close ()
{
	newPage
	disp "$THANKS_MESSAGE\n"
	disp "$CONTACT_INFO\n"
	exit $?
}

########################################################
# Runtime                                              #
########################################################

# These two lines will trap any CTRL-C or SIGINT/SIGTERM received, and calls the function close so that we can close out of the script properly.
trap close SIGINT
trap close SIGTERM

# Here is the script put together. We call the rootCheck function to check to see if we're running as a normal user (and exit if we're root), termCheck to check to see if we're running on a terminal set to our recommended WxH (and set $SMALLMODE to true if we're not), then finally the mainMenu function, which gives you the main menu.
rootCheck
termCheck
mainMenu

# Notice how this script doesn't end with the "exit" command. That's because it's unnecessary since the program will always (normally) exit under the close function, which does call for the "exit" command.
