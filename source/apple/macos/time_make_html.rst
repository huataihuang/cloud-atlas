.. _time_make_html:

=============================
macOS环境下time make html
=============================

一个有趣的对比，我在完成了 :ref:`colima_nfs` 实践之后，通过NFS共享方式获得了较高的I/O性能。现在我又开始构建 :ref:`macos_studio` ，在完成后，想要对比一下和之前在 :ref:`colima` 的容器环境中性能有多大差异。

同样执行 ``time make html`` ，在macOS环境下，默认Shell（Zsh) 的 ``time`` 输出格式和Linux上常用的 GNU ``time`` 不同:

.. literalinclude:: time_make_html/zsh_time
   :caption: zsh下time输出

- ``274.99s user`` 用户态 CPU 时间

  - 定义: make html 进程（以及它派生出的 Python、Sphinx 等子进程）在 用户空间（User Space） 执行纯业务逻辑、算法、文本处理时，所消耗的 CPU 核心时间总和。
  - 物理含义: 跨核心累加，也就是如果多个CPU核心并行编译，所有核心的用户态时间会累加起来，这样有可能得到的数值比 ``total`` 多很多

- ``15.45s system`` 内核态 CPU 时间

  - 定义：进程在 内核空间（Kernel Space） 执行系统调用（System Calls）时消耗的 CPU 时间总和。
  - 物理含义：在 make html 阶段，这个时间主要花在磁盘物理 I/O（频繁打开、读取大量源文件、写入生成的 HTML 文件）、内存分配（VMA 申请）、以及进程派生（Fork）上。
  - 健康度判定：15.45 秒相对于 274.99 秒来说非常低（约占 5% 左右），说明系统绝大部分时间都在进行高效的计算，没有被严重的磁盘锁或 I/O 阻塞拖死。

- ``5:00.04 total`` 实际墙上时间 - Wall Clock Time

  - 定义：从你敲下回车键，到命令执行完毕退出，物理世界中实际流逝的时间：5 分零 4 毫秒。
  - 核心注意点：它等同于 Linux 里的 real 时间。这是你肉眼直观感受到的等待时间。

- ``96% cpu`` CPU 平均吞吐率 / 利用率

  - 定义：这是 Zsh 自动帮你计算出来的多核整体综合利用率。
  - 数学公式: ``CPU利用率=(user+system)/total=(274.99+15.45)/300.04=96.8%``

注意，上述性能数据显示了:

- CPU 利用率显示为 96% 表明任务运行时， **几乎完美地用足了分配给它的CPU算力** 没有出现因为等网络、等磁盘而导致 CPU 闲置（IDLE）
- 但是:

  - ``user+system`` 的总时间几乎和 ``total`` 完全一致，这表明上述执行命令是 **纯单核单线程运行** ，Mac系统的多CPU核心没有充分利用

- 尝试并发make:

.. literalinclude:: time_make_html/make_j
   :caption: 尝试make -j

但似乎并没有提高编译性能(甚至速度更慢?不合理)

.. literalinclude:: time_make_html/make_j_output
   :caption: 尝试make -j

gemini解释说 ``make -j $(sysctl -n hw.ncpu)`` 要求 **Makefile 文件中必须存在多个可以同时并行的独立 target（目标文件）**

但对于Sphinx只有一个Makefile

- 改进编译命令：

.. literalinclude:: time_make_html/sphinx-build
   :caption: 直接使用 ``sphinx-build`` 来传递多核参数 ``-j auto``

或者修改 ``Makefile`` 设置添加 ``-j auto`` 参数:

.. literalinclude:: time_make_html/Makefile
   :caption: 修订 Makefile 添加 ``-j auto`` 参数
   :emphasize-lines: 5

目前看这个方法确实似乎有效(在Activity Monitor中看到的CPU使用部分阶段Python进程只使用了2个cpu，耗时确实缩短，但也要考虑缓存机制影响以及当时主机上是否有其他任务)

.. literalinclude:: time_make_html/Makefile_output
   :caption: 使用 ``-j auto`` 编译参数使得编译时间缩短


参考
========

- gemini
