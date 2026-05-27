.. _colima_mounttype_9p:

======================================
Colima mountType ``9p``
======================================

切换9p作为mountType
======================

由于我在Colima运行的debian容器中编译sphinx文档( ``time make html`` ) 看到性能极差，完整编译需要超过38分钟，表明在 "高并发、海量小文件遍历与读写" 场景中， ``sshfs`` 性能太差了

.. literalinclude:: colima_mounttype_9p/sshfs_time
   :caption: 编译sphinx文档 sshfs 环境消耗了38分钟非常缓慢

考虑到Colima的配置文档介绍 ``mountType`` 采用 ``9p`` 可以获得比 ``sshfs`` 性能更好(但大并发可能死锁)，对于个人使用可能比较合适。



containerd无法正常启动
======================

由于 :ref:`colima_config` 修订了存储 ``mountType`` ，将 :ref:`qemu` 默认的 ``sshfs`` 修订为 ``9p`` ，但是我发现重建了Colima VM之后， ``buildkit`` 服务启动失败，显示启动时无法访问 ``containerd.sock`` :

.. literalinclude:: colima_mounttype_9p/buildkit.log
   :caption: ``buildkit`` 启动失败日志

再一看系统中 ``containerd`` 进程确实没有启动，但是执行 ``systemctl restart containerd`` 启动却没有任何报错顺利启动了 ``containerd`` ，而且接着也能够启动 ``bulidkit`` 服务(因为containerd启动正常后buildkit终于能连接 ``containerd.sock`` )。但是，问题来了，为何每次重启系统 ``containerd`` 都没有正常启动? 执行 ``systemctl status containerd`` 可以看到:

.. literalinclude:: colima_mounttype_9p/status_containerd
   :caption: 重启系统后 ``containerd`` 没有正常启动
   :emphasize-lines: 3

检查启动日志:

.. literalinclude:: colima_mounttype_9p/journalctl_containerd
   :caption: 检查 ``containerd`` 日志

输出显示有一个很迷惑的 ``error="cni config load failed: no network config found in /etc/cni/net.d: cni plugin not initialized: failed to load cni config"`` ，然而这并不是导致containerd无法启动的原因:

- ``16:19:14`` 实际上显示了 ``containerd`` 启动成功: ``level=info msg="containerd successfully booted in 0.529690s"``
- 这里之所以出现 ``/etc/cni/net.d`` 目录下配置完全空，是因为我在 ``colima.yaml`` 明确配置了 ``kubernetes.enabled: false`` ，这就使得Colima不需要建立Kubernetes的CNI网络拓扑，所以配置空是合理的，这对运行Docker容器没有影响

但是，注意到日志结尾倒数第5行 ``Stopping containerd.service`` 这是由 :ref:`systemd` 发出的 ``Stopping`` 信号，主动把 ``containerd`` 关闭了。

Gemini给出了一个理由是Colima开机健康检查超时，也即是说Colima的内部守护进程在启动的6分钟内无法完成与宿主机的健康状态握手(Status Check Check-in)，导致 ``colima stop`` 停止VM？虽然我对这个解释存疑

我感觉我的 :ref:`mbp15_late_2013` 硬件不至于这么差，但是我的macOS是通过 :ref:`oclp_macos` ，所以OCLP为了能让macOS 15能够在缺乏现代硬件安全特性(如高级虚拟化安全页表扩展)的CPU运行， **对操作系统的内核和硬件抽象层(HAL)做了大量的硬拦截和指令集伪装** 。

这导致 ``colima`` 使用 ``9p`` 驱动运行QEMU时出现以下连锁反应:

- **内存映射死锁** ：9P 驱动（VirtIO-9P）在 Linux 内核与 QEMU 之间，极度依赖原生的大块连续物理内存映射（DMA 内存直通）。
- **OCLP的内核冲突** : QEMU尝试通过系统调用向macOS申请透传内存时，遇到了OCLP的内存也表伪装层。由于默认配置 ``cpuType: host`` 传递的核心拓扑让QEMU误以为拥有某些Haswell的原生直接调用，结果在内核态频繁触发 **指令集异常回滚(VTx VM-Exit异常)**
- **CPU陷入疯狂轮询** : 由于地层QEMU线程和OCLP补丁内核冲突，导致内核态死循环(spinlock)，这也就是开始6分钟卡死

