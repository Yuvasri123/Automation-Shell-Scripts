# !/bin/bash

#Synopsis: The script will perform the kernal parameter configuration 
#          Enter the server lists in the input file  
#          After editing the file '/etc/sysctl.conf', use the 'sysctl -p' command and restart the system to invoke the new settings.
#Author: Yuvasri C <yuvasri.c@dxc.com>
#Date: 05-04-2023     

############################### Error log file ###############################

exec 2> error.log
echo "Script Execution begins: ($date)" >> error.log

############################### file declarations #############################

echo "Script Execution begins:"

file="/etc/sysctl.conf"
input_file=$PWD/configuration.txt
parameter_file=$PWD/parameter.txt
output_file=$PWD/kernalconfig.txt

###############################################################################

############################ Removing Existing files #########################

if [ -f $output_file ];
then
     rm $output_file
     echo "Removing old output files"
else
     echo "File not exists"
fi

###############################################################################

################################ looping from the input file ##################

if [ -f $file ];
then
     echo "File exists"
     for server in $(cat configuration.txt);
	do
	    parameter_conf=`cat $PWD/parameter.txt >> /etc/sysctl.conf;`   
	    param=`echo $?`
	     if [ "$param" = 0 ];
	     then
		     echo "Updated successfully"
	     else 
		     echo "Exit"
	     fi 

          kernal=`sysctl -p;`
          kernal_update=`echo $?`
          if [ "$kernal_update" = 0 ];
          then     
               echo "Successfully executed..."
          else
               echo "Execution failed.."
          fi
     done 
else
               echo "File does not exists"
               echo "Creating the file..."
               touch /etc/sysctl.conf;
               param_conf=`cat $PWD/parameter.txt > /etc/sysctl.conf;`
               echo "File created successfully"
               kernal=`sysctl -p;`
               kernal_update=`echo $?`
                    if [ "$kernal_update" = 0 ];
                    then   
                         echo "Successfully executed..."
                    fi
fi	
	echo "Script execution ended successfully."

final_attach=`cat /etc/sysctl.conf;`
echo "$final_attach" >> $PWD/kernalconfig.txt

echo -e "Hello Team,\nPlease find the Attachment of kernal parameter configuration.\n\nRegards,\n Automation" | mailx -s "Kernal Parameter Configuration" -a "$PWD/kernalconfig.txt" shyamakantk@dxc.com
	

