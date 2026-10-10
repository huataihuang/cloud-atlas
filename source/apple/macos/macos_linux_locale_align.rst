.. _macos_linux_locale_align:

===============================
macOS和Linux环境locale对齐
===============================

我在初次安装完成 :ref:`ubuntu_linux` server版之后，在macOS客户端 :ref:`ssh` 访问时会提示:

.. literalinclude:: macos_linux_locale_align/locale_warning
   :caption: ``en_US.UTF-8`` 提示

这个提示其实和 :ref:`python_locale` 是一样的，也就是服务器端因为精简安装，没有安装 ``locale-gen`` 也没有设置 ``en_US.UTF-8`` ，所以首先需要安装 ``locales`` 软件包:

.. literalinclude:: ../../python/startup/python_locale/apt_install_locales
   :caption: 安装locales软件包

然后执行 ``locale-gen`` 生成对应的locles:

.. literalinclude:: ../../python/startup/python_locale/locale-gen
   :caption: 执行 ``locale-gen`` 来生成对应locales
