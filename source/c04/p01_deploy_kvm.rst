===========================================
4.1 部署KVM
===========================================

.. note::

    沙箱环境物理主机操作系统Ubuntu 16.04 LTS

物理主机列表：

* ``dc-1``
* ``dc-2``

-----------------
KVM部署前环境检查
-----------------

* 确定处理器是否支持硬件虚拟化

运行KVM前，需要确定处理器是否支持硬件虚拟化，Intel或AMD处理器分别称其为 ``VT-x`` 和 ``AMD-V``

::

    egrep -c '(vmx|svm)' /proc/cpuinfo

如果上述输出显示为 ``0`` 表明处理器不支持硬件虚拟化。 ``1`` 或以上责表示处理器支持，但是依然 **需要在BIOS中开启虚拟化支持** 。

* 64位处理器

要检查处理器是否是64位，可以使用如下方法：

::

    egrep -c ' lm ' /proc/cpuinfo


输出计数大于 ``0`` 就是64位处理器。

* 64位内核

检查内核是否是64位，使用命令：

···
uname -m
···

> 输出 ``x86_64`` 表示运行64位内核。如果输出 ``i386`` , ``i486`` ,  ``i586`` 或 ``i686`` 则为 ``32`` 位内核。

-----------------
安装KVM
-----------------

* 采用如下安装方法（Ubuntu 16.04及以上版本）

::

    sudo apt install qemu-kvm libvirt-bin virtinst

.. note::

    ``virt-install`` 是虚拟机命令行安装工具，原为Red Hat系列发行版所使用，比Ubuntu发行版所使用的类似工具 ``ubuntu-vm-builder`` 要好用。

-----------------
配置用户账号权限
-----------------

* Karmic(9.10)及以后版本（但不包括14.04 LTS）需要确保用户已经添加到组 ``libvirtd`` 中

::

    sudo adduser `id -un` libvirtd

.. note::

    添加自己的账号到 ``libvirtd`` 用户组则后续登陆系统不需要 ``sudo`` 切换到 ``root`` 账号就可以直接使用 ``virsh`` 工具命令管理 ``libvirt`` 。

重新登陆系统后，作为 ``libvirtd`` 用户组成员，即可以检查和操作虚拟机：

::

    $ virsh list --all
     Id    Name                           State
    ----------------------------------------------------

如果看到报错，例如无法访问 ``sock`` 文件，可以检查 ``/var/run/libvirt/libvirt-sock`` 文件权限：

::

    $ sudo ls -la /var/run/libvirt/libvirt-sock
    srwxrwx--- 1 root libvirtd 0 Mar 15 04:20 /var/run/libvirt/libvirt-sock

.. note::

    注意：上述 ``libvirt-sock`` 文件对于 ``libvirtd`` 组用户是可以读写执行的，所以才能够以普通用户身份运行 ``virsh`` 命令。

如果创建虚拟机时遇到问题，则检查 ``kvm`` 设备的属主：

::

    $ ls -lh /dev/kvm
    crw-rw----+ 1 root kvm 10, 232 Mar 15 04:20 /dev/kvm

可以看到 ``kvm`` 设备的组属主是 ``kvm`` 用户组，则需要调整成 ``libivrtd`` 组（因为前面我们将自己的账号放入了 ``libvirtd`` 组），或者将自己账号再放入到 ``kvm`` 组：

::

    sudo adduser `id -un` kvm

.. warning::

    如果你采用修改 ``/dev/kvm`` 设备属主，则需要重新启动内核模块或者 ``relogin``

::

    rmmod kvm
    modprobe -a kvm

----

以上我们已经初步安装完成了KVM虚拟化运行环境，下一步我们将安装启动第一个虚拟机。

-----------
参考
-----------

* `KVM/Installation <https://help.ubuntu.com/community/KVM/Installation>`_