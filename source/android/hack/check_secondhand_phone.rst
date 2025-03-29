.. _check_secondhand_phone:

=====================
二手手机验机
=====================

我曾经购买过两次 :ref:`iphone_se1` ，都是二手翻新，所以对二手手机验机比较关注，加上这次又冒险入手了 :ref:`pixel_4` 二手，记录一下。

二手Pixel使用成本
===================

Google Pixel系列新机的性价比不高(除非你在美国有良好的网络服务和售后)，在墙内基本只能通过淘宝二手。虽然不追新款可以省下很多钱，但是实际上我感觉性价比可能还不如iPhone:

- 我购买的二手Pixel手机通常会选择1k左右的机型，但是购买时通常已经该型号Pixel的产品支持周期的末尾，也就是最多只有不到1年时间的官方版本更新
- Google的手机品控和iPhone有较大差距

  - 我感觉重度使用可能只能支持2年，甚至1年可能就会有小毛小病( 我的 Nexus 6P 就是大冤肿 )，由于没有售后往往就只能废弃了
  - 可以说买二手Pixel就是堵运气: 希望我这次冒险 :ref:`pixel_4` 能坚持两年以上

- 平均下来使用Google手机的每日成本大约是2~3元

  - 选购iPhone同时期可以通过信用卡消费(2年无息还款): :ref:`iphone12_mini` 购于2020年底，至今已经使用了两年半，以当时售价和使用至今折算，每日成本大约 7.5 元，所所以要达到和Pixel持平的使用成本大约需要持续使用5年

二手验机步骤一
================

智能手机有一个 IMEI  码是唯一(理论上)标识你购买到的手机的的串码，也是首先需要仔细对比的地方: 

Pixel系列机型的「三码合一」指: 外包装盒、SIM卡托以及Android系统三个地方查询

Android系统内查询IMEI: 

- 「系统设置 > 关于手机 > IMEI」
- 拨号应用输入 ``*#06#`` 并拨号呼出

在Google Store上通过IMEI或者序列号可以查询手机的购买和保修信息(注意需要选择对应区域)，如果查询到的信息和你手机不一致，则可能就是手机存在拆机拼装的情况

在 IMEI Info 针对 Google Pixel 机型提供的查询服务还提供了设备的激活日期、激活时长等信息，方便你进一步确认手机的「真实年龄」

二手验机步骤二
=================

对于购买的是出厂包含 IP68 级防尘防水的旗舰 Pixel 机型，气密性指标可以验证手机是否存在拆修: 拆修一般会破坏掉设备默认的气密性，并且由于成本原因，普通的二手贩子一般也不会对气密性进行修复（并不绝对）

因为现代 Android 设备往往都内置了气压传感器，我们也可以通过机身内部气压传感器读取到的数值变化来判断机身气密性的完好程度:

- 下载安装 ``Dev Check`` ，并使用 ``气压传感器数据监测`` 功能
- 稍微用来按压屏幕

如果气密性完好，气压传感器读数会随着按压出现波动，波动幅度越大，则机身内部的封闭性就越好。

如果不使用第三方程序，也可以使用系统内置测试功能，例如拨号程序输入 ``*#0*#`` ，进入设备调试界面，选择 ``Sensor`` (传感器)，然后查看 ``Barometer Sensor`` 当前 ``hPa`` 数值，然后按压屏幕观察数值变化。

二手验机步骤三
===================

使用 :ref:`adb` 工具检查::

   adb shell
   cat /sys/class/power_supply/battery/uevent

输出信息中 ``POWER_SUPPLY_CYCLE_COUNT`` 标识电池循环次数，该值越小表示电池充电次数越少(也就是电池越新)

参考
======

- `大船靠岸，激动暂缓：以 Pixel 为例谈二手/水货 Android 手机验机 <https://sspai.com/prime/story/inspecting-imported-used-pixel>`_
- `Water Resistance Tester – 手机气密性检测，根据气压计测试手机防水性[Android] <https://www.appinn.com/water-resistance-tester-for-android/>`_
- `教你无需下水一招检测手机的防水性能是否失效 <https://www.toutiao.com/article/6464384149821063693/?source=seo_tt_juhe>`_
- `can not check imei pixel 4a <https://www.reddit.com/r/GooglePixel/comments/vbq61k/can_not_check_imei_pixel_4a/>`_
- `Find your IMEI and other Pixel phone ID numbers <https://support.google.com/pixelphone/answer/10402530?hl=en>`_ Google官方帮助
