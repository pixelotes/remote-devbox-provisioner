## Description
KVM-Qemu is a well known virtualization manager for Linux. It uses Qemu, a PC emulator, as its basis.
Instead of using qemu raw, it's wrapped with libvirt. Libvier is an open-source API, daemon and management tool for managing virtualization platforms such as KVM, Qemu, ESXi and others.

This setup automates the creation of the VM using Hashicorp's Vagrant, as well as the vagrant-libvirt plugin.
It also depends on Ansible for running the setup both on the host and the vm.

## Files overview

### Vagrantfile

This file allows the creation af a VM using declarative code. As the name implies, it's used by vagrant.
It allows to fine-tune all the creation parameters, as well as running a setup script on the vm after deploying the OS.
It uses premade "Vagrant boxes", which are prepackaged OS images. Canonical made official images up to Ubuntu 22.04.
For this setup, I'm using a community-made image of Ubuntu 24.04.

### setup.yaml

This is an ansible playbook that performs the required setup steps.

Actions performed:
- Installs kvm-qemu, libvirt and vagrant
- Installs the vagrant-libvirt plugin
- Creates a non-privileged user on the host
- Creates a key pair for the user and authorizes it
- Creates the vm with vagrant


Variables:
- username: The name of the user account

### setup.sh

This is the entrypoint for the setup. It installs the ansible package from Ansible's PPA repositories and then it runs the playbooks.

## Basic Vagrant commands
```bash
vagrant up # Starts the VM. Creates it if it doesn't exist.
vagrant halt # Stops the VM.
vagrant destroy # Destroys the VM.
vagrant ssh # Opens an ssh connection to the vm as root. No parameters are required.
vagrant ssh -c "command" # Executes a command on the vm
```

## Basic virsh commands
```bash
virsh list # Lists the running and stopped VMs.
virsh stop <vm-name> # Stops the VM.
virst delete <vm-name> # Deletes the VM.
virsh -c qemu:///system qemu-agent-command <vm-name> '{"execute": "some_command", "arguments": { "arg": "value" }}' --pretty
```