Gemini建议在 :ref:`oclp_macos` 的环境中，放弃 ``cpuType: host`` 改为 ``cpuType: qemu64`` ，这样将CPU类型显式降级为标准的、由QEMU自主完全控制的虚拟化指令集，就能够切断它与OCLP内核的冲突。

.. literalinclude:: colima_mounttype_9p/default.yaml
   :caption: 设置qemu64作为CPU类型

此外，根据 ``default.yaml`` 的注释可以看到，实际上还有一些细节优化，可以增加到 ``qemu64`` CPU类型来表示支持具体的指令集，以增强性能。根据gemini建议，针对我的Haswell架构i7处理器，实际配置可以采用

.. literalinclude:: colima_mounttype_9p/default_i7.yaml
   :caption: 设置qemu64作为CPU类型，针对i7优化

说明
=======

``9p`` vs ``sshfs``
---------------------

.. csv-table:: ``9p`` vs ``sshfs``
   :file: colima_mounttype_9p/9p_vs_sshfs.csv
   :widths: 20,40,40
   :header-rows: 1

.. warning::

   我的实践发现在 :ref:`oclp_macos` 场景下，修订为 ``9p`` 之后，编译 :ref:`sphinx_doc` 性能没有变化，看起来有可能这种 ``9p`` 挂载驱动需要原生的硬件支持才能发挥性能，我这种软件魔改注入驱动的操作系统无法发挥作用。

Haswell i7 的指令集调优组合
-----------------------------

观察到Colima的 ``default.ymal`` 注释中提到对于 ``qemu64`` 的CPU类型可以增加指令集调优:  ``qemu64`` 默认自带的指令集极其古老，为了能够尽可能发挥硬件性能，针对 :ref:`mbp15_late_2013`  (搭载 Intel 第 4 代 Haswell 架构 i7 处理器)，可以通过精细化手动追加指令集，让它在保持 qemu64 稳定性的同时提供针对特定用途的指令优化:

.. literalinclude:: colima_mounttype_9p/default_i7.yaml
   :caption: 设置qemu64作为CPU类型，针对i7优化

- +avx 和 +avx2（高级矢量扩展）—— 编译与矩阵计算

  - 优化场景：如果在容器里运行一些基础的 AI/ML 脚本、数据分析、或者密集型的 C++/Rust 编译器优化（LLVM 极其喜欢向量化）。
  - 威力：AVX2 允许 CPU 的寄存器一次性处理 256 位的数据。开启后，容器内的科学计算和复杂数据处理速度通常能获得 2x - 4x 的物理加速。

- ``+aes``（高级加密标准指令集）—— 网络与 HTTPS

  - 优化场景：git clone、gem install（走 HTTPS 拉取），以及所有走 SOCKS5 隧道的加密网络通信。
  - 威力：没有 +aes，虚拟机只能用软件模拟去解包 SSH/TLS 的加密数据，CPU 瞬间飙高；开启 +aes 后，解密工作直接下沉到 Intel 芯片的物理硬件电路，Git 克隆和网络吞吐的 CPU 占用率会瞬间暴跌。

- ``+sse4.1`` 、 ``+sse4.2`` 、 ``+ssse3`` （流式 SIMD 扩展）—— 文本与字符串处理

  - 优化场景：开发 Rails 时，各类打包工具（Webpack/Vite）、数据库查询文本解析、以及 Neovim 的语法高亮解析（Treesitter）。
  - 威力：大幅加速 XML/JSON 序列化、多媒体数据流和纯文本字符串的匹配检索效率。

- ``+popcnt`` （位计数指令）

  - 优化场景：很多现代高级语言的运行时（如 Go 语言的内建 Map 结构、Rust 的位图计算）在底层重度依赖这个特殊的硬件指令。如果缺失，这些语言编写的现代工具性能会发生隐性退化。

``cpuType: host``
---------------------

OCLP补丁这种非原生（魔改）的系统上跑 QEMU 虚拟化， ``cpuType: host`` 会触发以下两个问题:

