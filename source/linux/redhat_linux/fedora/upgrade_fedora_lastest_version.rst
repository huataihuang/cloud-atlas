.. _upgrade_fedora_lastest_version:

===========================
升级Fedora最新发行版本
===========================

.. note::

   Fedora 支持从不同低版本( :strike:`34/33` ，最多支持两代跨越，也就是最多支持 35 或 36) 直接升级到最新的 Fedora 37 

   我最初安装部署的 ``z-dev`` 版本是 Fedora 35，Fedora 37正式发布时做一次全面的版本升级，以体验最新的Linux技术

   升级需要较大的磁盘空间，我在最初构建虚拟机时候采用了非常小的初始磁盘。所以升级过程中DNF提示磁盘空间不足，采用 :ref:`libvirt_lvm_pool_resize_vm_disk` 将磁盘扩展到 :strike:`32G` 42G

- 更新所有系统已经安装的软件包:

.. literalinclude:: upgrade_fedora_lastest_version/dnf_refresh_upgrade
   :language: bash
   :caption: 更新操作系统的所有软件包

- 重启操作系统

- 安装/升级 ``dnf-plugin-system-upgrade`` 软件包:

.. literalinclude:: upgrade_fedora_lastest_version/install_dnf-plugin-system-upgrade
   :language: bash
   :caption: 安装 dnf-plugin-system-upgrade

- 下载更新软件包:

.. literalinclude:: upgrade_fedora_lastest_version/download_releasever_37
   :language: bash
   :caption: 下载Fedora 37更新软件包

如果一切检查正常，提示信息类似::

   ...
   Running transaction check
   Transaction check succeeded.
   Running transaction test
   Transaction test succeeded.
   Complete!
   Transaction saved to /var/lib/dnf/system-upgrade/system-upgrade-transaction.json.
   Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
   To remove cached metadata and transaction use 'dnf system-upgrade clean'
   The downloaded packages were saved in cache until the next successful transaction.
   You can remove cached packages by executing 'dnf clean packages'.

- 开始升级:

.. literalinclude:: upgrade_fedora_lastest_version/system-upgrade_reboot
   :language: bash
   :caption: 执行升级重启

升级完成后操作
================

大多数配置文件存放在 ``/etc`` 目录。如果修改过默认配置，则RPM安装会创建一个 ``.rpmnew`` 文件(也就是新版本的默认配置)或者 ``.rpmsave`` (旧的配置文件备份)。可以搜索这些文件，或使用 ``rpmconf`` 工具来处理::

   sudo dnf install rpmconf

然后执行::

   sudo rpmconf -a

.. note::

   对于使用BIOS的系统，会升级 ``GRUB`` rpm，但是安装或内嵌的bootloader不会自动升级，所以建议在fedora升级后执行一次重新安装升级::

      sudo mount | grep "/boot "
      # 假设这里显示 /dev/sda4 on /boot type ext4 (rw,relatime,seclabel)
      # 则执行
      sudo grub2-install /dev/sda

- 清理无用软件包

一些旧版本的软件包在新版本中已经不不再升级，也不再使用，建议删除:

如果只跨了一个版本升级(从Fedora 36升级到37)，则执行::

   sudo dnf install remove-retired-packages
   remove-retired-packages

如果跨2个版本升级(从Fedora 35升级到37)，则执行::

   sudo dnf install remove-retired-packages
   remove-retired-packages 35

- 清理旧软件包

先查看已经没有依赖关系的孤儿包::

   sudo dnf repoquery --unsatisfied

通过如下命令查看是否存在重复包(也就是安装了多个版本的软件包)::

   sudo dnf repoquery --duplicates

查看是否有不属于软件仓库的软件包::

   sudo dnf list extraso

上述软件包可以通过以下命令清理::

   sudo dnf remove $(sudo dnf repoquery --extras --exclude=kernel,kernel-\*)

- 清理不再使用的软件包::

   sudo dnf autoremove

- 清理旧软连接::

   # 检查
   sudo symlinks -r /usr | grep dangling
   # 清理
   sudo symlinks -r -d /usr

一些可能问题处理方法
=======================

- 如果出现一些RPM/DNF报错，可能是rpm数据库损坏，通过以下命令修复::

   sudo rpm --rebuilddb

- 系统升级默认使用了 ``dnf distro-sync`` ，但是可能会遇到软件包依赖错误，尝试以下修复方法::

   sudo dnf distro-sync

对于一些不再安全的依赖，可以通过以下方式检查::

   sudo dnf distro-sync --allowerasing

- 如果出现SELinux相关策略告警，可能是SELinux权限设置问题，执行::

   sudo fixfiles -B onboot

参考
========

- `Upgrade to Fedora 37 from Fedora 36 using DNF <https://www.if-not-true-then-false.com/2022/upgrade-to-fedora-37-using-dnf/>`_
- `DNF System Upgrade <https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/>`_ 官方文档
