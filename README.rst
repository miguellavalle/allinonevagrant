=======================================================
Vagrant and VirtualBox DevStack Environment for Neutron
=======================================================

The Vagrant file and shell scripts in this repository deploy OpenStack in an
"all in one" node configuration  using DevStack. The aim is to support
development and testing of Neutron, Routed Networks and the integration with
Nova and Designate in an easily deployable devstack configuration.

The deployed nodes are:

#. An OpenStack control plane, network node and compute node, named
   ``allinone``, containing the following OpenStack services:

   * Identity.
   * Image. 
   * Compute, including control plane and hypervisor.
   * Networking, including control plane, L2 agent and L3 agent in legacy mode
     without high availabiltiy.
   * The Segments service plug-in for Neutron.
   * Block Storage.
   * Designate.
   * Tempest.

During deployment, Vagrant creates the following VirtualBox networks:

#. Vagrant management network for deployment and nodes access to external
   networks such as the Internet. Becomes ``eth0`` network interface in all
   nodes.
#. Management network for the OpenStack control plane and Networking Service
   overlay networks (VXLAN). Becomes the ``eth1`` network interface in all
   nodes.
#. Physical network ``physnet1`` for VLAN type networks / segments. Becomes the
   ``eth2`` network interface in the ``allinone`` node

DevStack installation directory
-------------------------------

All the services enabled in DevStack are installed in ``/opt/stack``. The
``Nova`` and ``Neutron`` repositories are configured as Vagrant ``synced
folders`` with the following mapping:

.. list-table::
   :header-rows: 1
   :widths: 30 30

   * - Host machines
     - Nodes
   * - ~/nova
     - /opt/stack/nova
   * - ~/neutron
     - /opt/stack/neutron

This mapping enables the user to do all the Nova and Neutron development
activities with his / her tools of choice in the host machine, with all the
changes being reflected immediately in the nodes.

.. note::
   ``vim`` is configured in all nodes to support Python development. Besides
   having a proper ``.vimrc`` file for the ``vagrant`` account, the following
   ``vim`` plug-ins are installed and enabled:

   * `Syntastic <https://github.com/scrooloose/syntastic.git>`_ for syntax
     checking, configured with
     `Flake8 <https://flake8.readthedocs.io/en/latest>`_ for Python and pep8.
   * `SimpyFold <https://github.com/tmhedberg/SimpylFold>`_ for Python code
     folding.
   * `delimiMate <https://github.com/Raimondi/delimitMate>`_ for automatic
     closing of quotes, parenthesis, brackets, etc.

Requirements
------------

The default configuration requires approximately 8 GB of RAM. The amount of
resources can be changed in the ``provisioning/virtualbox.conf.yml`` file.

Deployment
----------

#. Install `VirtualBox <https://www.virtualbox.org/wiki/Downloads>`_ and
   `Vagrant <https://www.vagrantup.com/downloads.html>`_.

#. Clone the ``nova`` and ``neutron`` repositories into your home directory::

     $ git clone https://git.openstack.org/openstack/nova.git
     $ git clone https://git.openstack.org/openstack/neutron.git

#. Clone this repository into your home directory and change to it::

     $ git clone https://github.com/miguellavalle/allinonevagrant
     $ cd allinonevagrant

#. Install plug-ins for Vagrant::

     $ vagrant plugin install vagrant-cachier
     $ vagrant plugin install vagrant-vbguest

#. If necessary, adjust any configuration in the
   ``provisioning/virtualbox.conf.yml`` file.

#. Launch Vagrant and grab some coffee::

     $ vagrant up

#. After the process completes, you can use the ``vagrant status`` command
   to determine the status of the ``allinone`` node::

     $ vagrant status
     Current machine states:

     allinone              running (virtualbox)

#. You can access the ``allinone`` node using the following command::

     $ vagrant ssh allinone

#. Access OpenStack services via command-line tools on the ``allinone``
   node or via the dashboard from the host by pointing a web browser at the
   IP address of the ``allinone`` node.

   .. note::
   By default, OpenStack includes two accounts: ``admin`` and ``demo``, both
   using password ``devstack``. Keystone has been configured to issue token
   with a life of 1 year.

#. You can save the state of the entire configuration::
     
     $ vagrant suspend

#. After completing your tasks, you can destroy the configuration::

     $ vagrant destroy
