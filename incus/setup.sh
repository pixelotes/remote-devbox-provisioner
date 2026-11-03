#!/bin/bash
set -e

# Install ansible from official ppa if not installed
if ! command -v ansible &> /dev/null; then
    echo "==> Installing Ansible from PPA..."
    apt update
    apt install software-properties-common curl gpg -y
    add-apt-repository --yes --update ppa:ansible/ansible
    apt install ansible -y
    ansible-galaxy collection install community.general
fi

# Run the ansible playbooks, forwarding any extra CLI flags (e.g. -e "username=... vm_profile=...")
echo "==> Running Incus host setup..."
ansible-playbook ./setup_host.yaml "$@"

echo "==> Running Incus VM setup..."
ansible-playbook -i ./hosts.yaml ./setup_vms.yaml "$@"

