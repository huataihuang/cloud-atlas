.. _raspberry_pi_os_zfs:

=============================
Raspberry Pi OS 上运行ZFS
=============================

:ref:`raspberry_pi` 所使用的 Raspberry Pi OS 本质上是 :ref:`debian` ，所以可以参考 `OpenZFS Getting Started > Debian#Installation <https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html#installation>`_ 来完成安装。

和 :ref:`ubuntu_zfs` 不同， :ref:`debian` 发行版没有包含ZFS软件包，所以使用 `backports repository <https://backports.debian.org/Instructions/>`_ 仓库提供的ZFS:

- 添加 ``backports`` 仓库，即添加 ``/etc/apt/sources.list.d/bookworm-backports.list`` 配置:

.. literalinclude:: raspberry_pi_os_zfs/bookworm-backports.list
   :caption: 添加 ``/etc/apt/sources.list.d/bookworm-backports.list`` 设置 ``backports`` 仓库

- 添加 ``/etc/apt/preferences.d/90_zfs`` :

.. literalinclude:: raspberry_pi_os_zfs/90_zfs
   :caption: 添加 ``/etc/apt/preferences.d/90_zfs``

- 然后就可以进行安装(过程包含了 :ref:`dkms` 编译(非常简单丝滑，比 :ref:`archlinux_zfs-dkms_x86` / :ref:`archlinux_zfs-dkms_arm` 要简单得多):

.. literalinclude:: raspberry_pi_os_zfs/install_zfs
   :caption: 在 ``Raspberry Pi OS`` 上安装ZFS

不过需要注意， :ref:`pi_5` 火力全开编译对电源电源 **匹配** :strike:`功率` 要求很高，需要使用 **官方标配27W USB-C电源** 。我尝试使用苹果的 20W 快充电源，日常使用没有问题，但是在这个重负载编译时会出现电压不稳而直接死机，此时串口控制台输出:

.. literalinclude:: ../../../../raspberry_pi/hardware/pi_5/hwmon_undervoltage_error
   :caption: 没有使用官方电源在重负载下会导致电邀过低宕机

.. warning::

   实际上 :ref:`pi_5` 的电源和我们常用的快充电源协议似乎不兼容，我使用了绿联65W的电脑电源，理论上是能够满足树莓派最大功率的，但是一旦CPU开始全力运行，依然会出现上述电压过低的告警，然后死机。

   解决的方法我在 :ref:`pi_5_cpufreq` 中采用 :ref:`cpu_frequency_governor` 设置为 ``powersave`` 来限制主频，则可以满足稳定运行，确保完成编译。


参考
=====

- `OpenZFS Getting Started > Debian#Installation <https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html#installation>`_

