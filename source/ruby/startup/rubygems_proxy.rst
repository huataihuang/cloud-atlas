.. _rubygems_proxy:

=======================
RubyGems proxy 
=======================

RubyGems 好像不能支持 ``socks5h`` 协议，所以我在 :ref:`colima_images` 构建时， :ref:`mise` 使用了 socks5h 代理:

.. literalinclude:: rubygems_proxy/mise_socks5h
   :caption: :ref:`mise` 使用 socks5h 代理
   :emphasize-lines: 8

执行 ``gem install rails`` 如果继续采用 :ref:`mise_proxy` 代理配置会报错

.. literalinclude:: rubygems_proxy/socks5h_error
   :caption: 采用 ``socks5h`` 协议时gem install报错
   :emphasize-lines: 5

当需要gem支持代理时，可以使用 ``--http-proxy`` 参数来传递 ``http`` / ``https`` 等代理参数，但是这里的协议不支持 ``socks5`` / ``socks5h`` 协议

.. literalinclude:: rubygems_proxy/gem_install_http-proxy
   :caption: 采用http代理来使用gem install

我尝试过采用 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建的 ``socks`` 代理，但是出现报错:

.. literalinclude:: rubygems_proxy/gem_install_socks_error
   :caption: ``gem install`` 不支持 socks 协议报错
   :emphasize-lines: 3,4

如果确实无法构建良好的http代理，那么可以尝试使用国内的gem CDN加速，能够解决GFW阻塞问题:

.. literalinclude:: rubygems_proxy/gem_install_ruby-china
   :caption: 使用国内提供的CDN加速源


