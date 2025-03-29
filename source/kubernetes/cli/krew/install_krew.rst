.. _install_krew:

==================
安装Krew
==================

Krew自身也是一个 :ref:`kubectl` 插件，也可以通过Krew安装和更新(krew自我管理)

.. warning::

   krew只能兼容于 kubectl v1.12 或更高版本

macOS/Linux安装krew
======================

- 确保 :ref:`git` 已经安装好

- 执行以下脚本下载和安装 ``krew`` :

.. literalinclude:: install_krew/install_krew
   :language: bash
   :caption: 安装 ``krew`` 脚本

.. note::

   这里我遇到一个非常痛苦的事情，就是GFW阻塞了 ``krew`` 安装导致反复超时。解决方法可以采用 :ref:`openconnect_vpn`

- 在 :ref:`shell` 的profile中添加运行路径 ``$HOME/.krew/bin`` ，例如 ``.bashrc`` 和 ``.zshrc`` :

.. literalinclude:: install_krew/profile_krew
   :language: bash
   :caption: 在用户profile中添加krew安装路径

- 重新登陆，然后执行 ``kubectl krew`` 检查安装

现在可以尝试 :ref:`krew_startup` 了
