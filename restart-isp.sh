#!/bin/bash



# Variables
# ---------------------------------------------------\
file="/etc/httpd/conf/httpd.conf"
# file="/home/rb.kz/evgenii.goncharov/soft/scripts/restart-isp/httpd.conf.example"
tmpfile="/tmp/tmpcurl"

dt=$(date '+%d%m%Y-%H%M%S');
bakfile=$file"-"$dt".bak"

# Services
# ispmgr="nginx"
ispmgr="ispmgr"
httpd="httpd"

# Module name
cant="\\"
comment="#"
moduleload="LoadModule cgi_module modules"

# original module name #LoadModule cgi_module modules/mod_cgi.so
modeulename="/mod_cgi.so"

# Result flags
result_comment="1"
result_uncomment="0"

# SED patterns
pattern1="$comment$moduleload$cant$modeulename"
pattern2="$moduleload$cant$modeulename"

# Checking parameter in file
result=$(grep "$moduleload$modeulename" $file)


# Check tmpfile exist
createtmp(){
	if [ ! -f "$tmpfile" ]
	then
	    touch $tmpfile
	fi
}

# Backup config
# ---------------------------------------------------\
createbak(){
    /bin/cp $file $bakfile
}

# Comment param (pattern)
# ---------------------------------------------------\
comment_param(){
	echo "Paramater uncommented, start comment parameter..."
    createbak
    /bin/sed -i "s/$moduleload$cant$modeulename/$comment$moduleload$cant$modeulename/" $file
    echo -e "Paramenter commented!!\n"
}

# Uncomment param (pattern)
# ---------------------------------------------------\
uncomment_param(){
	echo -e "Parameter commented, start uncomment..."
    createbak
    /bin/sed -i "s/$comment$moduleload$cant$modeulename/$moduleload$cant$modeulename/" $file
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

# Notify
# ---------------------------------------------------\
note(){
	echo -e "--------------------------------------------------------\n"
	echo -e "\nYou need usage script with arguments: --restart-isp or --restat-server:\n\n $0 --restart-isp\n"
	exit 1
}

# Check service
# ---------------------------------------------------\

run_checking(){

	createtmp

	result_param=$(check_param)
	#echo $result_param

	if [[ $result_param == $result_comment ]]; then
	    # commented
	    uncomment_param
	    service $httpd restart
	    
	    if ps ax | grep -v grep | grep $ispmgr > /dev/null
	    	then
		    	/bin/killall $ispmgr

		    	# test
		    	# service $ispmgr restart

		    	curl -L -k https://178.88.115.227/myhosting-manager > $tmpfile
	    	else
	    		
	    		# test
		    	# service $ispmgr restart

	    		curl -L -k https://178.88.115.227/myhosting-manager > $tmpfile
	    fi

	    sleep 3
	    comment_param
	    service $httpd restart

	    exit 0

	else
		# uncommented
		if ps ax | grep -v grep | grep $ispmgr > /dev/null
	    	then
	    	/bin/killall $ispmgr

	    	# test
		    # service $ispmgr restart

	    	curl -L -k https://178.88.115.227/myhosting-manager > $tmpfile
	    fi

	    sleep 3
	    comment_param
	    service $httpd restart

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
    	run_checking

        break
    fi

    if [[ $i == "--restat-server" ]] ; then
    	
        break
    fi

done