.. _deploy_ghost_cms:

==================
部署Ghost CMS
==================

.. note::

   2021年初，我准备重新恢复 `我的个人网站 <https://huatai.me>`_ ，采用 :ref:`ghost_cms` 构建，以便分享所见所思。

安装nodejs运行环境
====================

- 安装nvm::

   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

- 将以下环境配置添加到环境配置，例如 ``~/.bashrc`` (脚本会自动添加) ::

   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
   [ -s "$NVM_DIR/bash_completion"  ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

.. note::

   我在 Ubuntu 18.04.5 LTS上通过上述方法无法加载环境，所以我切换到zsh来运行安装。

- 检查node版本::

   nvm ls-remote

- 安装node(目前仅支持最高v14，请先参考 `Ghost's Supported Node versions <https://ghost.org/docs/faq/node-versions/>`_ ) ::

   nvm install 14.17.0

准备数据库
===========

生产环境使用MySQL数据库::

   sudo apt-get install mysql-server

- 设置MySQL数据库::

   # To set a password, run
   sudo mysql

   # Now update your user with this command
   # Replace 'password' with your password, but keep the quote marks!
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

   # Then exit MySQL
   quit

   # and login to your Ubuntu user again
   su - <user>

Ghost安装
===========

- 安装ghost-cli (帮助安装ghost的工具) ::

   npm install ghost-cli -g

然后通过 ``ghost help`` 查看可用命令

- 创建目录::

   sudo mkdir -p /var/www/blog

- 设置目录owner::

   sudo chown huatai:staff /var/www/blog

- 设置权限::

   sudo chmod 775 /var/www/blog

- 进入目录::

   cd /var/www/blog

- 运行安装进程::

   ghost install

交互回答以下问题:

  - Blog URL: https://blog.huatai.me
  - MySQL hostname: ``localhost`` (默认本地主机，如果是安装在其他MySQL服务器，则输入实际主机名)
  - MySQL username / password: 输入 ``root`` 以及前面配置的MySQL数据库密码`
  - Ghost database name: 配置成推荐的 ``blog_prod``
  - Set up a ghost MySQL user?: 推荐，所以回答 ``Y`` 则创建一个 ``ghost`` 的mysql用户
  - Set up NGINX?: 推荐，所以回答 ``Y`` 会自动创建配置
  - Set up SSL?: 推荐，所以回答 ``Y`` 会自动创建证书
  - Set up systemd?: 推荐，所以回答 ``Y``


这里启动有一个报错::

   3) GhostError

   Message: Ghost was able to start, but errored during boot with: connect ECONNREFUSED 127.0.0.1:3306
   Help: Unknown database error
   Suggestion: journalctl -u ghost_blog-huatai-me -n 50

原因是我租用的VPS内存只有512M，对于同时运行mysql和ghost内存不足，在没有设置swap情况下，导致mysql退出。我重新增加了swap空间以后才能够运行。

SSL设置
=========

 我遇到一个问题是无法启动https，实际上::

    ghost setup ssl

重新设置，就发现报错::

   ? Enter your email (For SSL Certificate) huataihuang@gmail.com
   + sudo /etc/letsencrypt/acme.sh --issue --home /etc/letsencrypt --domain blog.huatai.me --webroot /var/www/blog/system/nginx-root --reloadcmd "nginx -s reload" --accountemail huataihuang@gmail.com
     ✖ Setting up SSL
     One or more errors occurred.

   1) ProcessError

   Message: Command failed: /bin/sh -c sudo -S -p '#node-sudo-passwd#'  /etc/letsencrypt/acme.sh --issue --home /etc/letsencrypt --domain blog.huatai.me --webroot /var/www/blog/system/nginx-root --reloadcmd "nginx -s reload" --accountemail huataihuang@gmail.com
   [Sat Jun  5 00:41:44 CST 2021] blog.huatai.me:Verify error:Invalid response from http://blog.huatai.me/.well-known/acme-challenge/slTxXchSnR4hl51jnJyBq7ABdyUwvGwpHiKzwRqhsaA [185.199.111.153]:
   [Sat Jun  5 00:41:44 CST 2021] Please add '--debug' or '--log' to check more details.
   [Sat Jun  5 00:41:44 CST 2021] See: https://github.com/acmesh-official/acme.sh/wiki/How-to-debug-acme.sh

我发现是域名解析错误，这里访问的 185.199.111.153 地址是我之前设置指向 github.io 的域名，需要调整成我实际当前服务器的IP地址

维护
==========

- 停止服务::

   systemctl stop ghost_blog-huatai-me.service

- 启动服务::

   systemctl start ghost_blog-huatai-me.service

参考
=====

- `GitHub TryGhost / Ghost README.md <https://github.com/tryghost/ghost>`_
- `How to install Ghost on Ubuntu <https://ghost.org/docs/install/ubuntu/>`_
