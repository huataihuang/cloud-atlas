.. _qemu_simple_bridge_network:

=========================
QEMU简单bridge网络设置
=========================

在 :ref:`blfs_qemu` 安装配置中，使用了BLFS提供的脚本来初始化QEMU的bridge网络 ``br0`` ，实际上通过简单的 ``bridge-utils`` 提供的命令行工具也能快速完成:

命令行设置
==========

- 配置 ``br0`` bridge设备并连接 ``eno1`` 物理网卡

.. literalinclude:: qemu_simple_bridge_network/brctl
   :caption: 使用 ``brctl`` 命令配置QEMU的bridge网络

- 配置iptables/nftables来转发bridge网络流量:

.. literalinclude:: qemu_simple_bridge_network/iptables
   :caption: 设置bridge网络的流量转发

- 使用时只需要在 :ref:`qemu` 运行命令添加类似 ``-net nic,model=virtio,macaddr=52:54:00:00:00:01 -net bridge,br=br0`` 就可以，案例见 :ref:`run_debian_in_qemu` :

持久化设置
===========

- 在 ``/lib/systemd/system/`` 目录下创建 ``qemu-startup.service`` 配置(这里假设使用 :ref:`systemd` ):

.. literalinclude:: qemu_simple_bridge_network/qemu-startup.service
   :caption: 配置systemd

参考
=======

- `Really Simple Network Bridging With qemu <https://www.spad.uk/posts/really-simple-network-bridging-with-qemu/>`_
- `Network bridge for QEMU <https://guix.gnu.org/cookbook/en/html_node/Network-bridge-for-QEMU.html>`_ 介绍了nmcli操作方法(基于系统使用 :ref:`networkmanager` )
- `How to set up a network bridge for virtual machine communication <https://www.redhat.com/en/blog/setup-network-bridge-VM>`_ RedHat官方博客介绍通过 :ref:`nmtui` 来配置bridge方法，也是基于 :ref:`networkmanager`
