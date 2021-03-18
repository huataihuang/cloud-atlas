.. _perf_startup:

==================
perf快速起步
==================

.. note::

   本文仅是一个快速实践记录，我对性能观测理解不深，需要不断学习和实践。会持续改进文档，补充内容。

perf实现原理
============

perf的原理是每隔固定时间，在CPU上(每个cpu核心)产生一个中断，在中断上看当前是哪个pid和哪个函数，然后给对应的pid和函数加上一个统计值。这样我们就能够知道CPU有百分之几的时间在某个pid或者某个寒霜了

.. figure:: ../../_static/kernel/perf/perf_interupt.png
   :scale: 70

perf stat
===========

``perf stat`` 提供了性能统计数据，可以指定进程进行观察::

   perf stat -p 103314

过一段时间按下 ``ctrl-c`` 退出perf，就可以看到统计信息::

    Performance counter stats for process id '103314':

           856,089.63 msec task-clock                #   10.327 CPUs utilized          
            1,121,134      context-switches          # 1309.600 M/sec                  
              171,867      cpu-migrations            #  200.758 M/sec                  
              214,445      page-faults               #  250.494 M/sec                  
    1,563,545,050,590      cycles                    # 1826381.428 GHz                   (83.21%)
      148,330,561,668      stalled-cycles-frontend   #    9.49% frontend cycles idle     (83.37%)
      196,549,357,979      stalled-cycles-backend    #   12.57% backend cycles idle      (83.39%)
    1,595,812,172,679      instructions              #    1.02  insn per cycle         
                                                     #    0.12  stalled cycles per insn  (83.45%)
      375,183,700,209      branches                  # 438253149.157 M/sec               (83.50%)
        3,660,917,377      branch-misses             #    0.98% of all branches          (83.11%)

         82.895081792 seconds time elapsed

perf记录和火焰图
==================

- 对应用进程进行perf记录::

   sudo perf record -F 99 -p 504843 -g -- sleep 60

参数说明:

  ``-F 99`` : 每秒采样99次 - 使用99而不是100，是为了防止采样周期与某些系统周期事件重合，影响采样结果
  ``sleep 60`` : 持续采样60秒
  ``-g`` : 记录调用栈
  ``-p 504843`` : 进程号，表示对哪个进程进行分析

CPU核心数量越多，则采样记录的调用栈就越多

上述命令执行结束以后，会在 ``/tmp`` 目录下生成一个 ``perf.data`` 文件

- 执行分析可以使用 ``perf report`` 命令统计::

   sudo perf report -n --stdio

统计出每个调用栈出现百分比，从高到低排序。不过这个输出不是很容易观察

火焰图
-------

- dump出perf.data内容::

   sudo perf script > out.perf

- 下载火焰图工具::

   git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
  
- 折叠调用栈::

   FlameGraph/stackcollapse-perf.pl out.perf > out.folded

- 生成火焰图::

   FlameGraph/flamegraph.pl out.folded > out.svg

生成火焰图可以指定参数， ``–width`` 可以指定图片宽度， ``–height`` 指定每一个调用栈的高度；还可以针对语言设置火焰图颜色，例如 ``--color=js`` 是针对JavaScript配色svg， ``--color=java`` 则是针对Java配色svg。

上述两个生成火焰图的命令步骤也可以合并成一个命令::

   FlameGraph/stackcollapse-perf.pl < out.perf | FlameGraph/flamegraph.pl out.folded > out.svg

其他的案例命令::

   FlameGraph/stackcollapse-perf.pl --kernel < out.perf | FlameGraph/flamegraph.pl --color=js --hash > out.svg

综合步骤
---------

如果对系统进行观察，可以将上述火焰图数据采集和操作步骤合并成以下命令::

   git clone https://github.com/brendangregg/FlameGraph 
   cd FlameGraph 
   perf record -F 99 -a -g -- sleep 60 
   perf script | ./stackcollapse-perf.pl | ./flamegraph.pl > out.svg

火焰图观察简介
==============

火焰图的Y轴表示调用栈，每一层都是一个函数。调用栈越深，火焰就越高，顶部就是正在执行的函数，下方就是该函数的父函数。

火焰图的X轴表示抽样数量，如果一个函数在X轴占据的宽度越款，就表示它被抽到的次数越多，即执行的时间越长。

**注意：X轴不代表时间，而是所有调用栈合并以后按照字母顺序排列的**

**火焰图就是看顶层哪个函数占据的宽对最大。只要有 ``平顶`` (plateaus) 就表示该函数存在性能问题。**

火焰图的颜色没有特殊含义，只是表示CPU的繁忙程度，一般选择暖色调。

- 鼠标放到一个函数上后, 会展示完整的函数名, 被抽样中的次数, 占总抽样次数的百分比
- 点击某个函数后, 该函数会水平放大到占据整个页面, 展示详细信息
- 点击左上角 ``Reset Zoom`` 恢复缩放
- ``ctrl + f`` 可以搜索关键词或正则, 所有符合的函数名会高亮显示 

火焰图局限性
==============

有两种情况无法画出火焰图，需要修正系统行为：

- 调用栈不完整： 当调用栈过深时，某些系统只返回前面一部分（例如前10曾）。
- 函数名缺失： 有些函数没有名字，编译器只是用内存地址来表示（例如匿名函数）。

参考
======

- `使用perf和火焰图分析系统性能 <https://codertang.com/2018/12/17/perf/>`_
- `如何读懂火焰图 <http://www.ruanyifeng.com/blog/2017/09/flame-graph.html>`_
- `系统级性能分析工具perf的介绍与使用 <https://www.cnblogs.com/arnoldlu/p/6241297.html>`_
- `在Linux下做性能分析3：perf <https://zhuanlan.zhihu.com/p/22194920>`_
- `《性能之巅》学习笔记之火焰图 其之一 <https://zhuanlan.zhihu.com/p/73385693>`_
