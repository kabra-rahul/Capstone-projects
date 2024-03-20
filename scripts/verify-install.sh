#!/bin/bash

#Verify installations
echo “Java version            : “  &&  java -version
echo “======================================”
echo “Jenkins Status         : “  &&  sudo systemctl status jenkins
echo “======================================”
echo “Docker version       : “  &&  docker--version
echo “======================================”
echo “Maven version       : “  &&  mvn --version
echo “======================================”
echo “Ansible version      : “  &&  ansible --version
echo “======================================”
echo “Terraform version : “  &&  terraform --version
echo “======================================”
echo “AWS version           : “  &&  aws --version
echo “======================================”
echo “Kubectl version      : “  &&  kubectl version --client
