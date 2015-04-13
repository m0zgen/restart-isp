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
	echo "No contains!"
    createbak
    /usr/bin/sed -i "s/$moduleload$cant$modeulename/$comment$moduleload$cant$modeulename/" $file
    echo -e "Run comment command\n"
}

# Uncomment param (pattern)
# ---------------------------------------------------\
uncomment_param(){
	echo "Contains!"
    createbak
    /usr/bin/sed -i "s/$comment$moduleload$cant$modeulename/$moduleload$cant$modeulename/" $file
    echo -e "Run uncomment command\n"
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
            echo "AAAAAAAAAAAAAAAA running!"

            result_param=$(check_param)
            echo "$result_param"

            if [[ $result_param == $result_comment ]]; then
			    #uncomment_param
			    echo "NO need comment"
			    exit 0
			else
				#comment_param
				echo "Need comment"
				service $httpd stop
	            check_and_comment
	            service $httpd start
	            check_httpd_status_service
	            check_isp_status_service
	            exit 0
			fi

    fi
    sleep 10


	done
}

run_checking(){
if ps ax | grep -v grep | grep $ispmgr > /dev/null

	then
	echo "$ispmgr running!"
	#/usr/bin/killall $ispmgr
	#echo "$ispmgr Killed!"

	result_param=$(check_param)

    if [[ $result_param == $result_comment ]]; then
	    #uncomment_param
	    check_and_uncomment
	    service $httpd restart
	    wait-and-kill-service
	else
		check_and_comment
		service $httpd restart
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

    if [[ $i == "--run-check" ]] ; then
    	run_checking
    	
        break
    fi

done