.. _gopath:

===============
$GOPATH 配置
===============

当你在非默认 ``$GOPATH`` 目录下存放Go代码，使用 :ref:`my_vimrc` 这样支持GO的编辑器编辑时，会出现类似以下错误提示::

   could not import github.com/xxx/yyy (cannot find package "github.com/xxx/yyy" in any of ...

这是因为在 Go 1.11之前，所有项目都在 ``$GOPATH`` 下创建，这样Go编译器就会搜索到依赖并构建Go应用程序。这里 ``$GOPATH`` 包含了源代码和二进制程序:

- ``$GOPATH/src`` - 所有源代码
- ``$GOPATH/pkg`` - Go内部使用的运行自身的包
- ``$GOPATH/bin`` - 包含执行程序

.. _go_modules:

Go Modules
============

从 Go 1.11之后，Go Modules可以在 ``$GOPATH`` 之外创建项目，并且导入包管理

在没有Go Modules之前的缺点:

- 没有Go Modules情况下，就会被迫把所有项目存放到单一的目录 ``$GOPATH``
- 不支持Go packages版本，不允许在 ``package.json`` 指定Go package的特定版本，也就是不能使用相同包的不同版本
- 所有扩展包被存放在一个 vender 目录并推送到服务器

Go Module提供了:

- 模块是相关 Go 包的集合，它们作为一个单元一起进行版本控制。
- 模块记录精确的依赖需求并创建可重现的构建。

操作
======

- 这里我是在学习 「Go in Action」的案例代码:

.. literalinclude:: gopath/main.go
   :language: golang
   :caption: modules import 扩展包

- 执行以下命令按照 ``github.com/{your_username}/{repo_name}`` 来创建一个 ``go.mod`` 文件::

   go mod init github.com/huataihuang/etudes

提示信息::

   go: creating new go.mod: module github.com/huataihuang/etudes
   go: to add module requirements and sums:
           go mod tidy

此时会在当前目录下生成一个 ``go.mod`` 文件内容如下:

.. literalinclude:: gopath/go.mod
   :language: golang
   :caption: go.mod

- 执行::

   go build

提示信息::

   main.go:7:2: no required module provides package github.com/goinaction/code/chapter2/sample/matchers; to add it:
           go get github.com/goinaction/code/chapter2/sample/matchers
   main.go:8:2: no required module provides package github.com/goinaction/code/chapter2/sample/search; to add it:
           go get github.com/goinaction/code/chapter2/sample/search

该怎么解决呢？

- ``go mod tidy`` 也即是前面 ``go mod init`` 初始化仓库的命令返回的提示，这个命令会帮助移除不需要的依赖， ``go build`` 只会更新依赖但不会触碰不需要的依赖。 ``tidy`` 会帮助你做清理::

   go mod tidy

执行了上述命令后，提示信息::

   go: finding module for package github.com/goinaction/code/chapter2/sample/search
   go: finding module for package github.com/goinaction/code/chapter2/sample/matchers
   go: downloading github.com/goinaction/code v0.0.0-20171020164608-49fc99e6affb
   go: found github.com/goinaction/code/chapter2/sample/matchers in github.com/goinaction/code v0.0.0-20171020164608-49fc99e6affb
   go: found github.com/goinaction/code/chapter2/sample/search in github.com/goinaction/code v0.0.0-20171020164608-49fc99e6affb

此时会看到当前目录下多了一个 ``go.sum`` 内容是::

   github.com/goinaction/code v0.0.0-20171020164608-49fc99e6affb h1:xpDeYJF7P9jgczf4KjRQOoqPrrKs56vqMBiWOXnSoQM=
   github.com/goinaction/code v0.0.0-20171020164608-49fc99e6affb/go.mod h1:3NRM3Fi26eZwRU/33Y0fH7YaVlo6EDQUAE2CBQ/snQ0=

而且 ``go.mod`` 内容最后添加了一行::

   require github.com/goinaction/code v0.0.0-20171020164608-49fc99e6affb

此时完整的 ``go.mod`` 内容如下:

.. literalinclude:: gopath/go-tidy.mod
   :language: golang
   :caption: 执行了go mod tidy命令之后的go.mod

``到这个步骤时，已经完成了非 $GOPATH 目录下项目的部署准备`` ，也即是此时再次执行 ``build`` 将不会报错::

   go build

Go将在当前项目目录下进行编译，并生成执行文件 ``etudes`` (也就是前面我们指定的项目名字repo_name ``github.com/{your_username}/{repo_name}`` )

注意，执行了 ``go mod tidy`` 命令之后，go会下载好依赖包并配置完module，所以此时在我前文说的 ``vim`` 编辑Go代码时候，不会再报错提示无法加载 ``could not import github.com/xxx/yyy (cannot find package "github.com/xxx/yyy" in any of ...``

- 如果还有 ``vendor`` 目录，则对应运行::

   go mod vendor

和 ``go mod tidy`` 类似，会自动下载所有依赖，并存放到项目目录的 ``/vendor`` 目录，解决依赖

总结
=======

- Go 1.11 之前，所有项目都必须存放在 ``$GOPATH`` 目录下
- Go 1.11 之后，项目可以存放在其他目录目录下，但是需要初始化项目module ::

   go mod init github.com/{your_username}/{repo_name}
   go mod tidy
   go mod vendor

此时Go会在当前项目目录下下载依赖package，并配置好 ``go.mod`` 和 ``go.sum`` 指向对应依赖package

- 接下来就可以按正常流程执行程序编译::

   go build

参考
======

- `Create projects independent of $GOPATH using Go Modules <https://medium.com/mindorks/create-projects-independent-of-gopath-using-go-modules-802260cdfb51>`_
