.. _lazy.nvim_docker:

========================
容器化lazy.nvim 
========================

我最近在实践 :ref:`colima_images` 时，采用了在debian开发容器镜像中加入nvim。gemini提供了一个很好的建议，能够自动完成 ``lazy.nvim`` 的安装以及插件的静默安装，这样就不需要每次构建容器之后，手工去启动一个nvim并等待插件安装完成。

.. note::

   由于插件安装需要访问GitHub，所以需要完成 :ref:`colima_socks_proxy` 配置，否则安装过程会阻塞中断


