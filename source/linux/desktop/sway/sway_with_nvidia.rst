.. _sway_with_nvidia:

===========================
在NVIDIA显卡环境运行Sway
===========================

最新的Sway版本已经隐含有限支持了NVIDIA显卡，运行参数::

   __GL_GSYNC_ALLOWED=0; __GL_VRR_ALLOWED=0; WLR_DRM_NO_ATOMIC=1; export QT_AUTO_SCREEN_SCALE_FACTOR=1; export QT_QPA_PLATFORM=wayland; export QT_WAYLAND_DISABLE_WINDOWDECORATION=1; export GDK_BACKEND=wayland; export XDG_CURRENT_DESKTOP=sway; export GBM_BACKEND=nvidia-drm; export __GLX_VENDOR_LIBRARY_NAME=nvidia; export MOZ_ENABLE_WAYLAND=1; export WLR_NO_HARDWARE_CURSORS=1; sway --unsupported-gpu

现有版本已经移除了之前的参数 ``--my-next-gpu-wont-be-nvidia`` ，改成了 ``--unsupported-gpu`` ，看起来应该可以基本运行。需要NVIDIA的驱动 ``495+`` 以上，后续我会验证测试

参考
=======

- `Sway 1.7有限支持NVIDIA显卡选项Zero-Copy Direct Scanout <https://www.phoronix.com/scan.php?page=news_item&px=Sway-1.7-rc2>`_
- `A quick look to Sway WM with Nvidia's drivers <https://www.reddit.com/r/swaywm/comments/sphp7b/a_quick_look_to_sway_wm_with_nvidias_drivers/>`_
- `NVIDIA (495) on sway tutorial + questions (Arch-based distros) <https://forums.developer.nvidia.com/t/nvidia-495-on-sway-tutorial-questions-arch-based-distros/192212>`_
