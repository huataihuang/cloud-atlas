.. _lineageos_apps:

=====================
LineageOS 应用
=====================

我尝试在精简的LineageOS环境使用 :ref:`pixel_4` 

LineageOS自带应用
==================

LineageOS的初始安装非常精简，只有少量必须的应用

- Music非常简洁，但是使用有点特殊:

  - 同步音乐是存放到 ``Download`` 目录(以及子目录) ( ``adb push * /sdcard/Music`` 到 Music 目录下不能自动识别 ): ( `LOS Default Music Player doesn't find my mp3 audio <https://www.reddit.com/r/LineageOS/comments/urjvsj/comment/i8yk5nm/>`_ )
  - 文件同步后，需要重启一次 Music 就能够识别

- Camera只有基本功能，虽然够用但是无法充分发挥pixel的 ``计算摄影`` 优势，所以替换为使用 Google Camera

安装Google apps
================

我最初想避免安装Google apps:

- 我担心Google全家桶实际上我并不需要这么多软件(之前使用Google Android 13官方镜像，默认安装了太多的狗家程序)
- 只想用最少的资源来运行一个简洁的ASOP系统

不过，经过短暂的尝试，我放弃上述想法，还是在 :ref:`lineageos_20_pixel_4` 后，再次 ``sideload`` 刷入 ``MindTheGapps`` :

- LineageOS只有非常简单的相机功能，实际上无法发挥出Pixel的摄影性能: 毕竟Google只针对Pixel系列优化了自己的摄影算法，其他手机都无法享用
- 难以找到合适的方式安装 :ref:`kindle` for Android，毕竟我主要的手机功能就是看书
- 需要使用Google的一些服务: Photos, keep, fit, youtube ... 缺乏基础服务的Android系统虽然轻量级，但是使用确实不便

LineageOS 使用的 ``MindTheGapps`` 默认只安装 Google Play Store 和 Google ，所以还算比较精简。

.. note::

   有些应用WEB实际上非常流畅，所以可以不用单独安装程序，直接使用WEB即可:

   - YouTube
   - Twitter

非Google Play Store的应用
==========================

- `微信官网应用下载 <https://weixin.qq.com>`_ 国民应用，如果不想失去社交的话还是得安装。微信现在也臃肿了，所以要在设置中把所有不需要的功能开关都关闭掉
- `支付宝官网应用下载 <https://alipay.com/>`_ 一定要开启极速模式，并且关闭所有页面功能
- `KOReader <https://f-droid.org/en/packages/org.koreader.launcher.fdroid/>`_ 非常轻量级的电子书阅读器，比 :ref:`kindle` 快捷(自己维护电子书同步)
- `脉脉 <https://maimai.cn/>`_
- `高德地图 <https://mobile.amap.com/>`_
- `全家超市: Fa米家 <https://sj.qq.com/appdetail/com.x2era.xcloud.app>`_ 在Google Play上提供的全家App似乎是台湾地区的，国内使用的是Fa米家，所以从腾讯应用宝网站下载


应用安装(尝试后放弃这种精简方式)
=================================

- :strike:`暂时不安装 Google Apps ，只在自己需要的应用官方网站下载各自软件包(我使用的软件极少)`

  - `微信官网应用下载 <https://weixin.qq.com>`_
  - `支付宝官网应用下载 <https://alipay.com/>`_
  - 高德地图
  - :strike:`大众点评` 使用微信小程序

- :strike:`Amazone AppStore` : 我最初想采用Amazone AppStore获得(Amazone的应用商店安装包只有16MB，依赖较少)软件，但是实践发现并不适合LineageOS

  - kindle: 无法识别LineageOS，所以会以不兼容理由拒绝安装

- `F-Droid <https://f-droid.org/>`_ 开源应用商店，不过我没有安装(网站提供了开放的直接下载应用，我只选择需要的应用安装)

  - 放弃 `OpenConnect <https://f-droid.org/packages/app.openconnect/>`_ (版本太陈旧无法工作)
  - :ref:`termux`
  - `KOReader <https://f-droid.org/en/packages/org.koreader.launcher.fdroid/>`_ 如果无法安装使用Kindle，则使用这个开源替代软件
