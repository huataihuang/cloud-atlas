.. _after_lfs_config:

====================
LFS之后的配置
====================

:ref:`lfs` 提供了一个基础系统，不过实际使用时，需要在完成LFS安装部署后，继续做一些补充配置

Firmware
===========

Linux系统要能够在真实硬件上良好运行，需要安装不同厂商提供的硬件firmware:

- CPU微码(microcode): 用于修复CPU漏洞
- GPU firmware: 典型的是三家GPU厂商 - AMD, Intel, Nvidia
- 有线网卡firmware: 通常能够修复问题提升性能
- 其他设备firmware: 例如无线网卡需要特定firmware驱动才能工作

.. _blfs_micorcode:

CPU microcode
-----------------

- 检查CPU信息:

.. literalinclude:: after_lfs_config/cpuinfo
   :caption: 检查CPU信息


- 检查当前微码(还没有更新之前):

.. literalinclude:: after_lfs_config/microcode_before
   :caption: 更新前的CPU微码

- 从 `Intel-Linux-Processor-Microcode-Data-Files <https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files/releases/>`_ 下载最新微码

.. note::

   在执行 构建 ``microcode.img`` 前，先完成 :ref:`blfs_cpio` 安装

- 构建 ``microcode.img`` :

.. literalinclude:: after_lfs_config/microcode.img
   :caption: 构建 ``microcode.img``

- Intel发布的微码 ``releasenote.md`` 中有说明可检查

.. csv-table:: Intel微码 ``releasenote.md`` 更新 Xeon E5 v3
   :file: after_lfs_config/microcode.csv
   :widths: 10,10,20,10,10,40
   :header-rows: 1

