#!/bin/bash
# Define the nameserver IP addresses
NAMESERVER1="8.8.8.8"
NAMESERVER2="8.8.4.4"

# Check if the /etc/resolv.conf file exists
if [ -f /etc/resolv.conf ]; then
    # Check if the nameserver entries already exist in the file
    if grep -q "^nameserver $NAMESERVER1$" /etc/resolv.conf && grep -q "^nameserver $NAMESERVER2$" /etc/resolv.conf; then
        echo "The nameservers $NAMESERVER1 and $NAMESERVER2 are already in /etc/resolv.conf."
    else
        # Append the nameserver entries to the end of the file
        echo "nameserver $NAMESERVER1" | sudo tee -a /etc/resolv.conf
        echo "nameserver $NAMESERVER2" | sudo tee -a /etc/resolv.conf
        echo "Added nameservers $NAMESERVER1 and $NAMESERVER2 to /etc/resolv.conf."
    fi
else
    echo "Error: /etc/resolv.conf does not exist."
fi

sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-8-jdk -y
sudo apt install tomcat8 tomcat8-admin tomcat8-docs tomcat8-common git -y
