.. _debian_tini_image:

==========================
Debian镜像(tini进程管理器)
==========================

Debian官方仓库已经提供了 :ref:`docker_tini` ，这意味着无需单独复制 ``tini`` (类似 :ref:`fedora_tini_image` 就不得不从容器外部复制对应的 ``tini`` 到镜像中)

`dockerhub: debian <https://hub.docker.com/_/debian>`_ 提供官方镜像(需要梯子):

- 当前 `debian.org <https://www.debian.org/>`_ 最新版本是 ``bookworm`` (12.6)，通过 ``tag`` 关键字 ``bookworm`` 或 ``latest`` 引用

tini运行ssh ``debian-ssh-tini``
===================================

- 参考之前 :ref:`ubuntu_tini_image` 经验，构建Dockerfile

.. literalinclude:: debian_tini_image/ssh/Dockerfile
   :language: dockerfile
   :caption: 具备ssh服务的debian镜像Dockerfile

- 构建镜像:

.. literalinclude:: debian_tini_image/ssh/build_debian-ssh-tini_image
   :language: bash
   :caption: 构建包含tini和ssh的debian镜像

这里我遇到一个报错:

.. literalinclude:: ../colima_proxy_archive/build_err
   :caption: 无法下载镜像导致构建失败
   :emphasize-lines: 14

通过 :ref:`colima_proxy` 来解决无法访问问题

- 运行容器: 注意这里继承了 :ref:`colima_storage_manage` 中两个HOST物理主机卷映射到容器内部，以便提供SSH密钥以及工作 ``docs`` 目录

.. literalinclude:: debian_tini_image/ssh/run_debian-ssh-tini_container
   :language: bash
   :caption: 运行容器挂载2个从HOST主机映射到colima虚拟机的卷(这样可以直接访问HOST主机数据)

- 一切顺利，现在在HOST主机上配置 ``~/.ssh/config`` 添加访问debian容器的SSH登陆(端口1122):

.. literalinclude:: debian_tini_image/ssh/ssh_config
   :caption: ``~/.ssh/config`` 添加访问debian容器的SSH登陆

.. note::

   HOST主机的 ``~/secrets`` 包含了SSH公钥，所以如果被正确挂载到容器的 ``~/.ssh`` 目录，就能够无需密码登陆容器

现在 ``ssh debian`` 就能够登陆到运行的容器中，并且执行 ``df -h`` 可以看到如下输出，显示HOST主机的存储卷被正确挂载到容器内部(包括登陆密钥):

.. literalinclude:: debian_tini_image/ssh/df
   :caption: 登陆容器检查卷挂载
   :emphasize-lines: 6,7

.. _container_debian-dev:

容器化开发环境 ``debian-dev``
===============================

在 ``debian-ssh-tini`` 基础上，增加开发工具包安装:

- ``debian-dev`` 包含了安装常用工具和开发环境:

.. literalinclude:: debian_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 包含常用工具和开发环境的debian镜像Dockerfile
   :emphasize-lines: 13

在colima虚拟机内部可以看到用户目录映射:

.. literalinclude:: debian_tini_image/colima_home_dir
   :caption: Colima启动虚拟机会自动将用户目录 ``bind`` 进虚拟机
   :emphasize-lines: 11

