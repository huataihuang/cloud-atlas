.. _linux_chinese_view:

==================
Linux中文显示
==================

中文显示
==========

现代Linux环境中文显示已经非常简单

- 设置字符集支持 :ref:`locale_env` : 配置 ``/etc/locale.gen`` :

.. literalinclude:: linux_chinese_view/localegen
   :language: bash
   :caption: 字符集支持UTF-8

.. note::

   我设置 ``en_US.UTF-8`` 是希望保持英文界面，同时能够输入中文。如果你希望使用中文界面，则修改成::

      zh_CN.UTF-8 UTF-8

- 安装中文字体，只需要安装 ``文泉驿`` 字体已经足够美观，我安装 ``微米黑`` :

.. literalinclude:: linux_chinese_view/apt_install_fonts-wqy
   :language: bash
   :caption: apt安装文泉驿字体

完成以上步骤以后，在 :ref:`x_window` 图形界面中，已经能够很好显示中文。

中文输入法
=============

接下来就是选择安装一种中文输入法:

- :ref:`fcitx` 轻量级输入法，目前再次活跃开发fcitx5 
- :ref:`ibus` debian默认输入框架，很多发行版默认
- :ref:`scim` 似乎不再活跃开发，不过比较轻量级
- nimf 似乎非常小众的轻量级输入框架，韩国人开发的
