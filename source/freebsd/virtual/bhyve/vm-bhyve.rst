.. _vm-bhyve:

=================
``vm-bhyve``
=================

我在直接使用 ``bhyve`` 命令时遇到的问题是无法修订创建的虚拟机配置: 在 :ref:`bhyve_ubuntu` 以及 :ref:`bhyve_pci_passthru_startup` 时尝试修订 ``-m`` 参数指定不同的内存大小都会报错。

`Github: freebsd/vm-bhyve <https://github.com/freebsd/vm-bhyve>`_ 是一个基于 :ref:`shell` 的最小化依赖的 ``bhyve manager`` ，非常方便管理虚拟机

安装
========

- 安装 ``vm-bhyve``

.. literalinclude:: vm-bhyve/install_vm-bhyve
   :caption: 安装 ``vm-bhyve``

- 创建存储: 

  - 创建 ``zdata/vms`` :ref:`zfs` 存储数据集，并且将默认 ``recordsize`` 属性 ``128K`` 调整为 ``64K``
  - 创建 ``zdata/vms/.templates`` 存储用于创建VM的模版

.. literalinclude:: vm-bhyve/zfs
   :caption: 创建虚拟机存储数据集

- 在 ``/etc/rc.conf`` 中设置虚拟化支持:

.. literalinclude:: vm-bhyve/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 支持虚拟化

- 在 ``/boot/loader.conf`` 添加:

.. literalinclude:: vm-bhyve/loader.conf
   :caption: ``/boot/loader.conf``

- 初始化:

.. literalinclude:: vm-bhyve/init
   :caption: 初始化

初始化步骤会激活 ``/etc/rc.conf`` 的 ``vm-bhyve`` 并设置使用的数据集，可以看到 ``/zroot/bhyve`` 目录下创建了:

.. literalinclude:: vm-bhyve/init_dir
   :caption: ``vm init`` 创建了zfs数据集目录

.. note::

   我在构建 ``zdata/vms`` zfs存储数据集时候，为每个 ``.xxx`` 目录构建了一个子存储卷。这个步骤不是必须的，我考虑是今后可以做隔离和quota。

在完成初始化之后，检查 ``/zdata/vms`` 下面的上述4个子目录，可以看到 ``.config`` 目录下有2个空文件:

.. literalinclude:: vm-bhyve/.config_dir
   :caption: ``.config`` 目录下有2个空文件

而在 ``.templates`` 目录下则有一个 ``default.conf`` 内容如下:

.. literalinclude:: vm-bhyve/template_default.conf
   :caption: ``.templates`` 目录下 ``default.conf``

- 在 ``/usr/local/share/examples/vm-bhyve/`` 目录下有虚拟机的配置模版案例，所谓的配置模版其实是一些简单的配置项来指定虚拟机如何运行。对于 ``vm-bhyve`` 使用的模版是存放在 ``$vm_dir/.templates`` ，所以执行以下命令复制模版:

.. literalinclude:: vm-bhyve/templates
   :caption: 复制模版

.. note::

   复制模版文件中有一个 ``config.sample`` 包含了详细的配置解析，可以参考这个配置案例来修订自己的配置文件

使用
=======

参考 ``config.sample`` ，我尝试定制自己的模版文件来实现 ``bhyve`` 虚拟机构建:

- 使用 ``uefi`` 来加载虚拟机环境
- 指定 ``/zdata/vms/<vm_name>`` 的 :ref:`zfs` 数据集来作为虚拟机存储磁盘
- 指定 :ref:`freebsd_bridge_startup` 和 :ref:`bhyve_startup` 构建的一个共用虚拟交换机 ``igc0bridge``

虚拟交换机
--------------

- 默认情况下可以创建一个 ``public`` 虚拟机交换机，然后将物理主机的某个网卡加入(例如 ``em0`` )，这样后续配置虚拟机的时候，只要为虚拟机指定这个 ``public`` 虚拟机交换机，那么虚拟机的虚拟网卡就会连接上 ``public`` 虚拟交换机，并通过 ``em0`` 网卡连接外部物理真实网络:

.. literalinclude:: vm-bhyve/swich
   :caption: 创建虚拟交换机并连接物理网卡

