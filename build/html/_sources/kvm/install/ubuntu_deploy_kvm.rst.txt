.. _ubuntu_deploy_kvm:

===================
Ubuntu部署KVM
===================

准备工作
===========

运行KVM前，需要确定处理器是否支持硬件虚拟化，Intel或AMD处理器分别称其为 ``VT-x`` 和 ``AMD-V`` ::

   egrep -c '(vmx|svm)' /proc/cpuinfo

如果上述输出显示为 ``0`` 表明处理器不支持硬件虚拟化。 ``1`` 或以上责表示处理器支持，但是依然需要在BIOS中开启。

.. note::

   如果操作系统使用了XEN内核，就不会显示 ``svm`` 或者 ``vmx`` 标记，此时在XEN环境需要使用如下方法::

      cat /sys/hypervisor/properties/capabilities

   同样需要在输出中看到 ``hvm`` 标记。

- 如果Ubuntu系统安装了 ``cpu-checker`` 软件包( 会同时安装 ``cpu-checker`` 和 ``msr-tools`` 软件包 )，则可以使用 ``kvm-ok`` 命令::

   kvm-ok

提示显示::

   INFO: /dev/kvm exists
   KVM acceleration can be used

如果输出显示如下::

   INFO: Your CPU does not support KVM extensions
   KVM acceleration can NOT be used

则依然可以运行虚拟机，但是没有KVM扩展支持则运行缓慢。

使用64位内核
----------------

由于32位操作系统会限制VM只能使用2G内存，并且在32位操作系统中无法运行64位虚拟机，所以强烈建议物理主机安装64位操作系统。

- 要检查处理器是否是64位，可以使用如下方法::

   egrep -c ' lm ' /proc/cpuinfo

输出计数大于0就是64位处理器。

- 检查内核是否是64位::

   uname -m

输出显示::

   x86_64

则表示是64位内核，如果输出i386, i486, i586 或 i686则是32位内核。

安装KVM
=========

安装必要软件包
-----------------

- Ubuntu 18.10及以上版本::

   sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst

- Ubuntu 16.04及以上版本::

   sudo apt install qemu-kvm libvirt-bin virtinst

.. note::

   我的安装命令中附加安装了 ``virtinst`` 工具包，原因是我习惯于redhat提供的 ``virt-install`` 安装工具

   Ubuntu文档建议的安装方法和我上述不同：

   - Lucid (10.04) 及以后版本::

      sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils

   - Karmic (9.10) 或早期版本::

      sudo aptitude install kvm libvirt-bin ubuntu-vm-builder bridge-utils

   我做了修订是因为: ``ubuntu-vm-builder`` 命令行工具提供构建虚拟机，这个工具并不好用，所以我还是使用 ``virt-install`` ( ``virtinst`` 软件包 )
   
安装的软件包说明:

  - ``libvirt-bin`` / ``libvirt-daemon-system`` 提供 ``libvirtd`` 用于通过libvirt管理qemu和kvm
  - 后端使用 ``qemu-kvm`` （早期Kamic及更早版本使用 ``kvm`` ）
  - ``bridge-utils`` 提供虚拟机网络的网桥

添加用户到用户组
--------------------

- Karmic(9.10)及以后版本（但不包括14.04 LTS）需要确保用户已经添加到组 ``libvirt`` 中::

   sudo adduser `id -un` libvirt

然后需要重新登陆系统以便 ``libvirt`` 用户组成员身份生效。这个组的成员可以运行虚拟机。

- Karmic(9.10)之前版本加入 ``kvm`` 组::

   sudo adduser `id -un` kvm

- 检查::

   $ virsh list --all
    Id   Name   State
   --------------------

如果看到报错，例如无法访问sock文件，可以检查 ``/var/run/libvirt/libvirt-sock`` 文件权限::

   $ sudo ls -la /var/run/libvirt/libvirt-sock
   srw-rw---- 1 root libvirt 0 Oct 12 15:51 /var/run/libvirt/libvirt-sock

上述 ``libvirt-sock`` 文件对于 ``libvirt`` 组用户是可以读写执行的，所以才能够以普通用户身份运行 ``virsh`` 命令。

此外可能在创建虚拟机时遇到问题，则检查 ``kvm`` 设备的属主::

   $ ls -lh /dev/kvm
   crw-rw---- 1 root kvm 10, 232 Oct 12 04:05 /dev/kvm

可以看到 ``kvm`` 设备的组属主是 ``kvm`` 用户组，则需要调整成 ``libivrt`` 组（因为前面我们将自己的账号放入了 ``libvirt`` 组），或者将自己账号再放入到 ``kvm`` 组::

   sudo adduser `id -un` kvm

注意：如果你采用修改 ``/dev/kvm`` 设备属主，则需要重新启动内核模块::

   rmmod kvm
   modprobe -a kvm

参考
=====

- `KVM/Installation <https://help.ubuntu.com/community/KVM/Installation>`_
