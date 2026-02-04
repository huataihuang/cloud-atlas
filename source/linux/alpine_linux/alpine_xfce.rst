.. _alpine_xfce:

===========================
设置Alpine Linux的xfce桌面
===========================

卸载xfce
==========

- 删除 XFCE 的核心组件及其附属应用:

.. literalinclude:: alpine_xfce/del
   :caption: 卸载XFCE4

- 清理孤立的依赖包 (Recursive Cleanup) -- Alpine 的 ``apk del`` 默认不会像 ``apt autoremove`` 那样自动删除所有不再需要的依赖，所以通过以下命令来彻底释放内存和磁盘:

.. literalinclude:: alpine_xfce/fix
   :caption: 清理孤立的依赖包

- 清理服务 -- 停止并禁用登录管理器(如果有必要也可以删除):

.. literalinclude:: alpine_xfce/lightdm
   :caption: 清理LightDM

注意需要保留 ``DBus`` ，因为 :ref:`sway` 同样需要 ``dbus`` 来处理应用间通信(例如 :ref:`fcitx` 和 :ref:`firefox` 间就需要通过 ``dbus`` ):

.. literalinclude:: alpine_xfce/dbus
   :caption: 确保 ``dbus`` 运行

- (可选) :ref:`alpine_sway`

- 删除Xorg(可选): 如果确定不再需要任何 X11 桌面，可以在完成 :ref:`alpine_sway` 之后尝试卸载 Xorg 相关包以节省更多空间:

.. literalinclude:: alpine_xfce/del_xorg
   :caption: 删除Xorg
