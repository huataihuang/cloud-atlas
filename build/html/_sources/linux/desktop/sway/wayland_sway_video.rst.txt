.. _wayland_sway_video:

=====================
Wayland+Sway视频播放
=====================

我在完成 :ref:`pi_400_audio` 配置之后，可以在 :ref:`pi_400` 硬件环境运行 Wayland + Sway 图形桌面正常播放音频，但是发现视频播放是失败的。不管使用哪种视频软件，如mpv和vlc，都会crash。例如，vlc的终端输出crash信息:

.. literalinclude:: wayland_sway_video/vlc_crash
   :language: bash
   :caption: wayland+sway环境VLC crash信息

这个错误原因实际上是因为VLC默认没有配置 :ref:`wayland` 作为视频输出设备，解决的方法简述见 :ref:`run_sway_on_kali_pi`
