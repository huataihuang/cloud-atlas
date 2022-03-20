.. _mini_k3s_prepare:

===================
微型K3s部署准备
===================

硬件: :ref:`pi_1`
=====================

为了能够发挥 :ref:`pi_1` 硬件余热(10年前购买的)，我通过 :ref:`alpine_install_pi_1` 来运行底层系统，一共使用了3个 :ref:`pi_1` :

- :ref:`alpine_install_pi_1` 只需要执行一次，另外两个树莓派通过 :ref:`alpine_pi_clone` 可以快速完成
- 按照 :ref:`edge_cloud_infra` 为3个 :ref:`pi_1` 分配IP地址及主机名，启动后，确保3台主机都能ssh登陆

  - 我发现实际上只有2台是512MB内存的B型 :ref:`pi_1` ，另外一台则只有 256MB 内存 ，所以硬件性能非常有限
  - 只能安装32位操作系统，使用 :ref:`alpine_linux` for ``armhf`` 系统，期望能够将硬件资源要求降到最低
  - :ref:`pi_1` 功率极低，无风扇，将3台设备叠加起来形成一个stack，扔到桌子底下连接到路由器的网口上组成小集群

alpine linux初始化
=======================

- :ref:`alpine_install_pi_1` 安装第一台主机，然后 :ref:`alpine_pi_clone`

最小化alpine linux安装(sys模式)，启动系统后观察可以看到，内存仅占用 42MB 

- 软件仓库激活 ``community`` ，即修改 ``/etc/apk/repositories`` :

.. literalinclude:: ../../../linux/alpine_linux/alpine_apk/repositories
   :language: bash
   :linenos:
   :caption: 激活community仓库
   :emphasize-lines: 3

- 安装工具 :ref:`screen` 并设置 ``~/.screenrc`` ::

   sudo apk add screen

:ref:`alpine_docker`
======================

执行以下步骤实现 :ref:`alpine_docker` :

- 安装docker ::

   apk add docker

- 将自己的账号加入到 ``docker`` 组::

   addgroup huatai docker

- 启动Docker服务 - 参考 :ref:`openrc` :

 .. literalinclude:: ../../../linux/alpine_linux/alpine_docker/docker_openrc
    :language: bash
    :caption: openrc 添加和启动 docker服务

- 执行以下命令添加 ``dockremap`` :   

.. literalinclude:: ../../../linux/alpine_linux/alpine_docker/dockremap
   :language: bash
   :caption: 添加dockremap(安全配置)

- 创建 ``/etc/docker/daemon.json`` :

.. literalinclude:: ../../../linux/alpine_linux/alpine_docker/daemon.json
   :language: json
   :caption: alpine 运行docker的 /etc/docker/daemon.json

- 执行cgroup的fs挂载配置:

.. literalinclude:: ../../../linux/alpine_linux/alpine_docker/cgroup_fstab
   :language: bash
   :caption: 配置cgroup的fs挂载配置 /etc/fstab

- 创建 ``/etc/cgconfig.conf`` :

.. literalinclude:: ../../../linux/alpine_linux/alpine_docker/create_cgconfig.conf
   :language: bash
   :caption: 创建 /etc/cgconfig.conf

- 修订alpine linux内核启动参数，``/media/mmcblk0p1/cmdline.txt`` 添加:

.. literalinclude:: ../../../linux/alpine_linux/alpine_docker/cmdline.txt
   :language: bash
   :caption: /media/mmcblk0p1/cmdline.txt 添加内核参数

- 重启主机，然后检查 ``docker info`` 输出信息

.. note::

   我这里遇到一个问题，配置最低的 :ref:`pi_1` 内存不到 180MB ，而安装了 docker 之后，启动即只剩 16MB 。看起来，至少要512MB内存规格的树莓派才可能运行服务了。

   这个问题待后续尝试 :strike:`淘一个二手树莓派` ? (2022年3月，芯片荒加上新冠疫情，树莓派售价飞涨，比之前购买时上价格翻倍，简直疯了)

   可能不能构建3节点集群，先尝试2节点简化部署，然后将这个内存极为有限的节点作为一个调度演示节点？运行极为轻量级的内存节点？削减 ``dockerd`` 和 ``containerd`` 的内存占用？
