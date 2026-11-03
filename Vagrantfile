Vagrant.configure("2") do |config|
    config.vm.box = "cloud-image/ubuntu-24.04"
    username = ENV['VDI_USER'] || 'devuser'
  
    # Network configuration
    config.vm.network "forwarded_port", guest: 22, host: 20000
  
    config.vm.provider :libvirt do |libvirt|
      libvirt.memory = 4096
      libvirt.cpus = 2
      libvirt.graphics_type = "vnc"
      libvirt.graphics_ip = "0.0.0.0"
      libvirt.video_type = "qxl"
  
      libvirt.storage :file, size: '100G'
    end
  
    # Copy the host's SSH public key to the VM
    config.vm.provision "file", source: "/home/#{username}/.ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"
  
    # Provisioning script
    config.vm.provision "shell", inline: <<-SHELL
      # Update and install Ubuntu desktop environment
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y curl nano
  
      # Create a new user
      useradd -m -s /bin/bash #{username}
      
      # Set up the .ssh directory and authorized_keys for the new user
      mkdir -p /home/#{username}/.ssh
      chmod 700 /home/#{username}/.ssh
      touch /home/#{username}/.ssh/authorized_keys
      chmod 600 /home/#{username}/.ssh/authorized_keys
      chown -R #{username}:#{username} /home/#{username}/.ssh
  
      # Add the host's SSH public key to the authorized_keys file
      cat /tmp/id_rsa.pub >> /home/#{username}/.ssh/authorized_keys
  
      # Grant root permissions to user
      echo "#{username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/#{username}
      chmod 440 /etc/sudoers.d/#{username}
      
      # Ensure the SSH service is running
      systemctl restart ssh
  
      # Cleanup
      rm -f /tmp/id_rsa.pub
    SHELL
  end