不过，我的实践有所不同: 我已经在 :ref:`freebsd_bridge_startup` 和 :ref:`bhyve_startup` 实践时构建了一个共用的虚拟交换机 ``igc0bridge`` ，也就是在 ``/etc/rc.conf`` 中配置了:

.. literalinclude:: ../../virtual/bhyve/bhyve_startup/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置虚拟交换机 ``igc0bridge``

所以在 ``vm-bhyve`` 中复用这个虚拟交换机: ``vm-hbyve`` 在模版文件中设置 ``network0_switch="igc0bridge"`` 来指定

存储
--------

- 在 ``vm create`` 命令时可以通过 ``-d <datastore>`` 指定和默认 ``vm_dir`` 不一样的ZFS存储数据集，例如我的 ``/etc/rc.conf`` 配置了 ``vm_dir="zfs:zdata/vms"`` ，但是我如果想要在另外一个 ``zstore/bhyve`` 数据集中创建一个虚拟机，则可以使用( ⚠️ 我还没有验证)::

   vm create -d zstore/bhyve ...

- 在 :ref:`bhyve_ubuntu` 实践中，我使用了 ZFS volume 来作为虚拟机的磁盘，这种 raw disk 可以提高存储性能。不过实验环境也可以使用 ``zfs create -sV 50G -o volmode=dev ...`` 来构建稀疏卷(sparse volume)来节约存储空间占用 

