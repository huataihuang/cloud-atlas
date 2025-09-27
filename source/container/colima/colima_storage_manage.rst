.. _colima_storage_manage:

=====================
Colima存储管理
=====================

Colima默认将用户目录映射进虚拟机，同时还映射了一个临时文件目录，所以在 ``colima`` 虚拟机内部执行 ``df -h`` 会看到以下内容:

.. literalinclude:: colima_storage_manage/df_output
   :caption: 在 ``colima`` 虚拟机内部通过 ``df -h`` 观察可以看到物理主机的用户目录已经映射
   :emphasize-lines: 7,8

这个设置在虚拟机启动配置 ``~/.colima/default/colima.yaml`` 中设置:

.. literalinclude:: colima_storage_manage/colima.yaml
   :caption: ``colima`` 存储挂载配置案例
   :emphasize-lines: 12

这个默认设置非常巧妙地解决了容器数据持久化能够直接存储到物理主机磁盘中，防止数据丢失。我在 :ref:`colima_images` 中就采用这个用户目录作为容器存储卷，方便开发工作。

为了能够更好控制目录映射(我希望仅映射用户目录下指定子目录，即 ``docs`` 和 ``secrets`` )，所以改变配置如下:

.. literalinclude:: colima_storage_manage/colima-docs.yaml
   :caption: ``colima`` 存储挂载配置 ``docs`` 和 ``secrets``
   :emphasize-lines: 14-18

重启 ``colima`` 服务 ( ``brew services restart colima`` )，进入虚拟机( ``colima ssh`` ) 可以看到目录挂载:

.. literalinclude:: colima_storage_manage/df_docs_output
   :caption: 在 ``colima`` 虚拟机内部通过 ``df -h`` 检查 ``docs`` 目录映射
   :emphasize-lines: 8,11

参考
======

- `colima FAQ <https://github.com/abiosoft/colima/blob/main/docs/FAQ.md>`_
