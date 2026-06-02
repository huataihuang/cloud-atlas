.. _colima_nfs:

=======================
Colima使用NFS共享存储
=======================

.. note::

   经过实践验证，采用NFS作为Colima的数据共享交换底层，在我的古旧的 :ref:`mbp15_late_2013` 替换 :ref:`qemu` 默认使用的 ``sshfs`` ，能够获得大约 ``5倍`` 的 I/O 性能提升。虽然探索设置有些折腾，但是能够让十几年前的硬件焕发青春，还是有点意义的。

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

- 修订 ``~/.colima/_template/default.yaml`` 配置，将sshfs修订 "伪挂载" ，并且独立挂载 ``/Users/admin/docs`` :

.. literalinclude:: colima_nfs/default.yaml

- 性能测试: 和 :ref:`colima_mounttype_9p` 采用相同的编译 :ref:`sphinx_doc` 方式 ``time make html``

.. literalinclude:: colima_nfs/make_html
   :caption: 使用NFS存储方式测试编译Sphinx文档的耗时(启用resvport参数,hard)
   :emphasize-lines: 1

不过，在没有启用 ``resvport`` 参数的 hard 挂载同样测试性能差一些，完成时间减慢到将近12分钟:

可以看到完成时间惊人地缩短到 ``7m25s`` ，是原本使用 ``sshfs`` 时间的 1/5 不到，已经接近物理主机的的编译性能

.. literalinclude:: colima_nfs/make_html_no_resvport
   :caption: 使用NFS存储方式测试编译Sphinx文档的耗时(去除resvport参数,hard)
   :emphasize-lines: 1

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

:strike:`休眠问题`
----------------------

上述NFS挂载确实使得I/O性能得到极大提升，但是我发现当笔记本合上以后进入休眠，再次唤醒系统时会发现Colima虚拟机无法登录且容器无响应。

这个问题是NFS挂载 ``hard`` 模式相关，实际上我在阿里巴巴工作时，也曾经遇到过NAS故障导致依赖NFS挂载的应用服务器无法 ``df`` 以及应用挂死的故障。

.. warning::

   这段排查我实践下来已经排除，gemini提供的建议不准确

gemini推测(其实我觉得不准确):

