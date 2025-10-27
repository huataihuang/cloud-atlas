.. _calibre_ebook_translator:

===============================
Calibre Ebook Translator插件
===============================

**强烈安利** `Ebook-Translator-Calibre-Plugin <https://github.com/bookfere/Ebook-Translator-Calibre-Plugin>`_ ，一款Calibre电子书翻译插件!!!

一直依赖，受困于中国文化审查，大陆出版的书籍往往是阉割版，甚至是扭曲版。对于像我这样英语水平有限，直接阅读原版电子书比较吃力，又不甘心浪费时间看国内翻译版本，就需要有一个能够自由翻译的工具软件。

`Ebook-Translator-Calibre-Plugin <https://github.com/bookfere/Ebook-Translator-Calibre-Plugin>`_ 作为开源Calibre插件，能够借助 Goole Translator 或者 DeepL 等免费引擎，甚至收费的ChatGPT引擎来完成电子书翻译。只要翻译引擎支持的语言都能实现电子书全文翻译。

安装
=====

- 从 `GitHub: bookfere/Ebook-Translator-Calibre-Plugin <https://github.com/bookfere/Ebook-Translator-Calibre-Plugin>`_ 下载最新的RELEASE版本，下载的文件是一个 ``Ebook-Translator-Calibre-Plugin_v2.4.1.zip`` 压缩文件，不需要解压缩

- 启动 Calibre ，然后选择菜单 ``Calibre > Preferences``
- 点击 ``Plugins`` 按钮，然后点击 ``Load plugin from file`` 完成安装
- 设置:

  - 需要设置翻墙代理，否则无法连接Google Translate

使用
=======

- 点击 ``Translate All`` 按钮开始全文翻译，等翻译完成后，再点击 ``Output`` 转存翻译后的 epub 电子书

.. figure:: ../../../_static/devops/docs/kindle/epub-translator_processing.png

使用体验
==========

- 特别适合翻译技术类书籍: 技术类书籍主要是翻译准确即可，无需语言再创作，所以Google Translate提供的翻译非常精准
- 计算机类电子书中代码部分会自动保留不翻译(google translate就能做到)，这对我们阅读代码类书籍非常友好
- 保留了epub电子书原本格式，所以阅读无障碍，以下是我使用 ``Ebook Translator插件`` 翻译的电子书 《Practical Deep Learning》其中一页的截图，可以看到电子书的格式完美，源代码清晰:

.. figure:: ../../../_static/devops/docs/kindle/epub-translator_example.png

