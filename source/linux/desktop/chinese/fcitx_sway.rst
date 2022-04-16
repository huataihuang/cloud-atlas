.. _fcitx_sway:

==========================
sway窗口管理器使用fcitx5
==========================

我 :ref:`install_kali_pi` ，使用体验发现默认的 :ref:`xfce` 对于ARM架构的 :ref:`pi_400` 还是过于沉重，所以尝试切换到基于 :ref:`wayland` 的 :ref:`sway` ，实践下来体验非常接近完美(资源占用极小)。

:ref:`sway` 使用非常现代化的 :ref:`wayland` 显示服务，这要求应用软件进行适配，所以也带来很多不兼容的问题。根据网上资料， :ref:`fcitx` 已经支持 sway ，并且根据我以往经验，fcitx配置也较为简便，兼容性不错，性能也比较好。所以，我经过一些尝试，成功在 :ref:`sway` 环境使用 :ref:`fcitx` 进行中文输入和日常工作。

安装
=======

- :ref:`kali_linux` 基于debian，软件非常丰富且安装简便::

   sudo apt install fcitx5 fcitx5-chinese-addons

- 启用fcitx的输入需要配置环境变量，标准方式是修改 ``/etc/environment`` (通用于各种 :ref:`shell` )，添加以下配置

.. literalinclude:: fcitx/environment                                                                                                                                                       
   :language: bash                                                                                                                                                                          
   :caption: 启用fcitx5环境变量配置 /etc/environment 

- 按照 :ref:`sway` 配置标准方法，先复制全局配置到个人配置目录下:



参考
========

- `WAY配置中文输入法 <https://zhuanlan.zhihu.com/p/379583988>`_
