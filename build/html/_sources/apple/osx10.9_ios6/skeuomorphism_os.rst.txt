.. _skeuomorphism_os:

===================
拟物化操作系统
===================

.. note::

   `知乎拟物化(Skeuomoriphism)话题 <https://www.zhihu.com/topic/19657384/hot>`_ ：拟物，或称拟物化，或叫现实主义（realism）。是一种 GUI 设计外观风格，常见在软件界面上模拟现实物品的纹理。其目标是使用户界面让用户更加熟悉亲和。降低使用的学习成本。

大约10年前的2010年前后，苹果生态系统采用了一种非常古典的拟物风格，每个精美的图标和操作界面都模拟现实生活中经典的物品，让人不经意间凭着直觉就可以进行交互。这个时代随着iPhone 5的谢幕，已经长久地消失在我们的世界中。然而，人总是容易怀旧，审美总是会轮回。经过这么多年扁平化的现代简洁交互界面的浸染，拿起当年经典的移动设备，依然莫名喜欢。

.. figure:: ../../_static/apple/osx10.9_ios6/ios6_style.jpg
   :scale: 75

.. figure:: ../../_static/apple/osx10.9_ios6/ios6_recorder.jpg
   :scale: 75

.. note::

   技术进步确实是带来人类的福祉，然而，物品没有得到充分的使用就被抛弃，造成大量的电子垃圾，破坏生态环境，也催生了人自身的欲望膨胀。其实，我们使用电子设备的初心是阅读、影视、资讯，重要的是富含意义的信息，而不是让我们虚耗时光的垃圾。

   可惜的是，免费外表下的互联网经济实际上是通过不断刺激你的多巴胺来无形中获取广告利润，所谓的人工智能大数据分析会不断限制你的思想边界，最终形成一个你自以为开放实际上只是不断重复的世界。

现在该如何体验iOS 6
====================

根据 `百度百科:ios 6 <https://baike.baidu.com/item/ios%206/3898909>`_ 支持iOS 6硬件有：

- iPhone 3Gs、iPhone 4、iPhone 4s、iPhone5是支持iOS 6的手机(从iPhone 5s/5c开始上市即采用iOS 7)
- iPad 2、全新iPad（第三代）、iPad（第四代）
- iPod touch 4、iPod touch 5

但是由于苹果公司对iOS系统有极强的控制，没有备份本机SHSH的情况下，一旦官方关闭认证通道，就无法降级到非官方支持的版本。所以，目前性价比较高的二手设备是：

- iPhone 3Gs(外观差一些的约100元): 虽然没有Retina屏幕，但是可打电话可上3G(联通 )
- iPod touch 4(外观较新约120元)：精致小巧的外观加上Retina屏幕，如果只是听歌和看书，这是最合适的设备(但是你还需要带一个额外的手机)

破解和降级
-----------

破解意味着对设备的完全掌控，对于古老的已经不再被官方支持的设备，破解是唯一可行的恢复使用的方法：

- `Phoenix Jailbreak <https://pangu8.com/tools/phoenix/>`_ 可以破解任何32位设备，也就涵盖了最高iPhone 5硬件，即可以最高可破解iPhone 5 9.3.6系统（从iPhone 5s开始使用64位硬件，不能使用这种破解方法）
- 越狱以后，就可以 `iPhone4S/iPad2降级6.1.3 <https://www.i4.cn/news_detail_16907.html>`_

iOS 6使用Tips
--------------

* iOS 6 (和Mac OS X 10.9.5)不支持目前苹果的两步验证方法，所以如果不关闭iCloud两步验证，无法登录App Store

  * 只有重新注册一个新的 ``美区`` Apple ID才能在注册时选择不启用两步验证的安全设置。注意，中国区无法人为关闭两步验证，所以必须翻墙在美区注册
  * 一旦启用两步验证就不能关闭两步验证(无法回退)，所以专用于旧系统Mac OS X 10.9或iOS 6的账号决不能启用两步验证(此账号安全性较低，只能作为备用账号)
  * 无法在美区绑定中国信用卡，所以需要通过美国Amazon购买Apple Gift Card充值

* 所有iOS软件的App Store版本都已经不再支持iOS 9以下版本，所以无法通过App Store安装任何软件；需要通过91助手或爱思助手安装

  * 可惜都是，几乎已经找不到合适都应用软件
  * iOS 6系统自带Music播放器可以自己同步Mp3进行播放，或者自行转换AAC音乐，所以比较适合纯欣赏音乐用户，你可以把它视为一个有触摸屏都iPod Classic

* 微信早期版本，而且还能够支持微信支付：详细的配置方法参考爱思助手网站上的 `iOS6.1.3系统微信不能用怎么办？ <https://www.i4.cn/news_detail_17137.html>`_

Mac OS X 10.9.5(Mavericks)
===========================

Mac OS X 10.9.5(Mavericks)是最后一代拟物化Mac OS X，具有经典的拟物化风格，可以配合iOS 6设备使用。我在9年前购买的MacBook Air 2011依然完好无损，性能完全满足日常的工作和生活。这款经典的Air笔记本即使在今天看来也不甚落伍，轻巧便携。

降级Mac OS X 10.9.5
----------------------

苹果公司提供了macOS的免费升级，并且每次升级都会带来全新的功能改进和bug修复。苹果的MacBook有一个特殊的recovery分区，能够通过网络自动恢复破坏的操作系统，不过，这个修复只限于最近安装的操作系统版本。也就是说，一旦操作系统升级，就如果iOS升级一样，想要回退到之前的旧版本，则非常困难。

