.. _lineageos_apps:

=====================
LineageOS 应用
=====================

我尝试在精简的LineageOS环境使用 :ref:`pixel_4` :

初始安装
==========

LineageOS的初始安装非常精简，只有少量必须的应用

应用安装
==========

- 暂时不安装 Google Apps ，只在自己需要的应用官方网站下载各自软件包(我使用的软件极少)

  - `微信官网应用下载 <https://weixin.qq.com>`_
  - `支付宝官网应用下载 <https://alipay.com/>`_
  - 高德地图
  - :strike:`大众点评` 使用微信小程序

- Amazone AppStore: 由于一些商业软件找到，或许可以从Amazone AppStore获得(Amazone的应用商店安装包只有16MB，依赖较少)

  - kindle

遇到一个问题 Amazone AppStore 会检查Android版本，但是LineageOS不能识别，所以导致无法安装兼容版本。有什么方法模拟成 Android 13?

- `F-Droid <https://f-droid.org/>`_ 开源应用商店，不过我没有安装(网站提供了开放的直接下载应用，我只选择需要的应用安装)

  - 放弃 `OpenConnect <https://f-droid.org/packages/app.openconnect/>`_ (版本太陈旧无法工作)
  - :ref:`termux`
  - `KOReader <https://f-droid.org/en/packages/org.koreader.launcher.fdroid/>`_ 如果无法安装使用Kindle，则使用这个开源替代软件
