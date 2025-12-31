.. _linux_swap:

==============
Linux swap
==============

.. _swap_file:

swap文件
==========

:ref:`gentoo_chromium` 编译对内存要求很高，超出了我的笔记本 16GB，会导致 :ref:`linux_oom` ，所以设置swap:

.. literalinclude:: linux_swap/swapfile
   :caption: 设置8G swap文件

在 :ref:`sphinx_memory` 中为 :ref:`alpine_linux` 设置 ``2GB`` swap 文件:

.. literalinclude:: linux_swap/swapfile_alpine_2g
   :caption: 设置alpine linux 的2G swap文件



.. _dphys-swapfile:

dphys-swapfile
=====================

在 :ref:`raspberry_pi_os` 中，现在默认安装可以在 ``top`` 输出中看到默认启用了 ``200M`` swap。但是，检查 ``/etc/fstab`` 可以看到提示，当前系统使用的是 ``dphys-swapfile`` 来管理 :ref:`swap_file`

.. literalinclude:: linux_swap/pi_fstab
   :caption: 树莓派的 ``/etc/fstab`` 注释显示通过 ``dphys-swapfile`` 工具管理swap文件
   :emphasize-lines: 4,5

实际上检查系统 ``/etc/dphys-swapfile`` 配置文件就会明白，原来 ``dphys-swapfile`` 工具将默认启用200M的swap文件存放在 ``/var/swap`` 

- ``/etc/dphys-swapfile`` 内容:

.. literalinclude:: linux_swap/dphys-swapfile_config
   :caption: ``dphys-swapfile`` 默认配置

**注意** 这里 ``CONF_SWAPSIZE`` 如果被注释掉，那么 ``dphys-swapfile`` 就会动态计算swap，并且受到 ``CONF_MAXSWAP`` 的限制。也就是说，实际上会配置2G swap文件

- 关闭 ``dphys-swapfile`` 所使用的swap:

.. literalinclude:: linux_swap/dphys-swapfile_off
   :caption: 动态关闭 ``dphys-swapfile``

不过动态关闭是临时的，重启系统还是会按照 ``/etc/dphys-swapfile`` 配置启用swap(默认200M)

- 彻底关闭  ``dphys-swapfile`` (持久化配置) 

.. literalinclude:: linux_swap/disable_dphys-swapfile
   :caption: 彻底关闭 ``dphys-swapfile`` 服务

swap分区
===========

.. _swap_on_optane:

在Optane(傲腾)构建swap分区
----------------------------

由于 :ref:`optane_performance` 性能和读写寿命都远超常规SSD，所以我在 :ref:`pi_5` 上采用 :ref:`intel_optane_m10` 来构建swap分区，以便扩展 :ref:`pi_5` 有限的8G内存:

.. literalinclude:: linux_swap/swap_partition
   :caption: 构建swap分区

最后在 ``/etc/fstab`` 中添加如下配置:

.. literalinclude:: linux_swap/fstab
   :caption: ``/etc/fstab`` 添加swap分区配置


参考
=====

- `arch linux: swap <https://wiki.archlinux.org/title/swap>`_
- `Permanently disable swap on Raspbian Buster <https://forums.raspberrypi.com/viewtopic.php?t=244130>`_
