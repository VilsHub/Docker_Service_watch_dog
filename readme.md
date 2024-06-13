# Installation

Follow the guide below to install the script

1. Specify the keyword1, keyword2 and all needed keywords values in the script file **./src/service_status_logger.sh**
2. Make the script file **./src/service_status_logger.sh** executable
3. Edit the **service_status_logger.service** file, and update the absolute path to the **service_status_logger.sh** file in the **service** directive section
4. Copy the **service_status_logger.service** to the directory **/etc/systemd/system/**
5. Execute the command **systemctl enable service_status_logger**
6. Execute the command **systemctl daemon-reload**
7. Execute the command **systemctl start service_status_logger**