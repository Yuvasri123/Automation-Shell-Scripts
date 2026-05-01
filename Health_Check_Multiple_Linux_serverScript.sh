#! /bin/bash
# Synopsis: The script will run a health check on multiple linux servers simultaneously.
# Author: Yuvasri C <yuvasri.c@dxc.com>
# Date: 02-08-2023

####################################################### file Declarations  ############################################
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
cred=$PWD/encrypted_password.txt
input=$PWD/serverlist.txt
text_file=$PWD/linux_health.$current_time.txt
###################################################### End of Declarations ############################################

###################################################### Removing the old files ##########################################
if [ -f $text_file ];
then
       rm $text_file

       echo "text file is removed - linux_health.$current_time.txt"
else

       echo "text file is created"
fi 
######################################################## End of Check ################################################

####################################################### Creating new files ###########################################
touch linux_health.$current_time.txt
text_file=$PWD/linux_health.$current_time.txt
#######################################################################################################################

###################################################### getting credentials ###################################################
if [ -f $cred ];
then
        echo "Password already existed"
        username=`head -1 $cred`
        #echo "$username"
        user_name=`echo $username | base64 --decode`
        #echo "$user_name"
        password=`head -2 $cred| tail -1`
        #echo "$password"
        pass=`echo $password | base64 --decode`
        #echo "$pass"
else
        echo "Enter the username"
        read username
        user=`echo $username | base64`
        echo "$user" > $cred
        read -s -p "enter password: " pass
        etext=`echo $pass | base64`
        echo "$etext" >> $cred
        #read -p "Enter username: " username
        #read -s -p "Enter password: " pass
fi


#######################################################################################################################

#################################################### Generating text file ###########################################

for server in $(cat serverlist.txt);
do 
   echo "server name" >> $text_file	
   echo $server >> $text_file
   echo "date" >> $text_file
   echo $current_time >> $text_file
   hst_name=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'hostname;'`
   echo "host name" >> $text_file
   echo $hst_name >> $text_file
   upt=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'uptime;'`
   echo "uptime" >> $text_file
   up_time=`echo $upt | sed 's/.*up \([^,]*\), .*/\1/'`
   echo $up_time >> $text_file
   cluster_info=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T '/data1/apache-cassandra-2.2.8/bin/nodetool -u cassandra -pw cassandra123 describecluster;'`
   echo "cluster information for server: $server" >> $text_file
   echo $cluster_info >> $text_file
done 

echo "execution completed"

#echo -e "Hello Team,\nPlease find  health check file.\n\nRegards,\n Automation" | mailx -s "Health Check File" -a "/tmp/linux_health.$current_time.txt" yuvasri.c@dxc.com

#echo "Hi there, health check report" | mail -s "Multiple linux server" yuvasri.c@dxc.com -A linux_health.$current_time.txt
#echo -e $html | mailx -s "Linux server health checks" yuvasri.c@dxc.com
####################################################################################################################
  
                                                                      