说明:

  - ``admin`` 用户的 ``uid`` 设置为 ``501`` ，这是因为macOS创建的第一个用户账号(也就是我自己)是 ``501``

    - 在安装 :ref:`macos` 的时候，我特意设置了第一个管理员账号为 ``admin`` (用户名依然是 ``Huatai Huang`` )，这样Host主机中我的用户目录就是 ``/Users/admin``
    - 在Colima中，Host主机的 ``/Users/admin`` 会被 ``bind`` 进虚拟机

    - 此时只要在 ``docker run`` 时候使用 ``-v /Users/admin:/home/admin`` 就能够完美将Host主机的用户目录映射进容器使用

  - 在Dockerfile中，使用的shell环境是 ``sh`` ，并且每一条命令都会启动一个 ``sh`` SHELL

    - 如果要在命令行读取环境变量，需要使用 ``RUN bash -c "source /home/admin/.bashrc && ..."``
    - 每个需要读取环境变量的 ``RUN`` 命令都要这样执行 ``source 配置文件``
    - 不能嵌套shell，例如很多程序有独立的SHELL配置文件，并且将这个配置文件通过在 ``~/.bashrc`` 添加引用来生效，这种嵌套在Dockerfile中不生效

      - 例如 :ref:`rvm` 在 ``~/.bashrc`` 中添加引用 ``. $HOME/.rvm/scripts/rvm`` ，在Dockerfile就不能通过 ``source /home/admin/.bashrc`` 生效
      - 需要直接引用最终配置文件，也就是 ``RUN bash -c 'source /home/admin/.rvm/scripts/rvm && ...'`` 才能生效

  - 所有使用GitHub仓库 ``git clone`` 都使用 ``https://`` 协议

    - 不需要本地具备GitHub仓库的SSH私钥就可以完成clone，通用性更好
    - GitHub仓库被GFW干扰: 当git使用operations over HTTP时，实际使用的是curl library，此时注入到Docker容器中的代理配置 ``http_proxy/https_proxy`` 生效就能正常工作

  - :ref:`nvim` 采用了 :ref:`nvim_ide` 配置，当容器内部第一次使用 ``vi`` 时会自动安装已经配置的插件，这个过程时间长度取决于网络(clangd下载特别耗时)

    - 在墙内安装有很大概率受到GFW影响很不稳定，所以建议在Colima虚拟机中启用 :ref:`ssh_tunneling` 共享给容器使用

- 构建 ``debian-dev`` 镜像:

.. literalinclude:: debian_tini_image/dev/build_debian-dev_image
   :language: bash
   :caption: 构建包含开发环境的debian镜像

- 运行 ``debian-dev`` :

.. literalinclude:: debian_tini_image/dev/run_debian-dev_container
   :language: bash
   :caption: 运行包含开发环境的debian容器

问题排查记录
==============

apt安装找不到软件包
----------------------

我在 ``amd64`` (x86_64)平台构建 ``debian-dev`` 成功，但是当我将同样的Dockerfile在 :ref:`install_docker_raspberry_pi_os` 却遇到无法安装 ``tini`` 报错:

.. literalinclude:: debian_tini_image/raspberry_pi_os_apt_error
   :caption: 在树莓派 Raspberry Pi OS上构建Docker镜像遇到无法找到软件包报错
   :emphasize-lines: 13,23

我最初以为是 :ref:`docker_proxy_quickstart` 设置代理网关错误(我确实错误设置了 ``127.0.0.1:3128`` ，正确应该是 ``172.17.0.1:3128`` )，但是实践发现即使修正了代理网关IP也同样报错。最后我发现，原来ARM版本的debian官方镜像似乎有仓库配置残留，在Dockerfile中添加 ``apt clean`` 步骤清理现场，然后执行升级和安装就能够正常工作。(已修正上文 ``debian-dev`` Dockerfile)

git下载出现curl报错"RPC failed; curl 18 Transferred a partial file"
----------------------------------------------------------------------

我在 :ref:`install_docker_raspberry_pi_os` 上执行构建(家里的网络远不如阿里云虚拟机公网)，反复出现curl报错:

.. literalinclude:: debian_tini_image/raspberry_pi_os_git_error
   :caption: ``git clone`` 时始终出现 "RPC failed; curl 18 Transferred a partial file" 错误
   :emphasize-lines: 5-9

注意，这里报错的 ``error: 1183 bytes of body are still expected`` 每次可能数值不同，看起来就是传输错误　

我尝试增加 ``git config --global http.proxy http://172.17.0.1:3128`` 这样可以确保 git 通过代理访问 HTTPS 来解决，但是我发现并没有解决上述报错。既然 git 在执行 operations over HTTP 实际使用的是curl库，所以我也尝试了 ``echo "proxy=172.17.0.1:3128" > /home/admin/.curlrc`` 来指定curl代理，但是此时报错:

