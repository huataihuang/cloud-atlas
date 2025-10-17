.. _intro_opnsense:

=======================
OPNsense简介
=======================

`OPNsense.org <https://opnsense.org/>`_ 和 :ref:`pfsense` 类似，都是基于FreeBSD的开源防火墙发行版。OPNsense是2015年从 pfSense 项目fork出来的，提供了更频繁的更新，现代化接口以及集成了诸如云备份的扩展功能。而 pfSense 则相对专注于企业级功能和性能增强，并且用于高速VPN和 :ref:`wireguard` 。

OPNsense vs. pfSense
========================

OPNsense 和 pfSense 都是FreeBSD上著名的开源防火墙，只不过两者的侧重点不同:

- OPNsense 提供丰富的功能

  - 友好的用户体验(现代化web界面，直接在GUI提供Wi-Fi配置)，适合家庭用户或初学者
  - 使用通用主线FreeBSD发行版，能够支持较新的硬件和功能
  - 提供云备份(如Google Drive)
  - 支持IPv6, DHCP功能等

- pfSense 专注于性能

  - 专注于高性能，例如加速的 :ref:`wireguard` 以及 ``双WAN failover`` 等企业级功能
  - 提供更快的关键安全修复
  - 更新没有OPNsense多，但是更聚焦稳定性和性能
  - 使用高度定制的FreeBSD: 对FreeBSD的基础进行大量定制，有时候会引入技术债务(历史悠久是优势也是负担)，但允许进行特定的优化

综上:

- OPNsense提供更现代化、透明和功能丰富的用户体验，特别适合家庭用户
- pfSense通常被企业级选用于要求苛刻的环境，因为其专注于性能、加速功能和更快的安全补丁
- OPNsense 和 pfSense 使用了共享的核心，提供相似的路由和防火墙的核心功能，两者都有很多可用的软件包和插件

油管上 `Opnsense vs Pfsense ~ My own thoughts and concerns <https://www.youtube.com/watch?v=Of0Zp8h258g&t=313s>`_ 提供了pfSense和OPNsense的对比，并且该视频下很多评论可以参考:

- OPNsense社区更友好，并且和FreeBSD紧密合作，使用了最新的FreeBSD发行版
- OPNsense使用方便，大多数评论者都倾向于使用OPNsense
- pfSense优势在于历史悠久且文档完善，特别是提供了一些企业级使用案例的解析，或许适合更进阶的学习
- pfSense的社区版本有延后倾向，以吸引用户使用其商业版；而OPNsense目前社区支持活跃，更为开放

  - 有评论指出pfSense没有完全开源所有源代码导致无法从发布的源代码构建pfSense，以及贡献的WireGuard开源代码质量不佳
  - pfSense背后的Netgate公司更注重商业化，并对OPNsense fork其开源项目攻击
  - 两者原理想通，所以可以相互借鉴学习: OPNsense社区论坛较弱，不能解决很多问题，需要在TrueNAS 和 Nethserver 论坛寻求帮助
  
OPNsense学习资源
=================

- `The Complete Beginner's Guide to OPNsense <https://www.youtube.com/playlist?list=PLf3PUjoXTtNHuXFPqGc1uVc66Bz8Vy5w1>`_ 油管BrainThaw Studios的一个入门系列(我还没有看)
