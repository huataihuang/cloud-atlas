.. _think_pilfs:

============================================================
PiLFS(Automated Linux from scratch on the Raspberry Pi)思考
============================================================

在构建 :ref:`lfs` 时，我注意到LFS手册仅聚焦于x86系统，并且手册也提到ARM架构需要做调整但不是该项目关注的方向。我找到一个 `PiLFS官网 <https://intestinate.com/pilfs/>`_ 专注于将LFS移植到 :ref:`raspberry_pi` ，

我有不同的树莓派，目前 :ref:`pi_1` 完全闲置，偶然看到 `Building Linux From Scratch on Raspberry Pi 1 <https://cspub.net/2023/03/22/building-lfs-on-raspberry-pi.html>`_ 有人在2023年提到用树莓派1代构建 :ref:`pilfs` 。

:ref:`pi_1` 硬件性能在十多年之后已经非常孱弱，甚至无法运行现代化的64位系统，不过闲着也是闲着，我想或许我可以借助 ``distcc`` 这样的工具在3台设备上同步编译来加快构建？(据前文别人的经验需要花费300+小时来编译系统)


.. note::

   在 :ref:`llm` 爆发的2023-2025年，是否还值得不断在底层技术上投入时间和精力呢？有点犹豫，待后续再看看...

   目前 :ref:`machine_learning` 如火如荼，时不我待...

参考
========

- `PiLFS官网 <https://intestinate.com/pilfs/>`_
