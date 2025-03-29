.. _qrencode:

===========================
qrencode 二维码(QR)生成CLI
===========================

我在撰写 :ref:`whats_past_is_prologue` (微信公众号第一篇)时意外发现，原来封闭的微信默认居然不允许外部链接。只有付费帐号(需要申请个体经营)才能在文档中使用外部链接。一时间无法解决，看到了网上有人介绍在微信公众号文章中嵌入二维码来代替链接(非常折腾)，所以就寻找并尝试实践如何在Linux命令行生成二维码。

简单来说，就是一个 ``qrencode`` 命令:

.. literalinclude:: qrencode/cloud-atlas
   :caption: 生成 https://cloud-atlas.readthedocs.io 二维码

则输出的二维码如下，可以嵌入到微信公众号文章中提供用户扫描识别:

.. figure:: ../../_static/shell/utils/cloud-atlas.png
   :scale: 50

   扫描上面的二维码可以访问 https://cloud-atlas.readthedocs.io

参考
=======

- `适用于Linux的5个最佳QR码生成器应用程序 <https://juejin.cn/post/7108919245362167838>`_
- `libqrencode官网 <https://fukuchi.org/works/qrencode/>`_
- `qrencode(1) - Linux man page <https://linux.die.net/man/1/qrencode>`_
