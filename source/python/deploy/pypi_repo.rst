.. _pypi_repo:

==================
PyPI仓库服务
==================

在我们交付Python服务软件时，通常会需要使用 ``pip`` 安装各种软件包，对于内部网络，很可能不能通过Interne从PyPi服务器安装软件包。此外，一些内部工程项目不能把Python包传到公开的pypi仓库，并且为了大规模部署服务也需要提高安装效率。以上多个需求都需要我们内部构建一个PyPi仓库服务。

构建PyPi仓库的方案
===================

- pypiserver

开源、轻量级、部署方便，但是没有web ui

- sonatype/nexus

分社区版和商业版，社区版能满足95%的市场需求

支持当前市面上大部分语言，就算原生不支持，github上也能搜索到对应的插件

非常重量级的解决方案，适合企业使用

- jfrog Artifactory

分社区和商业版，不过社区版很鸡肋，功能很少

商业版则非常强大，适合企业使用

- devpi

开源，比 pypiserver 略复杂，提供了 web ui

- 使用github实现pypi私服 `How to use GitHub as a PyPi server <https://www.freecodecamp.org/news/how-to-use-github-as-a-pypi-server-1c3b0d07db2/>`_

- PyPICloud

分社区和商业版

评估
======

- sonatype/nexus 功能丰富，我准备实践

- pypiserver 快速搭建，应该比较适合应急和快速实现

- devpi 提供 打包/测试/发布 的功能丰富的开源实现，值得实践

参考
======

- `使用sonatype/nexus构建企业级内部pypi仓库 <https://cloud.tencent.com/developer/article/1655121>`_
