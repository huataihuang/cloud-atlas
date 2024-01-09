.. _tiddlywiki_on_ruby_webrick:

=========================================
面向TiddlyWiki简单易用的ruby webrick服务
=========================================

TiddlyWiki页面不能在浏览器中直接保存:

- 虽然用浏览器插件能够解决文件本地存储，但是大多数插件都长时间没有更新，导致功能异常
  - `jimfoltz/tw5-server.rb <https://gist.github.com/jimfoltz/ee791c1bdd30ce137bc23cce826096da>`_ 通过一个简单的 :ref:`ruby` ``webrick`` 实现了服务端保存TiddlyWiki，特别适合个人简单使用

``tw5-server.rb``
====================

- 在安装了 :ref:`ruby` 的主机上，例如 ``docs`` 目录下存放从 `TiddlyWiki官网 <https://tiddlywiki.com/>`_ 下载一个空白文档 ``empty.html`` 。为了方便标识，将这个 ``empty.html`` 改名为 ``tiddlywiki.html``

- 在同一个目录下存放 `jimfoltz/tw5-server.rb <https://gist.github.com/jimfoltz/ee791c1bdd30ce137bc23cce826096da>`_ 提供的 ``tw5-server.rb`` :

.. literalinclude:: tiddlywiki_on_ruby_webrick/tw5-server.rb
   :language: ruby
   :caption: 提供 ``TiddlyWiki`` 读写访问的 ``tw5-server.rb``
   :emphasize-lines: 22

.. note::

   原 `jimfoltz/tw5-server.rb <https://gist.github.com/jimfoltz/ee791c1bdd30ce137bc23cce826096da>`_ 代码中 ``Dir.exists?`` 我修订成 ``Dir.exist?`` 以适应Ruby 3.2之后版本( `PSA (and a little rant): File.exists? Dir.exists? removed in Ruby 3.2.0 (deprecated in 2.2) <https://www.reddit.com/r/ruby/comments/1196wti/psa_and_a_little_rant_fileexists_direxists/>`_ )

   修改方法参考了 `Replace deprecated File.exists? with File.exist? #2740 <https://github.com/beefproject/beef/pull/2740/files>`_

- 在目录下运行命令:

.. literalinclude:: tiddlywiki_on_ruby_webrick/ruby_tw5-server.rb
   :caption: 运行

输出显示

.. literalinclude:: tiddlywiki_on_ruby_webrick/ruby_tw5-server_output
   :caption: 运行的输出信息
   :emphasize-lines: 3

可以看到web服务是绑定在 ``127.0.0.1:8000`` 上，这样可以防止外部不安全的访问

- 对于在服务器上运行的时候，由于对外网卡接口不提供服务，所以我们需要通过 :ref:`ssh_tunneling` 将ssh登陆后端本地端口转发到服务器上回环地址上:

配置 ``~/.ssh/config`` 设置:

.. literalinclude:: tiddlywiki_on_ruby_webrick/ssh_localforward
   :caption: ``~/.ssh/config`` 设置本地端口转发
   :emphasize-lines: 5

这样就可以在 :ref:`ssh` 登陆 ``bzcloud`` 之后在自己本地浏览器 http://127.0.0.1:8000 访问到服务器对应的 ``127.0.0.1:8000``

运行环境(补充)
=================

我在 :ref:`termux` ( :ref:`mobile_pixel_dev` )环境中，通过 ``apt install ruby`` 安装了 ``ruby 3.2.2`` 版本。需要注意，如果没有同时安装 :ref:`rails` ，则需要通过 :ref:`ruby_gem` 来安装上述执行脚本的依赖模块:

.. literalinclude:: tiddlywiki_on_ruby_webrick/gem_install
   :caption: 通过 :ref:`ruby_gem` 安装依赖
