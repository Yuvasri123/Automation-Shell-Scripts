#!/bin/bash
# Synopsis: This script is used to check, stop, and restart NetBackup services along with the VxPBX service on a server.
#           It ensures that these services are running correctly after a restart.
# Author: Yuvasri C <yuvasri.c@dxc.com>
# Date: 07-08-2024


########################################################### Checking the Status of NetBackup Services #############################################################


echo "Script Execution starts"

        echo "Initiating Check: NetBackup Services Status"
		sh /usr/openv/netbackup/bin/goodies/netbackup status
		
		Netbackup_status=`echo $?`
		if [ $Netbackup_status -eq 0 ] ;
		then
		     echo "Status Check: NetBackup Services are Active"
		else
		     echo "NetBackup Services are InActive"		
		fi

		echo "Stopping NetBackup Services"
		sudo /usr/openv/netbackup/bin/bp.kill_all

		echo "Stopping VxPBX Service"
		sudo /opt/VRTSpbx/bin/vxpbx_exchanged stop
		
		echo "Starting VxPBX Service"
		sudo /opt/VRTSpbx/bin/vxpbx_exchanged start
		
		echo "Starting NetBackup Services" 
		sudo /usr/openv/netbackup/bin/bp.start_al


############################################ Verifying the Status of NetBackup Services ##########################################################
                
				
		echo "Rechecking: NetBackup Service Status"
		sh /usr/openv/netbackup/bin/goodies/netbackup status
		
		Netbackup_status=`echo $?`
		if [ $Netbackup_status -eq 0 ] ;
		then
		     echo "Status Check: NetBackup Services are Active"
		else
		     echo "NetBackup Services are InActive"		
		fi


echo "Script Execution Ends"


######################################################################### End of Check ##########################################################################

