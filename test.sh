#!/bin/bash


echo "===========User Creation Scrip ============="

#set -x

read -p "enter your username: " name

#read -s -p "enter passwd: " pass

if_exist=$(tail /etc/passwd | grep -wc "$name")

if [ $if_exist -eq 1 ]

then
	echo -e "\033[31m user already exist \033[0m"

else
	echo "creating user with username : $name"

        read -s -p "enter passwd: " pass
	
	echo -e "\n"

	sudo useradd $name 

	echo -e "$pass\n$pass" | sudo passwd $name &> /dev/null


	echo -e "\033[32m ============User Created Successfully============\033[0m"

fi

echo -e "\n$(tail /etc/passwd |grep -i $name)"






