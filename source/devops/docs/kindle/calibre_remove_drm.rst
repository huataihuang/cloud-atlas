.. _calibre_remove_drm:

==============================
使用Calibre移除Kindle文档DRM
==============================

如果你和我一样，同时在美亚和中亚注册账号并分别购买正版的电子书籍，就会有一个困扰：我购买了正版的电子书，却无法打通账号，在同一个Kindle设备上阅读。

作为景德镇居民，即使你非常尊重版权，愿意购买正版的书籍和音像、软件，依然由于ZF的限制，无法自由获取信息。很多人可能需要在美区拥有一个账号，并通过曲径来获取知识和资讯。

.. warning::

   ``请支持正版！本文方法只建议用于自己购买的正版书籍并只用于自己阅读！``

打通Kindle账号的方法
=======================

Google了相关信息，共享书籍的方法概括如下：

- Amazon的美国账号和中国账号是两套完全隔离的账号系统，无法打通 - 从美国亚马逊的家庭共享方式来看，应该是能够在美亚账号体系内通打通2个成人+4个小孩账号，彼此间购买书籍是共享的。不过，这个方法无法适用于跨区的中亚账号。
- 在iOS/Android Kindle中，如果切换账号，本地设备的前一个账号的书籍会被全部抹掉；但是在Kindle WhitePaper设备上，切换账号会保留上一个账号的书籍，所以如果可以切换账号（虽然切换起来还是很麻烦），还是能够变相满足多个账号书籍共享。
- 通过Calibre这样的电子书工具，可以将PC/Mac上的Kindle书籍转换成epub或mobi格式，这样通过kindle email账号可以传输给指定的kindle用户阅读。这个方法不需要切换kindle设备账号，应该也是最方便的方法。

.. note::

   Kindle的所有正版电子书都是有DRM保护的，所以即使你购买了书籍，也无法直接把电子书转给自己的另外一个账号设备阅读。

   Calibre默认不能移除DRM，所以要通过第三方的DeDRM插件来去除 ``azw`` 文件的DRM

dedrm-ebook-tools
====================

`dedrm-ebook-tools(DRM Removal Tools for eBooks) <https://github.com/psyrendust/dedrm-ebook-tools>`_ 最早是为了保存 `Apprentice Alf's Blog <http://www.apprenticealf.wordpress.com/>`_ （景德镇居民无法访问的WordPress网站）提供的工具，但是目前因为apprenticeharper从2015年开始也建立了GitHub仓库，所以已经不再更新维护。

- （已失效)可以直接从 `apprenticeharper/DeDRM_tools <https://github.com/apprenticeharper/DeDRM_tools>`_ 获取最新的插件工具。 请参考 `DeDRM_tools/FAQs.md <https://github.com/apprenticeharper/DeDRM_tools/blob/master/FAQs.md>`_ 进行安装，其中面向最终用户的软件包发布可以从 `DeDRM_tools releases page <https://github.com/apprenticeharper/DeDRM_tools/releases>`_ 下载到。
- 2023年7月时，我使用 Calibre 6.23 ，发现上述 `apprenticeharper/DeDRM_tools <https://github.com/apprenticeharper/DeDRM_tools>`_ 已经不能工作(Calibre crash)，参考 `DeDRM not working #2250 <https://github.com/apprenticeharper/DeDRM_tools/issues/2250>`_ 改为使用 `noDRM/DeDRM_tools (GitHub) <https://github.com/noDRM/DeDRM_tools>`_

.. note::

   请尊重版权，开发者提供开源工具是为了正当的知识和文化传播，并不是支持盗版！

`apprenticeharper/DeDRM_tools <https://github.com/apprenticeharper/DeDRM_tools>`_ (归档)
----------------------------------------------------------------------------------------------

- 下载和解压缩::

   curl https://github.com/apprenticeharper/DeDRM_tools/releases/download/v6.6.2/DeDRM_tools_6.6.2.zip -o DeDRM_tools_6.6.2.zip
   unzip DeDRM_tools_6.6.2.zip

解压缩以后，在 ``DeDRM_calibre_plugin`` 目录下有 calibre 的插件，其中 ``DeDRM_plugin.zip`` 就是可以直接安装使用的。