.. literalinclude:: debian_tini_image/raspberry_pi_os_git_curl_error
   :caption: ``git clone`` 配置 ``~/.curlrc`` 指定代理，但是依然出现TLS报错，看起来是代理无法通过，还是代理问题
   :emphasize-lines: 8

参考 `Github - unexpected disconnect while reading sideband packet <https://stackoverflow.com/questions/66366582/github-unexpected-disconnect-while-reading-sideband-packet>`_ 提示是网络不稳定导致的，可以尝试:

.. literalinclude:: debian_tini_image/git_env
   :caption: 设置git环境变量跟踪错误

不过输出信息其实和之前报错是一样的

git ssh最终解决方法
~~~~~~~~~~~~~~~~~~~~~~

参考 `Error Cloning Repository: RPC Failed; curl 18 transfer closed with outstanding read data remaining #18972 <https://github.com/desktop/desktop/issues/18972>`_ : 使用 ssh 替代 https 来进行 git clone ，可以解决网络传输问题。(应该可行，因为GFW没有屏蔽github的SSH)就是需要在Dockerfile中复制一个本地专用于git的SSH密钥，导致Dockerfile通用性较差。

不过，也不是很顺利，原因是每次访问github的HOST主机密钥变化，需要默认接受，否则会报错:

.. literalinclude:: debian_tini_image/git_ssh_err
   :caption: 如果git没有默认接受github的主机ssh密钥，则会报错失败
   :emphasize-lines: 5-6

参考 `Git error: "Host Key Verification Failed" when connecting to remote repository <https://stackoverflow.com/questions/13363553/git-error-host-key-verification-failed-when-connecting-to-remote-repository>`_ 在执行git之前，首先添加github的主机密钥，避免脚本执行报错:

.. literalinclude:: debian_tini_image/ssh-keyscan
   :caption: 通过 ``ssh-keyscan`` 命令添加github主机认证密钥

另外一个要点是，用户git的私钥不能有密码保护(我通常个人使用都会给RAS密钥对的私钥加上密码)，否则也会报错: ``git@github.com: Permission denied (publickey).`` ，所以需要单独为git准备一个 **没有密码保护** 的RSA密钥对:

.. literalinclude:: ../../../infra_service/ssh/ssh_key/ssh-keygen
   :caption: 在当前目录下生成没有密码保护的密钥对(这样脚本执行时无需输入保护密码)

ARM版本 :ref:`nvim` 安装clangd LSP
------------------------------------

由于 LLVM clangd 没有在官方提供clangd的ARM64 for Linux，所以需要通过发行版安装 ``clangd`` 来实现 :ref:`nvim_clangd_arm` :

.. literalinclude:: ../../../linux/desktop/nvim/nvim_clangd_arm/clangd
   :caption: 通过安装发行版clangd解决debian ARM的NeoVim LSP

开发环境 ``debian-dev`` (ARM64版本)
========================================

.. note::

   实践在 :ref:`pi_5` 的环境中进行，为 :ref:`pi_soft_storage_cluster` 做准备

结合上述要点，参考 :ref:`git_ssh_script` 方法改进Dockerfile(不过由于SSH方法比较复杂，常规还是采用 git operations over HTTP，只有为了解决网络阻塞GFW的时候才使用SSH方法)，以下是完整Dockerfile:

.. literalinclude:: debian_tini_image/dev/Dockerfile.arm
   :language: dockerfile
   :caption: 包含常用工具和开发环境的debian镜像Dockerfile(为解决GFW干扰采用SSH方法)
   :emphasize-lines: 100-121

- 构建 ``acloud-dev`` 镜像:

.. literalinclude:: debian_tini_image/dev/build_acloud-dev_image
   :language: bash
   :caption: 构建包含开发环境的ARM环境debian镜像

- 运行 ``acloud-dev`` :

.. literalinclude:: debian_tini_image/dev/run_acloud-dev_container
   :language: bash
   :caption: 运行包含开发环境的ARM环境debian镜像

