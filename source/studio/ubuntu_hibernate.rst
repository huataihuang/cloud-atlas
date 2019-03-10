.. _ubuntu_hibernate:

=======================
Ubuntu Hibernate休眠
=======================

在 :ref:`ubuntu_on_mbp` 实现 :ref:`kvm_docker_in_studio` ，可以模拟出集群进行实践。在使用中，经常需要把笔记本携带在身边，每次都需要开关电脑，实际上就会不断重启虚拟机。对于恢复工作环境非常麻烦。

Linux支持 ``Suspend`` (挂起到内存) 和 ``Hibernate`` (挂起到磁盘) ，建议使用 ``Hibernate`` ，这样可以把内存中数据完全存储到磁盘，就可以断开电源，也不会出现因电能不足而关机。

不过，Linux上到Hibernate实现起来有点曲折，我的实践：

- `fedora系统使用systemd设置Hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/redhat/system_administration/systemd/hibernate_with_fedora_in_laptop.md>`_ 
- `Gentoo系统的suspend和hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/gentoo/suspend_hibernate.md>`_
- `Ubuntu系统hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/system_administration/ubuntu_hibernate.md>`_

测试Ubuntu Hibernate
==================================

- 检查内核是否支持Hibernate::

   cat /sys/power/state

输出中包含 ``disk`` 就表明支持Hibernate，例如::

   freeze mem disk

要验证当前系统是否已经支持Hibernate，只需要执行如下命令::

   sudo systemctl hibernate

如果系统能够自动保存所有当前状态，并且在按下电源键自动恢复原先的工作状态则表明已经支持了hibernate。不过，很不幸，默认的系统验证下来是直接关机了。

创建Hibernate使用的swap文件
==============================

在hibernate状态（HTD或ACPI S4）主机的状态需要写入磁盘，这样就无需电力维持。这个状态是通过写入swap分区或swap文件实现的。

.. warning::

   不要使用BTRFS尝试使用swap文件，这会导致文件系统损坏！！！

swap分区或swap文件需要和RAM一样大小，或者至少 2/5的内存大小，参考 `About swap partition/file size <https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#About_swap_partition.2Ffile_size>`_ 可以看到 ``/sys/power/image_size`` 设置了suspend-to-disk创建映像的大小，默认这个值设置的是内存的2/5大小。如果将数值 ``0`` 写入到 ``/sys/power/image_size`` 则系统会尽可能缩小suspend镜像。通过调整 ``/sys/power/image_size`` 你可以使得suspend镜像尽可能小，或者增加这个值以便hibernate处理速度更快。

.. note::

   这里建议可以设置swap分区至少 2/5 的内存大小是假设系统内存足够，这样一般情况下系统不会使用swap，所以就可以把所有swap都用于hibernate，也就是默认的 2/5 内存大小的swap应该也够用于保存内存状态。

实际我采用了 ``2/5 内存 + 2G`` 的swap大小，这是因为默认Ubuntu安装就设置了2G的swap文件，我再加上 2/5 的内存大小swap文件来做保障。我的笔记本是16G内存，所以，我设置了 ``/swapfile`` 文件 2G， ``/swapfile1`` 文件 7G::

   sudo fallocate -l 7g /swapfile1
   sudo chmod 600 /swapfile1
   sudo mkswap /swapfile1
   sudo swapon /swapfile1
   echo '/swapfile1  none  swap  sw  0  0' | sudo tee -a /etc/fstab

.. note::

   在之前测试通过内核参数传递的 ``resume=`` 参数是指磁盘设备名，通常是磁盘swap分区。如果使用swap文件，则需要指定swap文件所在的磁盘分区，同时加上这个磁盘文件的物理偏移量（ ``physical_offset`` ）。这种内核参数传递方法，请参考我之前的测试:

   `Ubuntu系统hibernate休眠 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/system_administration/ubuntu_hibernate.md>`_

安装uswsusp
================

- 安装用户空间软件suspend -- Userspace Software Suspend (uswsusp)::

   sudo apt install uswsusp

安装过程就会提示::

   The swap file or partition that was found in uswsusp's configuration file is not active. 
   In most cases this means userspace software suspend will not work as expected. You should choose another swap space.
   However, in some rare cases, this configuration may be intentional. 
   Continue without a valid swap space?

这里可以暂时回答Yes，因为我们下一步会进行配置。

配置uswsusp
=====================

- 验证Swap文件分区::

   sudo findmnt -no SOURCE,UUID -T /swapfile1

输出显示::

   /dev/sda2 decda038-1b51-4483-9491-15c3a640e133

- 创建 ``/etc/uswsusp.conf`` ，即执行::

   sudo dpkg-reconfigure -pmedium uswsusp

此时再次显示之前的提示::

   The swap file or partition that was found in uswsusp's configuration file is not active. 
   In most cases this means userspace software suspend will not work as expected. You should choose another swap space.
   However, in some rare cases, this configuration may be intentional. 
   Continue without a valid swap space?

这里选择：

- ``Yes`` 表示 ``Continue without a valid swap space?`` （此时Wizard还没有设置swap文件）
- 在下一个选择问题::

   To be able to suspend the system, uswsusp needs a swap partition or file to store a system snapshot. Please choose the device to use, from the list of suitable swap spaces, sorted by size (largest first).

   Swap space to resume from:

                              /swapfile1
                              /swapfile
                              /dev/disk/by-uuid/decda038-1b51-4483-9491-15c3a640e133

注意：选择 swap 文件所在的 ``partition`` ，即之前的命令 ``findmnt`` 输出的内容， ``不要`` 选择swap文件自身。所以，我们这里选择最后一行 ``/dev/disk/by-uuid/decda038-1b51-4483-9491-15c3a640e133``

- 在下一个页面中提问是否加密suspend内容（会影响速度）::

   For increased security, it is possible to encrypt the snapshot that is written to disk during suspend. On resume (and suspend if you don't use an RSA key), you will be prompted for a passphrase. Encryption adds a significant time to the suspend and resume processes.

   Encrypt snapshot?

安全要求不高，我选择默认 ``No`` 不加密

- 检查swap文件的 ``swap_id`` ::

   sudo -s swaplabel /swapfile1

输出显示::

   UUID:  2a91e2a6-e0fc-431f-94d2-1dff3241dcbf

- 创建文件 ``/etc/initramfs-tools/conf.d/resume`` 加入 ``swap_id`` ::

   echo "RESUME=UUID=2a91e2a6-e0fc-431f-94d2-1dff3241dcbf" > /etc/initramfs-tools/conf.d/resume

   update-initramfs -u

- 测试Hibernate::

   sudo s2disk

此时看到屏幕一闪进入终端模式，并显示在保存image。保存过程结束后，笔记本关机。再次按下电源按钮，会有一个image恢复过程，然后就会恢复到之前的图形界面。

参考
=========

- `How can I hibernate on Ubuntu 16.04? <https://askubuntu.com/questions/768136/how-can-i-hibernate-on-ubuntu-16-04>`_ 其中最重要的一个解决方案是 "Hibernation using systemctl and getting it working in tough cases" ，在这篇问答的第2个回答中。
