#!/bin/bash
webRoot="/var/www/html/besuMonitor"
serviceRootDir="/var/customservices"
serviceDirName="watchdog"
fullServicePath=$serviceRootDir"/"$serviceDirName
scriptName="service_status_logger.sh"
serviceName="besu_watch_dog"
systemDescription="Besu Watch Dog"
initServiceFileName="./docker_service_watch.service"
metricEndpoint="index.php"
serviceStatusEndpoint="service.php"

if [ ${#1} -eq 0 ]; then
    echo -e "Please supply the institution ID, with the command ./install.sh ID\n"
    exit 2
fi

institutionID=$1


# Create directories if not exist
if [ ! -d $webRoot ]; then
    mkdir -p $webRoot
fi

if [ ! -d $fullServicePath ]; then
    mkdir -p $fullServicePath
fi

echo "Copying CGI files to target directory...: $webRoot"
# Copy CGI files to the
cp ./cgi/php/metrics.php $webRoot"/"$metricEndpoint &&
cp ./cgi/php/service.php $webRoot"/"$serviceStatusEndpoint &&
echo -e "CGI files copied successfuly \n"

# Set institution ID
echo "Setting intitution ID to: $institutionID"
sed -i "s#YYYY#$institutionID#g" ./src/template &&
sed -i "s#YYYY#$institutionID#g" ./cgi/php/service.php &&
echo -e "Institution ID '$institutionID' set successfuly \n"

echo "Copying script files to target directory...: $fullServicePath"
# Copy source script to service path
cp ./src/* $fullServicePath &&
echo -e "Scripts files copied successfuly \n"

echo "Configuring service file with values..."
# Set the service description
sed -i "s#Docker Service Watch Dog#$systemDescription#g" $initServiceFileName

# Set the service working directory
sed -i "s#YYYY#$fullServicePath#g" $initServiceFileName

# Set the service script full path in the service file
sed -i "s#XXXX#$fullServicePath/$scriptName#g"$initServiceFileName &&
echo -e "Service configuration completed successfuly \n"

echo "Making script executable...."
# Make the copied script executable
chmod a+x "$fullServicePath/service_status_logger.sh" &&
echo -e "Script now executable \n"

echo "Setting up service...."
# Copied the service file to systemd directory
cp $initServiceFileName /etc/systemd/system/$serviceName".service" &&

# Install the service
systemctl enable $serviceName &&
echo -e "Service setup completed  \n"





