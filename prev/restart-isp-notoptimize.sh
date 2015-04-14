#!/bin/bash



# Variables
# ---------------------------------------------------\
file="/home/rb.kz/evgenii.goncharov/soft/scripts/restart-isp/httpd.conf.example"
dt=$(date '+%d%m%Y-%H%M%S');
bakfile=$file"-"$dt".bak"

ispmgr="nginx"
httpd="httpd"

cant="\\"
comment="#"
moduleload="LoadModule cgi_module modules"
modeulename="/mod_cgi_test.so"

result_comment="1"
result_uncomment="0"

pattern1="$comment$moduleload$cant$modeulename"
pattern2="$moduleload$cant$modeulename"

result=$(grep "$moduleload$modeulename" $file)

# Backup config
# ---------------------------------------------------\
createbak(){
    /usr/bin/cp $file $bakfile
}

# Comment param (pattern)
# ---------------------------------------------------\
comment_param(){
	echo "Paramater uncommented, start comment parameter..."
    createbak
    /usr/bin/sed -i "s/$moduleload$cant$modeulename/$comment$moduleload$cant$modeulename/" $file
    echo -e "Paramenter commented!!\n"
}

# Uncomment param (pattern)
# ---------------------------------------------------\
uncomment_param(){
	echo -e "Parameter commented, start uncomment..."
    createbak
    /usr/bin/sed -i "s/$comment$moduleload$cant$modeulename/$moduleload$cant$modeulename/" $file
    echo -e "Paramenter uncommented!!\n"
}

# Reverse change param :)
# ---------------------------------------------------\
check_param(){
	if [[ $result == *"$comment"* ]]; then
	    #uncomment_param
	    echo "$result_comment"
	else
	    echo "$result_uncomment"
	    
	fi
}

# Reverse check param :)
# ---------------------------------------------------\
check_and_comment(){
	if [[ $result != *"$comment"* ]]; then
	    comment_param
	fi
}

check_and_uncomment(){
	if [[ $result == *"$comment"* ]]; then
	    uncomment_param
	fi
}

# Notify
# ---------------------------------------------------\
note(){
	echo -e "--------------------------------------------------------\n"
	echo -e "\nYou need usage script with arguments: --restart-isp or --restat-server:\n\n $0 --restart-isp\n"
	exit 1
}

# Check service
# ---------------------------------------------------\
check_httpd_status_service(){
	if ps ax | grep -v grep | grep $httpd > /dev/null

	then
		echo "$httpd running!"

	else
		echo "$httpd NOT running!"

	fi
}

check_isp_status_service(){
	if ps ax | grep -v grep | grep $ispmgr > /dev/null

	then
	echo "$ispmgr running!"

else
	echo "$ispmgr NOT running!"

fi	
	

}

wait-and-kill-service(){
	while :
	do
		RESULT=`pgrep ${ispmgr}`

    if [ "${RESULT:-null}" = null ]; then
            echo "${ispmgr} not running!"
    else
			res_param=$(check_param)

            if [[ $res_param == $result_comment ]]; then
			    #uncomment_param
			    check_and_uncomment
	    		echo -e "Wait..\nHttpd go to restart..\n"
	    		service $httpd restart
			    echo -e "Done!"
			    exit 0
			else
				#comment_param
				check_and_comment
				echo -e "Wait..\nHttpd go to restart..\n"
				service $httpd restart
				echo -e "Done!"
				#echo -e "Parameter uncommented!\nStart commenting...\nStop HTTPD"
				#service $httpd stop
	            ##check_and_comment
	            #comment_param
	            #echo -e "Start HTTPD\n"
	            #service $httpd start
	            #check_httpd_status_service
	            #check_isp_status_service
	            exit 0
			fi

    fi
    sleep 10


	done
}

run_checking(){

echo -e "\nCheck $ispmgr status service..."

if ps ax | grep -v grep | grep $ispmgr > /dev/null

	then
	echo -e "$ispmgr running!\n"
	#/usr/bin/killall $ispmgr
	#echo "$ispmgr Killed!"

	result_param=$(check_param)

    if [[ $result_param == $result_comment ]]; then
	    # commented
	    echo -e "Parameter disabled!\n"
	    #wait-and-kill-service
	    exit 0
	else
		# uncommented
		echo -e "Parameter enabled!"
		wait-and-kill-service
	fi

else
	echo "$ispmgr NOT running!"

	while :
	do
		RESULT=`pgrep ${ispmgr}`

    if [ "${RESULT:-null}" = null ]; then
            echo "${ispmgr} not running!"
    else
            echo "running!"
    fi
    sleep 10


	done

fi
}

# Check run arguments
# ---------------------------------------------------\
if [ $# -ne 1 ]; then
    note
fi

# Run with argument
# ---------------------------------------------------\
for i in "$@" ; do

    if [[ $i == "--restart-isp" ]] ; then
    	
        break
    fi

    if [[ $i == "--restat-server" ]] ; then
    	
        break
    fi

    # default check
    if [[ $i == "--run-check" ]] ; then
    	run_checking
    	
        break
    fi

done