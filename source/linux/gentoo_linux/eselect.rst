.. _eselect:

==================
eselect
==================

类似 :ref:`update-alternative` ，gentoo 提供了采用 ``eselect`` 来构建软链接的方法:

- 检查当前 ``vi`` 对应的编辑器

.. literalinclude:: eselect/vi_show
   :caption: 检查 ``vi`` 对应的实际编辑器命令

当前没有设置的话，显示如下:

.. literalinclude:: eselect/vi_show_output_unset
   :caption: 没有设置vi的时候显示是unset

- 执行以下命令创建 :ref:`nvim` 映射到 ``vi`` :

.. literalinclude:: eselect/vi_set
   :caption: 设置 :ref:`nvim` 映射到 ``vi``

然后检查 ``/usr/bin/vi`` 可以看到是一个软链接

.. literalinclude:: eselect/ls_vi
   :caption: 检查 ``/usr/bin/vi``

输出显示是一个指向 ``nvim`` 的软链接:

.. literalinclude:: eselect/ls_vi_output
   :caption: ``/usr/bin/vi`` 是一个指向 ``nvim`` 的软链接

- 设置默认 ``editor`` 编辑器:

.. literalinclude:: eselect/editor_set
   :catption: 设置 ``EDITOR``

注意输出信息:

.. literalinclude:: eselect/editor_set_output
   :catption: 设置 ``EDITOR`` 输出信息

可以看到这里的 ``EDITOR`` 是一个环境变量。实际检查 ``/etc/profile.env`` 就可以看到以下配置行:

.. literalinclude:: eselect/editor_env
   :caption: ``/etc/profile.env`` 添加了一行 ``EDITOR`` 环境变量设置



参考
======

- `default editor in eselect editor [solved] <https://forums.gentoo.org/viewtopic-t-878023-start-0.html>`_
