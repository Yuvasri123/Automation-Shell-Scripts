#!/bin/bash
# Synopsis: The script will check if the user exists or not for this account. If the user exists then Prompting for resetting password and Prints Password Changed Successfully. now you can reset with your own password,
#           if user does not exist it Prints Unable to reset the psssword for this user.
#           Please enter the inputs in the Declarations Part of the script before execution.
# Author: Yuvasri C <yuvasri.c@dxc.com>
# Date: 30-08-2022


####################################################### Script Starts #################################################

##################################################### Declarations #######################################################


echo "Prompt for mailid and username"

# Prompt for mailid to send a mail to requestor
read -p "Enter the mailid: " mailid                        # ex: mailid="abc@dxc.com"

echo "Script Execution starts"

# Prompt for Username
read -p "Enter the username: " username

# Generate a random password
echo "System will Generate a random password..."
password=$(openssl rand -base64 12)


################################################### End of Declarations ###################################################


#sudo useradd $username

id -a $username
user_status=`echo "$?"`
if [ $user_status -eq 0 ];then
	echo "$username"
	echo "User $username exists for this account"


##################################################### Checking to Reset the Password #######################################

		
	echo "$username:$password" | sudo chpasswd
	status=`echo "$?"`
	if [ $status -eq 0 ];then
	    echo "One-Time Password is Changed Successfully"
		echo "A notification has been sent to the user regarding the password reset."

###################################################### Sending Via Email ####################################################

	    echo -e "Hello,\nPlease be informed that the password has been reset for the user.\n" | mailx -s "Password Reset Notification" $mailid 
	    status_mail=`echo "$?"`
	        if [ $status_mail -eq 0 ];then
	           echo "sent mail to the user successfully, and now you can reset with your own password."
	        fi
	else
	     echo "unable to reset the one-time password"
		 
	fi 	 
else
	echo "Username not supplied, you can’t run it without that information. Please investigate further."
	echo "Password does not change for the user you have entered."
fi


echo "Script Execution Ends"


######################################################### End of Script #########################################################








