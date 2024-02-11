.. _chrome_proxy_command_line:

=============================
Chrome命令行代理配置
=============================

在 :ref:`linux` 环境中运行的Chrome/Chromium ( :ref:`gentoo_chrome` / :ref:`gentoo_chromium` )的网络配置中虽然有 ``proxy settings`` 项，但是实际是无法配置的(灰色按钮)，通常表示跟随系统设置。

通常我会安装 ``Proxy SwitchyOmega`` 来配合 :ref:`ssh_tunneling_dynamic_port_forwarding` 。但是，首次安装Chrome插件需要访问Google Chrome扩展仓库(也是被屏蔽的)，所以必须有一个方法让chrome首次启动就使用代理。

Chrome/Chromium有一个命令行运行参数 ``--proxy-server`` 可以直接指定，无需系统配置:

.. literalinclude:: chrome_proxy_command_line/chrome_proxy
   :caption: 使用 ``--proxy-server`` 参数指定代理运行chrome

类似还有指定http代理方式，可以配合 :ref:`squid` 这样的传统代理服务器使用:

.. literalinclude:: chrome_proxy_command_line/chrome_proxy_http
   :caption: 使用 ``--proxy-server`` 参数指定HTTP代理运行chrome

参考
======

- `Configure Proxy for Chromium and Google Chrome From Command Line on Linux <https://www.linuxbabe.com/desktop-linux/configure-proxy-chromium-google-chrome-command-line>`_