.. warning::

   ⚠️

   不需要预先为 ``vm-bhyve`` 手工创建 稀疏卷(sparse volume) ，因为其内置了创建功能，而且约定了::

      DEVICE TYPE        DISK NAME      BHYVE PATH USED
      zvol|sparse-zvol  'disk0'     -> '/dev/zvol/pool/dataset/path/guest/disk0'

   也就是说，只要配置了::

      disk0_dev="sparse-zvol"
      disk0_name="disk0"

   就会自动在 ``/zdata/vms/mdev`` 目录下创建一个 ``disk0`` 稀疏卷(这里 ``zdata/vms`` 是指定的虚拟机卷集， ``mdev`` 是虚拟机名

:ref:`bhyve_pci_passthru`
-----------------------------

``vm-bhyve`` 支持 :ref:`bhyve_pci_passthru` ，并且可以检查系统中哪些设备可以passthrough:

.. literalinclude:: vm-bhyve/vm_passthru
   :caption: 检查可以passthrough的设备

我的 :ref:`tesla_p10` 已经在 :ref:`` 配置好passthrough，所以输出现实状态已经就绪:

.. literalinclude:: vm-bhyve/vm_passthru_output
   :caption: 检查可以passthrough的设备: 可以看到Tesla P10
   :emphasize-lines: 9

此时配置文件就可以设置:

.. literalinclude:: vm-bhyve/passthru.conf
   :caption: 配置passthrough设备

.. note::

   ``vm-bhyve`` 参考手册中， ``vm passthru`` 没有任何参数，只能显示当前可以passthrough的设备列表。似乎只有配置文件能够指定传递的设备

启动设备
--------------

``vm-bhyve`` 配置中使用了一个 ``start_slot`` 参数和 ``install_slot`` 参数:

- 对于UEFI虚拟机，一些UEFI虚拟机要求磁盘slot是 ``3-6`` ， ``vm-bhyve`` 默认使用 ``4`` 作为磁盘slot，而 ``3`` 保留给安装ISO

VNC图形界面
------------

``vm-bhyve`` 提供了一个 ``graphics`` 参数来支持VNC，端口从5900开始找寻，通过 ``vm list|info`` 输出可以看到虚拟机的VNC端口::

   # 默认提供VNC
   graphics="yes"

配置
========

- 在 ``/zdata/vms/.templates`` 构建一个我的自定义模版 ``x-vm.conf`` :

.. literalinclude:: vm-bhyve/x-vm.conf
   :caption: 自定义模版 ``x-vm.conf``

- 配置说明:

  - ``wired_memory`` 是因为 :ref:`bhyve_pci_passthru` 需要
  - ``disk0_dev`` 指定为 ``sparse-zvol`` ，这样 ``vm-bhyve`` 会自动创建 ``/zdata/vms/mdev`` 作为虚拟机存储数据集，并在下面创建一个 ``sparse volume`` raw磁盘 ``disk0``
  - ``network0_switch`` 指定了我预先配置的 ``igc0bridge`` 虚拟交换机
  - ``network0_device`` 这里设置了 ``tap0`` 而不是让 ``vm-bhyve`` 自动生成，是因为我发现我配置了指定交换机之后，自动生成的 ``tap3`` 没有 ``addm`` 到我指定的 ``igc0bridge`` 虚拟交换机，导致网络不通。我参考 ``config.sample`` 特定指定了我之前配置好的 ``tap0`` (已经连接在 ``igc0bridge`` 上)就解决了这个网络问题
  - 我发现初次安装的时候不能直接把 :ref:`tesla_p10` 直接 passthru 进虚拟机，会导致虚拟机启动后VNC没有输出(估计虚拟机发现有NVIDIA :ref:`tesla_p10` 导致默认输出到GPU上了。这里注销掉GPU就能安装，后续安装完再修订配置加入  pcie passthru

- 创建虚拟机:

.. literalinclude:: vm-bhyve/create_vm
   :caption: 创建虚拟机 ``mdev``

``-t x-vm`` 表示使用 ``/zdata/vms/.templates`` 目录下的 ``x-vm.conf`` 作为模版,我这里使用了 ``-s 60G`` 创建了一个特定的60G虚拟磁盘，配置中默认我设置了 ``50G``

- 在上述创建了虚拟机之后，就可以看到ZFS构建了一个 ``zdata/vms/mdev`` 存储集，并且在这个存储集下有一个 ``disk0`` 的 ``zvol`` raw disk:

.. literalinclude:: vm-bhyve/zfs_mdev
   :caption: 创建的虚拟机 ``mdev`` 对应的ZFS
   :emphasize-lines: 4,9,10

- ``vm-bhyve`` 提供了一个 ``vm iso`` 命令用于将镜像下载到 ``.iso`` 目录下(对于我的环境是 ``/zdata/vms/.iso`` )，也可以手工将已经下载的镜像iso文件移动到该目录(我在该目录下保存了我下载的 ``ubuntu-24.04.2-live-server-amd64.iso`` )

- 安装ubuntu:

.. literalinclude::  vm-bhyve/vm_install
   :caption: 安装虚拟机

终端输出显示:

.. literalinclude::  vm-bhyve/vm_install_output
   :caption: 安装虚拟机终端显示

虚拟机配置修改
==================

我需要实现 :ref:`bhyve_pci_passthru` ，所以修订虚拟机配置 ``/zdata/vms/mdev/mdev.conf`` (这个配置是 ``vm create`` 时创建的):

.. literalinclude:: vm-bhyve/mdev.conf
   :caption: 修订 ``/zdata/vms/mdev/mdev.conf``
   :emphasize-lines: 11

奇怪，启动虚拟机VNC控制台没有任何输出

我检查了 ``/zdata/vms/mdev/vm-bhyve.log`` :

.. literalinclude:: vm-bhyve/vm-bhyve.log
   :caption: ``vm-bhyve.log`` 日志没有看出报错

我加上了debug模式，但是输出的日志没有变化

另外 `Experience from bhyve (FreeBSD 14.1) GPU passthrough with Windows 10 guest <https://forums.freebsd.org/threads/experience-from-bhyve-freebsd-14-1-gpu-passthrough-with-windows-10-guest.94118/>`_ 提到了将slot修改为8，我也尝试了不行::

   #passthru0="1/0/0=8:0"
   passthru0="1/0/0"

如果不指定slot参数，会自动找一个可用的，我发现是 ``6:0`` :

.. literalinclude:: vm-bhyve/vm-bhyve.log_passthru
   :caption: 最简化 ``passthru0="1/0/0"``

但是还是VNC没有任何输出黑屏

参考
=======

- `From 0 to Bhyve on FreeBSD 13.1 <https://klarasystems.com/articles/from-0-to-bhyve-on-freebsd-13-1/>`_
- `FreeBSD Bhyve Companion Tools <https://vermaden.wordpress.com/tag/vm-bhyve/>`_
- `Github: freebsd/vm-bhyve <https://github.com/freebsd/vm-bhyve>`_
