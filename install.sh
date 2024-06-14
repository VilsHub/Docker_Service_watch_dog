#!/bin/bash
webRoot="/var/www/html/besuMonitor"
serviceRootDir="/var/customservices"
serviceDirName="watchdog"
fullServicePath=$serviceRootDir"/"$serviceDirName
scriptName="service_status_logger.sh"
serviceName="docker_service_watch"
systemDescription="Besu Watch Dog"
serviceFileName="./$serviceName.service"
metricEndpoint="index.php"
serviceStatusEndpoint="service.php"



# Create directories if not exist
if [ ! -d $webRoot ]; then
    mkdir -p $webRoot
fi

if [ ! -d $fullServicePath ]; then
    mkdir -p $fullServicePath
fi

# Copy CGI files to the
cp ./cgi/php/metric.php $webRoot"/"$metricEndpoint
cp ./cgi/php/service.php $webRoot"/"$serviceStatusEndpoint

# Copy source script to service path
cp ./src/* $fullServicePath

# Set the service description
sed -i "s#Docker Service Watch Dog#$systemDescription#g" $serviceFileName

# Set the service working directory
sed -i "s#YYYY#$fullServicePath#g" $serviceFileName

# Set the service script full path in the service file
sed -i "s#XXXX#$fullServicePath/$scriptName#g" $serviceFileName

# Make the copied script executable
chmod a+x "$fullServicePath/service_status_logger.sh"

# Copied the service file to systemd directory
cp $serviceFileName /etc/systemd/system/

# Install the service
systemctl enable $serviceName





