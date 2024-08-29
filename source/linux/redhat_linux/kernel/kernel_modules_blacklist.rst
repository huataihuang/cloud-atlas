.. _kernel_modules_blacklist:

=================================
禁止自动加载内核模块
=================================

.. note::

   我在 :ref:`install_nvidia_linux_driver` 实践中乌龙，导致反复排查内核模块自动加载问题。内核模块自动加载的防范有多种方法，本文试图按照最新Linux操作系统进行整理，为后续相关运维打基础。
   
   `How do I prevent a kernel module from loading automatically? <https://access.redhat.com/solutions/41278#EarlyBootStageModuleUnloading>`_ Red Hat官方知识库文档英文版写得非常详尽，但是中文版只是一个非常简略的早期版本，所以本文会详细记录一下不同版本RedHat的配置方法，但实践在Fedora 35上进行，相当于Red Hat Enterprise Linux 8/9

很多时候，我们需要禁止内核自动加载模块，例如 :ref:`install_nvidia_linux_driver` ，就需要屏蔽掉冲突的开源驱动 ``nouveau`` 内核模块。此外有些硬件设备我们并不希望启用，可能也需要通过禁止内核特定驱动模块来禁用设备。

说明
======

- 为防止在引导期间加载内核模块，必须将模块名称添加到 ``modprobe`` 程序的配置文件，该配置文件必须位于 ``/etc/modprobe.d`` 目录下
- 在屏蔽内核模块之前，必须确保被屏蔽模块没有配置在 ``/etc/modprobe.conf`` , ``/etc/modprobe.d/*`` 以及 ``/etc/rc.modules`` 或 ``/etc/sysconfig/modules/*`` 这些配置文件中加载 (避免冲突)
- RHEL 5、6、7、8 和 9 的有一些共享配置步骤，但是每个版本也有一些特定步骤，需要完成对应版本的所有配置才能确保不加载需要屏蔽的内核模块。

RHEL 5, 6, 7, 8 和 9共有的初始配置步骤
=========================================

由于内核模块可以直接加载，也可以作为另一个模块的依赖项加载，或者由于启动过程中加载: 所以我们必须采用多种步骤来防止模块被加载( 有点小复杂 ):

- [步骤1]如果运行的系统已经加载了内核模块，我们需要先卸载内核模块::

   modprobe -r module_name

- [步骤2]为防止模块被加载，需要将黑名单添加于 ``/etc/modprobe.d/`` 目录下的配置文件，例如名为 ``local-dontload.conf`` (名字不重要，主要是文件中配置项 ``blacklist`` )::

   echo "blacklist module_name" >> /etc/modprobe.d/local-dontload.conf

- [步骤3]在 ``/etc/modprobe.d/local-dontload.conf`` 配置中添加 ``install`` 行使得模块只会运行 ``/bin/false`` 而不是安装模块::

   echo "install module_name /bin/false" >> /etc/modprobe.d/local-dontload.conf

RHEL 8 和 9特定步骤
====================

- [步骤4]备份 ``initramfs`` ::

   cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.$(date +%m-%d-%H%M%S).bak

- [步骤5]如果内核模块是 ``initramfs`` 的一部分，可以通过以下命令检查::

   lsinitrd /boot/initramfs-$(uname -r).img|grep module-name.ko

.. note::

   ``lsinitrd`` 工具位于 ``dracut-core`` 软件包，在Ubuntu上需要单独安装

确定内核模块已经包含在 ``initramfs`` 中，则需要重新build initramfs 的ramdisk镜像，避免包含模块::

   dracut --omit-drivers module_name -f

为了在今后内核升级和initramfs重建时持续屏蔽掉指定内核模块，可以将配置添加到 ``dracut`` 的配置中::

   MODNAME="module_name"; echo "omit_dracutmodules+=\"$MODNAME\"" >> /etc/dracut.conf.d/omit-$MODNAME.conf

.. note::

   在 Ubuntu 系统中，提供了一个 ``update-initramfs`` 工具，可以读取 ``/etc/modprobe.d`` 目录下配置，就能将 ``blacklist`` 的屏蔽内核模块去除::

      update-initramfs -u -k $(uname -r)

- [步骤6]获取当前内核命令行参数::

   grubby --info DEFAULT
   grubby --info ALL

- [步骤7]在内核参数上添加 ``module_name.blacklist=1 rd.driver.blacklist=module_name`` ，这样RHEL8 和RHEL9的 ``grubby`` 工具就会修改内核参数::

   grubby --args  "module_name.blacklist=1 rd.driver.blacklist=module_name"  --update-kernel ALL

这个内核参数修改我建议直接修改 ``/etc/default/grub`` 配置，然后执行 ``update-grub`` 工具来修订

- [步骤8]备份kdump initramfs::

   cp /boot/initramfs-$(uname -r)kdump.img /boot/initramfs-$(uname -r)kdump.img.$(date +%m-%d-%H%M%S).bak

- [步骤9]将kdump initramfs也忽略模块，配置方法也是添加内核参数 ``rd.driver.blacklist=module_name`` ::

   sed -i '/^KDUMP_COMMANDLINE_APPEND=/s/"$/ rd.driver.blacklist=module_name"/' /etc/sysconfig/kdump

- [步骤10]重启kdump服务::

   kdumpctl restart

- [步骤11]重新build kdump initial ramdisk镜像::

   mkdumprd -f /boot/initramfs-$(uname -r)kdump.img

- [步骤12] 重启系统使修改生效::

   reboot

RHEL 7特定步骤
====================

- [步骤4] 备份initramfs::

   cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.$(date +%m-%d-%H%M%S).bak

- [步骤5] 如果内核模块是initramfs的组成部分，也需要使用 ``dracut`` 来删除掉内核模块::

   dracut --omit-drivers module_name -f

并且建议将配置持久化到内核更新和initramfs重建流程::

   MODNAME="module_name"; echo "omit_dracutmodules+=\"$MODNAME\"" >> /etc/dracut.conf.d/omit-$MODNAME.conf

- [步骤6]修订内核参数::

   sed -i '/^GRUB_CMDLINE_LINUX=/s/"$/ module_name.blacklist=1 rd.driver.blacklist=module_name"/' /etc/default/grub

- [步骤7]重新安装grub2::

   grub2-mkconfig -o /boot/grub2/grub.cfg

如果系统使用UEFI，则输出路径是 `` /boot/efi/EFI/redhat/grub.cfg`` ::

   grub2-mkconfig -o /boot/grub2/grub.cfg

- [步骤8]备份kdump initramfs::

   cp /boot/initramfs-$(uname -r)kdump.img /boot/initramfs-$(uname -r)kdump.img.$(date +%m-%d-%H%M%S).bak

- [步骤9]添加 ``rd.driver.blacklist=module_name`` 到 ``/etc/sysconfig/kdump`` 的配置项 ``KDUMP_COMMANDLINE_APPEND`` ::

   sed -i '/^KDUMP_COMMANDLINE_APPEND=/s/"$/ rd.driver.blacklist=module_name"/' /etc/sysconfig/kdump

- [步骤10]重启kdump服务使修改作用到kdump的initrd::

   kdumpctl restart

- [步骤11]重建kdump initial ramdisk镜像::

   mkdumprd -f /boot/initramfs-$(uname -r)kdump.img

- [步骤12]重启系统生效::

   reboot

参考
=======

- `How do I prevent a kernel module from loading automatically? <https://access.redhat.com/solutions/41278#EarlyBootStageModuleUnloading>`_ Red Hat官方知识库文档英文版写得非常详尽，特别是分别对现代RHEL 7/8/9 操作进行详述，适合现代化的各种Linux发行版，例如 Ubuntu 等
