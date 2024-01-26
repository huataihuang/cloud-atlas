.. _gentoo_kde_fcitx:

================================
Gentoo Linux KDE fcitx中文输入
================================

我在 :ref:`gentoo_sway_fcitx` 环境中折腾了很久中文输入，最终解决了 80% 的问题，勉强可用:

- 仓库中没有提供 ``kcm-fcitx`` ，这个组件之前是作为集成到KDE环境的Setting中来生成fcitx配置文件的工具，但是现在看来已经废弃了(KDE5中不再需要)
- 我推测 ``gentoo-zh`` :ref:`gentoo_overlays` 核心组件是能够工作的，但是没有提供很好的配置集成工具(我不确定完整安装 :ref:`gentoo_kde` 的 ``kde-plasma/plasma-meta`` 软件包是否提供设置方法。我为了能够尽快修复掉Gentoo Linux中文输入(已经停滞在这个中文输入问题上一周时间)，所以采用了 :ref:`gentoo_virtualization` 来运行 :ref:`fedora` 虚拟机KDE环境，快速完成 :ref:`fcitx` 配置之后，再将配置文件复制到Gentoo环境中使用
- 通过 :ref:`fedora` 提供的fcitx配置文件，就能够完成(本文) :ref:`gentoo_kde` 中文输入
- 也验证了 :ref:`gentoo_kde_fcitx` 的fcitx配置可以用于 :ref:`gentoo_sway_fcitx` 环境(无修改)，差异是在 :ref:`sway` 中终端程序 foot/alacritty 无法显示中文候选词窗口(KDE环境无此问题)。

.. note::

   这次折腾我 **基本** 找到了Gentoo环境的 :ref:`fcitx` 中文输入配置方法，虽然还有一些不足，但是基本可用。我准备在下次(大约一个月后)重新 :ref:`install_gentoo_on_mbp` 时再次验证和修订手册:

   - 备份和恢复本次实践通过 :ref:`fedora` KDE环境生成的 :ref:`fcitx` 配置文件，以绕开Gentoo环境没有合适的配置工具问题

     - 无需安装KDE环境来运行配置工具，可以大幅减少安装编译的投入
  
   - 仅安装核心 ``fcitx`` / ``fcitx-qt`` / ``fcitx-gtk`` / ``fcitx-rime`` 应该就能够满足中文输入需求

.. note::

   fcitx开发wengxt的博客 `Use Plasma 5.24 to type in Alacritty (Or any other text-input-v3 client) with Fcitx 5 on Wayland <https://www.csslayer.info/wordpress/linux/use-plasma-5-24-to-type-in-alacritty-or-any-other-text-input-v3-client-with-fcitx-5-on-wayland/>`_ 解释了 :ref:`wayland` 引擎Plasma(KDE)环境经下支持 ``text-input-v3`` 的客户端，如 :ref:`alacritty` 使用fcitx的原理:

   Fcitx5的Wayland IM Frontend通过KWin Wayland发送输入给使用 ``text-input-v3`` 可以实现非常完美的输入候选词窗口显示

输入引擎
===========

fcitx内置了非常简单的拼音输入法，所以通常会安装第三方输入法引擎:

- ``app-i18n/fcitx-cloudpinyin`` : `GitHub: fcitx-cloudpinyin <https://github.com/fcitx/fcitx-cloudpinyin>`_ 显示最近release是2019年11月8日
- ``app-i18n/fcitx-rime`` : `GitHub: fcitx-rime <https://github.com/fcitx/fcitx-rime>`_ 最近release是2017年9月15日 / 不过，上游 `GitHub: rime/librime <https://github.com/rime/librime>`_ 开发非常活跃
- ``app-i18n/fcitx-libpinyin`` : `GitHub: fcitx-libpinyin <https://github.com/fcitx/fcitx-libpinyin>`_ 最近release是2021年1月30日

总之，第三方输入法的开发不是很活跃， **可能** 需要先自己构建 :ref:`gentoo_ebuild_repository` (自己定制ebuild) 以便通过 :ref:`gentoo_version_specifier` 指定 ``SLOT 5`` 进行安装。我在 :ref:`gentoo_ebuild_repository` 完整记录了如何针对 ``fcitx5`` 安装 ``fcitx-rime`` 。

**经过简单对比，我最终采用Gentoo wiki中中文输入文档推荐的 fcitx-rime 输入法**

.. note::

   ``rime`` 输入法默认是繁体中文输入，调整方法是按下 ``F4`` 或者组合键 **Ctrl+`** ，就能看到输入选项，选择简体中文即可。 ( `GitHub: rime/wiki UserGuide <https://github.com/rime/home/wiki/UserGuide>`_ )

USE flags
==============

经过反复折腾，参考 `gentoo+sway无法在WPS、foot、dingtalk应用中显示输入法候选窗口 #455 <https://github.com/fcitx/fcitx5/issues/455>`_ 

- 尽可能不启用X支持，但是gtk,qt,sway似乎都需要X的支持才能使用fcitx输入中文，所以配置了如下组件X支持 ``/etc/portage/package.use/X`` :

.. literalinclude:: gentoo_kde_fcitx/X
   :caption: ``/etc/portage/package.use/X``

- 安装KDE，配置 ``/etc/portage/package.use/kde`` :

.. literalinclude:: gentoo_kde_fcitx/kde
   :caption: ``/etc/portage/package.use/kde``

- 配置 ``fcitx`` 启用X支持:

.. literalinclude:: gentoo_kde_fcitx/fcitx
   :caption: ``/etc/portage/package.use/fcitx``

使用 ``gentoo-zh`` :ref:`gentoo_overlays` 仓库
==============================================

实在难以解决，不想再折腾中文输入，改为参考 `SWAY配置中文输入法 <https://zhuanlan.zhihu.com/p/379583988>`_ 使用 ``gentoo-zh`` :ref:`gentoo_overlays` 仓库

.. note::

   详细折腾请参考 `Bug 760501 - app-i18n/fcitx-5 version bump <https://bugs.gentoo.org/760501>`_ 在一些非常用软件维护上，Gentoo使用不如 :ref:`arch_linux`

- :ref:`gentoo_emerge` 卸载之前已经安装的 ``SLOT 5`` 的 ``fcitx`` :

.. literalinclude:: gentoo_overlays/uninstall_fcitx5
   :caption: 卸载之前已经安装的 ``SLOT 5`` 的 ``fcitx``

- 激活 ``gentoo-zh`` 仓库:

.. literalinclude:: gentoo_overlays/enable_repository
   :caption: 激活 ``gentoo-zh`` 仓库

安装步骤参考了 `Gentoo 教程：系统完善 <https://blog.csdn.net/niuiic/article/details/109151402>`_

- 使用 ``emaint`` 对新添加Portage进行软件库同步:

.. literalinclude:: gentoo_overlays/emaint_sync
   :caption: 使用 ``emaint`` 同步新添加的软件库

- 配置 ``/etc/portage/package.accept_keywords/fcitx5`` :

.. literalinclude:: gentoo_sway_fcitx/package.accept_keywords.fcitx5
   :caption: 配置 ``/etc/portage/package.accept_keywords/fcitx5``

- 执行安装: 采用 ``gentoo-zh`` :ref:`gentoo_overlays` 安装源安装以下组件(下次再尝试精简，是否只需要安装 ``fcitx`` 和 ``fcitx-rime`` ?):

.. literalinclude:: gentoo_sway_fcitx/emerge_fcitx5_overlay
   :caption: 安装overlay的fcitx5(实际调正安装了更多软件包)

.. literalinclude:: gentoo_kde_fcitx/install
   :caption: 安装 ``fcitx`` 组件(针对KDE安装)

安装输出信息(依赖安装包)

.. literalinclude:: gentoo_sway_fcitx/emerge_fcitx5_overlay_output
   :caption: 安装overlay的fcitx5输出信息

由于多次调整USE flag，所以可能需要执行:

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了 USE flag 之后对整个系统进行更新

配置fcitx
============

Fedora
------------

在Gentoo Linux环境下我解决不了配置工具安装，所以采用 :ref:`gentoo_virtualization` 运行 :ref:`fedora` 虚拟机来配置 :ref:`fcitx` ，大致步骤按照官方文档:

- 在 :ref:`fedora` 中安装 ``fcitx5-autostart`` 软件包配合 ``fcitx`` 就能自动启动和设置好 fcitx5 运行环境
- 安装核心组件 ``fcitx5`` ``fcitx5-gtk`` ``fcitx5-qt`` ``fcitx5-rime`` :

.. literalinclude:: gentoo_use_flags/fedora_install_fcitx
   :caption: 在Fedora中安装fcitx

- 在Fedora中配置fcitx不需要使用 ``im-chooser`` ，只需要安装好 ``fcitx5-autostart`` 就能够在登录KDE时候自动启动 ``fcitx``

- 在Fedora中，启动 ``System Settings`` 点击 ``Input Devices`` 然后点击 ``Virtual Keyboard`` ，选择 ``Fcitx5`` 然后点击 ``Apply`` 。这样就将Fcitx5设置为虚拟键盘

- 在 ``Regional`` 设置中，选择 ``Input Method`` ，然后点击 ``Add Input Method`` ，选择 ``rime`` 作为输入法，并保存。这样重新登录以后，就会看到RIME输入法是可选的，通过 ``ctrl+space`` 可以切换

以上就是Fedora中配置，完成后将 ``~/.config/fcitx5`` 目录复制到 :ref:`gentoo_sway_fcitx` 的工作环境中就可以绕开Gentoo平台没有合适的配置工具的问题

Gentoo
--------

- 配置 ``~/.bashrc`` :

.. literalinclude:: gentoo_kde_fcitx/bashrc
   :caption: ``~/.bashrc`` 配置环境变量

.. note::

   在KDE环境中使用 ``fcitx`` 不需要配置 ``QT_IM_MODULE`` ， ``GTK_IM_MODULE`` 和 ``SDL_IM_MODULE`` 环境变量，虽然我配置了以后没有看出使用有什么不同。不过登录KDE环境时会提示不要设置这两个参数，所以我还是取消了。请参考 `Using Fcitx 5 on Wayland >> KDE Plasma <https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#KDE_Plasma>`_

参考
=======

- `gentoo linux wiki: Fcitx <https://wiki.gentoo.org/wiki/Fcitx>`_
- `Using Fcitx 5 on Wayland <https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland>`_
- `Bug 760501 - app-i18n/fcitx-5 version bump <https://bugs.gentoo.org/760501>`_ 关于fcitx5的讨论
- `gentoo linux wiki: How to read and write in Chinese <https://wiki.gentoo.org/wiki/How_to_read_and_write_in_Chinese>`_ 推荐采用fcitx和fcitx-rime
- `Use Plasma 5.24 to type in Alacritty (Or any other text-input-v3 client) with Fcitx 5 on Wayland <https://www.csslayer.info/wordpress/linux/use-plasma-5-24-to-type-in-alacritty-or-any-other-text-input-v3-client-with-fcitx-5-on-wayland/>`_ KDE环境使用Wayland时的fcitx5
- `Chrome/Chromium 今日 Wayland 输入法支持现状 <https://www.csslayer.info/wordpress/fcitx-dev/chrome-state-of-input-method-on-wayland/>`_ fcitx开发者的blog，技术细节满满
- `Gentoo設定Overlay，從第三方軟體庫安裝最新版Fcitx5中文輸入法 <https://ivonblog.com/posts/gentoo-overlay-setup/>`_
- `Fedora wiki: I18N/Fcitx5 <https://fedoraproject.org/wiki/I18N/Fcitx5>`_