- VMX (Intel VT-x) 的多层嵌套与状态混乱

  - host 模式会把物理芯片的 VMX 硬件虚拟化扩展标志也直接传进去
  - 宿主机 macOS 自身的内核就已经被 OCLP 动态修改了对 VTx 寄存器的控制权。当虚拟机内部的 Linux 内核尝试去初始化硬件虚拟化组件（如 KVM 模块）并调用 VMX 指令时，QEMU 发出的系统调用在穿透 OCLP 的补丁内核时，会引发非预期的 VM-Exit 异常（内核级死锁）。CPU 并没有死机，但它会因为状态不一致而在内核态疯狂打转（Spinlock），导致 Colima 监控直接超时断连。

- 电源管理与缓存拓扑的伪装失败

  - host 模式会透传诸如 APERF/MPERF（硬件变频计数器）、MSR（模型特定寄存器）等芯片底层的微代码接口
  - OCLP 在系统层面对老 CPU 的电源管理和变频做过硬欺骗。虚拟机直接去读物理芯片的 MSR 寄存器，会和 OCLP 的欺骗逻辑直接撞车，导致 QEMU 线程在 macOS 中被挂起。

- qemu64 是 QEMU 虚拟出来的一个极其保守、没有任何硬件特殊怪癖的标准 64 位通用 CPU 模板:

  - 主动阉割掉了所有可能引发内核冲突的危险特性（比如彻底关闭了 VMX 硬件透传，不暴露任何物理 MSR 寄存器，不透传变频计数器）。

  - 对于 OCLP 的补丁内核来说，这个虚拟机就像一个规规矩矩的“纯用户态应用程序”，绝对不会去触碰任何敏感的硬件特权指令。因此，底层的内核级死锁和冲突被 100% 根除了。

但是纯 ``qemu64`` 实在是太慢了，所以利用 ``+`` 号，把原本 2013 年 i7 芯片中最纯粹、最安全、专门用于纯数学/计算加速、绝不涉及内核特权的纯计算指令集，一项一项精准地塞回给虚拟机:

  - AVX / AVX2：纯粹的数学向量计算寄存器，不涉及任何系统控制。
  - AES：纯粹的硬件解密电路，只负责算数。
  - SSE 系列 / POPCNT：纯粹的字符串和位运算指令。

性能改进
=============

我在完成了上述 ``cpuType`` 调整之后，修订为 ``qemu64`` 确实至少让 ``containerd`` 能够正常启动，也就是说在colima虚拟机启动开头的6分钟，不再出现无响应这种异常。但是我实际使用 ``make html`` 编译 :ref:`sphinx_doc` 并没有看到

.. literalinclude:: colima_mounttype_9p/9p_time
   :caption: 编译sphinx文档 9p 环境消耗了33分钟依然非常缓慢

gemini提到: Colima 挂载 ``9p`` 时出于数据绝对安全的考虑，关闭了 Linux 内核端的 ``9p`` 文件系统缓存（或者是用了最保守的 ``cache=none`` 模式）。这使得Sphinx在频繁读取数千个 ``.rst`` 源文件，或高频写入编译生成的HTML碎片是，由于没有缓存，虚拟机里的Linux内核每次读写文件、甚至检查文件修改时间，都迫使QEMI通过共享内存通道向Mac宿主机发起一次物理IO握手。

解决的思路是通过 ``provision`` 脚本强行开启Linux内核的 ``9p`` 缓存模式，也就是在 ``provision`` (开机初始化脚本)里，利用Linux的 ``mount -o remount`` 逻辑来实现将 ``9p`` 强制重新挂载为 ``cache=mmap`` （或 ``cache=loose`` )

由于Colima在配置文件中将参数划分为两大类: ``运行时动态参数`` 和 ``实例初始化元数据`` ，对于 ``provision`` 这样的元数据，需要彻底重构，否则仅仅通过重启只会沿用旧硬件模版。

- 备份当前系统已经构建的 :ref:`colima_images` :

.. literalinclude:: colima_mounttype_9p/nerdctl_save
   :caption: 备份已经构建的镜像

- 销毁Colima VM:

.. literalinclude:: colima_mounttype_9p/colima_delete
   :caption: 删除Colima VM

- 修改 ``~/.colima/_template/default.yaml`` (这里gemini给出的案例提供了系统级脚本)

