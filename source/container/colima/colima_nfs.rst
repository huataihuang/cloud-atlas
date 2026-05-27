.. _colima_nfs:

=======================
Colima使用NFS共享存储
=======================

在尝试 :ref:`colima_mounttype_9p` 优化存储性能之后，我发现虽然I/O性能有一定提升，但是也带来了很多不稳定的因素:

- 可能由于 :ref:`oclp_macos` 魔改的驱动插入和内核调用拦截改写，导致了需要降级为 ``qemu64`` 类型的通用模拟CPU类型，导致性能和特性大幅下降
- 在使用过程中，容器中编译的应用多次闪退，虽然通过降级GCC编译的目标二进制指令集来规避，但是依然存在偶然的闪退

和gemini讨论启发了我，考虑采用对小文件更优的NFS服务来取代 ``sshfs`` 和 ``9p`` 存储挂载，虽然Colima没有内置支持这种NFS简洁方便的配置，但是可以采用 ``provision`` 脚本来实现通用型NFS挂载，来替代默认但性能底下的 ``mountType`` 。

快速起步
===========

.. note::

   本段设置方法是我的实践最终汇总，已经验证成功

- 配置 ``/etc/nfs.conf`` 性能优化配置

.. literalinclude:: ../../apple/macos/macos_nfs3/nfs_tunning.conf
   :caption: 性能优化的NFS v3 ``/etc/nfs.conf``

- 配置 ``/etc/exports`` 配置输出:

.. literalinclude:: ../../apple/macos/macos_nfs3/exports
   :caption: 输出 /Users/admin 目录

.. note::

   :ref:`macos_nfs4` 实践没有成功

异常排查
==========

.. note::

   以下是我的一次折腾之旅的记录，仅供参考。正确的方法则见本文前半部分!!!

- 我最初采用的NFS v4配置

``/etc/nfs.conf`` :

.. literalinclude:: ../../apple/macos/macos_nfs4/nfs.conf
   :caption: 配置启用NFSv4

- 我最初采用的Colima VM的配置 ``~/.colima/_template/default.yaml`` :

.. literalinclude:: colima_nfs/default_nfs.yaml
   :caption: 在模板中添加 ``provision`` 段落的NFS挂载脚本

===========

我发现启动Colima VM之后，并没有如预想的那样自动成功挂载 ``/Users/admin`` 目录，这里可能有几个潜在的问题:

- macOS的安全策略可能限制了 ``nfsd`` 这样的服务进程全盘访问，例如禁止访问敏感目录(完整全量的HOME目录)
- :ref:`debian` 客户端访问macOS的NFS v4协商失败

- 在 Colima VM ( :ref:`ubuntu_linux` )中安装 ``netcat-openbsd`` 软件包获取 ``nc`` 工具来检测服务端口可达性:

.. literalinclude:: colima_nfs/nc
   :caption: 执行端口2049检查

输出显示端口是通的:

.. literalinclude:: colima_nfs/nc_output
   :caption: 执行端口2049检查

- 偶然发现，在Colima VM中采用 ``rpcinfo -p 192.168.5.2`` 居然看到和macOS Host主机完全不同的内容，就好像 192.168.5.2 根本不是Host主机一样:

.. literalinclude:: colima_nfs/rpcinfo_in_vm
   :caption: 在Colima VM中观察 ``rpcinfo -p 192.168.5.2``

.. literalinclude:: colima_nfs/rpcinfo_in_host
   :caption: 在macOS Host主机上观察 ``rpcinfo -p``

可以看到两者完全不同: 即使在Colima VM中通过 ``nc`` 检查是能够访问Host主机的 ``2049`` 但是却看不到rpc信息

Gemini给出了一个可能的解释:

Colima 默认使用的 ``QEMU Slirp`` （用户态网络栈），为了在不需要 macOS 宿主机提供 root 权限和复杂桥接网卡的前提下实现虚拟机的 NAT 上网，它在虚拟机和宿主机之间实现了一个 **轻量级的内置虚拟路由器（由 QEMU 进程模拟）** :

- 执行 ``nc -zv 192.168.5.2 2049`` 时，QEMU 的 Slirp 引擎发现 2049 是一个普通端口，它做了一次透明的端口转发（Port Forwarding），把流量老老实实地导向了 Mac 宿主机真正的 localhost:2049。所以 nc 看到的是真 Mac，提示成功。
- 当执行 ``rpcinfo -p 192.168.5.2`` 时，请求去往的是 111 端口。 **QEMU 为了在虚拟网段内部提供基础的 RPC 发现，它自己内部实现了一个极简的、用户态的 RPCBind 服务（Portmapper）** QEMU 虚拟路由器拦截了发往 ``111`` 端口的请求。这里看到的 ``portmapper`` 和 ``status`` 但完全没有 ``nfs`` 和 ``mountd`` 的输出，实际上是QEMU进程自己伪造并返回给虚拟机的应答。

解决方法
-----------

macOS内核提供了 **仅限主机（Host-Only）的虚拟二层交换机（Virtual Switch）网络** :

- macOS 内核原生的 ``vmnet.framework`` （苹果官方虚拟化网络框架）会在系统底层虚拟出一块物理网卡（通常叫 ``fnetwork`` 或 ``vmnetX`` ），并直接分配给 Colima 虚拟机作为副卡。
- 虚拟机和 Mac 宿主机变成了同一个局域网内的两台独立主机。它们之间的通信直接走 macOS 内核的二层转发，QEMU 再也没有机会在半路拦截 111 或 858 端口。
- ``192.168.106.x`` 网段是 Colima 底层依赖的开源网络组件 :ref:`lima` （Linux virtual machines on macOS）在源码里硬编码死锁的默认保留网段。

- 方法一: 在命令行启用 ``address`` 网络

.. literalinclude:: colima_nfs/start_address
   :caption: colima命令行启用address网络

- 方法二: 修订 ``~/.colima/_template/default.yaml`` 启用 ``address`` 网络:

.. literalinclude:: colima_nfs/template_addresss
   :caption: 修订Colima虚拟机模板配置 ``~/.colima/_template/default.yaml``

在启用了 ``address`` 网络之后，通过 ``colima ssh`` 进入VM之后，检查 ``ip addr`` 可以看到VM中现在有 **2个网卡** :

.. literalinclude:: colima_nfs/ip_addr
   :caption: 在VM中可以看到2个网络
   :emphasize-lines: 7,9,13,15

- 现在用 ``rpcinfo -p 192.168.106.1`` 检查就能够看到macOS Host主机上的NFS服务:

.. literalinclude:: colima_nfs/rpcinfo_address
   :caption: 检查address网络上的macOS Host可以看到NFS服务
   :emphasize-lines: 8-11

- 然后在VM中测试挂载

.. literalinclude:: colima_nfs/mount_nfs_v3
   :caption: 命令行挂载NFS v3

挂载成功!!!


