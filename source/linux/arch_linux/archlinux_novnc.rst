.. _archlinux_novnc:

================================
在浏览器中访问arch linux(noVNC)
================================

之前实践过 :ref:`kali_novnc` ，而在arch linux中安装稍微有点区别: 官方仓库没有提供 noVNC ，需要 :ref:`archlinux_aur` 方式安装，也就是先安装 ``yay`` :

.. literalinclude:: archlinux_aur/install_yay
   :caption: 编译安装yay

然后通过 yay 安装 noVNC:

.. literalinclude:: archlinux_novnc/yay_novnc
   :caption: 安装noVNC

.. note::

   实际使用请参考 :ref:`kali_novnc` ，不过需要注意 ``x11vnc`` 运行需要主机已经启动了X桌面。暂时没有继续实践

参考
======

- `novnc on AUR (Arch User Repository) <https://linux-packages.com/aur/package/novnc>`_
