.. _intro_kaios:

===================
KaiOS简介
===================

Firefox OS
===================

Firefox OS，是由Firefox浏览器开发组织Mozilla创建的开源项目 `Boot to Gecko, B2g <https://github.com/mozilla-b2g/B2G>`_ 发展而来，通过在Linux内核上构建一个Firefox浏览器引擎( ``Gecko`` )来实现手机、平板电脑以及智能电视的操作系统。Firefox OS是一个完整的社区驱动操作系统，采用开发协议如 :ref:`javascript` 以及 HTML5来构建应用，并且提供了一个强健的私密模块和直接与硬件通讯的开放web API。这个先进的理念使得当时推出Firefox OS被视为能够和Apple的iOS、Google的Android一争高下的手机系统。不过，很不幸Firefox OS在2015年12月被Mozilla宣布放弃，最终Firefox的核心B2G OS以及相关衍生系统都退出了市场。后续在Firefox OS之上建立的KaiOS则凭借印度特定市场继续发展，但KaiOS是一个闭源系统。

虽然Firefox OS已经死亡，但是它的的设计架构以及独特的通过JS API来控制硬件实现智能操作系统的理念，依然有着独特的魅力。在Firefox OS发展的那些年，衍生操作系统 `JanOS <http://janos.io/>`_ 将Firefox OS转换成无需屏幕运行(headless)的IoT系统，通过 :ref:`javascript` 控制硬件，实现IoT硬件操控。在JanOS的官方网站，提供了一些 `Cross compiling A simple C++ application <http://janos.io/articles/cross-compile.html>`_ 案例以及如何使用 :ref:`android_ndk` 。

KaiOS
=========

- KaiOS是一个基于Linux的移动操作系统，用于键盘功能手机。由KaiOS Technologies (Hong Kong) Limited开发。一家总部位于香港跨国公司，最大股东是中国跨国电子集团TCL科技
- KaiOS 运行在由低功耗硬件和低功耗（因此电池寿命长）制成的功能手机上。KaiOS支持现代连接技术，如4G LTE-E、VoLTE、GPS 和Wi-Fi
- KaiOS运行基于HTML5的应用程序
- KaiOS支持无线更新，并拥有专门的应用程序商店 (KaiStore)
- KaiOS在硬件资源使用方面相对较轻，并且能够在只有256MB内存的设备上运行

KaiOS历史
----------------

KaiOS是从 Firefox OS的一个开源社区驱动分枝B2G fork出来的开源系统，于2017年首次发布，由总部位于香港的 KaiOS Technologies Inc. 开发。投资者包括Google，印度电信运营商 Reliance Jio，国泰创新 和 TCL控股

2018年 5月公布的市场份额研究结果中，KaiOS 击败苹果的 iOS 在印度排名第二

2020年 3月，Mozilla 和 KaiOS Technologies 宣布建立合作伙伴关系，用现代版 Gecko 浏览器引擎和更紧密结合的测试基础设施更新 KaiOS。 这一变化应该会给 KaiOS 带来四年的性能和安全改进以及新功能，包括 TLS 1.3、WebAssembly、WebGL 2.0、渐进式网络应用程序、WebP、AV1 等新视频编解码器以及现代 JavaScript 和层叠样式表(CSS) 功能。

参考
========

- `Wikipedia Firefox OS <https://en.wikipedia.org/wiki/Firefox_OS>`_
- `Wikipedia KaiOS <https://zh.wikipedia.org/wiki/KaiOS>`_
