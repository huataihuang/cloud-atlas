.. _vim_for_swift:

==================
使用vim开发Swift
==================

既然可以 :ref:`swift_on_linux` ，自然就会想到使用万能的 :ref:`vim` 来开发Swift程序:

- 在Linux服务器上，使用 :ref:`vim` 更为自然和熟悉
- 无需图形环境，资源占用更少 (不过 :ref:`vscode` 也可以通过 :ref:`vscode_remote_dev_ssh` 实现，但是对网络依赖严重)

`prabirshrestha/vim-lsp <https://github.com/prabirshrestha/vim-lsp>`_ 也是类似 :ref:`swift_on_linux` 中 :ref:`vscode` 采用 ``Language Server protocol`` 实现语法解析，只不过结合到了vim插件中。

.. note::

   待实践

另一种方式是采用苹果公司提供 `swift/utils/vim插件 <https://github.com/apple/swift/tree/main/utils/vim>`_ 帮助实现语法高亮，但是不如 ``vim-lsp`` 完善方便。

参考
======

- `Swift development environment for vim users <https://forums.fast.ai/t/swift-development-environment-for-vim-users/40420>`_
