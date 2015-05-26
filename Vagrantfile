# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.hostsupdater.remove_on_suspend = true
  config.vm.box = "ubuntu-14.04"
  config.omnibus.chef_version = '11.14.6'

  config.vm.define 'test' do |v|
    v.vm.network "private_network", ip: '10.0.0.100'
    v.vm.hostname = 'test'
    v.ssh.forward_agent = true
  end  
end
