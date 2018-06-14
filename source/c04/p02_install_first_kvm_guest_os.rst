===========================================
4.2 安装第一个KVM虚拟化Guest操作系统
===========================================

-----------------------
创建KVM虚拟机的方法
-----------------------

在Ubuntu上创建KVM虚拟机有以下几种方式：

* `virt-manager <http://virt-manager.et.redhat.com/>`_ : GUI工具
* `virt-install <http://www.howtoforge.com/installing-kvm-guests-with-virt-install-on-ubuntu-8.10-server>`_ : Red Hat开发的python脚本，需要安装 ``virtinst`` 包
* ``ubuntu-vm-builder``

.. note::

    推荐使用 `virt-install <https://help.ubuntu.com/16.04/serverguide/libvirt.html#libvirt-virt-install>`_ ，主要原因是通用性 - 这个工具是RedHat开发，可以在RHEL和Ubuntu上使用，并且Ubuntu Server手册主要介绍这个工具。

    `ubuntu-vm-builder <http://manpages.ubuntu.com/manpages/xenial/man1/ubuntu-vm-builder.1.html>`_ 现在只是 `vmbuilder <https://help.ubuntu.com/community/JeOSVMBuilder>`_ （属于 ``pyton-vm-builder`` 包）的wrpper，主要维护用于兼容旧的脚本。

-----------------------
创建虚拟机
-----------------------

* 串口控制台安装Ubuntu 18.04 LTS (Bionic Beaver)

::

    virt-install \
    --name ubuntu1804 \
    --ram 2048 \
    --disk path=/var/lib/libvirt/images/ubuntu1804.qcow2,size=10 \
    --vcpus 1 \
    --os-type linux \
    --os-variant ubuntu16.04 \
    --network bridge=virbr0 \
    --graphics none \
    --console pty,target_type=serial \
    --location 'http://mirrors.163.com/ubuntu/dists/bionic/main/installer-amd64/' \
    --extra-args 'console=ttyS0,115200n8 serial'

.. note::

    上述命令采用了串口控制台安装方法，适合远程在服务器上实施，无需运行VNC。

    串口安装过程完成后，操作系统启动后依然不是默认从串口输出的，需要定制内核启动参数。虚拟机串口输出设置请参考 :ref:`access-vm-console` 。

* 通过VNC方式通过图形界面安装CentOS 7.4

::

    virt-install \
      --network bridge:virbr0 \
      --name centos7 \
      --ram=2048 \
      --vcpus=1 \
      --os-type linux \
      --os-variant rhl7.3 \
      --disk path=/var/lib/libvirt/images/centos7.img,size=10 \
      --graphics vnc \
      --location=http://mirrors.163.com/centos/7/os/x86_64/

.. note::

    通过VNC方式安装操作系统可以方便做一些定制，操作简便。

    需要注意只有虚拟机内存配置2G以上才能启用图形化安装。

-----------------------
参考
-----------------------

* `Easy headless KVM deployment with virt-install <https://blog.zencoffee.org/2016/06/easy-headless-kvm-deployment-virt-install/>`_
* `Installing Virtual Machines with virt-install, plus copy pastable distro install one-liners <https://raymii.org/s/articles/virt-install_introduction_and_copy_paste_distro_install_commands.html>`_
* `virt-install(1) - Linux man page <https://linux.die.net/man/1/virt-install>`_