- 安装:

在calibre的 ``Preferences`` 对话框中，点击 ``Plugins`` 按钮。然后，点击 ``Load plugin from file`` ，找到刚才下载并解压缩的 ``DeDRM_tools`` 目录，在其子目录 ``DeDRM_calibre_plugin`` 找到一个 ``DeDRM_plugin.zip`` 。

点击这个文件并选择 ``Open`` 。

然后在 ``Are you sure?`` 对话框中点击 ``Yes`` 并确认加载这个插件。（提示有安全性因患，务必使用可靠来源的插件）

`noDRM/DeDRM_tools (GitHub) <https://github.com/noDRM/DeDRM_tools>`_
---------------------------------------------------------------------------

安装方法和 `apprenticeharper/DeDRM_tools <https://github.com/apprenticeharper/DeDRM_tools>`_ ，不再重复

配置Calibre使用DeDRM
------------------------

如果是从Kindle设备或者从亚马逊的web网站下载 - 在亚马逊网站的 ``管理我的内容和设备`` 页面，每个文件都有一个 ``通过电脑下载USB传输`` 。

推荐使用这个方法下载，下载时会提示  ``从下拉列表中选择一个设备`` ，实际上，这个步骤就是亚马逊根据你的注册设备为下载文件加上DRM加密。

- ``在Kindle的设备信息中可以找到序列号`` :

  - kindle paperwrite 1 / 2：

    - 中文版：首页 — 菜单（右上角的三道杠） — 设置 — 菜单（右上角三道杠） — 设备信息
    - 英文版：Home — Menu — Settings — Menu — Device Info

  - kindle 4 / kindle touch：

    - home — menu — setting — 第二页的Device Info里的“Serial Number:”

  - Kindle 1 / 2 / 3 / Keyboard / DX / DXG：

    - home — menu — settings — 屏幕右下角会显示序列号（未证实）


- ``在DeDRM Tools插件中添加Kindle设备序列号``

为了能够通过DeDRM Tools移除DRM，一定要在Preferences对话框的插件页面，再次选择DeDRM Tools插件。

然后点击 ``Customize Plugin`` 按钮，此时会弹出一个 ``Customize DeDRM`` 对话框。需要按照你设备选择对应按钮，这样就可以添加设备的序列号。这个序列号非常重要，没有则无法移除DRM。

使用Calibre+DeDRM
---------------------

- 把Kindle for PC下载的那些azw文件添加到Calibre即可（直接拖进去吧），DeDRM插件会自动去除azw文件的DRM保护并转换成原始格式: 导入后是去除DRM的 ``.azw3`` 格式文件，这个文件可以直接放到Kindle中阅读。例如，可以将文件存放到美区Kindle账号的Personal Documents中

.. note::

   Calibre支持 `send to kindle <https://www.amazon.com/gp/sendtokindle>`_ （即 `Kindle Personal Documents Service <https://www.amazon.com/gp/help/customer/display.html?nodeId=200767340>`_ ，非常方便把各种文档通过电子邮件方式发送给Kindle设备阅读），这样可以将中国区购买的Kindle书籍转换成去除DRM的 ``.azw3`` 文档发送到美国区Kindle设备，方便自己的学习。

.. note::

   Calibre删除电子书之后会放到自己的回收箱里面(不是系统的回收箱)，目录位于 ``Calibre Library`` 下的隐藏目录 ``.caltrash`` 。

参考
======

- `用Calibre导入Kindle电子书并去除DRM保护 <https://www.librehat.com/importing-kindle-books-with-calibre-and-remove-drm-protection/>`_ - 本文参考，作为支持正版，该文章建议只将移除DRM保护方法用于合法自购的电子书
- `Calibre DRM Removal Plugin, Calibre Remove DRM from EPUB Kindle <http://www.epubsoft.com/calibre-drm-removal-calibre-remove-drm.html>`_ - epubsoft提供了一个移除DRM的Calibre插件，不过我 **没有试用过**
- `DeDRM 完美破解去除 AZW 格式电子书 DRM 保护 – Kindle伴侣 <http://bbs.feng.com/read-htm-tid-11303089.html>`_
