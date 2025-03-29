.. _linux_overlayfs:

======================
Linux系统overlayfs
======================

在 :ref:`overlayfs` 可以实现底层只读(共享给多个系统)，上层读写(实现变化文件)，这种模式在 :ref:`docker_overlay_driver` 有广泛的应用，也是目前Docker系统中核型的存储技术。

本文通过简单的实践来演示和分析 :ref:`overlayfs` 的 ``Upper`` / ``Lower`` / ``Work`` / ``Merged`` 各个层中间关系，更形象生动理解:

.. figure:: ../../../_static/kernel/filesystem/overlayfs.png
   :scale: 60

- 创建目录::

   mkdir ~/overlayfs
   cd overlayfs
   mkdir lower1  lower2  lower3  merged  upper  work

- 挂载构建 :ref:`overlayfs` ::

   sudo mount -t overlay -o lowerdir=lower1:lower2:lower3,upperdir=upper,workdir=work overlay merged

- 检查挂载::

   mount

显示输出::

   overlay on /home/huatai/overlayfs/merged type overlay (rw,relatime,seclabel,lowerdir=lower1:lower2:lower3,upperdir=upper,workdir=work)

现在我们有多个目录，其中底层目录( ``Lower`` )我们采用多个 ``lower1  lower2  lower3`` ，上层( ``Upper`` )采用 ``upper`` ::

   upper
   lower1
   lower2
   lower3

.. note::

   需要注意底层目录是有顺序的，挂载时候列出名字是从左到右，代表文件系统层是从上往下

- 可以在 ``/etc/fstab`` 中添加如下配置::

   overlay /home/huatai/overlayfs/merged overlay noauto,x-systemd.automount,lowerdir=/home/huatai/overlayfs/lower1:/home/huatai/overlayfs/lower2:/home/huatai/overlayfs/lower3,upperdir=/home/huatai/overlayfs/upper,workdir=/home/huatai/overlayfs/work 0 0

.. note::

   这里参数 ``noauto`` 和 ``x-systemd.automount`` 挂载选项是必须的，可以避免systemd启动时如果出现无法挂载overlay不会出现挂死。

.. note::

   这里 :ref:`overlayfs` 的每个目录都需要使用绝对路径。之前我执行命令使用相对路径是因为我当时执行命令位于目录 ``/home/huatai/overlayfs`` 中，所以相对目录可以找到。采用绝对目录挂载之后，再次使用 ``mount`` 检查可以看到::

      overlay on /home/huatai/overlayfs/merged type overlay (rw,relatime,seclabel,lowerdir=/home/huatai/overlayfs/lower1:/home/huatai/overlayfs/lower2:/home/huatai/overlayfs/lower3,upperdir=/home/huatai/overlayfs/upper,workdir=/home/huatai/overlayfs/work,x-systemd.automount)

测试
=======

- 在底层对同一个文件进行操作::

   echo "I'm in lower3" > /home/huatai/overlayfs/lower3/file.txt
   echo "I'm in lower2" >> /home/huatai/overlayfs/lower2/file.txt
   echo "I'm in lower1" >> /home/huatai/overlayfs/lower1/file.txt

- 测试检查文件可以看到每一层只看到一个文件内容行::

   $ cat lower3/file.txt
   I'm in lower3
   $ cat lower2/file.txt
   I'm in lower2
   $ cat lower1/file.txt
   I'm in lower1

上述3个层，底层文件系统操作上层不会看到，所以每个层都是只有一行记录

- 此时合并到 ``merged`` 层，就会看到3个底层最上一层 ``lower1`` 的内容::

   $ cat merged/file.txt
   I'm in lower1

- 现在对合并层进行文件修改::

   echo "I'm in merged" >> merged/file.txt

检查内容::

   $ cat merged/file.txt
   I'm in lower1
   I'm in merged

- 这个合并层会反馈在 ``upper`` 层，但是不会显示在底层::

   $ cat upper/file.txt
   I'm in lower1
   I'm in merged

   $ cat lower1/file.txt
   I'm in lower1
   $ cat lower2/file.txt
   I'm in lower2
   $ cat lower3/file.txt
   I'm in lower3

只读overlay
===============

当不提供 ``upper`` 和 ``work`` 层参数，则挂载的 :ref:`overlayfs` 的底层自动为只读::

   sudo mount -t overlay -o lowerdir=/home/huatai/overlayfs/lower1:/home/huatai/overlayfs/lower2:/home/huatai/overlayfs/lower3lower1:lower2:lower3 overlay /home/huatai/overlayfs/merged

参考
=========

- `arch linux: Overlay filesystem <https://wiki.archlinux.org/title/Overlay_filesystem>`_
