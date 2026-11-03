#!/bin/bash
set -e

if ! command -v ansible &> /dev/null; then
    apt update
    apt install software-properties-common -y
    add-apt-repository --yes --update ppa:ansible/ansible
    apt install ansible -y
    ansible-galaxy collection install community.general
fi

ansible-playbook ./setup.yaml "$@"
