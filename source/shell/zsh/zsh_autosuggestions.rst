.. _zsh_autosuggestions:

===================
Zsh自动提示
===================

Zsh有一个非常有用的插件 `zsh-autosuggestions <https://github.com/zsh-users/zsh-autosuggestions>`_ 可以自动提示根据当前上下文可能的命令，方便快速补全。

.. warning::

   autosuggestions 虽然非常灵活，但是我发现在 :ref:`pixel3` 中 :ref:`termux` 启用这个插件会极大消耗资源，导致shell提示符响应以及 :ref:`vim` 开启文件非常缓慢，所以最终我放弃这个插件。

- 在 Oh My Zsh环境安装::

   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

- 然后在 ``~/.zshrc`` 中配置::

    plugins=(其他的插件 zsh-autosuggestions)

再次登陆，当输入时就会自动建议完整命令，只需要按下 ``右方向键`` 就能自动把整条命令输入好，非常方便
