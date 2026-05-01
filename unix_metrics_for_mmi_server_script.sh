#! /bin/bash
# Synopsis: The script will perform an unix server health checks production core monitoring metrics
# Author: Yuvasri C <yuvasri.c@dxc.com>
# Date: 05-12-2022

####################################################### file Declarations  ###################################################
cred=$PWD/encrypted_password.txt
input=$PWD/serverlist.txt
html=$PWD/health_check.html
###################################################### End of Declarations ############################################

###################################################### Removing the old files ##########################################
if [ -f $html ];
then
        rm $html

        echo "html file is removed - health_check.html"
else

        echo "html file is created"
fi
######################################################## End of Check ################################################

####################################################### Creating new files ###########################################
touch health_check.html
html=$PWD/health_check.html
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
fi


#######################################################################################################################

#################################################### Generating HTML file ############################################
echo "<!DOCTYPE HTML>" >> "$html" 
echo "<html>" >> "$html"
echo "<head><style> table, th, td {border: 1px solid black; border-collapse: collapse;}</style> </head>" >> "$html"
echo "<body style='background-color:#f5f6fa'>" >> "$html"
echo "<center>" >> "$html"
echo "<h2 style='color:#350d9e;'>unix metrics for mmi server </h2>" >> "$html"
echo "</center>" >> "$html"
echo "<center>" >> "$html"
echo "<table class="pure-table">" >> "$html"
echo "<thead>" >> "$html"
echo "<tr>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>hostname</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>kernelversion</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>uptime</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>lastreboottime</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>no of cpu's</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>loadaverage</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>memory</th>" >> "$html"
echo "<th style='background-color:#350d9e; color:#f0edf7;'>diskusage</th>" >> "$html"
echo "</tr>" >> "$html"
echo "</thead>" >> "$html"
echo "</center>" >> "$html"
echo "<center>" >> "$html"
echo "<tbody>" >> "$html"

for server in $(cat serverlist.txt);
do 
   echo $server
   hst_name=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'hostname;'`
   echo $hst_name
   ver_sion=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'uname -r;'`
   echo $ver_sion
   upt=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'uptime;'`
   up_time=`echo $upt | sed 's/.*up \([^,]*\), .*/\1/'`
   echo $up_time
   reb=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'who -b;'`
   reboot=`echo $reb | awk '{print $3,$4}'`
   echo $reboot
   cpu=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'lscpu;'`
   cp_no=`echo "$cpu" | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}'`
   echo $cp_no
   load_avg=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'uptime;'`
   ld_avrg=`echo $load_avg | awk -F 'load average:' '{ print $2 }' | cut -f1 -d,`
   echo $ld_avrg
   memory=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'free -m;'`
   echo $memory
   disk=`sshpass -p $pass ssh -o StrictHostKeyChecking=no $user_name@$server -T 'df -Th;'`
   disk_usage=`echo $disk | grep -E "([90][0-9]|100)%"`
   
   if [ $disk_usage > 90 ];
   then 
      echo "reached above 90%"
      disk_usage_final="$disk_usage"
   else
      disk_usage_final=`echo "file system usage below 90%"`
   fi

		echo "Creating html for $server"
		echo "<tr>" >> "$html"
        echo "<td style=text-align:center><pre>$hst_name</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$ver_sion</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$up_time</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$reboot</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$cp_no</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$ld_avrg</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$memory</pre></td>" >> "$html"
        echo "<td style=text-align:center><pre>$disk_usage_final</pre></td>" >> "$html"
        echo "</tr>" >> "$html"

done 

echo "</tbody>" >> "$html"
echo "</table>" >> "$html"
echo "</center>" >> "$html"
echo "</body>" >> "$html"
echo "</html>" >> "$html"
echo "execution completed"

echo -e "Hello Team,\nPlease find  health check report.\n\nRegards,\n Automation" | mailx -s "Health Check Report" -a "/tmp/health_check.html" yuvasri.c@dxc.com

#echo "Hi there, health check report" | mail -s "unix metrics for mmi server" devi.s@dxc.com -A health_check.html
#echo -e $html | mailx -s "unix server health checks production core monitoring metrics" yuvasri.c@dxc.com
####################################################################################################################
  
                                                                      