不过，好在Mac设备是生产力设备，苹果公司相对控制较少，只要能够找到早期发行版的安装介质，依然有可能降级Mac操作系统。只是，这个找寻非常花费时间，所以自制安装介质通常需要同样的操作系统，就比较折腾。所以，我总结了一些经验：

* 从 `Mac OS X Mountain Lion 10.8.5 Free Download <http://allmacworld.com/mac-os-x-mountain-lion-10-8-5-free-download/>`_ 下载 Mountain Lion 10.8.5镜像文件.dmg

  * 选择Mountain Lion的原因是只有这个版本才能直接从安装包中直接复制出`InstallESD.dmg`光盘镜像；
  * 而更高的Mavericks则需要动用 ``createinstallmedia`` 镜像工具，可惜这个镜像工具必须在Mavericks操作系统中运行，并且需要从AppStore下载Installer软件包，这两个条件无法满足(当时没有正在运行Mavericks的Mac设备)

* 使用 ``InstallESD.dmg`` 光盘镜像先在VMware Fusion中安装一个Mountain Lion的虚拟机，这样就具备了最初的低版本操作系统。
* 在Mountain Lion的虚拟机中，支持使用 ``Disk Utility`` 来创建安装U盘：

  * 使用从ISORIVER下载 `Mac OS X Mavericks 10.9 ISO and DMG Image Download <https://isoriver.com/mac-os-x-mavericks-10-9-iso-dmg-image/>`_ 的 ``Mavericks_ESD.dmg`` 恢复到U盘中，然后将U盘拿到物理主机MacBook Air 2011上安装。

* 后来还找到了很久以前(2017年)通过Time Machine备份的笔记本完整操作系统，也可以恢复旧版本OS X，甚至可以用来创建VMware虚拟机。

.. note::

   我的折腾记录请参考 `降级macOS <https://github.com/huataihuang/cloud-atlas-draft/tree/master/develop/mac/downgrade_macos.md>`_

Apple ID
----------

虽然iOS 6已经无法使用App Store安装软件，但是Mac笔记本性能相对性能过剩，早期的操作系统依然得到很多应用软件支持。但是Mac OS X 10.9.5和iOS 6一样，不支持Apple ID的双重验证，也就无法登录Apple账号。

参考 `从两步验证切换至双重认证 <https://support.apple.com/zh-cn/HT207198>`_ 中的有关关闭两步验证的方法，先关闭两步验证才能继续安装。但是，实际上苹果没有提供安全降级方法，即一旦开启了双重认证就无法关闭，则需要重新申请一个账号，并且在创建账号时候一定需要注意：

* 使用一台高版本macOS电脑创建新账号，一定要选择美国区创建账号（中国区创建账号默认就启用了双重认证并且无法选择关闭）
* 创建完美区账号以后，一定要登陆一次App Store，此时会提示review账号信息，此时就需要填写美国地址信息，完成后才能在App Store上购买和下载软件。

美区Apple ID申请
-----------------

申请美区Apple ID是唯一可以关闭两步认证以便旧版本Mac OS X可以登录App Store的方式，我参考 `如何申请美区苹果App Store账户？ <https://www.zhihu.com/question/26458172>`_ 中的 "syl小虫" 的答案（提供了详细的自助找到美国地址的方法）:

* 使用VPN翻墙才能够注册美区Apple ID
* 访问 `Google 地图 <https://www.google.com/maps>`_ 通过卫星地图随便找一个房子，就能够看到对应地址，以及邮编
* 从 `美国国际区号 <https://cn.mip.chahaoba.com/美国>`_ 以查到地址对应的区号，至于电话号码，则为 xxx-xxxx 大概编写一个

应用软件购买
-------------

申请到美区账号以后，实际上由于没有绑定信用卡，是不能直接购买收费软件的。不过，苹果支持Gift Card，可以直接在美亚上购买充值，就可以购买需要的软件:

* 美亚上提供 `App Store & iTunes Gift Cards - Email Delivery <https://www.amazon.com/gp/product/B075Y8WBTS/ref=ppx_yo_dt_b_asin_title_o00?ie=UTF8&psc=1>`_ ，只需要苹果的接收账号的电子邮件地址。
* 在美亚上通过信用卡购买Gift Card后，会直接向接受人的电子邮箱发送Gift Card激活邮件，只需要登录邮箱确认就可以使用。

回到初心
==========

在大约折腾了1个月之后，2020年春节年初六(按照惯例，这是最后一个春节假日，虽然由于新型冠状病毒爆发政府又紧急延长了3天假期)，我还是放弃继续使用iOS6系统，主要原因：

* 破解iOS的社区已经衰退了，有些网站很难访问，破解需要花费大量的时间精力
* 我的目标是"断舍离"，屏弃分散自己注意力的社交软件和无聊娱乐，集中精力阅读，目前看，最新的iOS 13具备的screen功能可以满足绝大多数克制
* iOS6的应用软件非常难以寻找到合适的应用，即使基础的阅读软件也很难获得，更无法获得现代iOS平台上的阅读体验

我还是使用我心爱的iPhone SE，它是性价比最高的二手iPhone，不仅能够流畅运行最新的iOS 13，而且小巧便携，充分满足阅读、影视、资讯的需求。并且，随着苹果推出的"屏幕时间"(screen)功能，只要将"内容访问限制>App"限制为"4+"，就可以屏蔽掉几乎所有社交软件，而且不影响日常生活起居(因为还可以使用支付宝)。

这样，基本上只要有心，依然可以在最新的iOS上实现"断舍离"，尽可能管理好自己的时间。

此外，我准备保留一台Mac OS X 10.9.5(MacBook Air 2011)和一台iOS 6.1.5设备(iPod touch 4)，用于学习早期的苹果操作系统技术。
