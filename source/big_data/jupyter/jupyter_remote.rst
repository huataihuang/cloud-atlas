.. _jupyter_remote:

=================
Jupyter远程访问
=================

当我使用 :ref:`dl_env` 时，由于是在 :ref:`linux_jail` 结合 :ref:`vnet_jail` ，所以在我的 :ref:`mbp15_late_2013` 中需要远程访问 ``Jupyter`` 。

由于 ``Jupyter`` Notbook服务器默认只监听回环地址，所以需要修订启动配置:

- 先生成 ``Jupyter`` 配置文件:

.. literalinclude:: jupyter_remote/generate-config
   :caption: 生成 ``Jupyter`` 配置文件

此时提示可以看到输出了一个默认启动配置:

.. literalinclude:: jupyter_remote/generate-config_output
   :caption: 生成 ``Jupyter`` 默认配置文件

- 修订 ``~/.jupyter/jupyter_notebook_config.py`` :

.. literalinclude:: jupyter_remote/jupyter_notebook_config.py
   :language: python
   :caption: 修订 ``~/.jupyter/jupyter_notebook_config.py``
   :emphasize-lines: 8,13

- 然后再次启动 ``jupyter notebook`` 就会监听所有网卡接口，就能够从远程访问Notebook

参考
======

- `Why I can't access remote Jupyter Notebook server? <https://stackoverflow.com/questions/42848130/why-i-cant-access-remote-jupyter-notebook-server>`_
