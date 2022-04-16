.. _run_sway_on_pi:

=============================
在树莓派上运行sway窗口管理器
=============================

安装
======

- :ref:`kali_linux` 环境安装 ``sway`` ::

   sudo apt install sway

:ref:`kali_linux` 默认使用的图形登陆管理器可以自动管理 ``sway`` 的登陆会话，并且会正确设置 :ref:`wayland` 显示服务，所以只需要在图形登陆管理器中选择 ``sway`` 登陆就是这个平铺WM了。

使用设置
==========

- :ref:`fcitx_sway` 输入法可以非常完美使用中文，但是需要注意

  - 默认 ``foot`` 终端虽然能够输入中文，但是无法现实中文候选字词，所以改为 ``qterminal`` (默认 :ref:`kali_linux` 的 :ref:`xfce` 配套终端模拟器，轻量级且功能完备)就可以正常输入中文
  - ``chromium`` 无法输入中文(显示运行没有问题)，不过好在 ``firefox`` 使用中文输入正常，所以我同时采用这2个浏览器取长补短

- 配置定制，先将全局配置复制到个人目录下:

   

参考
======

- `反璞归真 -- Sway上手和配置(2021) <https://zhuanlan.zhihu.com/p/441251646>`_
- `使用Wayland和sway <https://blog.tiantian.cool/wayland/>`_
- `arch linux: sway <https://wiki.archlinux.org/title/Sway>`_
