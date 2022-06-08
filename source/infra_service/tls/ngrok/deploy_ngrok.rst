.. _deploy_ngrok:

==================
Ngrok部署
==================

Ngrok官方提供了非常方便的安装步骤:

- 注册一个登陆账号
- 注册后平台会发送一个邮件给你的注册邮箱，从这个邮件中链接激活注册账号
- 登陆Ngrok的dashboard，默认引导到安装界面完成安装步骤

安装
======

- 按照需要公布到internet上的主机的架构选择客户端安装包，支持 :ref:`macos` / :ref:`linux` / :ref:`windows` / :ref:`freebsd` 操作系统，并且同时支持 X96 和 :ref:`arm` 两种硬件架构

我在 :ref:`edge_cloud_infra` 采用 :ref:`raspberry_pi` 部署 :ref:`k3s` ，所以在ARM架构上运行Ngrok输出对外服务，首先输出的是 :ref:`ssh`

- 解压缩下载的ngrok for ARM64::

   tar xfz ngrok-v3-stable-linux-arm64.tgz

解压以后获得 ``ngrok`` 执行程序，将这个程序(Go执行程序)移动到执行目录下::

   sudo mv ngrok /usr/bin/

- 根据提示，首先需要将认证token添加到默认 ``ngrok.yml`` 配置文件中，这个步骤可以通过以下命令完成::

   ngrok config add-authtoken <TOKEN>

- 检查帮助::

   ngrok help

可以看到非常简洁的使用帮助

- 注册输出SSH服务::

   ngrok tcp 22

则会在本地终端输出所有相关访问配置信息::

   ngrok                                                         (Ctrl+C to quit)
   
   Hello World! https://ngrok.com/next-generation
   
   Session Status                online
   Account                       <YourName> (Plan: Free)
   Version                       3.0.4
   Region                        Japan (jp)
   Latency                       41ms
   Web Interface                 http://127.0.0.1:4040
   Forwarding                    tcp://<ngrok_server_ip>:<ngrok_server_port> -> localhost:22
   
   Connections                   ttl     opn     rt1     rt5     p50     p90
                                 64      1       0.00    0.00    0.08    0.50

根据提示，你可以看到本地主机服务已经注册到Internet上Ngork提供的服务IP和端口上: ``tcp://<ngrok_server_ip>:<ngrok_server_port>`` ，所以只需要简单在自己的 :ref:`ssh` 访问配置 ``~/.ssh/config`` 添加::

   Host myserver
       HostName <ngrok_server_ip>
       Port <ngrok_server_port>

就可以通过 ``ssh myserver`` 从Internet访问自己在家里的内网服务器SSH登陆，也就是可以随时随地开发运维。
