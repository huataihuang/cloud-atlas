.. _pacman:

=============
Pacman
=============

pacman是arch linux的主要包管理工具。它包含了简单的二进制包格式和易于使用的编译体系。通过和主服务器同步pacman可以保持系统的软件包更新，其服务器/客户对模式允许用户下载和安装软件包以及所有依赖软件包。

pacman简明使用
================

.. note::

   pacman 的 ``-S`` 参数表示 ``--sync`` 同步软件包，软件包将直接从远程仓库安装到本地主机，包括所有运行着软件包的依赖包。

* 安装软件包::

   pacman -S package_name1 package_name2 ...

* 使用正则方式安装一系列软件包::

   pacman -S $(pacman -Ssq package_regex)

* 如果有多个软件包位于不同仓库，例如extra仓库和testing仓库，则在软件包前加上仓库定义::

   pacman -S extra/package_name

* 支持简单的名字模式::

   pacman -S plasma-{desktop,mediacenter,nm}

* 甚至支持多级扩展::

   pacman -S plasma-{workspace{,-wallpapers}<Plug>PeepOpena}

* 一些软件包支持整组安装，例如gnome::

   pacman -S gnome

要检查这个组中包含的软件包::

   pacman -Sg gnome

* 忽略依赖强制安装::

   pacman -Sd package_name

* Arch Linux的软件包是 ``tar.stz`` 格式，可以下载以后本地安装::

   pacman -U --noconfirm edk2-armvirt-202208-3-any.pkg.tar.zst

* 删除单一软件包，但是保留已经安装的这个软件包的依赖::

   pacman -R package_name

* 删除软件包并且删除所有没有被其他软件包所使用的该软件包的依赖::

   pacman -Rs package_name

* 删除软件包，该软件包被其他软件包所使用，但是不删除依赖软件包::

   pacman -Rdd package_name

.. warning::

   上述命令会打破系统完整，所以需要避免

* 升级整个系统所有软件包::

   pacman -Syu

* 清理缓存::

   pacman -Sc

* 查询系统中安装的某个程序属于哪个软件包提供(这里举例查询netstat命令)::

   pacmsn -Qo /usr/bin/netstat

* 查询系统某个软件包包含的文件::

   pacman -Ql package_name

激活仓库,安装指定版本及锁定版本
================================

默认情况下， ``testing`` 和 ``community-testing`` 仓库没有激活，这个配置位于 ``/etc/pacman.conf`` 。例如，在 :ref:`arm_k8s_deploy` 在加入Arch Linux节点时，为了能够安装 ``community-testing`` 仓库最新版本的Kubernetes 1.22.0 ，配置如下::

   [community-testing]
   Include = /etc/pacman.d/mirrorlist 

- 然后执行仓库数据库同步::

   pacman -Sy

- 安装指定版本::

   pacman -S kubelet=1.22.0-1 kubeadm=1.22.0-1 kubectl=1.22.0-1

- 由于Kubernetes软件升级涉及到管控和工作节点升级，需要精心的手工操作，所以必须锁定软件版本不能滚动升级。锁定软件版本也是编辑 ``/etc/pacman.conf`` 将需要忽略升级到软件包配置如下::

   IgnorePkg   = kubelet kubeadm kubectl

- 再次修订 ``/etc/pacman.conf`` 将 ``community-testing`` 仓库注释掉，避免其他软件版本升级到测试版本。

国内仓库配置
---------------

- 在 ``/etc/pacman.conf`` 最后添加两行::

   [archlinuxcn]
   Server = https://mirrirs.tuna.tsinghua.edu.cn/archlinuxcn/$arch

- 使用 ``paman -Sy`` 同步源

- 然后导入GPG key::

   pacman -S archlinuxcn-keyring

break dependency
=================

执行 ``pacman -Syu`` 时候遇到报错::

   looking for conflicting packages...
   error: failed to prepare transaction (could not satisfy dependencies)
   :: installing xorgproto (2019.2-2) breaks dependency 'xf86miscproto' required by libxxf86misc

参考 `xorgproto issues.. <https://bbs.archlinux.org/viewtopic.php?id=251517>`_ 处理::

   pacman -Rdd libxxf86misc && pacman -Syu

signature error
===================

执行 ``pacman -Syu`` 出现报错::

   error: pacman: signature from "Levente Polyak (anthraxx) <levente@leventepolyak.net>" is unknown trust
   :: File /var/cache/pacman/pkg/pacman-5.2.1-4-x86_64.pkg.tar.zst is corrupted (invalid or corrupted package (PGP signature)).

上述问题参考 `pacman/Package signing <https://wiki.archlinux.org/index.php/Pacman/Package_signing>`_ 和 `Signature is unknown trust [SOLVED] <https://bbs.archlinux.org/viewtopic.php?id=207957>`_ 原因是系统长时间没有更新，本地使用的key已经过期，需要重新刷新::

   pacman-key --refresh-keys

conflicting files
==================

执行 ``pacman -Syu`` 提示报错::

   error: failed to commit transaction (conflicting files)
   nss: /usr/lib/p11-kit-trust.so exists in filesystem
   Errors occurred, no packages were upgraded.

这个问题参考 `archlinux - pacman <https://wiki.archlinux.org/index.php/Pacman>`_ 中 ``"Failed to commit transaction (conflicting files)" error`` 解决方法::

   pacman -Qo /usr/lib/p11-kit-trust.so

检查看看是否有软件包包含这个文件::

   error: No package owns /usr/lib/p11-kit-trust.so

然后将这个文件重命名::

   sudo mv /usr/lib/p11-kit-trust.so /usr/lib/p11-kit-trust.so.bak

参考
=======

- `archlinux - pacman <https://wiki.archlinux.org/index.php/Pacman>`_
- `xorgproto issues.. <https://bbs.archlinux.org/viewtopic.php?id=251517>`_
- `How do I list files installed by a package from the AUR? <https://superuser.com/questions/1265425/how-do-i-list-files-installed-by-a-package-from-the-aur>`_
