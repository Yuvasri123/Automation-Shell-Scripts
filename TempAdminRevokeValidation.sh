# !/bin/bash

#Synopsis: The script will perform the Temp Admin Access Revoke Validation and prompt for the server login username and password.
#          Enter the server lists from the input file and it will connect to the server 
#          Checks whether the username is revoked or not by using the "id username | grep custacc" command.
#Author: Yuvasri C <yuvasri.c@dxc.com>
#Date: 15-03-2023     

############################### Error log file ###############################

exec 2> error.log
echo "Script Execution begins: ($date)" >> error.log

############################### file declarations #############################

input=$PWD/server.txt
output=$PWD/output_file.txt

############################ Removing Existing files #########################

if [ -f $output ];
then 
     rm $output
     echo "Removing old output files"
else 
     echo "File not exists"
fi

###############################################################################

###################### getting server login credentials #####################

echo "Prompting for the server login username and password"
read -p "Enter server login username:" ssh_user
read -s -p "Enter server login password:" ssh_pass

###############################################################################

############################## validate user ################################

echo "Prompting for the username to validate..."
read -p "Enter the username:" validate_user

#############################################################################

################################ looping from the input file ##################

for server in $(cat server.txt);
do 
    echo "ssh pass command is connecting to the server..."
    echo "Server Name : $server" >> $output
    #id $validate_user >> $output
	
    sshpass -p $ssh_pass ssh -o StrictHostKeyChecking=no $ssh_user@$server -T 'id $validate_user;'
    echo "ssh pass command is connected to the server..."
    id $validate_user | grep custacc

test=`echo $?`
echo "checking if the user is revoked or not..."

if [ $test -eq 0 ];
then
     echo "Appending the contents to Output File..."
     echo "username $validate_user still present ..please investigate manually" >> $output
     echo "Username $validate_user is present in custacc."
else
     echo "Appending the contents to Output File..."
     echo "username $validate_user revoked successfully. $validate_user not availabe" >> $output
     echo "Username $validate_user is not present in custacc."

    echo "Script execution ended successfully."
fi

done 

###############################################################################
