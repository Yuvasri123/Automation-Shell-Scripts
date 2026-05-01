#!/bin/bash

# Script Name : Weekly CPU and RAM Utilization Report
# Author      : Yuvasri C <yuvasri.c@dxc.com>
# Date        : 20-08-2024

#  Description:
#  This cript automates the process of gathering CPU and RAM usage statistics from multiple servers over the past week
#  (starting from the last Thursday to the current Thursday)
#  and sends the collected data as a weekly report via email to specified recipients.

# INPUTS 
#   Ensure 'server_names.txt' contains the list of servers.
#   Run the script and provide the SSH credentials when prompted.

# OUTPUTS
#   The script will generate the output TEXT file ('Weekly_CPU_RAM_Utilization.txt') and send an email with a file attachment.


####################################################### Script Starts #################################################

####################################################### File Declarations ############################################


input=$PWD/server_names.txt
output_file=$PWD/Weekly_CPU_RAM_Utilization.txt
DATE=$(date '+%Y-%m-%d %H:%M:%S')


################################################### Email Declaration #################################################


subject="Weekly CPU and RAM Utilization Report"                                 # If want, you can change the Subject of the mail
email_recipient="gauravkumar.singh2@dxc.com"                                    # Enter the configured mailid's  [ eg:abc@dxc.com ]
from_address="gauravkumar.singh2@dxc.com"                               


###################################################### End of Declarations ############################################

###################################################### Removing the old files ##########################################


if [ -f "$output_file" ];
then
        echo "Removing the existing Output File from the Path if exists..."
        rm -rf $output_file
        echo "Successfully removed the old file."
else
        echo "Previous Output file not found"
fi


########################################################### End of Check #####################################################

###################################################### Getting Credentials ###################################################


echo "Script Execution starts"

echo "Prompt for username and password"

read -p "Enter the username: " user
read -s -p "Enter the password: " pass
echo 


######################################################## Input Validation ############################################


if [[ ! -f "$input" ]]; then
    echo "Error: server_names.txt file not found!"
    exit 1
fi


######################################################## Generating TEXT file ################################################


# Calculate the most recent Thursday and the next Thursday
start_date=$(date -d "last Thursday" '+%Y-%m-%d')
end_date=$(date -d "$start_date + 7 days" '+%Y-%m-%d')

echo "Start Date: $start_date"
echo "End Date: $end_date"

echo "Loop through servers in the server list file"

for server in $(cat server_names.txt); do
    echo "Connecting to the $server"

   for ((i=0; i<=7; i++)); do
        current_date=$(date -d "$start_date + $i days" '+%d')
        month=$(date -d "$start_date + $i days" '+%m')
        year=$(date -d "$start_date + $i days" '+%Y')

        echo "SSH into the server and retrieve output of 'CPU & MEM' command for $year-$month-$current_date"

        # Run the command for CPU utilization
        CPU_Util=$(sshpass -p $pass ssh -o StrictHostKeyChecking=no $user@$server "sar -u -f /var/log/sa/sa${current_date}")
    
        # Run the command for RAM utilization
        RAM_Util=$(sshpass -p $pass ssh -o StrictHostKeyChecking=no $user@$server "sar -r -f /var/log/sa/sa${current_date}")
        
        echo "CPU-RAM data collected for $server on $year-$month-$current_date."

        echo "Append relevant data to the output TEXT file"
        echo -e "$year-$month-$current_date,$server,$CPU_Util" >> "$output_file"
        echo -e "$year-$month-$current_date,$server,$RAM_Util" >> "$output_file"

    done
done < "$input"


###################################################### Sending Via Email #######################################################


echo "Sending an email with the output file contents"
echo -e "Hi Team,\n\n Please find attached the CPU and RAM utilization report for the week.\n\nRegards,\nGaurav kumar Singh,\nUNIX Specialist | Managed services for VPC,\nDXC Technology" | mailx -s "$subject" -a $output_file -r "$from_address" -v "$email_recipient"

# Check if the mail command was successful
if [ $? -eq 0 ]; then
    echo "Output text file sent via email successfully"
else
    echo "Failed to send the email."
fi


echo "Script Execution Ends"


######################################################### End of Script #########################################################
