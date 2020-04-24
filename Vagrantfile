# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'ipaddr'

vagrant_config = YAML.load_file("provisioning/virtualbox.conf.yml")

# check if proxy is enabled in host, so that environment can be passed
# on otherwise firewall will block outside network
use_proxy = !((ENV['http_proxy'].nil? || ENV['http_proxy'].empty?) &&
              (ENV['https_proxy'].nil? || ENV['https_proxy'].empty?))

Vagrant.configure(2) do |config|
  config.vm.box = vagrant_config['box']
  if use_proxy
    if Vagrant.has_plugin?("vagrant-proxyconf")
      config.proxy.http = ENV['http_proxy']
      config.proxy.https = ENV['https_proxy']
      config.proxy.https = ENV['ftp_proxy']
      config.proxy.no_proxy = ENV['no_proxy']
    else
      raise "vagrant-proxyconf (https://github.com/tmatilai/vagrant-proxyconf/) is not installed and proxy being used"
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  #config.vm.synced_folder
  config.vm.synced_folder File.expand_path("~/neutron"), "/opt/stack/neutron"
  config.vm.synced_folder File.expand_path("~/nova"), "/opt/stack/nova"

  # Build the common args for the setup-base.sh scripts.
  setup_base_common_args = "#{vagrant_config['allinone']['ip']} #{vagrant_config['allinone']['short_name']}"

  # Bring up the Devstack allinone node on Virtualbox
  config.vm.define "allinone", primary: true do |allinone|
    allinone.vm.host_name = vagrant_config['allinone']['host_name']
    allinone.vm.network "private_network", ip: vagrant_config['allinone']['ip']
    allinone.vm.provision "shell", path: "provisioning/setup-base.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['mtu']} #{setup_base_common_args}"
    allinone.vm.provision "shell", path: "provisioning/setup-allinone.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['vlan_interface']} " +
               "#{vagrant_config['allinone']['physical_network']}"
    allinone.vm.provider "virtualbox" do |vb|
       vb.memory = vagrant_config['allinone']['memory']
       vb.cpus = vagrant_config['allinone']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nic3', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet3', "physnet1"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           'modifyvm', :id,
           '--natdnshostresolver1', "on"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end
end
