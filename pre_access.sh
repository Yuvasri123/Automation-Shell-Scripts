
#!/bin/bash
# Synopsis: The script will check if the directory exists or not. If the directory does not exist, it will create 
#           Run the commands and it will append all the commands output into the text file         
# Author: Yuvasri C <yuvasri.c@dxc.com>
# Date: 26-10-2022

################################################################## Declaring Paths ###########################################################################
directory_name="/var/tmp/temp_admin"
file_path_pre="/var/tmp/temp_admin/pre_access.txt"

################################################################# End in Declaring paths #######################################################################


############################################################## Check the Directory exists or not ############################################################
if [ -d $directory_name ]; then
    echo "directory $directory_name already exists"
else
    mkdir $directory_name
    echo "directory $directory_name created successfully"
fi

###################################################################### Remove the Files ######################################################################
if [ -f $file_path_pre ]; then
    rm $file_path_pre
    echo "file is removed"
else
    touch $file_path_pre
    echo "file created"
fi

####################################################################### End of Check ##########################################################################


################################################################ Appends commands output to a text file ########################################################
long_lists=`ls -l /`
echo "root files:" > $file_path_pre
echo -e "$long_lists\n\n" >> $file_path_pre

list_files=`ls -l /etc/`
echo "etc directory files:" >> $file_path_pre
echo -e "$list_files\n\n" >> $file_path_pre

disk_free=`df -h`
echo "informations of file system:" >> $file_path_pre
echo -e "$disk_free\n\n" >> $file_path_pre

users_info=`cat /etc/passwd` 
echo "list of all users:" >> $file_path_pre
echo -e "$users_info\n\n" >> $file_path_pre

group_file=`cat /etc/group`
echo "groups info:" >> $file_path_pre
echo -e "$group_file\n\n" >> $file_path_pre

files=`cat /etc/sudoers`
echo "sudoers info:" >> $file_path_pre
echo -e "$files\n\n" >> $file_path_pre

confi=`netstat -ntlp`
echo "displays network statistics:" >> $file_path_pre
echo -e "$confi\n\n" >> $file_path_pre

########################################################################## End ###############################################################################