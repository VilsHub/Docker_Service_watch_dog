#!/bin/bash
delay='8s'
serviceName="besu.validator.zone"

keyword_S1="INFO"
keyword_S2="PersistBlockTask"
keyword_S3="Imported"
keyword_D1="QbftBesuControllerBuilder"
keyword_D2="pending"

lastNLines=1
statusFile="./status"
templateDataFile="./template"
tmpTemplateDataFile=$templateDataFile"_.tmp"
tmpOutput='./tmp'

# Define functions
function check_status() {
    docker logs --tail $lastNLines $serviceName > $tmpOutput
    error=$(cat $tmpOutput | grep -w "$keyword_S1" | grep -w "$keyword_S2" | grep -w "$keyword_S3")

    if [ ${#error} -eq 0 ]; then # Keywords not matched, crashed or pending
        pending=$(cat $tmpOutput | grep -w "$keyword_D1" | grep -w "$keyword_D2")

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

        if [ $ec = "crashed" ]; then 
            # Service crashed, write to log
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
