#!/bin/bash

# Check if the required parameters are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <access_key> <secret_key> <region>"
    exit 1
fi

#Install asw cli
sudo yum install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install unzip
unzip awscliv2.zip
sudo ./aws/install --update

# Access and use the runtime parameters
access_key=$1
secret_key=$2
region=$3

# Set AWS credentials and default region
aws configure set aws_access_key_id $access_key
aws configure set aws_secret_access_key $secret_key
aws configure set default.region $region

#Install Kubectl
curl -LO "https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
#Set env variable
echo PATH="$PATH:~/.local/bin/"
echo "export PATH=$PATH:~/.local/bin/" >> ~/.bashrc
