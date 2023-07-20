.. _kindle_download_helper:

=========================
kindle电子书批量下载
=========================

Kindle中国电子书店在2023年6月30日18店停止运营，留给我们只有1年的时间(2024年6月30日)可以下载已经购买过的电子书。

对于中国读者而言，这是一个无奈且悲伤的象征性事件，然而我们不得不面对现实:

- 批量下载已购买的电子书
- 移除DRM( :ref:`calibre_remove_drm` )，将电子书转到其他平台继续阅读(我准备通过 ``Send to Kindle`` 转一部分到美亚账号，并且通过 :ref:`read_e-books_after_kindle` 方式在Apple iBook和Google Books中归档阅读)

批量下载
==========

- 准备 :ref:`virtualenv` ( :ref:`macos` ) :

.. literalinclude:: ../../../python/startup/virtualenv/brew_install_pip3_venv
   :language: bash
   :caption: 在 :ref:`macos` 环境安装 ``pip3`` 以及 ``venv``

.. literalinclude:: ../../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

.. literalinclude:: ../../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

- clone `Kindle_download_helper (Github) <https://github.com/yihong0618/Kindle_download_helper>`_ ，然后 ``pip`` 安装对应模块:

.. literalinclude:: kindle_download_helper/install_kindle_download_helper
   :caption: 安装 ``Kindle_download_helper``

- 执行以下命令下载自己的购买书籍，同时移除DRM:

.. literalinclude:: kindle_download_helper/kindle_download_helper
   :caption: 运行 ``kindle_download_helper`` 下载书籍

默认(如果是已经通过浏览器登陆在 amazon 网站)会使用 ``browser-cookie3`` 库自动从浏览器获得cookie。如果不是本级下载，则需要手工获得cookie来下载，详见 `Kindle_download_helper (Github) <https://github.com/yihong0618/Kindle_download_helper>`_

不过，我还是遇到无法获取 ``CSRF token`` 报错:

.. literalinclude:: kindle_download_helper/kindle_download_helper_error
   :caption: 运行 ``kindle_download_helper`` 下载书籍报错: 没有找到 ``csrf token``

这个 ``CSRF Token`` 参考 `Kindle_download_helper (Github) <https://github.com/yihong0618/Kindle_download_helper>`_ 帮助，从 `Amazon.cn全部书籍 <https://www.amazon.cn/hz/mycd/myx#/home/content/booksAll/dateDsc/>`_ 页面中，通过网页源码，搜索 ``csrfToken`` 添加到命令行参数 ``${csrfToken}`` :

.. literalinclude:: kindle_download_helper/kindle_download_helper_device_csrftoken
   :caption: 运行 ``kindle_download_helper`` 下载书籍(结合 ``device_sn`` 和 ``csrfToken`` )

还是遇到一个报错，和 `python kindle.py --pdoc --mode sel --cn --cookie ${cookie} ${csrf}报错 #139 <https://github.com/yihong0618/Kindle_download_helper/issues/139>`_ 报错相同

.. literalinclude:: kindle_download_helper/kindle_download_helper_device_csrftoken_error
   :caption: 运行 ``kindle_download_helper`` 下载书籍(结合 ``device_sn`` 和 ``csrfToken`` )报错

可以看到是 ``kindle_download_helper/kindle.py`` 中::

   def download_books(self, start_index=0, filetype="EBOK"):
       # use default device
       device = self.find_device()

获取默认设备报错

顺着报错，可以定位到 ``get_devices`` 函数:

.. literalinclude:: kindle_download_helper/kindle.py
   :language: python
   :caption: kindle.py 代码片段 ``get_devices``

可以看出这里 ``get_devices`` 实际上是从 ``cookie`` 中获取的，这说明程序中 ``browser-cookie3`` 库自动从浏览器获得cookie存在问题。所以按照 `Kindle_download_helper (Github) <https://github.com/yihong0618/Kindle_download_helper>`_ 帮助，从浏览器页面获取 ``cookie`` :  在 `Amazon.cn全部书籍 <https://www.amazon.cn/hz/mycd/myx#/home/content/booksAll/dateDsc/>`_ 页面中，按 ``F12`` ，进入 ``Network`` 面板。在 ``Name`` 栏找到任意一个 ``ajax`` 请求，右键，找到 ``Copy request headers``
，从这个复制出来的文本中找到 ``Cookie: ZZZ`` ，然后按照以下命令执行:

.. literalinclude:: kindle_download_helper/kindle_download_helper_device_cookie_csrftoken
   :caption: 运行 ``kindle_download_helper`` 下载书籍(结合手工获取的 ``cookie`` 和 ``csrfToken`` )

.. note::

   ``DeDRM`` 是失败的，所以我还是采用 :ref:`calibre_remove_drm`

参考
======

- `Kindle_download_helper (Github) <https://github.com/yihong0618/Kindle_download_helper>`_
