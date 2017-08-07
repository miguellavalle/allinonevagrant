#!/usr/bin/env bash

# Script Arguments:
# $1 -  Interface for Vlan type networks
# $2 -  Physical network for Vlan type networks interface in allinone and compute1 "rack"
VLAN_INTERFACE=$1
PHYSICAL_NETWORK=$2

cp /vagrant/provisioning/local.conf.base devstack/local.conf
DESIGNATE_ZONE=my-domain.org.

# Get the IP address
ipaddress=$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)")

# Create bridges for Vlan type networks
sudo ifconfig $VLAN_INTERFACE 0.0.0.0 up
bridge=br-$VLAN_INTERFACE
sudo ovs-vsctl add-br $bridge
sudo ovs-vsctl add-port $bridge $VLAN_INTERFACE

# Adjust local.conf
cat << DEVSTACKEOF >> devstack/local.conf

# Set this host's IP
HOST_IP=$ipaddress

# Enable Neutron as the networking service
disable_service n-net
enable_service placement-api
enable_service neutron
enable_service neutron-api
enable_service q-meta
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service tempest
enable_plugin designate https://git.openstack.org/openstack/designate

[[post-config|\$NEUTRON_CONF]]
[DEFAULT]
service_plugins=router,segments
dns_domain=$DESIGNATE_ZONE 
external_dns_driver=designate

[designate]
url=http://$ipaddress:9001/v2
admin_auth_url=http://$ipaddress:35357/v2.0
admin_username=neutron
admin_password=devstack
admin_tenant_name=service
allow_reverse_dns_lookup=True
ipv4_ptr_zone_prefix_size=24
ipv6_ptr_zone_prefix_size=116

[[post-config|/\$Q_PLUGIN_CONF_FILE]]
[ml2]
type_drivers=flat,vxlan,vlan
tenant_network_types=vxlan,vlan
mechanism_drivers=openvswitch,l2population
extension_drivers=port_security,dns

[ml2_type_vxlan]
vni_ranges=1000:1999

[ml2_type_vlan]
network_vlan_ranges=$PHYSICAL_NETWORK:1000:1999

[ovs]
local_ip=$ipaddress
bridge_mappings=$PHYSICAL_NETWORK:$bridge

[agent]
tunnel_types=vxlan
l2_population=True

[[post-config|\$Q_L3_CONF_FILE]]
[DEFAULT]
router_delete_namespaces=True

[[post-config|\$Q_DHCP_CONF_FILE]]
[DEFAULT]
dhcp_delete_namespaces=True

[[post-config|\$KEYSTONE_CONF]]
[token]
expiration=30000000
DEVSTACKEOF

devstack/stack.sh

source devstack/openrc demo demo
openstack zone create --email malavall@us.ibm.com $DESIGNATE_ZONE

source devstack/openrc admin admin
NET_ID=$(neutron net-create --provider:network_type=vxlan \
    --provider:segmentation_id=2016 --shared --dns-domain $DESIGNATE_ZONE \
    external | grep ' id ' | awk 'BEGIN{} {print $4} END{}')
neutron subnet-create --ip_version 4 --name external-subnet $NET_ID \
    172.31.251.0/24
neutron subnet-create --ip_version 6 --name ipv6-external-subnet $NET_ID \
    fd5e:7a6b:1a62::/64
