
#!/bin/bash
# Synopsis: The script will check if the directory exists or not. If the directory does not exist, it will create 
#           To monitor the changes during the temp admin. Run the commands and it will append all the commands output into the text file         
# Author: Yuvasri C <yuvasri.c@dxc.com>
# Date: 26-10-2022

################################################################## Declaring Paths ###########################################################################
################################################################### Declare the Directory name ###############################################################
directory_name="/var/tmp/temp_admin"

########################################################################################################################################################################

file_path_pre="/var/tmp/temp_admin/pre_access.txt"
file_path_post="/var/tmp/temp_admin/post_access.txt"

################################################################### End in Declaring paths ###################################################################

############################################################## check the Directory Exists or not ###############################################################
if [ -d $directory_name ]; then
    echo "directory $directory_name already exists"
else
    mkdir $directory_name
    echo "directory $directory_name created successfully"
fi

###################################################################### Remove the Files #####################################################################
if [ -f $file_path_post ]; then
    rm $file_path_post
    echo "file is removed"
else
    touch $file_path_post
    echo "file created"
fi

######################################################################## End if Check ########################################################################

########################################################## Appends commands output to a text file ############################################################
long_lists=`ls -l /`
echo "root files:" > $file_path_post
echo -e "$long_lists\n\n" >> $file_path_post

list_files=`ls -l /etc/`
echo "etc directory files:" >> $file_path_post
echo -e "$list_files\n\n" >> $file_path_post

disk_free=`df -h`
echo "informations of file system:" >> $file_path_post
echo -e "$disk_free\n\n" >> $file_path_post

users_info=`cat /etc/passwd` 
echo "list of all users:" >> $file_path_post
echo -e "$users_info\n\n" >> $file_path_post

group_file=`cat /etc/group`
echo "groups info:" >> $file_path_post
echo -e "$group_file\n\n" >> $file_path_post

files=`cat /etc/sudoers`
echo "sudoers info:" >> $file_path_post
echo -e "$files\n\n" >> $file_path_post

confi=`netstat -ntlp`
echo "displays network statistics:" >> $file_path_post
echo -e "$confi\n\n" >> $file_path_post

############################################################# To monitor the changes of both Scripts ########################################################
diff $file_path_pre $file_path_post

####################################################################### End ##################################################################################

