.. _gentoo_sway_fcitx_native_wayland:

===============================================
Gentoo Linux Sway(純wayland) fcitx中文输入
===============================================

在 :ref:`gentoo_sway_fcitx` 中，最終實際上是採用了Xwayland來實現中文輸入:

- ``sway`` 啓用了X支持， ``fcitx5`` 也啓用了X支持，這樣繪製中文候選詞時，採用的是X協議

我一直想精簡系統，所以再次嘗試構建 native wayland 環境的 sway

.. warning::

   目前我尚未解决纯 native wayland 环境的fcitx5中文候选字，所以暂时采用 :ref:`gentoo_sway_fcitx_x` 过渡。待后续sway发布新版，再回来重新实践。

進啓用native wayland
=======================

- 全局進啓用waylan，但是關閉X, gtk, qt

.. literalinclude:: gentoo_sway_fcitx_native_wayland/make.conf
   :caption: 全局配置 ``/etc/portage/make.conf`` USE flags

- 配置 :ref:`gentoo_overlays` 激活 ``gentoo-zh`` 仓库:

.. literalinclude:: gentoo_overlays/enable_repository
   :caption: 激活 ``gentoo-zh`` 仓库

- 配置激活 fcitx 使用 ``~amd64`` 非穩定版本: 配置 ``/etc/portage/package.accept_keywords/fcitx5``

.. literalinclude:: gentoo_sway_fcitx_native_wayland/package.accept_keywords.fcitx5
   :caption: 配置 ``/etc/portage/package.accept_keywords/fcitx5``

.. note::

   請注意這裏只激活 fcitx 和 fcitx-rime 的非穩定版本，因爲我只安裝這兩個組件

- 安裝 ``fcitx5`` :

.. literalinclude:: gentoo_sway_fcitx_native_wayland/install_fcitx5
   :caption: 安裝 fcitx 和 fcitx-rime

- 配置用戶 ``~/.bashrc`` :

.. literalinclude:: gentoo_sway_fcitx_native_wayland/bashrc
   :caption: 配置用戶 ``~/.bashrc``

- 將原先在 :ref:`gentoo_sway_fcitx` 中生成的 ``~/.config/fcitx5`` 配置文件目錄複製過來(這些配置是我通過KDE環境圖形界面配置的)

重新登錄sway 

問題
----------

上述安裝fcitx5完全關閉了GTK/QT支持，也關閉了X11支持，那麼究竟好用麼？

- 在 :ref:`sway` 環境中，實際上可以在 ``foot`` 和 ``firefox`` 中輸入中文，但是有一個缺陷: 沒有候選字顯示。也就是中文輸入完全是盲打，能夠輸入中文，但是如果有多個同音字，很難正確選擇
- 由於 ``rime`` 默認是啓用繁體字，切換簡體字也是需要候選顯示的，這導致我輸入始終是繁體字

我對比研究了一下網上的文檔:

- fcitx5似乎是支持wayland的候選，但是這個popup是需要一個補丁 `text_input: Implement input-method popups #7226 <https://github.com/swaywm/sway/pull/7226>`_ 來支持 text-input-v3 客戶端顯示候選字
- 上述補丁已經合併到sway主線代碼，但是目前(2024年3月)，最新的release 1.9 尚未包含這個補丁(我嘗試在Gentoo中激活 sway 的 ``~amd64`` 非穩定版本安裝，驗證依然無法顯示候選字)
- 我準備等待sway下一個release版本再來嘗試native wayland輸入法

暫時的解決方法
=================

由于我需要尽快能够实现中文输入，所以我对比了之前的实践和本次实践，重新修订了 :ref:`gentoo_sway_fcitx_x` 作为临时过度方案。
