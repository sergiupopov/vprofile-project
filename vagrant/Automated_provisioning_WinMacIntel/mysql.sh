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

DATABASE_PASS='admin123'
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y


# starting & enabling mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
cd /tmp/
git clone -b main https://github.com/devopshydclub/vprofile-project.git
#restore the dump file for the application
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
sudo systemctl restart mariadb


#starting the firewall and allowing the mariadb to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
