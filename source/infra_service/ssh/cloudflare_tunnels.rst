.. _cloudflare_tunnels:

===========================
Cloudflare Tunnels
===========================

虽然 :ref:`ssh_tunneling_remote_port_forwarding` 可以实现 ``内网穿透`` ，将局域网内部服务映射到公网对外服务，但是也有以下不便:

- 需要有异常检测保活能力，通常需要复杂脚本，或者使用开源工具实现
- 需要自己部署一个VPS服务器(具备公网IP)，有一定投入成本

著名的网络服务商Cloudflare提供了一个免费的 ``Tunnels`` 服务，提供了 :ref:`ssh_tunneling_remote_port_forwarding` 增强服务。

Cloudflare初始准备
===================

访问 `Cloudflare Dashboard <https://dash.cloudflare.com/>`_ 的菜单，在 ``Zero Trust`` 分类下，有一个 ``Networks >> Tunnels`` 配置(需要先注册帐号，并且选择一个Free的Plan，绑定信用卡之后，就可以使用免费服务)

- 下载页面提供了多个工具，需要下载一个名为 ``cloudflared`` 的服务程序，官方说明为 ``cloudflared is a lightweight daemon that runs in your infrastructure and lets you securely expose internal resources to the Cloudflare edge.``

.. note::

   在官方网站提供的 ``cloudflared`` 二进制执行程序(安装包)只有x86/amd64版本。我的实践是在 :ref:`raspberry_pi` 环境，所以需要从 `GitHub cloudflare/cloudflared Releases <https://github.com/cloudflare/cloudflared/releases>`_ 下载。GitHub上提供了更多架构的编译版本发布

.. warning::

   下载的软件包，请使用网站提供的 ``SHA256 Checksums`` 校验，例如我下载的 ``cloudflared-linux-arm64.deb`` :

   .. literalinclude:: cloudflare_tunnels/sha256sum
      :caption: 使用网站提供的 ``SHA256 Checksums`` 校验下载的软件包

   输出校验的字符串应该和网站一致:

   .. literalinclude:: cloudflare_tunnels/sha256sum_output
      :caption: 使用网站提供的 ``SHA256 Checksums`` 校验下载的软件包输出的校验结果

.. note::

   时间不够，我后续再继续实践，待续...

参考
======

- `使用Cloudflare做HTTP内网穿透 <https://zhuanlan.zhihu.com/p/671576822>`_
- `使用cloudflare tunnel打洞，随时随地访问内网服务 <https://juejin.cn/post/7186228417699217467>`_
