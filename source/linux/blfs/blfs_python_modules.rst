.. _blfs_python_modules:

=======================
BLFS Python模块
=======================

.. warning::

   这里记录我所用到的软件包所依赖Python Modules: 即我只安装我需要的部分模块

.. _python_packaging:

Packaging
============

``Packaging`` 库提供交互操作性规范的使用程序，包括用于版本处理，说明符(specifiers)，标记(makers)，标签(tags)以及要求的实用程序。

.. literalinclude:: blfs_python_modules/packaging
   :caption: 安装packaging Python模块

.. _python_docutils:

docutils
============

``docutils`` 是Python中处理HTML，XML或LaTeX的模块，在编译 :ref:`glib` 时候会提示需要 ``rst2man`` 是通过这个模块获得

.. literalinclude:: blfs_python_modules/docutils
   :caption: 安装docutils Python模块

