.. _gentoo_sway_fcitx_x:

===============================================
Gentoo Linux Sway fcitx中文输入(通过X11支持)
===============================================

在 :ref:`gentoo_sway_fcitx` 中，最終實際上是採用了Xwayland來實現中文輸入:

在上次 :ref:`gentoo_sway_fcitx` 实践中，实际上最终是启用了X支持来实现中文候选字的。我在最近的一次实践中，尝试 :ref:`gentoo_sway_fcitx_native_wayland` ，不过很不幸没有成功。所以我再次整理和总结通过启用X11支持来完成sway环境下的fcitx5中文输入。本文是最新的一次实践总结，相对较为精简和完整，请参考。

- ``/etc/portage/package.use/fcitx5`` :

.. literalinclude:: gentoo_sway_fcitx_x/package.use_fcitx5
   :caption: 配置fcitx5的 ``/etc/portage/package.use/fcitx5``
   :emphasize-lines: 2,10,11,16,21

- ``/etc/portage/package.use/sway`` :

.. literalinclude:: gentoo_sway_fcitx_x/package.use_sway
   :caption: 配置sway的 ``/etc/portage/package.use/sway``
   :emphasize-lines: 9,15,22,31,38

然后重新 ``emerge world`` 来更新USE flags:

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

经过反复尝试(主要以firefox为输入对象)，需要以下配套use flags:

- ``app-i18n/fcitx`` 和 ``gui-wm/sway`` 启用了 ``X``

  - 在纯粹 ``wayland`` 环境的 sway 中，输入中文其实不需要X支持，fcitx5能够输入中文，但是无法绘制候选字匡(完全盲打)
  - 参考 `gentoo+sway无法在WPS、foot、dingtalk应用中显示输入法候选窗口 #455 <https://github.com/fcitx/fcitx5/issues/455>`_ fcitx开发者wengxt的答复，提示需要在开启fcitx5的X支持
  - 根据找到的资料，fcitx5如果不能使用wayland绘制候选字匡，就会回退到Xwayland绘制，所以开发者wengxt建议fcitx5启用X支持(其实还提示了需要在gtk2和gtk3开启X11，不过我最初没有理解，后来才想到原来绘制是通过gtk3实现的)

- ``app-i18n/fcitx-gtk`` 同时启用了 ``gtk3 gtk4`` (可能只需要gtk3)

  - 我最初编译 ``fcitx-gtk`` 启用了 ``gtk4`` 支持，并且我尝试了在 ``gui-libs/gtk`` 启用X支持(我的想法是尝试纯GTK 4。但是发现依然无法显示候选字
  - 这说明fcitx5绘制候选字不是采用 ``gtk4`` 而是采用 ``gtk3``

- ``x11-libs/gtk+`` 启用了 ``X`` 

  - 这步非常重要，我最初只激活了 ``fcitx`` 和 ``sway`` 的 ``X`` ，发现依然无法弹出候选字(而我上一次实践是成功的，所以我对比了两次系统的use flags)
  - firefox并非gtk程序，所以理论上其实并不需要 ``fcitx-gtk`` ，但是我发现我这次仅启用 ``X`` 并不能显示候选字，对比了上次实践的use flags，发现上次是启用了 ``gtk+`` (也就是GTK3) 的 ``X``
  - 我修订了 ``x11-libs/gtk+`` 启用 ``X`` 的 use flag之后，就能够正常浮现候选字了

综上:

- 如果sway不能在纯wayland环境提供 ``text-inut-v3`` 绘制输入法popups(需要等待已经合入代码主干的sway发布下一个扳本)，那么就需要启用sway和fcitx5的X11支持
- fcitx5的候选字绘制是采用GTK3来实现的，所以 ``x11-libs/gtk+`` 也需要激活 ``X11`` 支持
