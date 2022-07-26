.. _cpu_c-state:

=======================
CPU c-state
=======================

最早是在 486DX4 处理器引入了低功耗模式，随着CPU一代代改进，引入了更多的功耗模式，并不断增强，使得CPU在低功耗模式下消耗更少的电能。低功耗模式的设计是通过切断CPU内部空闲单元的时钟信号和电源。但是需要考虑CPU需要花费更多的时间 ``唤醒`` 并再次 100% 运行。这些低功耗模式称为 C 状态( ``c-state`` )。 ``c-state`` 级别从 ``C0``
开始，表示正常的CPU工作模式，即CPU 100%运行。随着C数值增加，CPU睡眠模式更深，也就是关闭更多电路和信号，这样CPU将耗费更多时间回到 ``C0`` 模式。

需要注意 :ref:`amd_cpu_c-state_freezing` ，我遇到国产化海光处理器7285( :ref:`amd_zen` )存在和 ``intel_idle.max_cstate`` 配置冲突的bug，必须关闭 ``intel_idle.max_cstate`` 才能稳定工作。

参考
========

- `What are the CPU c-states? How to check and monitor the CPU c-state usage in Linux per CPU and core? <https://www.golinuxhub.com/2018/06/what-cpu-c-states-check-cpu-core-linux/>`_
- `wmealing/C-states.md <https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7>`_