.. note::

   在执行 ``/boot/grub/grub.cfg`` 中添加 ``initrd`` 配置 前，先查看一下 :ref:`blfs_initramfs` 是否有必要一起完成。

   目前我还没有使用 ``initramfs`` ，仅加载 CPU microcode : 后续有需要在补充添加 :ref:`blfs_initramfs` (可以补充在cpu microcode 的 ``initrd`` 后面加载

   另外，如果 ``intel-ucode`` 微码目录完整复制到 ``/lib/firmware`` 目录下，那么 **也可以** 不用执行下面一步 在 ``/boot/grub/grub.cfg`` 中添加 ``initrd`` 配置 ，直接执行 :ref:`blfs_initramfs` 中 ``mkinitramfs`` 会自动添加cpu microcode。

- 在 ``/boot/grub/grub.cfg`` 中添加 ``initrd`` 配置:

.. literalinclude:: after_lfs_config/grub.cfg
   :caption: 配置 grub.cfg
   :emphasize-lines: 4

-  重启系统，然后检查:

.. literalinclude:: after_lfs_config/dmesg
   :caption: 检查启动系统输出

由于我的系统CPU在之前 :ref:`ubuntu_linux` 安装运行时已经自动更新过CPU microcode，所以这里没有更新信息，还是 ``0x00000049`` (也是之前检查 ``releasenote.md`` 可以看到最高版本)

.. literalinclude:: after_lfs_config/dmesg_output
   :caption: 检查启动系统输出显示CPU微码更新情况

网卡firmware
---------------

待补充...

Bash Shell启动文件
======================

有关bash的一些环境设置:

- 交互式登录 shell 在成功登录后通过读取 ``/etc/passwd`` 文件使用 ``/bin/login`` 启动
- shell通常读取 ``/etc/profile`` 和用户私有等效 ``~/.bash_profile`` 或 ``~/.profile``
- 在 私有等效 ``~/.bash_profile`` 或 ``~/.profile`` 调用读取 ``~/.bashrc``
- 通常自己 **定制内容** 应该存放在 ``~/.bashrc``
- ``~/.bash_logout`` 在用户推出交互式登陆 shell 时被读取和执行(类似退出清理动作可以在这里设置)
- 很多发行版使用 ``/etc/bashrc`` 进行非登陆shell的系统范围初始化，该文件通常还会从用户的 ``~/.bashrc`` 文件中调用而不是直接内置在bash本身中

- 创建 ``/etc/profile``

.. literalinclude:: after_lfs_config/profile
   :caption: ``/etc/profile``

- 创建 ``/etc/profile.d`` 目录

.. literalinclude:: after_lfs_config/profile.d
   :caption: ``/etc/profile.d`` 目录

- ``/etc/profile.d/bash_completion.sh``

.. note::

   以下bash补全脚本会在bash环境中添加许多行(通常超过1000行)，并且很难用 ``set`` 命令检查简单的环境变量。省略词脚本不会映像bash使用tab键进行文件名补全的能力。

   **我没有添加这个脚本**

.. literalinclude:: after_lfs_config/bash_completion.sh
   :caption: ``bash_completion.sh``

确保目录存在:

.. literalinclude:: after_lfs_config/bash_completion.d
   :caption: 确保 ``/etc/bash_completion.d`` 目录存在

- ``/etc/profile.d/dircolors.sh``

这个脚本使用 ``~/.dircolors`` 和 ``/etc/dircolors`` 文件夹来控制目录列表中文件的颜色。可以控制 ``ls --color`` 等命令的色彩输出

.. literalinclude:: after_lfs_config/dircolors.sh
   :caption: ``/etc/profile.d/dircolors.sh``

- ``/etc/profile.d/extrapaths.sh``

这个脚本向 ``PATH`` 添加了一些用用的路径，并可用于定制所有用户可能需要的其他 ``PATH`` 相关环境变量(例如 ``LD_LIBRARY_PATH`` 等)

.. literalinclude:: after_lfs_config/extrapaths.sh
   :caption: ``/etc/profile.d/extrapaths.sh``

- ``/etc/profile.d/readline.sh``

这个脚本设置默认的 ``inputrc`` 配置文件

.. literalinclude:: after_lfs_config/readline.sh
   :caption: ``/etc/profile.d/readline.sh``

- ``/etc/profile.d/umask.sh``

设置 ``umask`` 值对于安全非常重要，这里对系统用户及当前用户名和组名不同时，默认组写权限关闭。

.. literalinclude:: after_lfs_config/umask.sh
   :caption: ``/etc/profile.d/umask.sh``

- ``/etc/profile.d/i18n.sh``

这个脚本设置本地语言支持所需的环境变量

.. literalinclude:: after_lfs_config/i18n.sh
   :caption: ``/etc/profile.d/i18n.sh``

- ``/etc/bashrc``

基础 ``/etc/bashrc`` ，请阅读文件中的注释

.. literalinclude:: after_lfs_config/bashrc
   :caption: ``/etc/bashrc``

- ``~/.bash_profile``

以下时一个基础的 ``~/.bash_profile`` ，如果希望每个新用户自动拥有这个文件，只需要将命令输出更为为 ``/etc/skel/.bash_profile`` ，并在运行命令后检查权限。然后可以将 ``/etc/.skel/.bash_profile`` 复制到现有用户(包括root)的祝目录，并是饿到甚至所有者和组

.. literalinclude:: after_lfs_config/bash_profile
   :caption: ``~/.bash_profile``

- ``~/.bsashrc``

.. literalinclude:: after_lfs_config/home_bashrc
   :caption: ``~/.bashrc``

- ``~/.bash_logout``

这里是空白的 ``~/.bash_logout`` 模版。注意基本的 ``~/.bash_logout`` 并不包含 ``clear`` 命令，这是因为 ``clear`` 是由 ``/etc/issue`` 文件处理的

.. literalinclude:: after_lfs_config/bash_logout
   :caption: ``~/.bash_logout``

- ``/etc/dircolors``

如果要使用 ``dircolors`` 能力，则执行以下命令

也可以在 ``/etc/skel`` 目录下添加同样的 ``.colors`` ，这样新用户就会自动拥有 ``~/.dircolors`` 文件以便用户自己定制目录颜色

.. literalinclude:: after_lfs_config/dircolors
   :caption: ``/etc/dircolors``

``/etc/vimrc`` 和 ``~/.vimrc`` 文件
=====================================

- 基本的 ``/etc/vimrc`` 和 ``~/.vimrc`` 文件

.. literalinclude:: after_lfs_config/vimrc
   :caption: 基本的 ``/etc/vimrc`` 和 ``~/.vimrc``

随机数生成
===============

通过 ``blfs-bootscripts-20240416`` 软件包安装 ``/etc/rc.d/init.d/random`` 初始化脚本

.. literalinclude:: after_lfs_config/random
   :caption: 安装 ``/etc/rc.d/init.d/random`` 初始化脚本

参考
=====

- `After LFS Configuration Issues <https://www.linuxfromscratch.org/blfs/view/stable/postlfs/config.html>`_
