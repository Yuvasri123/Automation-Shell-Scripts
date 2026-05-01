#!/bin/bash

# Script Name : VPC-Automate execution of showvlun -v command on various LUNs on several 3PAR storages and validate host mappings. 
# Author      : Yuvasri C <yuvasri.c@dxc.com>
# Date        : 20-06-2024

# Description:

#The script performs the following steps:
#   Removes any existing output CSV file.
#   Prompts the user for SSH credentials (username and password).
#   Reads the list of 3PAR servers and volumes from input text file 'volume.txt'.
#   Connects to each 3PAR server using SSH and retrieves volume information.
#   Checks if each volume has host mappings.
#   Writes the results to '3PAR_Validationfile.csv'.
#   Ensures each 3PAR system and volume is checked only once.
#   This script generates a validation report of volumes across multiple 3PAR storage arrays.


# INPUTS:
#   Ensure 'volume.txt' contains the list of 3PAR storage arrays.
#   Run the script and provide the SSH credentials when prompted.


# OUTPUTS:
#   The script will generate the output CSV file ('3PAR_Validationfile.csv') in the current directory.


####################################################### Script Starts #################################################

####################################################### file Declarations  ############################################
 

# Input file containing storage systems and volumes
INPUT_FILE="volume.txt"
CMD_OUTPUT_FILE="showvlunOutput.txt"
CSVFILE="3PAR_Validationfile.csv"


###################################################### End of Declarations ############################################


###################################################### Removing the old files ##########################################


if [[ ! -f $INPUT_FILE ]]; then
    echo "Input file not found: $INPUT_FILE"
    exit 1
fi


if [ -f "$CSVFILE" ]; then
    echo "Removing the existing output file: $CSVFILE"
    rm -f "$CSVFILE"
fi


if [ -f "$CMD_OUTPUT_FILE" ]; then
    echo "Removing the existing command output file: $CMD_OUTPUT_FILE"
    rm -f "$CMD_OUTPUT_FILE"
fi


########################################################### End of Check #####################################################


###################################################### Getting credentials ###################################################


echo "Script Execution starts"

read -p "Enter the SSH username: " user
read -s -p "Enter the SSH password: " pass
echo


######################################################## Generating CSV file ################################################


echo "Write headers to the output CSV file"

echo "Storage Array,Volume,Validation Status" > "$CSVFILE"
UNIQ_ARRAY=$(cat $INPUT_FILE | awk '{print $1}' | uniq)
echo "UNIQ_ARRAY are: ${UNIQ_ARRAY}"
for array in $UNIQ_ARRAY; do
    echo "Processing for storage array ${array}"
    luns=$(cat $INPUT_FILE | grep ${array} | awk '{print $2}' | uniq)
    echo "storage array ${array} luns are: ${luns}"
    for lun in $luns; do
        echo "Processing for one lun: ${lun}"
        volumes_info=$(sshpass -p $pass ssh -o StrictHostKeyChecking=no $user@$array -T "showvlun -v ${lun}" 2>&1)
        echo "Server output for: ${volumes_info}"
		echo "Server output for lun is ${lun}: ${volumes_info}" >> "$CMD_OUTPUT_FILE"
		echo "===================================================" >> "$CMD_OUTPUT_FILE"
        if [[ $volumes_info ]]; then
			if (echo "${volumes_info}" | grep -i "Invalid vv name"); then
				validation_status="Volume doesn't exist or has been deleted."
			elif (echo "${volumes_info}" | grep -i "no vluns listed"); then
				validation_status="There are no host mappings associated with the volume $lun"
			elif (echo "${volumes_info}" | grep -i "Lun.*VVName.*HostName"); then
				validation_status="There are host mappings associated with the volume $lun"
			else
			    validation_status="Couldn't match any existing condition. Validate manually"
			fi
		else
		    validation_status="No output from server. Validation couldn't be performed"
		fi
        echo "validation remark is: ${validation_status}"
        echo "$array,$lun,$validation_status" >> "$CSVFILE"
    done

    echo "Completed operations on storage array: $array"
done


echo "Script completed successfully."


######################################################### End of Script #########################################################

