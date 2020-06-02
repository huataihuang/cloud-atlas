.. _jdk8_on_macos:

====================
macOS上使用Java 8
====================

虽然Oracle依然免费提供最新版本的Java JDK，例如，当前JDK 14可以从Oracle官网下载。但是Oracle对于旧版本JDK，特别是当前企业大量使用的成熟版本的JDK 8是需要收费账号才可以下载使用。

开源的OpenJDK维护了不同版本的JDK，也包括了JDK 8。所以，如果你个人开发使用，可以使用OpenJDK来代替Oracle的JDK。

在macOS平台，可以通过 :ref:`homebrew` 来完成Java不同版本的安装。但是需要注意，虽然我们可以通过 ``brew cask install java`` 安装JDK，但是默认安装的是最新版本 JDK 14，所以我们需要通过以下方式使用 `AdoptOpenJDK <https://adoptopenjdk.net/>`_ 提供了旧版本，如Java 8::

   brew tap adoptopenjdk/openjdk
   brew cask install adoptopenjdk8

如果出现 ``Error: Cask adoptopenjdk8 exists in multiple taps`` 报错提示，则需要使用完整路径指定安装::

   brew cask install adoptopenjdk/openjdk/adoptopenjdk8

上述方法甚至可以安装不同版本JDK::

   brew tap adoptopenjdk/openjdk

   brew cask install adoptopenjdk8
   brew cask install adoptopenjdk9
   brew cask install adoptopenjdk10
   brew cask install adoptopenjdk11

通过Docker运行JDK8
====================

此外可以通过 :ref:`docker` 获取官方提供的旧版本JDK容器，好处是不需要手工安装JDK并保持了主机的简洁，而且可以通过切换容器来切换Java版本。

- 创建 `Dockerfile` ::

   FROM java:8
   COPY . /usr/src/myapp
   WORKDIR /usr/src/myapp

- 创建 `docker-compose.yml` 文件::

   version: "2"

   services:
     java:
       build: .
       volumes:
         - .:/usr/src/myapp

- 然后我们编辑一个java程序文件::

   public class HelloWorld {
       public static void main(String[] args) {        
           System.out.println("Hello, World");
       }
   }

- 编译java::

   docker-compose run --rm java javac HelloWorld.java 

- 然后我们就可以运行了::

   docker-compose run --rm java java HelloWorld 

jenv管理多个Java版本
=======================

要管理多个JDK版本可以使用jevn::


   brew install jenv
   echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bash_profile
   echo 'eval "$(jenv init -)"' >> ~/.bash_profile
   source ~/.bash_profile

然后将安装的java添加到jenv::

   jenv add /Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home
   jenv add /Library/Java/JavaVirtualMachines/jdk1.11.0_2.jdk/Contents/Home

则可以查看所有安装的java::

   jenv versions

可以配置使用的java版本::

   jenv global oracle64-1.6.0.39

设置 JAVA_HOME ::

   jenv enable-plugin export


.. note::

   安装的JDK版本位于 ``/Library/Java/JavaVirtualMachines``

参考
=======

- `Installing a Java 8 JDK on OS X using Homebrew <http://www.lonecpluspluscoder.com/2017/04/27/installing-java-8-jdk-os-x-using-homebrew/>`_
- `How to install Java 8 on Mac <https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac>`_
