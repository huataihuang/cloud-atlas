.. _cn_samsung_galaxy_watch_4_wich_android:

============================================
原生Android适配使用国行三星Galaxy Watch 4
============================================

所谓 "国行"
=============

我在选购 :ref:`samsung_galaxy_watch_4` 时，最初是想购买三星Galaxy Watch 4美版，因为二手价格相对低廉。不过，一番折腾和偶然发现，最后"阴差阳错"购买了国行版本 :ref:`samsung_galaxy_watch_4_classic_lte` 。折腾就此拉开序幕...

解决方案(综合)
=================

- 从 `APKMirror <https://www.apkmirror.com/>`_ 搜索下载 ``Wear OS by Google(China)`` (关键字 ``wear OS china`` )，也就是Wear OS中国版。这个版本是针对中国市场定制的特供版，也就是只有这个版本才能完成国行三星Galaxy Watch 4的配对

  - 如果已经安装了 Samsung Wearable 软件，则需要先卸载 wearable
  - 我下载的是 ``Wear OS by Google (China) 2.52.0.394110842.le by Google LLC``

- 系统管理关闭 Google Play service 和 Play store (按照网友建议，这步是解决 ``Samsung wareables`` 运行的关键)

- :strike:`先确保卸载了之前安装的 Samsung wareable (但是不要卸载我曾将安装过的watch4plugin，因为这个软件太大下载很长时间，会导致手表配对超时重新开始配对，就前功尽弃了)` 启动 ``Wear OS by Google(China)`` ，这个软件不会检测国行限制(太恶心了)，所以就可以开始和国行手表进行配对

  - 当手机和手表上同时出现开始配对的数字，先点一下手机上的确认配对，过一秒钟，马上点一下手表上的确认按钮(重要，否则会配对超时失败)，此时手机上马上会显示配对成功，就会开始进行读取手表信息的读条
  - 当 ``Wear OS by Google(China)`` 完成配对之后，这个软件就不需要使用了，后面的工作由 ``Samsung wareable`` 来完成

- 配对过程中如果出现手表蓝牙断开，则还需要再次使用 ``Wear OS by Google(China)`` 完成配对，配对以后就可以重新使用 ``Samsung wareable`` 完成后续设置

.. note::

   目前我遇到问题是，所有步骤都正常，但是到 ``Samsung wareable`` 已经完成同步最后设置时突然退出，导致所有都失败。我怀疑是 LineageOS 还存在什么不兼容的地方。或许需要Android原生官方系统来完成这个步骤可能可以成功

   我准备使用google官方原生的Android版本重新刷一下手机再试试

其他方案
=============

另一种思路是把手表系统刷成国际版本:

- `Galaxy Watch 4/5 国行转外版固件资料 <https://www.bilibili.com/read/cv21804247/>`_
- `Galaxy Watch 4/5 固件刷写指南 (2nd Version) <https://www.bilibili.com/read/cv23847143/>`_

  - 介绍 `Bifrost - Samsung Firmware Downloader <https://github.com/zacharee/SamloaderKotlin>`_ 可以下载三星的firmware

不过刷机以后会丢失国行提供的交通卡和门禁卡功能，另外刷机没有保修。此外，我最大担心是刷机以后，国行的LTE功能可能就无法使用了，因为对于Android系统来说，没有运营商的profile，是无法正常使用LTE功能的。

所有，我力求保留国行系统的条件下，实现原生Android的配对和使用。

参考
======

- `非国行的Android不能使用国行的Watch4？不指望三星，自力更生完美解决 <https://blog.xuegaogg.com/posts/1931/>`_
- `给国行 Galaxy Watch 4 应用生态加了一片瓦（YaoYao 跳绳） <https://v2ex.com/t/821295>`_
- `抢先 Pixel Watch，三星 Galaxy Watch 4 手表获得基于 Wear OS 4 的 One UI 5 Watch 更新 <https://www.ithome.com/0/717/060.htm>`_ 新闻而已，不过可以知道Galaxy Watch 4会得到更新
- `Galaxy Watch4：难道只是星粉的自我狂欢？ <https://sspai.com/post/70741>`_
