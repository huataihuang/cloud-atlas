.. _fix_macbook_slow:

=======================
修复MacBook缓慢
=======================

.. note::

   本文是我遇到的一个硬件系统缓慢异常的处理实践记录，仅供参考

我最近一年重新开始在 :ref:`mbp15_late_2013` 上重新安装了 macOS Big Sur (Version 11.7.10，该硬件支持的最高版本)，但是发现一个非常奇怪的现象:

在重新安装macOS之前， :ref:`mbp15_late_2013` 部署的是 :ref:`arch_linux` ，运行性能正常。但是切换回macOS之后，发现中文输入法时候经常卡顿，也就是选词弹出会停顿不流畅，其他现象就是操作系统启动和应用启动明显比之前缓慢很多。

最初我怀疑是磁盘SSD存在故障，但是也未免太巧了。但是没有其他异常，也就忍了。

最近我在尝试对比 :ref:`rancher_desktop` 运行的 :ref:`lima` 虚拟机性能，尝试在虚拟机内容器运行 :ref:`sphinx_doc` 的 ``make html`` 并对比物理主机 :ref:`mbp15_late_2013` macOS直接运行 ``make html`` 的编译时间，结果大出意料: 物理主机的编译速度居然比虚拟机编译速度还要慢10倍:

.. literalinclude:: fix_macbook_slow/time_make
   :caption: 在 :ref:`lima` 虚拟机中容器化编译 ``make html`` 耗时

.. literalinclude:: fix_macbook_slow/time_make_macos
   :caption: 在物理主机macOS直接运行编译 ``make html`` 耗时

可以看到虚拟机容器编译耗时16分钟，大多数时间都是在等待磁盘IO；但是物理主机编译则完全消耗在User空间的计算任务，却惊人地消耗了2.5小时，物理主机居然整整慢了10倍？

这是一个古怪的结果...

排查
=======

Google AI提到了:

- 如果硬件散热问题(例如风扇积灰或散热膏失效)，macOS会通过 ``kernel_task`` 进程占满CPU资源来防止CPU进一步法人，从而导致用户任务极其缓慢
- 电源适配器功率不足(非原装或充电头/线材孙欢)，macOS也可能会进入低功耗模式，墙纸锁定CPU频率

对应排查方法:

- 在终端运行 ``pmset -g thermlog`` ，观察到 ``CPU_Speed_Limit`` 数值小于 ``100`` 说明正在发生硬件限速

.. literalinclude:: fix_macbook_slow/pmset
   :caption: 在 ``make html`` 编译任务时检查 ``pmset`` 输出
   :emphasize-lines: 7

但是我没有观察到 ``CPU_Speed_Limit`` 低于 100

- 系统级干扰可能有:

  - SSD剩余空间足部(通常低于15%)时文件系统读写效率会断崖式下跌，且交换文件(swap)效率极低，会影响所有计算密集型任务
  - 如果物理主机在进行Spotlight索引，Photos图库处理或Time Machine备份，则CPU资源会被占用

我的主机都没有上述现象

排查造作:

- 重置控制芯片：尝试重置 SMC (系统管理控制器) 和 NVRAM，这能解决许多与电源管理和硬件性能相关的古怪问题
- 检查电池状态：如果 Mac 电池显示“建议维修”，系统可能会为了保护电压稳定而大幅降低 CPU 频率

我的电池检查完全正常(最近一年刚更换过电池)，而且我是插着电源工作，不会受到电池影响

所以我的排查转向尝试 :ref:`reset_mac`

- :ref:`reset_mac` ，完成后发现并没有改善，编译执行时间:

.. literalinclude:: fix_macbook_slow/make_html_macos_1
   :caption: reset NVRAM没有改善

- 我忽然想起MacBook Pro有两个显卡，CPU集成的Intel GPU以及外置的NVIDIA GeForce 750M。我之前遇到过内置Intel显卡发生过显示抖动问题，所以曾将关闭了 ``Automatic graphics switching`` 功能而优先使用外之地NVIDIA GeForce 750M。最近一次重装系统又恢复为默认的自动显卡切换。会不会是这个自动显卡切换触发了异常的主频限制功能？

很不幸，我管理自动显卡切换，强制启用NVIDIA GeForce 750M，发现性能没有改善。

