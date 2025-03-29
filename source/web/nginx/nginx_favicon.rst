.. _nginx_favicon:

==================
Nginx favicon.ico
==================

在检查 `cloud-atlas.io <https://cloud-atlas.io>`_ Nginx日志时，可以看到每次浏览器请求都会记录

.. literalinclude:: nginx_favicon/error
   :caption: Nginx日志显示每次访问都缺少 ``favicon.ico`` 文件

`Favicon.ico & App Icon Generator <https://www.favicon-generator.org/>`_ 提供了根据上传图片生成icon图片的功能:

- favicon就是一种16x16的小图标文件，显示在浏览器地址栏网站的URL旁边，或者是浏览器Tab，书签列表中玩站名称帮，方便用户快速识别网站
- App Icon是时能手机按下启动应用程序的图像，随着手机屏幕分辨率的不断提高，需要更高分辨率的应用程序图标
- 现代浏览器支持将图标保存为GIF，PNG或其他流行文件格式，不过古老的Internet Explorer仍要求将图标保存为ICO文件(微软图标格式)

当使用 `Favicon.ico & App Icon Generator <https://www.favicon-generator.org/>`_ 生成了ico文件(其实是 ``favicon`` 目录下一组png图片文件，则可以在网站HTML的头部添加以下代码

.. literalinclude:: nginx_favicon/favicon.html
   :caption: favicon嵌入html头部的内容

但是，如果页面的header没有嵌入上述 ``favicon`` 引用代码，那么浏览器默认就会请求网站根目录下的 ``favicon.ico`` 文件(可以将一个 ``16x16`` 的 PNG 图片文件复制到Nginx网站的根目录下，就能够解决这个问题。

- 案例: :ref:`sphinx_favicon`

参考
=======

- `Favicon.ico & App Icon Generator <https://www.favicon-generator.org/>`_
