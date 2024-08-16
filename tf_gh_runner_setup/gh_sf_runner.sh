#!/bin/bash
# Owner: Saurav Mitra
# Description: Configure Gihub Self-hosted Runner

# Install GH Runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.319.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.0/actions-runner-linux-x64-2.319.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.319.0.tar.gz
export RUNNER_ALLOW_RUNASROOT="1"
./config.sh --unattended --url https://github.com/${GH_ORGNAME}/${GH_REPONAME} --token ${GH_TOKEN} --name aws-hosted-runner --labels aws-hosted-runner --disableupdate
# ./run.sh
./svc.sh install
./svc.sh start
./svc.sh status

# Install Docker Engine for Demo
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce -y
systemctl status docker
