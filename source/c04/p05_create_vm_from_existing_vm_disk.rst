============================
4.5 从虚拟机镜像磁盘创建虚拟机
============================

很多时候，我们已经创建过的虚拟机需要迁移到其他HOST主机上运行（例如升级替换硬件），也就是在现有的虚拟机镜像磁盘上启动虚拟机。此时，我们不需要从头开始安装操作系统，只需要导入镜像，采用合适的配置启动器虚拟机。

.. note::

    在虚拟机镜像导入时，经常会遇到别人提供给你的镜像磁盘格式不是 ``qcow2`` 格式，例如在微软hypervisor平台常用的 ``vpc`` 格式（ ``.vhd``文件后缀 ），而在阿里云导出的镜像格式默认为 ``raw``（ 参考阿里云ECS帮助： `导出自定义镜像 <https://www.alibabacloud.com/help/zh/doc-detail/58181.htm>`_ ）。

    详细的虚拟机磁盘镜像转换方法请参考下一章 :ref:`qemu-img-convert`

.. _virt-install-import:

-------------------------------------
导入镜像启动虚拟机
-------------------------------------

假设我们现在有一个阿里云平台有一个Windows 2016虚拟机，现在导出下载到本地沙箱环境测试，我们可以采用如下方法

* 首先将下载的镜像文件转换成 ``qcow2`` 格式：

::

    qemu-img convert -O qcow2 wind2016_xxxx.raw win2016.qcow2

* 将转换后的QEMU镜像文件存放到 libvirt 默认的镜像目录，并设置好相应的权限

::

    mv win2016.qcow2 /var/lib/libvirt/images/
    chown root:root /var/lib/libvirt/images/win2016.qcow2
    chmod 600 /var/lib/libvirt/images/win2016.qcow2

* ``virt-install`` 现有存在的磁盘镜像创建KVM VM，使用 ``--import`` 参数

::

    virt-install --name win2016 --ram=2048 --vcpus=2 --os-type=windows --os-variant=win2k12r2 \
    --disk /var/lib/libvirt/images/win2016.qcow2,device=disk,bus=virtio \
    --network bridge=virbr0,model=virtio --vnc --noautoconsole --import

.. note::

    使用 ``osinfo-query os`` 可以找到 ``os-variant`` 参数所有支持的类型。不过，不是所有os类型都支持，我选择最接近的os类型。

上述命令执行很快结束，此时检查系统可以看到虚拟机启动

::

    $ virsh list
     Id    Name                           State
    ----------------------------------------------------
     1     win2016                        running

上述虚拟机提供了VNC输出，但是，当你使用 ``virsh dumpxml win2016`` 检查虚拟机配置，可以看到VNC仅监听在服务器的回环地址 ``127.0.0.1`` ，这是为了安全原因不直接暴露VNC端口。带来的麻烦是无法直接通过VNC客户端远程访问。



------------
参考
------------

* `KVM Guests: Using Virt-Install to Import an Existing Disk Image <https://www.itfromallangles.com/2011/03/kvm-guests-using-virt-install-to-import-an-existing-disk-image/>`_