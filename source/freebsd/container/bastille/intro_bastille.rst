.. _intro_bastille:

==================
Bastille 简介
==================

Bastille是一个自动部署和管理FreeBSD容器化应用的开源软件，完全由Bourne Shell( :ref:`bash` )编写。

Bastile特点:

- 使用模板完成自动化不俗
- 支持各种FreeBSD Tail: :ref:`thin_jail` , :ref:`thick_jail` , :ref:`linux_jail` 等
- 支持VNET
- 没有任何依赖(也就是纯Shell)
- 支持导入和导出
- 支持动态端口重定向
- 支持资源控制( ``rctl`` )
- 支持 Linux Containers
- 活跃开发(目前2025年1月仍然活跃commit，最近的Releaes是20241124)

`BastilleBSD <https://bastillebsd.org/>`_ 网站有一个 `Compare Bastille <https://bastillebsd.org/compare/>`_ 对比了类似功能的多个工具，可以看到Bastille是功能最全且活跃度最高。

参考
=======

- `BastilleBSD <https://bastillebsd.org/>`_ 开发Bastille的官网
