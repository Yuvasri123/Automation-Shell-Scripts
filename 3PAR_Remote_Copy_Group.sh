#!/bin/bash

# Script Name : VPC-Volume report corresponding to 3PAR Remote Copy Groups
# Author      : Yuvasri C <yuvasri.c@dxc.com>
# Date        : 06-02-2024

# Description:
#   This script generates a report of volumes corresponding to 3PAR Remote Copy Groups.
#   It connects to multiple 3PAR storage arrays specified in the 'serverlist.txt' file, retrieves information about Remote Copy Groups using SSH, 
#   and formats the data into a CSV file ('3PAR_Outputfile.csv'). The script then sends an email with the CSV file attached to the specified recipient.

# INPUTS 
#   Ensure 'serverlist.txt' contains the list of 3PAR storage array hostnames or IPs.
#   Run the script and provide the SSH credentials when prompted.

# OUTPUTS
#   The script will generate the output CSV file ('3PAR_Outputfile.csv') and send an email with a file attachment.


####################################################### Script Starts #################################################

####################################################### file Declarations  ############################################
 

input=$PWD/serverlist.txt
outputCSV_file=$PWD/3PAR_Outputfile.csv


################################################### Email Declaration #################################################


subject="France || Volume Report Corresponding to 3PAR Remote Copy Groups"          # If want, you can change the Subject of the mail
email_recipient="p.bhavirisetty@dxc.com"                                            # Enter the configured mailid's  [ eg:abc@dxc.com ]


###################################################### End of Declarations ############################################


###################################################### Removing the old files ##########################################


if [ -f "$outputCSV_file" ];
then
        echo "Removing the existing Output File from the Path if exists..."
        rm -rf $outputCSV_file
        echo "Successfully removed the old file."
else
        echo "Previous Output file not found"
fi


########################################################### End of Check #####################################################


###################################################### Getting credentials ###################################################


echo "Script Execution starts"

echo "Prompt for username and password"

read -p "enter the username: " user
read -s -p "enter the password: " pass
echo "\n"


######################################################## Generating HTML file ################################################


echo "Write headers to the output CSV file"

echo "Storage Array,Remote Copy Group,Role,Primary VV,Target Array,Secondary VV,Sync Status" > "$outputCSV_file"

echo "Loop through servers in the server list file" 

for server in $(cat serverlist.txt);
do  
      echo "Connecting to 3PAR $server"

      echo "SSH into the server and retrieve output of 'showrcopy groups' command"
      text1=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user@$server -T 'showrcopy groups'`
      text=`echo "$text1" | awk '{print $1,$2,$3,$4,$5}' | tail -n +7`


name_section=false

echo "Loop through each line of the output"

while read -r linen; do
    echo "$linen"
    if [[ "$linen" =~ ^Name ]]; then
        name_section=false
        read line1
        name=`echo "$line1" | awk '{print $1}'`
        target=`echo "$line1" | awk '{print $2}'`
        role=`echo "$line1" | awk '{print $4}'`
        
    
    elif [[ "$linen" == *"LocalVV"* ]]; then
        name_section=true
    
    elif [[ "$linen" != "" ]] && [[ "$name_section" == true ]]; then
        localVV=`echo "$linen" | awk '{print $1}'`
        remoteVV=`echo "$linen" | awk '{print $3}'`
        syncst=`echo "$linen" | awk '{print $5}'`
        
        echo "Append relevant data to the output CSV file"
        echo "$server,$name,$role,$localVV,$target,$remoteVV,$syncst" >> "$outputCSV_file"
    fi
done <<< "$text"
done


###################################################### Sending Via Email #######################################################


   echo "Sending an email with the output file contents"
   echo -e "Hello Team,\n Please find attached the 3PAR Remote Copy Group report with respect to its volumes. \n\nRegards,\n Automation" | mailx -s "$subject" -a "$outputCSV_file" "$email_recipient"
   echo "Output HTML file and CSV file sent via email Successfully"

echo "Script Execution Ends"


######################################################### End of Script #########################################################

