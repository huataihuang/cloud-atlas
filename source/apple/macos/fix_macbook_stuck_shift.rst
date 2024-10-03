.. _fix_macbook_stuck_shift:

============================
修复MacBook卡住的shift键
============================

.. note::

   这是一个奇特的经历，困扰了我半天时间: 我最初以为是旧笔记本的主板(firmware)之类的故障，然而反复google之后，线索似乎是键盘问题，多次尝试后的修复，既简单又意想不到。

我在尝试 :ref:`mba11_late_2010` 修复 :ref:`archlinux_on_mba` ，遇到了和之前尝试安装Windows 10一样的问题: 键盘无法正确使用。简单来说:

- 电脑似乎一直按着 ``shift`` 键，导致无法输入数字(总是输入数字键上方的特殊字符)；通过 ``caps lock`` 键确实可以暂时输入小写字母(很巧，当shfit键卡住时，使用 ``caps lock`` 键锁住大小写恰好会持续输入小写字母)，但是依然无法输入数字
- 外接USB键盘也不能解决这个问题: 就好像系统内部有一个特殊的映射导致内部和外部键盘都同时失效了

当时我还不知道这是 ``shift`` 键问题，因为是内部和外部键盘同样的异常，以为是我的旧 :ref:`mba11_late_2010` 的BIOS/firmware故障(这个故障其实困扰了我一年，我一直以为是主板的firmware损坏导致我无法重装系统)

通过 google 搜索 ``shift key always on`` / ``arch linux macbook shift`` 等关键字，逐步发现 `Why is my MacBook shift key always pressed? <https://www.ifixit.com/Answers/View/4485/Why+is+my+MacBook+shift+key+always+pressed>`_ 是最有可能的解决方案:

**Turn the computer off, take off the shift key, and reboot the Macbook. If the computer boots as it should, make sure to reinstall the key correctly. I guess the scissor mechanism or the metal arm under the key is not well fixed.**

我忽然想到，外接USB键盘依然会受到内部键盘安装 ``shift`` 键影响，这也就是为何只有远程ssh登陆主机才能避免这个问题。

维修经历
===========

参考 `如何维修 MacBook 键盘上卡住的按键 <https://zh.ifixit.com/Guide/%E5%A6%82%E4%BD%95%E7%BB%B4%E4%BF%AE+MacBook+%E9%94%AE%E7%9B%98%E4%B8%8A%E5%8D%A1%E4%BD%8F%E7%9A%84%E6%8C%89%E9%94%AE/37709>`_ ，用塑料片橇下左右两个 ``shift`` 键，重启电脑...

悲剧，怎么还是没有解决 ``shift`` 卡住问题？

正当我沮丧地重新按回两个 ``shift`` 按键，我突然发现随着清脆的 ``咔哒`` 声反复响起几次，按键安装到位之后。原先卡住的 ``shift`` 键突然恢复正常了....

多么奇妙的柳暗花明，开心啊，旧设备终于修好恢复青春了

我突然明白了
===============

原先我反复尝试 ``internet recovery`` 不成功，原来是因为这 ``shift`` 键卡住了，所以导致每次recovery的组合键其实都是错误的(但是你无法感知到)

参考
======

- `Why is my MacBook shift key always pressed? <https://www.ifixit.com/Answers/View/4485/Why+is+my+MacBook+shift+key+always+pressed>`_
- `如何维修 MacBook 键盘上卡住的按键 <https://zh.ifixit.com/Guide/%E5%A6%82%E4%BD%95%E7%BB%B4%E4%BF%AE+MacBook+%E9%94%AE%E7%9B%98%E4%B8%8A%E5%8D%A1%E4%BD%8F%E7%9A%84%E6%8C%89%E9%94%AE/37709>`_
