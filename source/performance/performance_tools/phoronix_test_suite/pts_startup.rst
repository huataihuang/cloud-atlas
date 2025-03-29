.. _pts_startup:

===============================
Phoronix Test Suite快速起步
===============================

`Phoronix Test Suite性能测试组件 <https://www.phoronix-test-suite.com/>`_ 是一个基于PHP的测试工具，只需要系统安装了PHP就能够完成整个测试，可以用来对比性能。针对Linux,Solaris,macOS,Windows以及BSD系统，提供了复杂测试和benchmarking平台。所有的测试都是可重现，易于使用以及支持全自动执行。Phoronix Test Suite是遵循GNU GPLv3 开源软件。

Phoronix Test Suite自身是一个开源框架，将众多工具进程进测试，能够根据系统自动安装软件进行测试。这个测试框架设计成一个可扩展架构，所以新的测试方式以及给偶那句能够方便地加入和执行性能测试，但愿测试，以及其他质量相关验证(如镜像质量对比和验证是否通过)。

通过 :ref:`openpenchmarking` 提供的众多测试方案，其中有200多个测试套件被集成到Phoronix Test Suite的默认配置。

安装
=========

- 环境准备::

   sudo apt install -y php7.4-cli php7.4-xml

- 下载测试组件::

   curl -LO https://phoronix-test-suite.com/releases/phoronix-test-suite-10.8.3.tar.gz
   tar -xvf phoronix-test-suite-10.8.3.tar.gz
   cd phoronix-test-suite

- 完成安装::

   ./phoronix-test-suite system-info <<-END
   y
   n
   n
   END

使用
=====

- 列出建议测试项::

   ./phoronix-test-suite list-recommended-tests

- 测试需要root权限，建议不要在系统目录完成测试::

   PHORONIX_CONFIG_PATH="/var/lib/phoronix-test-suite"
   sudo mkdir -p $PHORONIX_CONFIG_PATH/test-suites/local/raspberrypi

- 创建配置文件::

   tee suite-definition.xml <<EOF
   <?xml version="1.0"?>
   <!--Phoronix Test Suite v9.6.1-->
   <PhoronixTestSuite>
     <SuiteInformation>
       <Title>RaspberryPi</Title>
       <Version>1.0.0</Version>
       <TestType>System</TestType>
       <Description>General system tests for the Raspberry Pi.</Description>
       <Maintainer>Jeff Geerling</Maintainer>
     </SuiteInformation>
     <Execute>
       <Test>pts/encode-mp3</Test>
     </Execute>
     <Execute>
       <Test>pts/x264</Test>
     </Execute>
     <Execute>
       <Test>pts/phpbench</Test>
     </Execute>
   </PhoronixTestSuite>
   EOF   

   sudo mv suite-definition.xml $PHORONIX_CONFIG_PATH/test-suites/local/raspberrypi/

- 执行::

   sudo ./phoronix-test-suite benchmark raspberrypi

上述测试配置虽然只测试3个项目，但是也需要下载大量文件::

   4 Tests To Install
       5 Files To Download [723MB]
       2606MB Of Disk Space Is Needed
       2 Minutes, 21 Seconds Estimated Install Time

参考
======

- `geerlingguy/pi-general-benchmark.sh <https://gist.github.com/geerlingguy/570e13f4f81a40a5395688667b1f79af>`_ geerlingguy的树莓派测试脚本，采用Phoronix Test Suite
- `GitHub phoronix-test-suite <https://github.com/phoronix-test-suite/phoronix-test-suite/>`_
