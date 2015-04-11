#!/bin/bash

file="httpd.conf.example"
dt=$(date '+%d%m%Y-%H%M%S');
bakfile=$file"-"$dt".bak"

cant="\\"
comment="#"
moduleload="LoadModule cgi_module modules"
modeulename="/mod_cgi_test.so"

pattern1="$comment$moduleload$cant$modeulename"
pattern2="$moduleload$cant$modeulename"

result=$(grep "$moduleload$modeulename" $file)

createbak(){
    /usr/bin/cp $file $bakfile
}

if [[ $result == *"$comment"* ]]; then
    echo "Contains!"
    createbak
    /usr/bin/sed -i "s/$comment$moduleload$cant$modeulename/$moduleload$cant$modeulename/" $file

else
    echo "No contains!"
    createbak
    /usr/bin/sed -i "s/$moduleload$cant$modeulename/$comment$moduleload$cant$modeulename/" $file
fi

