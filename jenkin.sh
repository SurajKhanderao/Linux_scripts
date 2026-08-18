#!/bin/bash

sudo yum -y update

#STEP-1: Installing Git and Maven
sudo yum install git maven -y

#STEP-2: Repo Information (jenkins.io --> download -- > redhat)
sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

#STEP-3: Download Java 21 and Jenkins
sudo yum install java-21-amazon-corretto -y
sudo yum install jenkins -y
sudo mount -o remount,size=2G /tmp

#STEP-4: Start and check the JENKINS Status
sudo systemctl start jenkins.service
sudo systemctl status jenkins.service

#STEP-5: Auto-Start Jenkins

sudo systemctl enable jenkins.service
