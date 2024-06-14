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

echo "Copying CGI files to target directory...:$webRoot"
# Copy CGI files to the
cp ./cgi/php/metric.php $webRoot"/"$metricEndpoint &&
cp ./cgi/php/service.php $webRoot"/"$serviceStatusEndpoint &&
echo -e "CGI files copied successfuly \n"

echo "Copying script files to target directory...:$fullServicePath"
# Copy source script to service path
cp ./src/* $fullServicePath &&
echo -e "Scripts files copied successfuly \n"

echo "Configuring service file with values..."
# Set the service description
sed -i "s#Docker Service Watch Dog#$systemDescription#g" $serviceFileName

# Set the service working directory
sed -i "s#YYYY#$fullServicePath#g" $serviceFileName

# Set the service script full path in the service file
sed -i "s#XXXX#$fullServicePath/$scriptName#g" $serviceFileName &&
echo -e "Service configuration completed successfuly \n"

echo "Making script executable...."
# Make the copied script executable
chmod a+x "$fullServicePath/service_status_logger.sh" &&
echo -e "Script now executable \n"

echo "Setting up service...."
# Copied the service file to systemd directory
cp $serviceFileName /etc/systemd/system/ &&

# Install the service
systemctl enable $serviceName &&
echo -e "Service setup completed  \n"





