.. _lfs_use:

===============
使用LFS
===============

在这么冗长艰难的LFS构建之后，终于能够启动运行一个自己手搓的Linux，感觉确实良好。

接下来该怎么使用这个系统呢?

我有自己的计划，在 :ref:`think_blfs` 中构想:

- :ref:`blfs_virtualization`
- :ref:`blfs_container`
- :ref:`blfs_k8s`
- :ref:`blfs_desktop`

主要基于我的工作中心是后端。

LFS手册提供了一个很好的使用思路: 在Host主机中通过 :ref:`chroot` 来进行操作

准备工作
============

- 之前在 :ref:`lfs_prepare` 配置了 ``root`` 用户的 ``~/.bashrc`` ，但是需要注意，这个 ``~/.bashrc`` 是需要通过 ``~/.profile`` 引用才能自动生效的，所以这里补充一个 ``~/.profile`` 配置(从 :ref:`debian` 系统中复制):

.. literalinclude:: lfs_use/profile
   :caption: 增加 ``~/.profile`` 来引用 ``~/.bashrc``

- 我在 ``~/.bashrc`` 中修改 ``$LFS`` 设置为 ``/chroot/lfs`` (这只是我的喜好，官方原文是 ``/mnt/lfs`` ):

.. literalinclude:: lfs_use/bashrc
   :caption: 调整 ``~/.bashrc`` 将 ``$LFS`` 设置为 ``/chroot/lfs``

- 参考 :ref:`thick_jail` 的思路，在物理主机上创建 ``/sketch`` 目录，将 ``/etc`` 目录下需要可以修订的配置文件复制到这个目录下并建立软链接，这样当 ``/etc`` 目录被 ``mountbind`` 到 ``$LFS`` 中以后，这些文件对于jail内部是可以自由修订的

.. literalinclude:: lfs_use/sketch
   :caption: 构建一个需要为每个jail定制的可修改目录 ``/sketch``

- 创建设备目录:

.. literalinclude:: lfs_chroot_build_tools/mkdir
   :caption: 创建虚拟内核文件系统挂载点
   :emphasize-lines: 13-16

.. warning::

   这里必须 **补全 lib64 指向 lib 的库文件软链接** ，否则 ``chroot`` 进入 ``$LFS`` 之后执行任何命令都会失败，但是会返回一个非常迷惑的提示:

   .. literalinclude:: lfs_use/chroot_error
      :caption: 执行 ``chroot`` 始终提示找不到文件

- 准备 ``mount-virt.sh`` 脚本

.. literalinclude:: lfs_use/mount-virt.sh
   :caption: 挂载虚拟文件系统，为chroot准备
   :emphasize-lines: 46

.. note::

   这里执行 ``mount --bind`` 将 Host 主机的 ``/usr`` 目录映射到 ``chroot`` 中，就不用完整复制 ``/usr`` 目录了(所有LFS的编译后 **执行程序和库** 都在这个目录下

- 使用 ``root`` 身份执行:

.. literalinclude:: lfs_use/run_mount-virt.sh
   :caption: 执行挂载虚拟文件系统脚本 

.. note::

   这个脚本也可以用普通用户身份执行，但是需要安装 ``sudo`` (在后续 :ref:`blfs` 中完成，所以这里我还是用 ``root`` 身份执行)

完成后检查 ``df -h`` 输出类似如下:

.. literalinclude:: lfs_use/run_mount-virt_df
   :caption: 挂载虚拟文件系统后检查
   :emphasize-lines: 9,10

LFS建议不要将 :ref:`blfs` 使用的源代码包和LFS使用的源代码包混合存放在 ``/sources`` (chroot环境中的路径)中

- 最后进入chroot环境 - 配置 ``~/.bashrc`` 添加进入的命令别名:

.. literalinclude:: lfs_use/chroot
   :caption: 配置 ``~/.bashrc`` 添加进入的命令别名

普通用户 ``admin`` 设置
========================

为了能够让admin用户也使用 ``chroot`` ，对 ``admin`` 用户账号也做了响应调整

.. note::

   普通用户 ``chroot`` 需要使用 ``sudo`` 工具，所以必须先完成 :ref:`blfs` 中 ``sudo`` 工具的安装

- 同样配置 ``~/.profile`` 和 ``~/.bashrc`` ，但是在 ``~/.bashrc`` 中配置 ``aliad chroot`` 稍作调整

.. literalinclude:: lfs_use/bashrc

异常排查
==============

chroot报错 ``No such file or directory``
---------------------------------------------

我在执行 ``chroot`` 时候遇到一个问题，始终提示:

.. literalinclude:: lfs_use/chroot_error
   :caption: 执行 ``chroot`` 始终提示找不到文件

但是实际上 ``/chroot/lfs/usr/bin/env`` 程序是存在的(通过 ``mount --bind`` 从host中挂载

我以为是 ``mount --bind`` 问题，就完整把Host主机上 ``/usr`` 目录复制到chroot的 ``/chroot/lfs`` 下，但是报错依旧。似乎是host主机 ``chroot`` 无法正常工作？

`LFS chroot cannot find /usr/bin/env <https://superuser.com/questions/1667097/lfs-chroot-cannot-find-usr-bin-env>`_ 给了我启发(不过我的情况不一样)，我对比了host主机的根目录和 ``$LFS`` ( ``/chroot/lfs`` )目录，发现 ``$LFS`` 缺少一个 ``/lib64`` 

而执行 ``ldd /usr/bin/env`` 可以看到，这个程序依赖 ``/lib64/ld-linux-x86-64.so.2``

所以补充执行

.. literalinclude:: lfs_use/lib64
   :caption: 补全 ``$LFS`` 目录下的 ``lib64``

果然，再次执行 ``chroot`` 这串指令就不再报错了

.. note::

   我已经将这个补充命令添加到前面的执行脚本命令中，如果你按照我的步骤，应该不再报错

参考
======

- `chroot: failed to run command ‘/bin/bash’: No such file or directory <https://unix.stackexchange.com/questions/128046/chroot-failed-to-run-command-bin-bash-no-such-file-or-directory>`_ 这个回答关于chroot无法找到文件的解释是正确的
