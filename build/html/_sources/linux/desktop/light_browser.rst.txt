.. _linux_light_browser:

=====================
Linux轻量级浏览器
=====================

对于Linux用户，性能是非常关注的重点。在我使用的Linux桌面，选择轻量级的 :ref:`xfce` 桌面，并且主要的工作都是通过浏览器完成，所以特别关注和希望选择既满足功能又能够节约运行资源的浏览器。

当前浏览器市场主要被google的chrome占领，很多公司网站应用甚至只针对chrome优化和测试，使用其他浏览器存在很多障碍。这和多年以前微软的IE统治无甚差别，也是垄断带来的恶果。不过，对于我这样的技术工作者，依然寻求轻量级的浏览器来完成大多数工作，尽量避免依赖chrome这样庞大臃肿的巨无霸。

根据 `wikipedia: Comparison of lightweight web browsers <https://en.wikipedia.org/wiki/Comparison_of_lightweight_web_browsers>`_ 可以了解目前依然活跃开发的主要有:

.. csv-table:: 活跃开发的轻量级浏览器
   :file: light_browser/light_browser.csv
   :widths: 20, 20, 20, 20, 20
   :header-rows: 1

可以看到，除了重量级的 Chromium(chrome) 和 Firefox 浏览器之外，轻量级浏览器主要分为:

- WebKit引擎: 分支分别基于 QT 或 GTK
- Gecko: 上一代Firefox引擎
- 其他小众独立引擎(兼容性问题较多)

我的选择
-----------

我在 :ref:`edge_cloud` 中构建基于 :ref:`raspberry_pi` 的集群环境，力求采用占用资源少且能够兼容最新的WEB标准。这就要求浏览器时钟活跃开发持续升级，同时避免使用 Chrome/Firefox 的浏览器引擎。

我有安装重量级的桌面，而尝试 :ref:`i3` 窗口管理器。不过，通过资料对比，我意外发现，原来 :ref:`suckless` 是轻量级窗口管理器的底层基石，其组件 :ref:`surf` 使用了现代化的浏览器引擎( ``WebKit2/GTK+`` )，同时又完美契合了 :ref:`dwm` 极简主义(minimalist)动态窗口管理器(dynamic window manager)。这更加吸引我探索 ``suckless`` 系列...

经过短暂体验，我选择 :ref:`surf` 作为轻量级浏览器:

- 配合 :ref:`dwm` 或 :ref:`i3` 
- 现代化的 WebKit 引擎，且使用轻量级的 GTK+

轻量级浏览器对比(归档)
==========================

- Midori

轻量级的WebKit浏览器，最初采用C和GTK2编写，现在已经采用Vala和GTK3重写了。Midori支持HTML5以及一些浏览器基本功能，如bookmark管理。

Midori一度停止开发，所以当前Ubuntu并没有直接提供apt安装，但是可以通过snap安装或者源代码编译安装。

我个人使用经验来看Midori带来的使用体验不佳，页面加载速度不如chrome，并且感觉比较消耗内存。功能使用上也比较简陋，所以我最终放弃。

- Falkon

Falkon是基于QtWebEngine的浏览器，可以在Ubuntu中直接通过apt进行安装。

- Qutebrowser

Qutebrowser是一个键盘(使用vim风格)浏览器，具有简洁的界面，采用Python和PyQt5开发。

- Otter

Otter浏览器同样也是基于Qt框架实现，依赖和前述的Falkon和Qute类似。

.. note::

   由于我使用xfce，非常倾向使用GTK程序，所以很多轻量级浏览器所依赖的Qt库就需要安装大量的软件包，运行也需要加载Qt库，其实和我所期望的轻量级运行有差距。

- :ref:`netsurf`

Netsurf使用C编写，并且它独立实现了底层引擎而不是套用chrome/firefox/QtWebEngin/WebKit这样的引擎。我比较喜欢这种干净功能简洁的程序。

不过Netsurf非常小众，在Arch Linux上可以简单通过 ``pacman -S netsurf`` 安装，但是对于其他发行版则需要自己手工编译安装。

参考
==========

- `Top 5 Lightweight Web Browsers for Linux <https://linuxhint.com/top_lightweight_web_browsers_linux/>`_
- `wikipedia: Comparison of lightweight web browsers <https://en.wikipedia.org/wiki/Comparison_of_lightweight_web_browsers>`_