.. literalinclude:: colima_mounttype_9p/provision.sh
   :caption: 在Colima启动虚拟机时运行脚本
   :language: yaml

这里 ``mode: system`` 表示该脚本在虚拟机拉起后，直接以 ``root`` 用户的特权身份在全局命名空间执行。注意， **务必保持脚本的"密等性"** ，也就是注释中写明了 ``Provisioning scripts are executed on startup and therefore needs to be idempotent.”`` ，这些脚本在 **每次开机都会无脑执行一次**

- 创建Colima VM，此时创建的VM内部使用了 ``9p`` mountType并且启用了缓存:

.. literalinclude:: colima_mounttype_9p/colima_start
   :caption: 创建Colima VM

- 恢复容器:

.. literalinclude:: colima_mounttype_9p/nerdctl_load
   :caption: 恢复容器

- 在容器中再次运行 ``time make html`` 验证性能:

.. literalinclude:: colima_mounttype_9p/9p_time_tunning
   :caption: 启用了缓存设置的9p mountType

对比
-------

通过将 ``sshfs`` mountType 更换成 ``9p`` ，再微调 ``9p`` 启用缓存，性能对比

.. csv-table:: sshfs vs. 9p
   :file: colima_mounttype_9p/sshfs_vs_9p.csv
   :widths: 10, 15, 15, 15, 15, 15, 15
   :header-rows: 1

可以看到当 ``9P + 缓存`` I/O 耗时缩短了大约10分钟，相当于提升了 33% 。这意味着 Sphinx 编译时频繁进行的 stat（检查文件修改时间）和读取小文件的请求，有超过三分之一直接在虚拟机的内存缓冲区中被“截获”并秒回，根本没有去打扰 Mac 宿主机的物理磁盘。总编译时间直接砍掉了接近 12 分钟（整体性能提升 29.69%）。

- ，注意到 在 SSHFS 下，user 花了 9分01秒，而到完全体 9P 时，变成了 7分27秒。这说明 ``上下文切换（Context Switch）`` 在SSHFS 模式下，由于 I/O 极度密集且延迟高，Python 进程频繁地在“运行”和“因等待 I/O 而挂起”之间来回极其高频地切换。每次切换，CPU 都要被迫保存和恢复进程寄存器状态，这部分损耗也会有很大一部分被操作系统算在 user 时间头上。

进一步优化(无效)
=================

对于 :ref:`mbp15_late_2013` 处理器是 :ref:`intel_core_i7_4850hq` ，巨鳖4个Core8个超线程。所以考虑到能够具备4个核心并行，且我主要使用Linux平台开发，所以我为Colima虚拟机分配 ``3c6g`` 规格，并尝试并行编译:

- 调整 ``~/.colima/default/colima.yaml`` 调整CPU和内存:

.. literalinclude:: colima_mounttype_9p/3c6g.yaml
   :caption: 调整Colima VM的CPU数量和内存
   :emphasize-lines: 3,7

- 重启Colima虚拟机

.. literalinclude:: colima_mounttype_9p/restart_vm
   :caption: 重启Colima VM

- 尝试以3个并发进行 :ref:`sphinx_doc` 编译: ``time make html -j3``

.. literalinclude:: colima_mounttype_9p/9p_time_tunning_3c
   :caption: 启用了缓存设置并增加VM规格3c6g的9p mountType

但是很不幸，我原本以为 ``-j3`` 能够加速编译，但是实际发现Python进程全程处于 ``D`` 状态等待I/O，所以增加CPU数量并没有提升编译性能。有可能纯CPU计算的程序可能会有部分收益。

以下是编译时从容器内部观察 ``top`` ，可以看到 ``user`` 虽然分散到3个cpu core，但是实际很低并没有跑满CPU， ``Python`` 进程始终处于 ``D`` 状态，显示正在等待I/O。从macOS的Host主机观察， ``qemu`` 进程实际上 ``2c`` 或 ``3c`` 没啥差别，占用CU负载就只能 ``120~140%`` ，无法充分发挥CPU性能。

.. literalinclude:: colima_mounttype_9p/top
   :caption: 从容器内部观察top显示CPU资源无法充分利用
   :emphasize-lines: 2-4,9

参考
======

- Gemini
