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

.. literalinclude:: ../colima_proxy/build_err
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

开发环境 ``debian-dev``
===============================

在 ``debian-ssh-tini`` 基础上，增加开发工具包安装:

- ``debian-dev`` 包含了安装常用工具和开发环境:

.. literalinclude:: debian_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 包含常用工具和开发环境的debian镜像Dockerfile
   :emphasize-lines: 13

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

结合上述要点，参考 :ref:`git_ssh_script` 方法改进Dockerfile(不过由于SSH方法比较复杂，常规还是采用 git operations over HTTP，只有为了解决网络阻塞GFW的时候才使用SSH方法)，以下是完整Dockerfile:

.. literalinclude:: debian_tini_image/dev/Dockerfile.ssh
   :language: dockerfile
   :caption: 包含常用工具和开发环境的debian镜像Dockerfile(为解决GFW干扰采用SSH方法)
   :emphasize-lines: 100-114

