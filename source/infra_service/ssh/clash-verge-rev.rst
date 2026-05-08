.. _clash-verge-rev:

===================
clash-verge-rev
===================

我在最近一次实践 :ref:`oclp_macos` 遇到一个非常麻烦的事情: GFW防火墙屏蔽了GitHub，而OCLP在完成 :ref:`macos` 15安装启动后，必须在启动后安装驱动补丁才能正常使用显卡、无线网卡。

我最初以为通过 :ref:`ssh_tunneling_dynamic_port_forwarding` 能够轻易通过系统级全局设置sock5代理 :ref:`across_the_great_wall` ，但是 OCLP 反复提示 ``Cannot patch due to the following reasons: Missing Network Connection.`` 。

原因很简单，OCLP核心使用了 :ref:`python` 开发，默认不支持socks代理(需要补充安装python模块 ``PySocks`` )，所以在macOS中设置了系统全局socks5代理也没有效果。

gemini提供了一个非常简洁的建议，我实践下来非常有效，所以整理记录如下:

`clash-verge-rev开源项目 <https://www.clashverge.dev/>`_ 提供了简单配置就能够管理系统代理、TUN(虚拟网卡)模式:

- 内置 `Clash.Meta(mihomo) <https://github.com/MetaCubeX/mihomo>`_ 内核，并支持切换 Alpha 版本内核
- 简洁美观的用户界面
- 配置文件管理和增强（Merge 和 Script），配置文件语法提示
- 系统代理和守卫、TUN(虚拟网卡) 模式

在gemini的指导下，前后花费10分钟就能够完成配置(摸索)

.. note::

   我依然使用 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建底层的socks5代理， ``clash-verge-rev`` 作用是构建和维护TUN设备，将系统流量通过TUN设备转发给本地已经构建的socks代理，以实现 :ref:`across_the_great_wall`

架构
========

``clash-verge-rev`` 本身并不负责处理数据包，它是一个使用 Tauri（基于 Rust 和 Webview2）编写的图形界面（壳）：

- GUI (Tauri + React): 负责配置管理、可视化节点选择、日志展示和策略组切换
- Core (Mihomo/Clash Meta): 它是真正的执行引擎。当你启动软件时，它会在后台拉起一个 mihomo 核心进程。这个核心负责维护 TCP/UDP 连接、执行分流规则和处理加密协议（如 Shadowsocks, Vmess, Trojan 等）。

TUN 模式 (虚拟网卡层)
------------------------

- 通过 utun 驱动在 macOS 系统中创建一个虚拟网卡
- 修改系统的路由表，将所有流量的默认出口指向这个虚拟网卡
- 所有的网络请求（无论是 Python, 终端还是系统更新）都会经过这个虚拟接口
- ``Mihomo`` 核心通过 L3 (网络层) 抓取这些数据包
- 核心解析数据包的目标地址，根据你定义的规则（Rules）分流，再通过 ``SSH SOCKS5`` 隧道 发送出去

配置
=========

已经完成了 :ref:`ssh_tunneling_dynamic_port_forwarding` ，然后配置 ``clash-verge-rev`` :

- 点击 ``配置 (Profiles)`` ，并点击 ``新建 (New)``
- 类型选择 “本地 (Local)”，命名为你希望的名字，如 ``ssh-tunnel``
- 在配置文件中写入以下内容和前面设置的 :ref:`ssh_tunneling_dynamic_port_forwarding` 对应:

.. literalinclude:: clash-verge-rev/profile.yaml
   :caption: 设置一个profile

- 返回配置页面，点击刚才创建的配置文件，使其变成蓝色(激活)

- 在 ``Settings`` 页面，勾选 ``TUN 模式 (TUN Mode`` 和 ``系统代理 (System Proxy)``

此时就会在Home观察页面看到流量活动，就可以尝试访问google或youtube验证

参考
======

- gemini