进一步排查
===========

我回忆之前安装过的Linux系统，感觉当时使用Linux系统的性能是正常的，似乎是重装macOS之后才发现性能缓慢的。

我推测是不是Linux没有自动显卡支持，或者有什么电源节能管理功能绕过了这个MacBook Pro存在异常的节点组件？我甚至推测由于设备非常陈旧，是否有某个电源管理模块监控功能混乱导致macOS无法正常管理CPU频率。而我安装了Linux系统，恰恰因为不完全支持MacBook Pro的节点管理功能，误打误撞绕过了这个问题。

暂时解决
==========

由于是非常古老的MacBook硬件，我并没有一直使用这台笔记本电脑，偶然在使用时发现这台笔记本再次无法启动，并且每次加电都会进入修复模式，强制要求我重装系统。我开始担心是硬件故障了

MacBook 启动时自动进入 Recovery（恢复）模式并提示重装系统，通常意味着电脑在启动过程中遇到了无法自行修复的问题，导致无法引导进入正常的 macOS 系统:

- 文件系统错误： 磁盘的目录结构或分区表出现故障
- 磁盘空间极度不足： 如果硬盘几乎全满，系统可能无法创建必要的缓存文件来完成启动
- 硬件故障： 对于较旧的机型（如带机械硬盘的 MacBook），可能是硬盘老化；对于新款（板载 SSD），则可能是闪存芯片故障

我在Recovery过程中使用了 ``First Aid`` 工具检查macOS卷，显示正常，但是检查 ``macOS-Data`` 卷是出现报错 ``rror: (oid 0x15891b) om: btn: found zeroed-out block Ojbect map is invalid. The volume /dev/rdisk3s1 cound not be verified completely. File system check exit code is 8.`` :

错误代码 ``exit code is 8`` (表示fsck_apfs发现错误但无法在线修复)配合 ``found zeroed-out block`` (发现全零块，意味着磁盘在该位置数据已经全部丢失或无法读取)和 ``Object map is invalid`` （对象映射无效），是一个比较典型的 APFS 文件系统底层元数据损坏，通常是频繁断电、强制关机、或SSD固件瞬时故障导致卷的元数据出错。

- 尝试修复:

.. literalinclude:: fix_macbook_slow/fix_disk
   :caption: 尝试通过修复磁盘文件系统来避免重装系统

但是很不幸，修复不成功

但是幸运的时，按照提示重新安装了一遍Big Sur系统(格式化抹掉了磁盘数据)之后，整个macOS意外复活了: 已经不再像之前重装系统之后非常卡顿甚至编译也非常缓慢。

这让我非常惊喜也非常疑惑，和gemini讨论之后，推测主要原因:

- Late 2013 MacBook Pro (Haswell 架构)运行 macOS 11 Big Sur 出现卡顿，往往不是 NVMe 硬盘的硬件缺陷，而是 macOS 11 对非原生驱动支持的优化问题，以及 Big Sur 之后系统对索引（Spotlight）和图形加速（Metal）的需求大幅提升所致

  - 显卡 (核心限制)：Late 2013 使用的是 Intel Iris Pro (GT2) 或 NVIDIA GT 750M。这些显卡不支持 Metal 2/3

    - ``系统设置 -> 辅助功能 -> 显示 -> 降低透明度`` (Reduce transparency)对于非原生Metal显卡的老Mac提升明显

  - 我使用了第三方NVMe( :ref:`samsung_pm9a1` )，其早期固件版本在macOS下存在Trim延迟(尤其是 7301Q 或更早版在非原生系统下会导致严重的性能衰减)

    - 当 :ref:`oclp_macos` 前建议 :ref:`update_samsung_pm9a1_firmware_on_winpe`
    - 在 OCLP 编译设置中，确保开启了 ``SetApfsTrimTimeout`` 为 ``999`` 或 ``-1`` 。这能极大缓解启动缓慢和写入时的系统假死(也就是Trim超时立即返回避免陷入长时间假死)

下一步
========

在和gemini讨论 :ref:`obsidian` 无法在Big Sur安装时，gemini建议我 :ref:`oclp_macos` **15** ``Sequoia`` 来实现
