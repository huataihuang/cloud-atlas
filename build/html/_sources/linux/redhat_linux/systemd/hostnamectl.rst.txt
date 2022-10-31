.. _hostnamectl:

=================
hostnamectl
=================

systemd的 ``hostnamectl`` 工具提供了服务器主机名的管理修订功能，并且提供了对主机常用信息的清晰提取

基本使用
=========

- 不带任何参数执行 ``hostnamectl`` 可以输出主机的关键信息:

.. literalinclude:: hostnamectl/fedora_hostnamectl_output
   :language: bash
   :caption: Fedora 35 执行hostnamectl输出信息

可以看到 ``hostnamectl`` 输出信息包括了:

- 主机是物理主机还是虚拟机，虚拟化技术类型( :ref:`kvm` )
- 硬件架构( ``x86_64`` )以及硬件厂商信息(对于虚拟机也会提供相应信息)

对于物理主机，例如在 :ref:`hpe_dl360_gen9` 上运行的 :ref:`ubuntu_linux` 执行 ``hostnamectl`` 输出案例:

.. literalinclude:: hostnamectl/ubuntu_hostnamectl_output
   :language: bash
   :caption: Ubuntu 22.04 hostnamectl 执行输出信息

持久化设置
===========

- 对于主机名配置的持久化设置(也就是重启服务器不变的配置)，需要使用 ``--static`` 参数来执行 ``set-hostname`` 命令::

   hostnamectl --static set-hostname zcloud.staging.huatai.me

- 显示当前静态主机名::

   hostnamectl --static

则显示::

   zcloud.staging.huatai.me

此时检查 ``/etc/hostname`` 可以看到内容被替换成::

   zcloud.staging.huatai.me

附加信息(Supplementary settings)
=================================

上述 ``hostnamectl`` 输出的主机基本信息是操作系统安装默认生成的一些配置信息。此外， :ref:`systemd` 还在 ``hostnamectl`` 标准化配置上提供了一些对于主机管理有用的信息记录位于 ``/etc/machine-id`` 。不过， ``machine-id`` 不是默认生成的，需要通过一些指令来修改(直接生成也行)，可以帮助系统管理员管理大量的数据中心服务器，来构建CMDB(配置管理)

- 设置 pretty hostname::

   hotnamectl --pretty set-hostname "Priv Cloud Infra - ZCloud"

装饰主机名(pretty hostname)可以为主机名添加有用的附加信息，此时 ``cat /etc/machine-info`` 可以看到::

   PRETTY_HOSTNAME="Priv Cloud Infra - ZCloud"

- 设置主机图标(icon-name)::

   hostnamectl set-icon-name linux-vm

对于物理主机，可以设置::

   hostnamectl set-icon-name computer-server

- 设置主机底盘(chassis)::

   hostnamectl set-chassis vm

对于物理主机，可以设置::

   hostnamectl set-chassis server

- 设置主机部署(development, staging, production)，这里设置为 ``staging`` 环境::

   hostnamectl set-deployment staging

也就是在 ``/etc/machine-info`` 中添加了::

   DEPLOYMENT=staging

- 设置主机安装位置(可以设置为机房，机架，机位信息)::

   # 这里我杜撰一个机位信息，实际可以根据公司机房机位命名规则设置这个信息，方便程序解析
   hostnamectl set-location "R00.C1-1.SH"

- 最终完成检查，可以 ``cat /etc/machine-info`` 看到类似如下信息::

   PRETTY_HOSTNAME="Priv Cloud Infra - ZCloud"
   DEPLOYMENT=staging
   LOCATION=R00.C1-1.SH

machine-id
============

在使用 ``hostnamectl`` 输出主机信息的时候，你可能会注意到有一个 ``machine-id`` 类似::

   Machine ID: 63189bc6f6c149598d5bef3afa0cbf40

这是 ``/etc/machine-id`` 文件的内容，是安装或引导期间设置的本地系统的唯一机器ID(以换行符结尾的十六进制32个字符的小写ID)

:ref:`systemd` 和 dbus 都使用这个 ``machine-id`` 来跟踪机器ID，并且历史原因 ``/var/lib/dbus/machine-id`` 是软连接到 ``/etc/machine-id`` 上(实际文件是 ``/etc/machine-id`` )

``machine-id`` 的目的是为主机(或者更准确说是操作系统安装)提供唯一标识符，在网络中每个主机都应该有唯一的 ``machine-id`` : 如果多台主机的 ``machine-id`` 相同，会出现非常奇怪的现象。

``machine-id`` 的用途:

- 创建 DHCP 主机标识符（可能导致多台机器争夺 DHCP 服务器上的同一 IP 地址）
- systemd-boot EFI 引导加载程序将操作系统安装的内核存储在以机器 ID 命名的目录中，以防止冲突
- clone系统时会生成新的 ``machine-id``

chroot和容器通常没有systemd和sysvinit，但是建议为其配置 ``machine-id`` 以做区分

参考
=======

- `Configuring Host Names Using hostnamectl <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec_configuring_host_names_using_hostnamectl>`_
- `How to change system hostname <https://sleeplessbeastie.eu/2020/06/22/how-to-change-system-hostname/>`_ 有意思的主机名设置案例，没有想到实际上可以在标准化的hostname提供很多附加信息，其实非常方便在CMDB(配置管理)结合使用，也就是能够标准化存储主机相关信息，如服务器位置、用途等等
- `debian wiki: machine id <https://wiki.debian.org/MachineId>`_
