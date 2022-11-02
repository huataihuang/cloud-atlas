.. _rebuild_virtualenv:

==========================
重建Virtualenv
==========================

我在 :ref:`termux_dev` 采用 :ref:`virtualenv` 提供 :ref:`sphinx_doc` 运行，但是最近的 ``termux`` 升级软件包之后破坏了 ``Virtualenv`` 提示错误::

   Traceback (most recent call last):
     File "/data/data/com.termux/files/home/venv3/bin/sphinx-build", line 5, in <module>
       from sphinx.cmd.build import main
   ModuleNotFoundError: No module named 'sphinx'
   make: *** [Makefile:19: html] Error 1

解决方法是重建 :ref:`virtualenv`

- 之前已经为自己的项目 ``cloud-atlas`` 生成过软件包列表::

   pip freeze > source/requirements.txt

所以只要重建 :ref:`virtualenv` 然后依据这个 ``requirements.txt`` 就可以恢复

.. note::

   ``requirements.txt`` 中所有安装依赖包是指定版本的，如果时间较久，则版本会比较older，可以修改一下这个文件，去除掉版本指定。

- 重建virtualenv::

   cd ~
   python3 -m venv venv3
   . ~/venv3/bin/activate

- 重新安装软件包::

   pip install -r source/requirements.txt

参考
=======

- `Rebuilding a Virtualenv <https://help.pythonanywhere.com/pages/RebuildingVirtualenvs/>`_
