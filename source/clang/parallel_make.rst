.. _parallel_make:

======================
并行make
======================

我在为 :ref:`build_glusterfs_11_for_suse_12` 做 :ref:`upgrade_gcc_on_suse12.5` ，发现一个麻烦的事情，编译 GCC 实在太耗时了。同事提醒可以修改configure参数，增加多核并行。

我想起来当时编译时确实发现只有一个 ``cc1plus`` 进程运行，完全浪费了多cpu core的高性能服务器资源。当时因为只处理一台编译，也就没有再尝试优化。

没有启用 ``-j XX`` 参数 :ref:`` 耗时:

.. literalinclude:: parallel_make/build_gcc_before_parallel_time
   :caption: 没有启用 ``-j XX`` 参数之前编译gcc 耗时
   :emphasize-lines: 1

由于服务器有128个cpu core( ``Hygon C86 7291 32-core Processor`` :ref:`amd_zen` )，所以执行以下命令配置 ``make`` 并行度 ``96`` (保留了部分cpu core):

.. literalinclude:: parallel_make/make_j

使用 ``-j 96`` :

.. literalinclude:: parallel_make/make_j_output
   :caption: 使用96个并发任务执行make可以大大加速编译gcc速度(30分钟哦)

.. note::

   使用 ``-j`` 参数并发在多处理器服务器上运行编译，可以看到 ``real`` 时间远小于 ``system`` 和 ``user`` 累加的时间。这是因为 ``system`` 和 ``user`` 消耗时间是在多个处理器上累加起来的，多个并发实际完成时间大大缩短 ( ``real`` 时间 )。详见 :ref:`time`

异常排查
===========

我在生产环境启用了并行make，遇到一个困难 :ref:`parallel_make_oom`

参考
======

- `Parallel make: set -j8 as the default option <https://stackoverflow.com/questions/10567890/parallel-make-set-j8-as-the-default-option>`_
