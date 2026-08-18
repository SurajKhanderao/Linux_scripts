#!/bin/bash


set -x

echo "========user Detete script=========="


read -p "Enter name of User : " username

check=$(tail /etc/passwd |grep -wc "$username")

if [ $check -eq 1 ]

then
	sudo userdel -r $username 2> /dev/null

 echo -e "\033[31m USER DELETED \033[0m"

else
	echo -e "\033[31m USER NOT EXIST \033[0m"

	tail /etc/passwd	
fi




