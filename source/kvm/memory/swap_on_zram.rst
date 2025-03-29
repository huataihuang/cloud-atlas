.. _swap_on_zram:

====================
ZRAM运行swap
====================

在 :ref:`jetson` GPU硬件环境，默认定制的 :ref:`ubuntu_linux` 激活了基于 :ref:`zram` 的 :ref:`jetson_swap` ，当时我关闭了 :ref:`zram` 以便适应 :ref:`kubernetes` 部署要求。不过，在 :ref:`apple_silicon_m1_pro` Macbook Pro 2022笔记本，内存有限，所以想要通过 :ref:`zram` 来增加内存超卖(通过部分内存构建swap来实现压缩)。

:ref:`zram` 能够在内存中存储更多信息，通过消耗CPU资源来节约内存使用。在 :ref:`kvm_memory_tunning` 可以结合采用 :ref:`zram` 来实现，主要有两种方式:

- :ref:`zram_swap_script`
- :ref:`zram_generator`

对于 :ref:`arch_linux` ，也建议采用 :ref:`zram_generator` 工具来完成简洁的配置:

- 使用 :ref:`archlinux_aur` 安装 ``zram-generator`` 并将案例配置复制为 ``/etc/systemd/zram-generator.conf`` :

.. literalinclude:: swap_on_zram/zram_generator
   :language: bash
   :caption: 安装zram-generator

- 检查 ``/usr/share/doc/zram-generator/zram-generator.conf.example`` 如下:

.. literalinclude:: swap_on_zram/zram_generator_conf.example
   :language: bash
   :caption: /usr/share/doc/zram-generator/zram-generator.conf.example

.. note::

   官方提供的 zram-generator.conf 默认配置了2个zram，但是启动只成功了 zram1 ，看起来是环境问题。

参考Fedora系统，我发现在Fedora上，默认就已经启动了 ``zram-generator`` 服务，默认就是使用了配置 ``/usr/lib/systemd/zram-generator.conf`` 内容如下

.. literalinclude:: swap_on_zram/zram_generator_conf_fedora
   :language: bash
   :caption: Fedora的默认 /usr/lib/systemd/zram-generator.conf 配置

- 我感觉配置2G RAM应该足够，或者就采用 1/10 内存来构建swap on zram，所以修订配置为:

.. literalinclude:: swap_on_zram/zram_generator_conf
   :language: bash
   :caption: 参考Fedora配置的 /etc/systemd/zram-generator.conf

- 启动zram0:

.. literalinclude:: swap_on_zram/zram0
   :language: bash
   :caption: 启动zram0压缩swap

- 此时检查 ``top`` 就会看到系统增加了2G的swap，并且执行 ``zramctl`` 可以看到::

   NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
   /dev/zram0 lzo-rle         2G  16K  103B   16K      10 [SWAP]

参考
=======

- `Configuring Swap on ZRAM <https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-configure-swaponzram/>`_
- `arch linux: Improving performance#zram or zswap <https://wiki.archlinux.org/title/Improving_performance#zram_or_zswap>`_
