.. _python_locale:

========================
Python运行环境locale
========================

在 :ref:`colima` 容器环境运行 :ref:`debian_tini_image` ，会发现 :ref:`sphinx_doc` 执行 ``make`` 报错:

.. literalinclude:: python_locale/lc_all_err
   :caption: debian容器镜像 ``locale`` 错误导致执行python模块locale报错
   :emphasize-lines: 8,10

检查 ``locale`` 命令输出可以看到容器环境没有配置 ``LC_CTYPE`` , ``LC_MESSAGES`` , ``LC_ALL`` :

.. literalinclude:: python_locale/locale_output_err
   :caption: ``locale`` 输出显示部分locale变量没有配置
   :emphasize-lines: 1-3

上述报错是因为没有配置 ``locales`` ，我参考 `Python locale error: unsupported locale setting <https://stackoverflow.com/questions/14547631/python-locale-error-unsupported-locale-setting>`_ 想重新配置，却发现实际上 ``locales`` 软件包没有安装:

.. literalinclude:: python_locale/locales_err
   :caption: ``locales`` 软件包没有安装导致无法配置
   :emphasize-lines: 22

通常我们会为了支持某个locales，需要先配置环境变量，然后执行 ``locale-gen`` ，但是显然这里也是错误的:

.. literalinclude:: python_locale/locale-gen
   :caption: 执行 ``locale-gen`` 来生成对应locales

不过这里会报错 ``locale-gen: command not found``

解决方法
===========

其实很简单的，就是docker官方debian镜像没有安装 ``locales`` 软件包导致的，所以需要补充安装:

.. literalinclude:: python_locale/apt_install_locales
   :caption: 通过安装locales软件包解决

安装会自动调用 ``locale-gen`` ，则根据 ``/etc/locale.gen`` 配置，会自动完成 ``locale-gen en_US.UTF-8``

参考
=======

- `Python locale error: unsupported locale setting <https://stackoverflow.com/questions/14547631/python-locale-error-unsupported-locale-setting>`_
- `Linode Lish bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8) <https://stackoverflow.com/questions/55077450/linode-lish-bash-warning-setlocale-lc-all-cannot-change-locale-en-us-utf-8>`_
