#!/bin/bash
source ./delay.sh
serviceName="besu.validator.zone"

keyword_S1="INFO"
keyword_S2="PersistBlockTask"
keyword_S3="Imported"
keyword_D1="QbftBesuControllerBuilder"
keyword_D2="pending"
tracker="./timeTracker"
counter="./counter"

webRoot="/var/www/html/besuMonitor"

lastNLines=1
statusFile="$webRoot/status.txt"
serviceStatusFile="$webRoot/service_status"
templateDataFile="./template"
tmpTemplateDataFile=$templateDataFile"_.tmp"
tmpOutput='./tmp'
frozenAlertCount=5

# Init
if [ ! -f $tracker  ]; then
   echo "YYYY-MM-DDHH:MM:SS.000+00:00" >  $tracker
fi

if [ ! -f $counter  ]; then
   echo 0 > $counter
fi


# Define functions
function log_time(){
    date +%s > $serviceStatusFile
}

function  getTimeStamp(){
   local log=$1
   ts=""

   d=$(echo $log | awk  '{print $1}')
   t=$(echo $log | awk  '{print $2}')

   ts=$d$t
   echo $ts
}

function getState(){

    if [ ${#log} -eq 0 ]; then # Keywords not matched, crashed or pending
        pending=$(cat $tmpOutput | grep -iw "$keyword_D1" | grep -iw "$keyword_D2")
        local response=""
        if [ ${#pending} -eq 0 ]; then # Keywords not matched, crashed
            response="crashed"
        else
            response="pending"
        fi

    else
        response="running"
    fi

    echo $response
}

function check_status() {

    docker logs --tail $lastNLines $serviceName > $tmpOutput
    log=$(cat $tmpOutput | grep -iw "$keyword_S1" | grep -iw "$keyword_S2" | grep -iw "$keyword_S3")

    # Check if its frozen
    lastLog=$(cat "$tracker")
    currentLogTimeStamp=$(getTimeStamp "$log")
    
    # Update log
    echo $currentLogTimeStamp > $tracker

    if [ "$lastLog" = "$currentLogTimeStamp" ]; then
        count=$(cat "$counter")
        
        if [ $count -gt $frozenAlertCount ]; then
            response="frozen"
        else
            response=$(getState)
            count=$(( count += 1 ))
            echo "$count" > $counter
        fi        
    else
        # Check for the service state
        # if [ ${#log} -eq 0 ]; then # Keywords not matched, crashed or pending
        #     pending=$(cat $tmpOutput | grep -iw "$keyword_D1" | grep -iw "$keyword_D2")

        #     if [ ${#pending} -eq 0 ]; then # Keywords not matched, crashed
        #         response="crashed"
        #     else
        #         response="pending"
        #     fi

        # else
        #     response="running"
        # fi
        echo "0" > $counter
        response=$(getState)
    fi

    log_time
    echo $response

}

function write_to_log(){
    local status=$1

    # Duplicat template file
    cp $templateDataFile $tmpTemplateDataFile

    # Replace status
    sed -i "s/XXXX/$status/g" $tmpTemplateDataFile

    cat $tmpTemplateDataFile > $statusFile

}

function watch_for_failures() {

    ec=$(check_status)

    while [ : ]; do

        if [[ $ec = "crashed" || $ec = "frozen" ]]; then 
            # Service crashed or frozen, write to log
            write_to_log 0
        elif [ $ec = "pending" ]; then 
            # Service pending, write to log
            write_to_log 0.5
        else
            # Service running, write to log
            write_to_log 1
        fi
        
        ec=$(check_status)
        
        sleep $delay
    done
}

watch_for_failures
