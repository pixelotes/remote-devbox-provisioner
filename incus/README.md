# README for Incus VM Setup

## Description
[Incus](https://linuxcontainers.org/incus/) is the community-driven fork of LXD, maintained by the original creator (Stéphane Graber) and the [Linux Containers](https://linuxcontainers.org/) project.

It provides next-generation system container and virtual machine management with several key advantages over Canonical LXD:
- **No Snap required**: Installs natively via standard APT `.deb` packages (from the official Zabbly repository) rather than Snap.
- **Unrestricted image access**: Full access to the official Linux Containers image server (`images.linuxcontainers.org`), offering lightweight, optimized cloud images for Ubuntu, Debian, Fedora, Alpine, and more.
- **True open-source governance**: Maintained by the community under the Apache 2.0 license without Canonical's contributor license agreements (CLA).

Like LXD, Incus manages KVM-QEMU virtual machines behind a clean, declarative REST API and CLI tool (`incus`).

## Files Overview

### `preseed.yaml`
Declarative initialization file for Incus. Configures:
- Private network bridge `incusbr0` with CIDR `10.0.0.1/24` and NAT enabled.
- Default storage pool (`dir` driver on host filesystem).
- Default profile binding guests to `incusbr0` and root disk.

### `setup_host.yaml`
Ansible playbook executing host configuration:
1. Installs Incus from the official Zabbly APT repository.
2. Initializes Incus with [`preseed.yaml`](./preseed.yaml).
3. Creates 5 hardware profiles (`s-vm-profile` through `xxl-vm-profile`).
4. Launches the guest VM using the official `images:ubuntu/24.04` image.
5. Overrides the `eth0` interface with a static IP (default: `10.0.0.100`).
6. Generates [`hosts.yaml`](./hosts.yaml) configured with the `community.general.incus` connection plugin.
7. Boots the VM and injects the user's public SSH key.

### `setup_vms.yaml`
Ansible playbook configuring the guest operating system:
1. Upgrades packages.
2. Creates the target user with passwordless `sudo` rights.
3. Configures `~/.ssh/authorized_keys`.

### `setup.sh`
The entrypoint script. Installs Ansible and the `community.general` collection, then runs both playbooks.

#### Usage
Run with defaults:
```bash
sudo ./setup.sh
```

Or customize user, VM size, and static IP on the fly using Ansible extra variables (`-e`):
```bash
sudo ./setup.sh -e "username=carlos vm_profile=m-vm-profile ipv4_address=10.0.0.105"
```

Any arguments passed to `setup.sh` are forwarded directly to both playbooks.

## Basic Incus Commands

```bash
incus list                                  # List all containers and VMs with status and IPs
incus launch images:ubuntu/24.04 <vm> --vm  # Launch a new Ubuntu VM
incus start <vm-name>                       # Start a VM
incus stop <vm-name>                        # Stop a VM
incus delete <vm-name>                      # Destroy a VM
incus exec <vm-name> -- bash                # Open a root shell inside the VM
incus config show <vm-name>                 # Show VM configuration
incus profile list                          # List all hardware profiles
incus network list                          # List all virtual network bridges
cat preseed.yaml | incus admin init --preseed # Re-initialize Incus with preseed
```

