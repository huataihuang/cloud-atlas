.. _google_play:

================
Google Play服务
================

Fix "Books on Google Play is not available in your country yet"
=================================================================

.. note::

   Google服务按照国家区域进行提供，由于各种政治和经济的交互作用，并不是所有国家都能提供完整的Google服务。在 `Google Play Help: Country availability for Google Play apps & digital content <https://support.google.com/googleplay/answer/2843119#zippy=>`_ 列出了提供服务的国家。

当你默认安装Google Android系统并注册好Google账号(翻墙)，根据GPS定位，Google会默认注册你的账号是 Chinese(CN)。此时即使你翻墙访问Google Play Store，你也找不到一些应用，包括Google Books。

并且当你尝试访问 `Google Play Books <https://play.google.com/books/>`_ 网站，也会看到如下提示::

   Sorry! Books on Google Play is not available in your country yet.

   We're working to bring the content you love to more countries as quickly as possible.

   Please check back again soon.

这个问题并不能通过VPN翻墙解决，而是需要修订你账号的Country配置。

.. warning::

   Google修订Country设置每年只允许一次，所以一旦修改国家注册地，再次修改只有等下一年!!!

修改Google账号国家注册地
---------------------------

- 打开浏览器(电脑或Android手机)，访问 `Google Pay <https://pay.google.com/>`_ 网站
- 点击 ``Settings`` ，此时可以看到 ``Country/Region`` 项显示 ``Chinese(CN)``
- 在 ``Country/Region`` 项点击 ``Edit``
- 选择 ``Create new profile`` ，此时在 ``Create a new payments profile``

.. figure:: ../../_static/android/google/create_google_payments_profile.png
   :scale: 60

- 按照提示导引选择国家，例如选择 Unite State (US)

- 需要填写一个美国地址，可以在 `BestRandoms网站: Random address in United States <https://www.bestrandoms.com/random-address-in-us>`_ 找到一个随机生成的美国地址，填写并提交

- 等待48小时，Google Play会修改你的 ``country/region``

清理Google Play和相应服务缓存
---------------------------------

修改了Google账号国家注册地之后，依然可能不能访问对应国家的应用、电子书或视频等服务。此时可能需要清理Google Play数据，步骤如下:

- 打开 ``Settings``
- 选择 ``Apps`` ，并展开所有应用(只有展开所有应用才能看到 ``...`` 菜单)
- 点击右上角 ``...``  (3个点)菜单，然后选择 ``show system processes``
- 从所有apps列表中选择以下  ``3个`` 服务进行数据清理:

  - ``Google Play Store``
  - ``Google Play Services``
  - ``Google Services Framework``

清理方法是进入服务后，点 ``Storage & cache`` ，然后点 ``Clear cache`` ，然后点 ``Clear storage``  

可能需要更换VPN的IP
=======================

.. warning::

   实际上我采用了上述步骤并没有解决Google Play国家区域问题，依然无法使用 Google Books。我在注册 Spotify 也遇到了这个问题，Spotify反复提示我使用了代理或者VPN，最初我以为是应用检测到我本地开启了VPN程序，就改成 :ref:`vpn_hotspot`
   方式，即手机开启VPN翻墙，然后手机启动热点共享给电脑使用。这样电脑上没有设置任何proxy配置，电脑上也没有启动VPN。但是没有想到，Spotify依然提示我使用代理和VPN不能提供服务。

   所以，我推测是我使用的自建 :ref:`openconnect_vpn` ，底层VPS服务商的IP地址已经被这些Internet服务商列为黑名单，也就是无法作为正常的个人用IP。

参考 `YouTube上的中国注册Spotify指南 <https://www.youtube.com/watch?v=WtT-_ZS-a5A&list=LL&index=1>`_ ，我使用 `WHOER <https://whoer.net/>`_ 检查了自己访问外部显示的IP地址和DNS，都正常显示了美国，但是依然无法通过Spotify的VPN和代理检查步骤。可见我所使用的VPS的IP地址可能已经被服务商列为黑名单，需要想办法换其他VPS的IP地址测试。

参考
========

- `This item isn’t available in your country on Play Store (FIX) <https://mobileinternist.com/this-item-isnt-available-in-your-country>`_
