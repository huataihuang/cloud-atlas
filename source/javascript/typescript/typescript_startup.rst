.. _typescript_startup:

========================
TypeScript起步
========================

TypeScript和JavaScript关系
============================

- TypeScript源码编译输出的是JavaScript源码，在编译阶段的AST(抽象句法树, abstract syntax tree, AST)会进行类型检查:

  - TypeScript源码 -> typeScript AST
  - 类型检查器检查AST
  - TypeScript AST -> JavaScript源码

代码编辑器设置
=================

案例使用 :ref:`vscode`

- 初始化NPM项目, 安装 TSC, TSLint 和 NodeJS的类型声明:

.. literalinclude:: typescript_startup/npm_init_typescript
   :language: bash
   :caption: 初始化NPM项目，安装 TSC, TSLint 和 NodeJS的类型声明

这里会有一个WARNING，原因是TSLint将被ESLint取代，不过我目前学习过程暂时忽略::

   npm WARN deprecated tslint@6.1.3: TSLint has been deprecated in favor of ESLint. Please see https://github.com/palantir/tslint/issues/4534 for more information.
   
   added 43 packages, and audited 44 packages in 13s
   
   5 packages are looking for funding
     run `npm fund` for details
   
   found 0 vulnerabilities 

``npm init`` 和 ``npm install``  之后，目录下有一个 ``package.json`` 文件包含了依赖组件版本信息；在 ``node_modules`` 子目录下包含了安装的所有软件包

- 在目录下创建一个 ``tsconfig.json`` 文件:

.. literalinclude:: typescript_startup/tsc_init_tsconfig.json
   :caption: 使用  ./node_modules/.bin/tsc --init 命令生成初始的 tsconfig.json

在默认的配置文件中增加配置 ``outDir`` 指定TypeScript编译输出的 :ref:`javascript` 文件存放到独立的 ``dist`` 子目录，这样可以和源代码 ``src`` 目录区分开(如果没有这个配置默认ts和js在同一个目录并且只有文件名后缀区别):

.. literalinclude:: typescript_startup/tsconfig.json
   :language: json
   :caption: 使用  ./node_modules/.bin/tsc --init 命令生成初始的 tsconfig.json的内容
   :emphasize-lines: 15

这个 ``tsconfig.json`` 创建可以手工编辑，也可以直接使用 ``./node_modules/.bin/tsc --init`` 生成，具体内容可以参考自动生成文件的注释

- 在目录下创建 ``tslint.json`` 文件:

.. literalinclude:: typescript_startup/tslint_init_tslint.json
   :caption: 使用  ./node_modules/.bin/tslint --init 命令生成初始的 tslint.json

默认生成内容:

.. literalinclude:: typescript_startup/tslint.json
   :language: json
   :caption: 使用  ./node_modules/.bin/tslint --init 命令生成初始的 tslint.json

- 创建源代码目录 ``src`` ，并在该目录下生成一个简单的 TypeScript 代码 ``index.ts`` :

.. literalinclude:: typescript_startup/generate_index.ts
   :language: typescript
   :caption: 创建源代码目录src并构建一个简单的初始代码 src/index.ts

- 编译并运行TypeScript代码( ``tsc`` 生成js代码， ``node`` 运行js代码 ):

.. literalinclude:: typescript_startup/tsc_node_typescript
   :language: bash
   :caption: tsc编译生成js代码，node运行生成的js代码

一切正常的话，在终端会看到输出::

   Hello TypeScript!

对比一下生成的 ``dist/index.js`` :

.. literalinclude:: typescript_startup/index.js
   :language: typescript
   :caption: 创建源代码目录src并构建一个简单的初始代码 src/index.ts

可以看出 ``TypeScript`` 不使用 JavaScript的 ``;`` 结尾的语法

一些尝试
===========

- 参考 O'REILLY 《TypeScript编程》的案例，可以将上文的 ``src/index.js`` 修改成:

.. literalinclude:: typescript_startup/more_index.ts
   :language: typescript
   :caption: 修改 src/index.ts 加一些计算功能




参考
======

- O'REILLY 《TypeScript编程》
