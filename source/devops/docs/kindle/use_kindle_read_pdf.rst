.. _use_kindle_read_pdf:

=======================
使用Kindle阅读pdf文档
=======================

Kindle是非常简约的电子书阅读器，它的功能单一给使用者一种心理暗示，你需要专注于阅读，专注于能够给予你知识和思想的阅读。虽然我反复折腾过很多电子设备，但是对于Kindle的黑白墨水屏始终有一种难以割舍的眷恋。

在很多年前，当我第一次看到 `Kindle DX <https://baike.baidu.com/item/kindle%20DX/5033313>`_ 能够完整阅读A4纸大小的pdf文档，我确实非常心动。然而，Kindle DX高昂的售价和沉重的使用体验，让人望而却步。

然而，对于计算机技术工作者，有太多的技术书籍和文档都是采用pdf格式发行，没有一个趁手的阅读设备始终是一个遗憾。

到了2016年，终于入手了Kindle Paper White，但是6英寸的屏幕适合阅读 ``.azw3`` 文档(Kindle专用)，却对已经排版好的pdf文档非常不友好。特别是对于很多留有页面空白的pdf文档，在Kindle上阅读的字体实在太小了，阅读体验极差。

不过经过多次折腾，渐渐我也摸索出如何在6英寸屏幕Kindle上阅读pdf的方法，以下是我的一些心得供参考。

pdf中文字体
==============

很多中文pdf文档没有包含字体，这种pdf文档在PC主机上阅读没有问题，但是同步到Kindle上则无法显示中文。

解决的方法是使用操作系统的pdf 打印功能：

- 对于macOS内建的打印功能就支持直接输出保存为pdf：在 ``Preview`` (macOS的pdf阅读器) 中按下 ``command + p`` ，然后点击 ``PDF`` 下拉菜单，选择 ``save as PDF`` ，这样生成的PDF文件就会内嵌中文字体。

- 对于Windows操作系统，可以安装 `Foxit Reader <https://www.foxitsoftware.com/pdf-reader/>`_ 就会得到一个PDF打印驱动。这样也能够通过打印获得内嵌中文字体的pdf文档。

然后将内嵌中文字体的文档同步到kindle中就可以正确阅读。

pdf文档裁边
============

由于Kindle的屏幕只有6英寸，虽然便携，但是通过一屏显示大约A4大小的pdf文档会导致字体非常细小，几乎无法辨识。

开源的 `briss <http://sourceforge.net/projects/briss/>`_ 提供了一种更合适Kindle阅读的pdf文档裁剪方法，也就是把pdf文档的所有白边都切除掉，只保留有内容的部分。这样无形中就使得屏幕较小的移动设备能够较好夜读pdf文档。

我推荐采用briss进行简单的裁边而不是 `K2pdfopt <https://www.willus.com/k2pdfopt/>`_ 对pdf文档进行重排。主要原因还是pdf文档格式太复杂，重排虽然更适合移动设备看清文字，但是会丢失原先的排版，阅读非常不舒适。

使用 briss 裁边pdf也非常简单，从 sourceforge 下载 `briss <http://sourceforge.net/projects/briss/>`_ ，然后使用以下脚本crop掉pdf文档的白边( ``crop example.pdf`` ):

.. literalinclude:: use_kindle_read_pdf/briss_crop
   :language: bash
   :caption: 使用 ``briss`` 裁剪pdf的白边

kindle个人文档同步
====================

Amazon提供了 ``Kindle个人文档`` (kindle personal document)服务，可以将个人的word,pdf,azw3等格式文档通过电子邮件方式发送到自己的个人图书馆中，方便云同步阅读。

- 访问amazon网站的 ``管理您的内容和设备`` （ ``Contents & Devices`` )
- 点击 ``首选项`` 面板 ( ``Preferences`` )
- 点击 ``个人文档设置`` 选项 ( ``Personal Document Settings`` )
- 此时会列出所有 ``〖发送至Kindle〗电子邮箱`` 邮箱地址列表 ( ``Send-to-Kindle E-Mail Settings`` )
- 同时也列出了 ``已认可的发件人电子邮箱列表`` 电子邮箱 ( ``Approved Personal Document E-mail List`` )，即从这些邮箱发出的邮件可以发送给kindle作为个人文档存储
- 通过上述邮箱向Kindle电子邮箱发送邮件，kindle还会发送一份验证邮件到你的注册邮箱，48小时内确认验证，则文档才会真正存储到kindle图书馆/内容库

最终阅读
===========

通过以上3个步骤，你就可以把pdf文档同步到Kindle中，随时随地阅读来增长知识、滋润灵魂。

如果pdf文档依然由于页面较大，在kindle中显示字体过小的话，还有最后的杀手锏 - ``Landscape Mode`` 也就是横屏阅读：

- 在Kindle屏幕上半部分轻点，显示菜单，下拉右上角 ``三`` 横下拉菜单，选择 ``Landscape Mode``
- Kindle横向展示pdf文档会自动调整显示字体，这样就可以清晰阅读pdf文档
- Kindle还很好支持了pdf翻页功能，即使一屏无法展示完整pdf页面，但是翻页依然能够准确定位阅读位置，也即是将一页pdf分成kindle的两页来阅读，使用体验非常舒适

``Kindle在，书未老``

