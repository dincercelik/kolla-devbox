Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |v|
    v.cpus = 2
    v.memory = 4096
    v.linked_clone = true
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]

    if Vagrant.has_plugin?("vagrant-disksize")
      config.disksize.size = "40GB"
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      owner: "_apt",
      group: "root",
      mount_options: ["dmode=777,fmode=666"]
    }
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  end

  config.vm.define "openstack", primary: true do |openstack|
    openstack.vm.box = "ubuntu/bionic64"
    openstack.vm.hostname = "openstack"
  end

  config.vm.box_check_update = false
  config.ssh.insert_key = false

  config.vm.synced_folder "./", "/vagrant", disabled: true
  config.vm.synced_folder "./", "/openstack", create: true, owner: "vagrant", group: "vagrant"

  config.vm.provision "file", source: "~/.ssh/config", destination: "~/.ssh/config"
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~/.ssh/id_rsa"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
  config.vm.provision "shell", inline: "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys", privileged: false
  config.vm.provision "shell", path: "scripts/bootstrap.sh"
  config.vm.provision "shell", path: "scripts/docker.sh"
  config.vm.provision "shell", path: "scripts/openstack.sh"
end
