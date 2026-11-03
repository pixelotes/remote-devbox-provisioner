## Description
LXD is a virtualization system from Canonical. It's composed of LXC and LXD.

LXC is the underlying engine (akin to containerd), while LXD wraps LXC with an API, clients, clustering capabilities, snapshotting, etc (akin to docker).

LXD can run both containers and vms.

Containers are not the same as in docker. Instead, containers are a lightweight VM that shares the kernel with the host, among other resources. It has 99% of the baremetal performance, and the boot time is 1-2 seconds.

VMs use KVM in the background, so it has a fully virtualized hardware environment. It's deemed to have 94-96% of the baremetal performace.

It can also run docker containers, although it's a bit convoluted as it runs them inside one of the lightweight "containers" which have docker installed.

## Files overview

### preseed.yaml

The preseed.yaml file contains a premade configuration for LXD. It's set to create a bridge "lxdbr0" with the host's main network adapter and CIDR 10.0.0.x/24, a storage pool of the type "folder", which stores the guest files on folders in the host (similar to what docker does) and sets up an eth0 device for the vms using the previously created network bridge.

### setup_host.yaml

This is an ansible playbook that performs the setup on the host, mainly the creation of a non-privileged user, the installation and setup of lxd and the creation of a vm.

Variables:
- username: The user name on both the host and the vm. It's also used for setting up the name of the vm.
- ipv4_address: Static ip addressfor the vm
- vm_profile: The hardware profile the vm will be using ["s-vm-profile"|"m-vm-profile"|"l-vm-profile"|"xl-vm-profile"|"xxl-vm-profile"]
- vm_image: The image tag. "n" is the alias for Ubuntu 24.04 noble.
- vm_repository: The image repository for LXD. Ubuntu images can be forund on "https://cloud-images.ubuntu.com/releases"
- vm_type: The type of deployment ["container"|"virtual-machine"]

### setup_vms.yaml

This file sets up the user and ssh key on the virtual machine. It also upgrades all the packages in the process.

Variables:
- username: The user name on both the host and the vm.

### setup.sh

This is the entrypoint for the setup. It installs the Ansible package from Ansible's PPA repositories (if not already installed) and executes the playbooks.

You can run it with default parameters:
```bash
sudo ./setup.sh
```

Or customize user, VM size, and static IP on the fly using `-e` / `--extra-vars`:
```bash
sudo ./setup.sh -e "username=carlos vm_profile=m-vm-profile ipv4_address=10.0.0.105"
```

Any arguments passed to `setup.sh` are automatically forwarded to both playbooks. Additionally, `setup_host.yaml` writes the selected `target_username` directly into `hosts.yaml`, so `setup_vms.yaml` automatically configures the correct user inside the guest VM.

## Basic LXD commands
```bash
lxd init --auto # Inits LXD with the default options (10.x.x.x CIDR, btrfs storage)
cat preseed.yaml | lxd init --preseed # Inits lxd with custom options
lxc list # Lists all the containers and VMs and their associated IP addresses.
lxc launch <repository>:<tag> <vm-name> # Starts a container with the specified image (i.e. ubuntu:22.04)
lxc launch <repository>:<tag> <vm-name> --vm # Starts a vm with the specified image (i.e. ubuntu:22.04)
lxc network list # Lists all the virtual networks
lxc storage list # Lists all the storage pools
lxc start <vm-name> # Starts the VM. Creates it if it doesn't exist.
lxc stop <vm-name> # Stops the VM.
lxc delete <vm-name> # Destroys the VM.
lxc exec <vm-name> -- "command" # Executes any command on the vm
lxc exec <vm-name> -- bash # Executes a remote bash terminal on the vm
```

## Links

The are some resources I used for the setup, or I found interesting to watch:
* Configure networking for LXD virtual machines: https://www.youtube.com/watch?v=vYK1aLSDVIw
* Getting started with LXD containerization: https://www.youtube.com/watch?v=aIwgPKkVj8s
* Terraform and LXD: https://www.youtube.com/watch?v=ul_UxJOHiKM
* How to set up bridge for LXD containers: https://www.youtube.com/watch?v=DgBbhrv3KQg
* Running a docker container inside LXD: https://www.youtube.com/watch?v=_fCSSEyiGro
* Network bridge vs Macvlan in LXD: https://www.youtube.com/watch?v=GZJ3ArkEAz0
* How to create a bridge network on Linux with Netplan: https://www.youtube.com/watch?v=Mc1JuPxI9mY