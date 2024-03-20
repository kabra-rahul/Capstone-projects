#!/bin/bash

#Installing Java and Jenkins
sudo yum update –y
sudo amazon-linux-extras install java-openjdk11 -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

#Installing NodeJs
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

#Installing Maven
sudo yum install -y maven

#Installing Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

#Installing python and Ansible
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
sudo yum update -y
sudo yum install git python python-level python-pip openssl ansible -y

#Installing Terraform
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
