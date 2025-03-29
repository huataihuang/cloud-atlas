.. _pi_fake_numa:

=====================
树莓派Fake NUMA
=====================

.. note::

   在 :ref:`pi_5` 上启用 :ref:`pi_fake_numa` 能够通过将物理RAM分成快，利用 **交错分配** 策略来激活 ``BCM2721`` 内存控制器更好利用物理内存芯片组的并行性。根据资料，启用 :ref:`fake_numa` 之后 :ref:`pi_5` 的 GeekBench 6测试，基准单核得分提高约 ``6%`` ，多核得分提高约 ``18%`` 。

待实践...

参考
=======

- `NUMA Emulation speeds up Pi 5 (and other improvements) <https://www.jeffgeerling.com/blog/2024/numa-emulation-speeds-pi-5-and-other-improvements>`_
