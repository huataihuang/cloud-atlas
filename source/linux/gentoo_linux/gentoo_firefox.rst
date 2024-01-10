.. _gentoo_firefox:

====================
Gentoo Firefox
====================

我在重新部署 :ref:`install_gentoo_on_mbp` 之后，一直思考如何将系统做到轻量级。在选择 :ref:`gentoo_sway` 桌面之后，我同样考虑能够较好支持 :ref:`wayland` 图形系统，并且较为轻量级的开源浏览器 Firefox:

- 平衡Google这样 `利维坦 <https://zh.wikipedia.org/wiki/%E5%88%A9%E7%BB%B4%E5%9D%A6_(%E9%9C%8D%E5%B8%83%E6%96%AF)>`_ 的开源力量
- 没有商业(广告)驱动，更专注于隐私，降低不必要的跟踪技术植入

安装
=======

浏览器的编译非常庞大，不过 Firefox 编译似乎比 :ref:`gentoo_chromium` 要轻很多，在我的 :ref:`mba13_mid_2013` 上一个晚上就完成了编译(具体时间不详)，看起来我的 i5 处理器 8G 内存也能轻松完成

- Firefox的 ``ebuild`` 有大量的USE参数，可以通过如下命令检查:

.. literalinclude:: gentoo_firefox/equery
   :caption: 通过 ``equery`` 查询 ``www-client/firefox`` 的USE参数

输出信息:

.. literalinclude:: gentoo_firefox/equery_output
   :caption: 通过 ``equery`` 查询 ``www-client/firefox`` 的USE参数输出案例


需要注意，由于Firefox使用了 :ref:`rust` 代码，所以天然的建议使用LLVM来最为编译后端，所以建议使用 Clang 而不是 GCC来完成编译。这里的USE参数默认有一个 ``clang`` 表示采用Clang完成软件编译。

在 :ref:`wayland` 运行
=========================

.. note::

   只要 ``wayland``  USE flag设置， ``www-client/firefox`` 和 ``www-client/firefox-bin`` 默认就会激活 **wayland** ，这段应该不用设置。不过，如果在Wayland环境运行还是失败，可以尝试

从Firefox 65开始，就可以在 :ref:`wayland` 环境中原生运行Firefox，只需要启动时带上 ``GDK_BACKEND=wayland`` 环境变量(当然 :ref:`gentoo_emerge` 时要配置 ``walyand`` USE flag):

.. literalinclude:: gentoo_firefox/wayland_firefox
   :caption: 在wayland环境运行firefox

此外，要确保通用Wayland环境变量，这样才能确保GDK和compositer通讯::

   XDG_RUNTIME_DIR
   WAYLAND_DISPLAY
   XDG_SESSION_TYPE

要设置firefox始终使用Wayland后端，可以在 ``~/.bashrc`` 中设置:

.. literalinclude:: gentoo_firefox/wayland_firefox_profile
   :caption: 在 ``~/.bashrc`` 中设置 firefox 使用Wayland

初步使用
==========

- 非常轻快，在 :ref:`mba13_mid_2013` 启动迅速(默认没有使用插件)
- 默认就能够播放视频(B站)，不过音频设置待完成

参考
======

- `gentoo linux wiki: Firefox <https://wiki.gentoo.org/wiki/Firefox>`_
