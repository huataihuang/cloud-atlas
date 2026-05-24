.. _colima_containerd_debug:

======================================
Colima虚拟机中Containerd启动失败排查
======================================

由于 :ref:`colima_config` 修订了存储 ``mountType`` ，将 :ref:`qemu` 默认的 ``sshfs`` 修订为 ``9p`` ，但是我发现重建了Colima VM之后， ``buildkit`` 服务启动失败，显示启动时无法访问 ``containerd.sock`` :

.. literalinclude:: colima_containerd_debug/buildkit.log
   :caption: ``buildkit`` 启动失败日志

再一看系统中 ``containerd`` 进程确实没有启动，但是执行 ``systemctl restart containerd`` 启动却没有任何报错顺利启动了 ``containerd`` ，而且接着也能够启动 ``bulidkit`` 服务(因为containerd启动正常后buildkit终于能连接 ``containerd.sock`` )。但是，问题来了，为何每次重启系统 ``containerd`` 都没有正常启动? 执行 ``systemctl status containerd`` 可以看到:

.. literalinclude:: colima_containerd_debug/status_containerd
   :caption: 重启系统后 ``containerd`` 没有正常启动
   :emphasize-lines: 3

检查启动日志:

.. literalinclude:: colima_containerd_debug/journalctl_containerd
   :caption: 检查 ``containerd`` 日志

输出显示有一个很迷惑的 ``error="cni config load failed: no network config found in /etc/cni/net.d: cni plugin not initialized: failed to load cni config"`` ，然而这并不是导致containerd无法启动的原因:

- ``16:19:14`` 实际上显示了 ``containerd`` 启动成功: ``level=info msg="containerd successfully booted in 0.529690s"``
- 这里之所以出现 ``/etc/cni/net.d`` 目录下配置完全空，是因为我在 ``colima.yaml`` 明确配置了 ``kubernetes.enabled: false`` ，这就使得Colima不需要建立Kubernetes的CNI网络拓扑，所以配置空是合理的，这对运行Docker容器没有影响

但是，注意到日志结尾倒数第5行 ``Stopping containerd.service`` 这是由 :ref:`systemd` 发出的 ``Stopping`` 信号，主动把 ``containerd`` 关闭了。

Gemini给出了一个理由是Colima开机健康检查超时，也即是说Colima的内部守护进程在启动的6分钟内无法完成与宿主机的健康状态握手(Status Check Check-in)，导致 ``colima stop`` 停止VM？虽然我对这个解释存疑

我感觉我的 :ref:`mbp15_late_2013` 硬件不至于这么差，但是我的macOS是通过 :ref:`oclp_macos` ，所以OCLP为了能让macOS 15能够在缺乏现代硬件安全特性(如高级虚拟化安全页表扩展)的CPU运行， **对操作系统的内核和硬件抽象层(HAL)做了大量的硬拦截和指令集伪装** 。

这导致 ``colima`` 使用 ``9p`` 驱动运行QEMU时出现以下连锁反应:

- **内存映射死锁** ：9P 驱动（VirtIO-9P）在 Linux 内核与 QEMU 之间，极度依赖原生的大块连续物理内存映射（DMA 内存直通）。
- **OCLP的内核冲突** : QEMU尝试通过系统调用向macOS申请透传内存时，遇到了OCLP的内存也表伪装层。由于默认配置 ``cpuType: host`` 传递的核心拓扑让QEMU误以为拥有某些Haswell的原生直接调用，结果在内核态频繁触发 **指令集一场回滚(VTx VM-Exit异常)
- **CPU陷入疯狂轮询** : 由于地层QEMU线程和OCLP补丁内核冲突，导致内核态死循环(spinlock)，这也就是开始6分钟卡死

Gemini建议在 :ref:`oclp_macos` 的环境中，放弃 ``cpuType: host`` 改为 ``cpuType: qemu64`` ，这样将CPU类型显式降级为标准的、由QEMU自主完全控制的虚拟化指令集，就能够切断它与OCLP内核的冲突。

.. literalinclude:: colima_containerd_debug/default.yaml
   :caption: 设置qemu64作为CPU类型

此外，根据 ``default.yaml`` 的注释可以看到，实际上还有一些细节优化，可以增加到 ``qemu64`` CPU类型来表示支持具体的指令集，以增强性能。根据gemini建议，针对我的Haswell架构i7处理器，实际配置可以采用

.. literalinclude:: colima_containerd_debug/default_i7.yaml
   :caption: 设置qemu64作为CPU类型，针对i7优化

说明
=======

``9p`` vs ``sshfs``
---------------------

.. csv-table:: ``9p`` vs ``sshfs``
   :file: colima_containerd_debug/9p_vs_sshfs.csv
   :width: 20,40,40
   :header-rows: 1

.. warning::

   我的实践发现在 :ref:`oclp_macos` 场景下，修订为 ``9p`` 之后，编译 :ref:`sphinx_doc` 性能没有变化，看起来有可能这种 ``9p`` 挂载驱动需要原生的硬件支持才能发挥性能，我这种软件魔改注入驱动的操作系统无法发挥作用。

Haswell i7 的指令集调优组合
-----------------------------

观察到Colima的 ``default.ymal`` 注释中提到对于 ``qemu64`` 的CPU类型可以增加指令集调优:  ``qemu64`` 默认自带的指令集极其古老，为了能够尽可能发挥硬件性能，针对 :ref:`mbp15_late_2013`  (搭载 Intel 第 4 代 Haswell 架构 i7 处理器)，可以通过精细化手动追加指令集，让它在保持 qemu64 稳定性的同时提供针对特定用途的指令优化:

.. literalinclude:: colima_containerd_debug/default_i7.yaml
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

总结
======

在调整了 ``cpuType`` 之后，我确实发现 ``9p`` 挂载不再导致系统挂起，此时 ``containerd`` 确实能够正常启动运行。不过，很不幸，我调整为 ``9p`` 并没有带来容器性能的提升，感觉编译 Sphinx 文档的耗时还是和 ``sshfs`` 相当。不过，这项折腾也启发了我对Colima的参数微调的想法，后续可能在实际物理硬件上再做进一步尝试。我感觉如果不使用 :ref:`oclp_macos` 直接裸硬件，应该能够充分发挥 ``9p`` 这个IO驱动的性能。

参考
======

- Gemini
