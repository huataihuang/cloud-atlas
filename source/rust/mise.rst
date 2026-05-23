.. _mise:

=========================
mise
=========================

`mise-en-place <https://mise.jdx.dev/>`_ 提供的开源软件 ``mise`` 为开发者提供了一个快速的环境就绪，免除了多语言开发工作者不要使用不同的软件版本管理工具来安装不同的开发语音的痛苦。网站上有一句话非常打动人心 ``You dev env, already prepped.``

``mise`` 使用Rust开发，能够管理 rust, python, ruby, node 等，将开发工具安装在用户的HOME目录，无需root权限，并且支持在不同项目中使用不同的开发语言版本，这对于需要维护不同环境的工作非常有利。

我在 :ref:`colima_images` 中融合了 ``mise`` 来安装我的开发环境

.. _mise_proxy:

mise代理
==========

mise的代理设置才用了类似 :ref:`curl` 的环境变量方式，我在 :ref:`colima_images` 构建时是用了socks5h代理
