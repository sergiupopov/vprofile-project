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


sudo yum install epel-release -y
sudo yum update -y
sudo yum install wget -y
cd /tmp/
dnf -y install centos-release-rabbitmq-38
 dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
 systemctl enable --now rabbitmq-server
 firewall-cmd --add-port=5672/tcp
 firewall-cmd --runtime-to-permanent
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
