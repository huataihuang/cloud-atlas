.. _multi_jdk_on_macos:

=========================
macOS上使用多个JDK版本
=========================

虽然Oracle依然免费提供最新版本的Java JDK，例如，当前JDK 14可以从Oracle官网下载。但是Oracle对于旧版本JDK，特别是当前企业大量使用的成熟版本的JDK 8是需要收费账号才可以下载使用。

.. note::

   使用Oracle官方提供的JDK软件安装包安装JDK之后，如果要切换到社区维护的不同JDK版本，则需要先卸载Oracle Java。不过卸载方法有些复杂。我以前的一些实践记录 `在Mac OS X上安装Java多个版本 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/mac/multiple_versions_java_in_os_x.md>`_`

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

安装的jdk8，位于 ``/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/bin/java``

安装了多个版本jdk，可以通过 ``jenv`` 管理版本::

   brew install jenv

然后设置 ``~/.zshrc`` ::

   export PATH="$HOME/.jenv/bin:$PATH"
   eval "$(jenv init -)"

然后设置版本::

   jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home

此时提示::

   openjdk64-1.8.0.252 added
   1.8.0.252 added
   1.8 added

例如，再添加jdk 14::

   jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home

然后就可以通过 ``/usr/libexec/java_home -verbose`` 检查系统安装的JDK版本::

   Matching Java Virtual Machines (2):
       14.0.1, x86_64:"AdoptOpenJDK 14": /Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home
       1.8.0_252, x86_64:"AdoptOpenJDK 8": /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home

可以看到现在的java位置 ``which java`` 显示是 ``/Users/huatai/.jenv/shims/java`` ，当前的 ``java -version`` 输出就是::

   openjdk version "14.0.1" 2020-04-14
   OpenJDK Runtime Environment AdoptOpenJDK (build 14.0.1+7)
   OpenJDK 64-Bit Server VM AdoptOpenJDK (build 14.0.1+7, mixed mode, sharing)

- 检查当前已经添加的Java版本::

   jenv versions

jenv使用
---------

.. note::

   对于开发者来说，系统中需要安装多个JDK版本进行兼容性验证。部分开发项目需要指定特定的JDK版本运行，每次手工切换实在是非常麻烦。

   jenv 提供了一个非常灵活便捷的设置方式，只需要在执行目录下存放一个 ``.java-version`` 文件配置了Java版本，则进入该目录运行Java程序就会以指定的Java版本运行。

有两种jenv版本设置方式，一种是当前工作目录的本地Java版本，将在当前目录下创建一个 ``.java-version`` 文件，这个文件可以添加到项目的git仓库中。 ``jenv`` 可以在当前目录下启动shell时正确加载java版本::

   jenv local 1.8
   exec $SHELL -l
   cat .java-version

此时显示 ``.java-version`` 内容是 ``1.8`` ，我们现在来验证一下::

   java -version

则显示输出::

   openjdk version "1.8.0_252"
   OpenJDK Runtime Environment (AdoptOpenJDK)(build 1.8.0_252-b09)
   OpenJDK 64-Bit Server VM (AdoptOpenJDK)(build 25.252-b09, mixed mode)

而没有设置 jenv local 的全局版本显示 ``java -version`` 输出为::

   openjdk version "14.0.1" 2020-04-14
   OpenJDK Runtime Environment AdoptOpenJDK (build 14.0.1+7)
   OpenJDK 64-Bit Server VM AdoptOpenJDK (build 14.0.1+7, mixed mode, sharing)

上述设置只要是环境shell中初始化了jenv，则只要进入设置了 ``.java-version`` 的程序目录，则 ``java -version`` 自动会切换到指定Java版本，非常方便。

对于全局性Java版本，则使用::

   jenv global 14

这样通常情况下就会使用JDK 14来运行程序。

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

参考
=======

- `Installing a Java 8 JDK on OS X using Homebrew <http://www.lonecpluspluscoder.com/2017/04/27/installing-java-8-jdk-os-x-using-homebrew/>`_
- `How to install Java 8 on Mac <https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac>`_
- `jenv README.md <https://github.com/jenv/jenv/blob/master/README.md>`_
- 我以前的一些实践记录 `在Mac OS X上安装Java多个版本 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/mac/multiple_versions_java_in_os_x.md>`_`
