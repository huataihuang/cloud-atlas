.. _debian_downgrade_kernel:

===========================
Debian降级内核
===========================

在排查 :ref:`samsung_pm9a1_timeout_failure` 我发现 :ref:`samsung_pm9a1` 之前在内核 5.15/5.19 工作正常，但是近期升级到 Kernel 6.x 之后无法识别。所以尝试降级内核 5.x :

- 搜索官方提供的内核选项：

.. literalinclude:: debian_downgrade_kernel/search_linux
   :caption: 搜索debian发行版提供的内核

输出显示:

.. literalinclude:: debian_downgrade_kernel/search_linux_output
   :caption: 搜索debian发行版提供的内核的列表

如果需要安装某个低版本，则使用指定内核版本:

.. literalinclude:: debian_downgrade_kernel/downgrade_linux
   :caption: 指定低版本内核安装

哦，对于 debian 12，当前不提供旧版本 5.x 内核了么？

`How To Install Linux Kernel 5.15 on Debian 11 <http://idroot.us/install-linux-kernel-5-15-debian-11/>`_ 提供了一个思路就是自己编译主线内核...

查看了一下 `Debian version history <https://en.wikipedia.org/wiki/Debian_version_history>`_ 原来Debian内核版本是固定的:

  - Bullseye(11) 内核 5.10
  - Bookworm(12) 内核 6.1

也就是说如果要回退内核，需要降级到 Debian 11 ?

debian 提供了一个 `debian内核镜像归档 <https://snapshot.debian.org/binary/linux-image-amd64/>`_

- `linux-image-amd64 5.19.11-1 <https://snapshot.debian.org/package/linux-signed-amd64/5.19.11%2B1/#linux-image-amd64_5.19.11-1>`_

.. literalinclude:: debian_downgrade_kernel/downlaod_5.19
   :caption: 下载5.19内核软件包

- 安装低版本内核:

.. literalinclude:: debian_downgrade_kernel/install_5.19
   :caption: 安装5.19内核

安装输出信息:

.. literalinclude:: debian_downgrade_kernel/install_5.19_output
   :caption: 安装5.19内核
   :emphasize-lines: 13

注意，这里安装有一些报错，例如 ``dkms`` 报错，因为没有安装对应 5.19 内核的 headers包导致的。由于我只是临时使用，所以这里没有修复。实际上安装时应该再加上::

   linux-headers-amd64_5.19.11-1_amd64.deb

由于降级到 5.19 还没有解决 :ref:`samsung_pm9a1_timeout_failure` ，所以继续降级到 5.15:

.. literalinclude:: debian_downgrade_kernel/downlaod_5.15
   :caption: 下载5.15内核软件包

安装 5.15:

.. literalinclude:: debian_downgrade_kernel/install_5.15
   :caption: 安装5.15内核

.. warning::

   很遗憾，我的内核降级没有解决 :ref:`samsung_pm9a1_timeout_failure` ，还在探索中

参考
=======

- `Downgrading kernel <https://www.reddit.com/r/debian/comments/18h3fxt/downgrading_kernel/>`_
