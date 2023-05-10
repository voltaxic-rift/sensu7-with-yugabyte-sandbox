# -*- mode: ruby -*-
# vi: set ft=ruby :

cpus = 4
memory = 4096

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure('2') do |config|
  config.vm.box = "almalinux/8"
  config.vm.box_version = "8.7.20230228"
  config.ssh.insert_key = false

  config.vm.provider 'libvirt' do |provider|
    provider.driver = 'kvm'
    provider.memory = memory
    provider.cpus = cpus
    provider.storage :file, size: '20G'
  end

  (1..3).each do |i|
    config.vm.define "monitor#{i}" do |n|
      n.vm.hostname = "monitor#{i}"
      n.vm.network 'private_network', ip: "192.168.57.20#{i}"
      n.vm.synced_folder '.', '/vagrant', create: true, owner: "vagrant", group: "vagrant", type: "sshfs"
    end
  end

  (1..3).each do |i|
    config.vm.define "agent#{i}" do |n|
      n.vm.hostname = "agent#{i}"
      n.vm.network 'private_network', ip: "192.168.57.#{i+1}"
      n.vm.synced_folder '.', '/vagrant', create: true, owner: "vagrant", group: "vagrant", type: "sshfs"
    end
  end

  # SSH Command: vagrant ssh agent-c6 -- -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa
  config.vm.define "agent-c6" do |n|
    n.vm.box = "generic/centos6"
    n.vm.hostname = "agent-c6"
    n.vm.network "private_network", ip: "192.168.57.6"
    n.vm.synced_folder '.', '/vagrant', create: true, owner: "vagrant", group: "vagrant", type: "sshfs",
      ssh_opts_append: "-o HostKeyAlgorithms=+ssh-rsa -o PubKeyAcceptedKeyTypes=+ssh-rsa -o StrictHostKeyChecking=no -o CheckHostIP=no"
  end
end