- 由于我在NFS挂载的 ``/home/admin/`` 目录下工作，当MacBook合盖休眠， ``vmnet`` 虚拟网卡( ``192.168.106.1``` )随之断电。此时虚拟机内还有工作进程(例如正在使用 ``vim`` 编辑该目录下文件)
- ``hard`` 模式下，Linux内核会立即将该I/O进程挂起，并进入不可中断的睡眠状态(D状态, Uninterruptible Sleep)
- 当电脑唤醒时，macOS的虚拟网卡需要几秒钟的握手时间，而此时虚拟机内部因为D状态进程无法被杀死，会迅速把系统的VFS(虚拟文件系统)控制块耗尽
- 负载处理 ``colima ssh`` 登录的 ``sshd`` 守护进程在读取用户配置或日志时，一旦触碰到被锁死的VFS锁，它也会瞬间变成D状态挂起。最终现象就是虚拟机虽然在运行，但是整个I/O链路已经挂起导致任何命令都无法进行

解决方法尝试:

- 修订 ``default.yaml`` 的挂载参数

将 ``hard`` 模式修订为待要高频超时重试的 ``soft,retrans`` 组合，并缩短超时周期

.. literalinclude:: colima_nfs/mount_nfs_v3_soft.yaml
   :caption: 采用 ``soft,retrans`` 组合挂载

说明:

- ``soft`` （软挂载）: 如果网络断开（合盖休眠），向 Mac 发起的 I/O 请求在重试失败后， **直接向调用进程返回一个 EIO（I/O 错误）状态码，而不是让进程进入死等的 D 状态！** 这样就彻底保护了系统的 sshd 等核心基础设施不会被连带锁死。
- ``timeo=10`` : 将单次 RPC 请求的超时时限缩短为 1.0 秒（单位是 0.1 秒）。默认是 60 秒，合盖时根本等不起。
- ``retrans=3`` : 当发生超时后，只尝试重试 3 次（总计 3 秒钟）。如果 3 秒内 Mac 没醒过来，立刻切断本次连接并报错返回。

样微调后，合盖时虚拟机内部的进程会抛错，而不会卡死系统。当开盖网卡恢复后，下一次 I/O 请求又会瞬间重新拉通。

其他调整(可选):

如果Mac 经常在后台跑长时间的编译任务，可以利用 macOS 內置的 ``pmset`` 电源管理工具，允许 Mac 在合盖时依然保持网络栈和虚拟机的微弱唤醒状态（不进入物理彻底断电）:

.. literalinclude:: colima_nfs/pmset
   :caption: 设置合盖微弱唤醒

休眠问题(再查)
------------------

我还发现一个Colima VM挂载的特性:

- 当没有配置 ``mounts:`` 部分，也就是采用默认配置，Colima会自动挂载 HOME 目录，而且只挂载 HOME 目录。此时进入VM执行 ``df -h`` 可以看到:

.. literalinclude:: colima_nfs/default_mount_df
   :caption: 默认挂载HOME目录，在VM内部检查
   :emphasize-lines: 4

但是，当我配置了一个欺骗Colima的空目录挂载:

.. literalinclude:: colima_nfs/default_nfs.yaml
   :caption: 配置欺骗的空挂载
   :lines: 4-10
   :emphasize-lines: 5,6

则此时进入VM会看到一个特殊的 **缓存挂载** :

.. literalinclude:: colima_nfs/cache_mount_df
   :caption: 当使用了定制挂载，Colima会挂载一个系统级的 ``缓存挂载``
   :emphasize-lines: 4

这就带来一个冲突隐患: 如果我再直接通过NFS挂载 ``/Users/admin`` 目录到VM内部，是否和这个缓存挂载目录冲图，是否会引起前面所说的挂起死机:

- 可以看到当停止默认的HOME挂载，Coliama会明确挂载一个缓存目录 ``/Users/admin/Library/Caches/colima`` ，这个缓存目录原先是包含在HOME挂载中的，所以这个目录独立挂载以后，再通过NFS去直接挂载HOME目录存在冲图:

  - NFS是最后挂载的，并且覆盖了缓存目录挂载，虽然理论上Colima依然可以通过NFS访问缓存文件，但是一旦主机从休眠中恢复，显然NFS服务没有这么块就能够就绪
  - 缓存目录可能是Colima最早需要访问的数据，由于NFS覆盖了原本sshfs提供的目录挂载导致Colima内核暂时看不到缓存，此时可能会导致系统挂起

- 前述Gemini建议的NFS挂载修改为Soft模式并且快速重试应该能够改善NFS的挂起，但是根据我的经验，这种NFS挂载通常不会导致挂起，但是这里存在的问题是缓存也在NFS上，这个内核机制锁死了系统

- 综上，我 :strike:`觉得` **必须** 放弃(或不建议)直接在NFS中输出完整的HOME目录，除非缓存目录能够从HOME目录中移出，以避免和HOME的NFS挂载冲突。

所以最终修订目录 ``/Users/admin`` 改为 ``/Users/admin/docs`` (挂载数据目录)

.. literalinclude:: colima_nfs/mount_nfs_v3_soft_docs.yaml
   :caption: 采用 ``soft,retrans`` 组合挂载 ``/Users/admin/docs``

soft挂载的自动恢复
---------------------

在使用了 ``soft`` 挂载NFS之后，实践发现，当主机休眠以后，再恢复工作，此时VM内部的挂载会提示报错:

.. literalinclude:: colima_nfs/io_error
   :caption: 当主机休眠后恢复soft挂载会提示I/O错误

不过系统不会挂死，此时需要手工umount并重新mount一次进行恢复。

为了能够自动完成恢复，gemini提供了一段脚本定期检查和恢复，参考如下

.. literalinclude:: colima_nfs/cron_mount
   :caption: 通过定时任务来检查soft挂载是否异常，并自动重新挂载
   :language: bash

.. note::

   这里的脚本仅供参考，但我实际方案改回了hard挂载，所以不再出现这里的soft挂载问题，方案就可以简化为不需要这段 ``cron_mount`` 修复

最终验证方案
=============

如上所述，我最终验证确实如我推测，最核心的导致Colima VM在主机从休眠中恢复时挂起，其实就是cache缓存目录被NFS挂载HOME目录所覆盖，导致NFS暂停以后缓存机制失效而死机。

我对比了 ``hard`` 和 ``soft`` 两种挂载方式:

- 只要没有 ``/Users/admin/Library/Caches/colima`` 和 ``/Users/admin`` (NFS挂载) 的挂载冲突，那么不管 ``hard`` 和 ``soft`` NFS挂载都不会导致Colima VM挂起无响应问题
- 但是 ``soft`` 挂载和 ``hard`` 挂载表现不同的是，当macOS Host主机进入休眠，然后恢复时， ``hard`` 模式下 ``df -h`` 会卡住任何输出，而 ``soft`` 则表现为能够输出所有和NFS无关的挂载输出，并且显示I/O错误:

.. literalinclude:: colima_nfs/soft_nfs_io_error
   :caption: ``soft`` NFS挂载显示I/O错误 
   :emphasize-lines: 1

- 理论上 ``soft`` 和 ``hard`` 的NFS挂载I/O性能应该是相同的，但是实践发现在编译sphinx文档，原本 ``hard`` 挂载的完成时间是 ``7m25s`` ，现在 ``soft`` 挂载则退化成大约 ``12m`` 。Gemini提示之前soft的参数 ``timeo=5`` (表示0.5秒)太激进:
  
  - 编译 Sphinx 的 I/O 特征：Sphinx 在 make html 时，不仅有大文件的写入，更包含数万个小 .rst 和缓存文件的密集读写与元数据 lstat() 状态对齐。
  - 延迟滚雪球：当虚拟机瞬间发起成百上千个小文件的 RPC 请求时，Mac 宿主机的物理磁盘或内核 nfsd 线程池即便再快，在并发洪峰下，个别 RPC 请求的响应时间也难免会超过 0.5 秒。
  - 重传惩罚：一旦超过 0.5 秒，虚拟机内核判定触发 soft 超时。它会立刻中断当前的 TCP 传输，丢弃已经传输了一半的数据，重新发起重传（Retransmit）。这导致网络中充满了大量无效的、重复的重传风暴（Retransmission Storm）。
  - TCP 拥塞控制踩刹车：由于频繁触发超时，Linux 内核的 TCP 拥塞控制算法（如 Cubic）会误判定“网络发生了严重拥堵”，从而强行将 TCP 滑动窗口（Window Size）和慢启动阈值调整到最低。

- 我偶然发现，我在操作macOS Host主机，并且确认macOS没有休眠的情况下，Colima VM中的NFS挂载还是出现了上述NFS挂起无响应，出现 ``Input/output error`` ，这说明:

  - 并非是macOS Host主机休眠导致的NFS Server无法响应或恢复缓慢导致Colima虚拟机NFS挂起
  - 我最初怀疑是macOS的vmnet虚拟网卡在一段时间没有数据流量进入休眠导致了Colima VM到Host主机网络断开，但是通过 ``ip link`` down/up 并且确认网络正常情况下，NFS客户端挂载依然没有自动恢复，这和我之前在阿里的运维经验不同(NFS客户端应该在NAS恢复时自动恢复)。我通过持续的 ``ping 192.168.106.1`` 确认 ``vmnet`` 持续保持流量情况下，依然出现NFS挂起，这说明Colima NFS异常和 ``vmnet`` 没有直接关系

- ``resvport`` 可能是导致无法重新挂载NFS的元凶:

  - ``resvport`` 要求在1024端口以下对macOS服务端发起连接，这对于前一个NFS连接挂起(umount掉以后也可嫩更没有释放端口资源)再发起连接可能存在bug还是使用原先的 ``resvport``
  - 去掉这个 ``resvport`` 参数以后，我验证发现至少 ``soft`` 挂载能够轻松地 ``umount`` 并且重新 ``mount``

- 我现在怀疑是Colima VM自身的NFS软件堆栈在长时间没有数据传输情况下进入了假死状态，这个问题可能和虚拟化有关

  - 为了验证假设，我采用简单的脚本命令每10秒钟向NFS挂载目录写入一个时间戳，看看是否能够通过保持数据读写来keepalive:

.. literalinclude:: colima_nfs/keepalive.sh
   :caption: 持续写入NFS文件看能否保活

**经过验证，采用每10秒写入一次NFS能够keepalive保持Colima VM的挂载正常**

还是恢复了 ``hard`` 挂载，而单纯采用 ``/Users/admin/docs`` 数据目录挂载，避免了目录冲图。这种 ``hard`` 挂载模式稳定性极佳。

最后，在 ``default.yaml`` 中采用了 ``crontab`` 方式每分钟写一次 ``/Users/admin/nfs_watchdog`` 文件的时间戳记录，这样就能够保证NFS不挂死:

.. literalinclude:: colima_nfs/nfs_watchdog
   :caption: 定时每分钟写一次nfs_watchdog文件来保持NFS keepalive
   :language: bash

性能参数
==========

``resvport``
---------------

在 macOS 的NFS Clinet启用 ``resvport`` 对性能影响很大:

- ``resvport`` (reserved port)指NFS客户单使用一个私有的低于1024"保留的"TCP/UDP源端口来连接服务器，这意味着客户端具备root权限(常规用户无法绑定低于1024的端口)。这个设计是NFS历史上用于验证请求是从私有的信任的客户端发起的。
- macOS 对 ``noresvport`` 发起的请求会采用更为严格要求的安全沙箱进行隔离，这导致性能消耗严重

通过 :ref:`sphinx_doc` 的 ``time make html`` 对比，大致能够得出采用 ``resvport`` 的I/O性能大约比 ``noresvport`` 提升 36% :

.. literalinclude:: colima_nfs/make_html
   :caption: 使用NFS存储方式测试编译Sphinx文档的耗时( ``启用`` resvport参数,hard)
   :emphasize-lines: 1

不过，在没有启用 ``resvport`` 参数的 hard 挂载同样测试性能差一些，完成时间减慢到将近12分钟:

.. literalinclude:: colima_nfs/make_html_no_resvport
   :caption: 使用NFS存储方式测试编译Sphinx文档的耗时( ``去除`` resvport参数,hard)
   :emphasize-lines: 1

需要注意:

- ``resvport`` 是 “动作型参数” ，和通常通过 ``-o`` 传递给NFS client的 "状态型参数" ( ``rsize,wsize,noatime,soft`` 等)不同: 

  - 状态型参数是在整个挂载生命周期内，文件西欧通难过如何表现，内核需要通过状态型参数永久记录在系统的 ``mount`` 表中供调用者查询
  - 动作型参数( ``resvport`` )本质上是一个 "临时的连接协商指令" ，内核的 RPC 客户端（ ``sunrpc`` ）在建立物理 TCP 三次握手的那一瞬间，看到 ``resvport`` ，就会启动特权端口分配逻辑（在 ``0–1023`` 之间挑一个绑死）。一旦 TCP 握手成功（ ``ESTABLISHED`` ），这个参数的使命就彻底完成了。 Linux 内核并不会把这个属于套接字（Socket）层面的临时握手标记，当成文件系统的属性保存在 ``/proc/mounts`` 里，所以使用 ``mount`` 命令差看不到，而需要通过以下命令检查客户端端口:

.. literalinclude:: colima_nfs/ss_2049
   :caption: 检查NFS客户端端口

这里可以看到客户端本地端口是 ``812``
