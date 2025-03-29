.. _firefox_addons:

============================
Firefox插件
============================

.. _firefox_translate:

Firefox翻译
==================

从 Firefox 版本118开始内置了 `Firefox 全页面翻译 <https://support.mozilla.org/zh-CN/kb/website-translation>`_ 功能，通过安装本地语言可以实现无需依赖云服务的本地设备翻译:

- 只支持全文翻译
- 对混合语言翻译支持有限
- **目前不支持中文**

所以，对于中国大陆人而言，依然需要安装第三方翻译插件。

我试用了Firefox Addons网站上排名前几的翻译插件，感觉不是很好用。所以推荐使用 `Firefox划词翻译插件 <https://addons.mozilla.org/en-US/firefox/addon/hcfy/>`_ :

- 持续开发更新，作者提供了非常详细的使用文档
- 支持谷歌,DeepL,Yandex,必应词典 **免费翻译**

  - 谷歌翻译没有限制，但是需要参考 `划词翻译: 谷歌翻译不能用的解决方案 <https://hcfy.app/blog/2022/09/28/ggg>`_ 来解决 :ref:`across_the_great_wall`
  - `划词翻译使用的第三方翻译服务 <https://hcfy.app/docs/services/intro/>`_ 需要自行申请密钥(免费翻译有每月额度限制, Pro版需要按月付费)

- 大部分功能免费使用，部分高级功能需要会员
- `划词翻译的网页全文翻译 <https://hcfy.app/docs/guides/page>`_ 方便快捷，但是需要注意全文翻译会消耗大量字符(第三方收费翻译按字符数量收费)

.. _firefox_epub:

Firefox中阅读epub电子书
===========================

.. note::

   firefox内置了pdf阅读功能，所以无需安装任何扩展就可以完美阅读。

EPUBReader
==============

`EPUBReader <https://addons.mozilla.org/firefox/addon/epubreader/>`_ 提供了epub阅读能力，能够本地加载epub电子书。虽然页面排版比较简陋，但是能够无障碍阅读，而且对中文支持良好。

Read Aloud: text to speech voice reader
==========================================

`Read Aloud: text to speech voice reader <https://addons.mozilla.org/firefox/addon/read-aloud/>`_ 提供超过40种语言的阅读功能，育英阅读方便我们学习英语。

EpubPress – read the web offline
=================================

`EpubPress <https://addons.mozilla.org/firefox/addon/epub-read-the-web-offline/>`_ 可以将web保存为本地epub，是 :ref:`save_web_page_as_pdf` 的另一种补充方案:

- 优点是更为通用的格式，方便小屏幕移动设备阅读
- 缺点是无法抓取页面图片，对于以图片传达信息的web页面无能为力

.. note::

   :ref:`read_e-books_after_kindle` ，我的主要解决方案是云端同步电子书(Google Play)， :ref:`read_ebook_in_linux` 则采用轻量级应用程序，Firefox的内置pdf以及epub扩展，可以是一种解决方案

参考
=====

- `Read EPUB e-books right in your browser <https://addons.mozilla.org/blog/read-epub-e-books-right-in-your-browser/>`_
