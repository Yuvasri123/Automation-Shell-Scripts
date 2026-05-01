#!/bin/bash


# Script Name : File System Extension
# Author      : Yuvasri C <yuvasri.c@dxc.com>
# Date        : 25-03-2024

# Description:
# The script automates the process of extending storage volumes in a Linux environment. 
# It reads input from a text file containing information about the disks to be added, volume group (VG) name, space size, and logical volume (LV) name. 
# The script performs the necessary steps to extend the storage, including creating physical volumes, extending volume groups, and extending logical volumes.
# It also checks the status of the storage extension after each step and adds output to a specified text file.

####-------------------- Checking the storage extension status after each step using appropriate commands: -----------------####

####### (lsblk, pvcreate, vgextend, lvextend, df) #########

# INPUTS 
# The script reads input data from a text file named ('inputfile.txt'),
# which contains space-separated values for disk name, volume group name, space size, and logical volume name.
# Each line in the input file represents a storage extension.

# OUTPUTS
# The script creates an output file named ('Storage_Extension.txt') to log the execution details and results of each storage extension operation.
# If the output file already exists, it will be removed before starting the script execution


####################################################### Script Starts #################################################

####################################################### file Declarations  ############################################


input_file=$PWD/inputfile.txt
output_file=$PWD/Storage_Extension.txt
file_cont=`cat "$input_file"`


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


echo "Script Execution starts"


################################################### Appends commands output to a text file ###################################


while IFS=" " read -r disk_name vg_name space_size lv_name; do


    # Step 1: Check mount point and available disks
    echo "Step 1: Check mount point and available disks" >> "$output_file"
    lsblk >> "$output_file"
    echo "Successfully checked mount points and available disks."
    echo "Successfully checked mount points and available disks." >> "$output_file"


    # Step 2: Create Physical volume using the new added disk
    echo "Step 3: Creating Physical volume..." >> "$output_file"
    pvcreate /dev/"$disk_name" >> "$output_file"
    echo "$disk_name" 
    echo "Physical volume created successfully for $disk_name"
    echo "Physical volume created successfully for $disk_name" >> "$output_file"


    # Step 3: Extend the volume group
    echo "Step 4: Extending the volume group..." >> "$output_file"
    vgextend -v "$vg_name" /dev/"$disk_name" >> "$output_file"
    echo "$vg_name"
    echo "Volume group $vg_name extended successfully."
    echo "Volume group $vg_name extended successfully." >> "$output_file"


    # Step 4: Extend the logical volume
    echo "Step 5: Extending the logical volume..." >> "$output_file"
    lvextend -L "$space_size" /dev/"$vg_name"/"$lv_name" -r >> "$output_file"
    echo "$lv_name" 
    echo "Logical volume $lv_name extended successfully."
    echo "Logical volume $lv_name extended successfully." >> "$output_file"


    # Step 5: Check whether storage is extended or not
    echo "Step 6: Checking storage extension..." >> "$output_file"
    df -h >> "$output_file"
    echo "Storage extension successfully verified."
    echo "Storage extension successfully verified." >> "$output_file"


    echo "Append relevant data to the output TEXT file"


    echo "Storage extension for $vg_name/$lv_name completed successfully." >> "$output_file"


done < "$input_file"


echo "Script Execution Ends"


######################################################### End of Script #########################################################
