.. _terraform_aliyun_demo:

=====================
阿里云Terraform Demo
=====================

所有的语言描述不如实际操作 -- 很多Terraform的Hello World案例都是基于AWS的（毕竟云计算的No.1），然而，作为国内云厂商No.1，阿里云同样也提供了Terraform支持。

.. note::

   本章节我们来演示如何从0开始在阿里云上运行Hello World Demo。

Provider
==========

Provider是Terraform的基础设施后端驱动，也就是对应每个云计算厂商，包含资源元数据定义，上层请求的处理和后端OpenAPI的调用和响应处理。Terraform调用不同的Provider来完成不同类型资源的同意管理。阿里云的Provider名为 ``alicloud`` 。

Provider不需要手工安装，Terraform会在 ``init`` 阶段根据模板地影自动夹在，即关键字 ``provider`` 声明::

   provider "alicloud" {
       profile = "terraform"
       region = "cn-hangzhou"
   }
   
.. note::

   - ``provider`` 指定需要插件``alicloud``
   - 大括号中配置提供了Provider的配置
     - ``profile`` 表示可以从阿里云帐号 ``~/.aliyun/config.json`` 中名为 ``terraform`` 的配置信息中读取
     - ``region`` 则定义资源创建在杭州区域

阿里云帐号
===========

阿里云CLI
------------

安装参考 `Linux平台 <https://help.aliyun.com/document_detail/121541.html?spm=a2c4g.11186623.6.546.48606bbbqRbbXI>`_ 或 `MacOS平台 <https://help.aliyun.com/document_detail/121544.html?spm=a2c4g.11186623.6.547.3dd66bbbzC6PGx>`_ 从 `aliyun-cli Releases <https://github.com/aliyun/aliyun-cli/releases?spm=a2c4g.11186623.2.13.121d6bbb4P8wxK>`_ 安装阿里云CLI（以下案例为Linux）::

   # 假设下载文件在 ~/Download 目录下
   cd  $HOME/Download
   tar xfz aliyun-cli-linux-3.0.30-amd64.tgz
   sudo mv aliyun /usr/local/bin

AK
----

请参考 `配置阿里云CLI > 配置凭证 > 非交互式配置 <https://help.aliyun.com/document_detail/121259.html?spm=a2c4g.11186623.6.554.30166e7fuh0o4s>`_ 帮助文档配置阿里云访问凭证(案例是AK)::

   aliyun configure set \
     --profile terraform \
     --mode AK \
     --region cn-hangzhou \
     --access-key-id AccessKeyId \
     --access-key-secret AccessKeySecret

上述命令将在 ``~/.aliyun`` 目录下创建AK配置文件 ``config.json``

.. note::

   这里传递的参数 ``--profile terraform`` 表示在AK配置文件中添加名为 ``terraform`` 的profile

部署简单服务器
================

初始化Terraform
----------------

Terraform代码使用了 HashiCorp Configuration Language(HCL)，代码文件扩展名为 ``.tf`` ，在一个空目录(假设我创建了一个目录 ``terraform-demo`` 下创建一个 ``main.tf`` 文件作为主程序::

   provider "alicloud" {
       profile = "terraform"
       region = "cn-hangzhou"
   }
   
然后执行以下命令初始化::

   terraform init

此时会看到Terraform开始下载名为 ``aliclouod`` 的provider插件

定义资源
---------

resource是Terraform中特定基础设置资源，通过 create, update, read, delete 方法的实现来管理特定资源的生命周期。

在上述 ``main.tf`` 中添加::

   resource "alicloud_instance" "default" {
      image_id = "centos_7_7_64_20G_alibase_20191008.vhd"
      instance_type = "ecs.t6-c4m1.large"
      instance_name = "terraform-demo"
   }

.. note::

   阿里云ECS的规格价格差异很大，作为学习和验证，请在ECS的控制台先交互选择合适规格再使用Terraform对应创建，以节约使用费用。这里选择价格低廉的入门级(共享)实例 ``ecs.t6-c4m1.large`` 。

计划Plan
-----------

在完成基础配置之后，通过 ``terraform plan`` 命令可以预览代码执行效果，调试是否存在问题。

例如，上述 ``resource`` 配置，对应执行 ``terraform plan`` 会提示还缺少必要参数::

   Error: Missing required argument
   
      on main.tf line 6, in resource "alicloud_instance" "default":
       6: resource "alicloud_instance" "default" {

   The argument "security_groups" is required, but no definition was found.

所以，我从交互方式创建的ECS实例获取安全组名称，假设名字是 ``sg-bp1ceir9l2mgph4bp5kx`` ，所以修改上述配置，添加内容::

   security_groups = ["sg-bp1ceir9l2mgph4bp5kx"]

.. note::

   安全组可以通过Terraform来创建，后续补充。初始时，你可以通过ECS的WEB管控台先构建一个安全组，然后把该安全组作为实验使用。

   安全组是一个字符串集，所以需要使用 ``[]`` 括起一个或多个安全组字符串。

现在我们再次执行 ``terraform plan`` 命令，不再报错，表明已经就绪，可以执行了::

   terraform will perform the following actions:
   
     # alicloud_instance.default will be created
     + resource "alicloud_instance" "default" {
         + availability_zone          = (known after apply)
         + credit_specification       = (known after apply)
         + deletion_protection        = false
         + dry_run                    = false
         + host_name                  = (known after apply)
         + id                         = (known after apply)
         + image_id                   = "centos_7_7_64_20G_alibase_20191008.vhd"
         + instance_charge_type       = "PostPaid"
         + instance_name              = "terraform-demo"
         + instance_type              = "ecs.t6-c4m1.large"
         + internet_max_bandwidth_in  = (known after apply)
         + internet_max_bandwidth_out = 0
         + key_name                   = (known after apply)
         + private_ip                 = (known after apply)
         + public_ip                  = (known after apply)
         + role_name                  = (known after apply)
         + security_groups            = [
             + "sg-bp1ceir9l2mgph4bp5kx",
           ]
         + spot_strategy              = "NoSpot"
         + status                     = (known after apply)
         + subnet_id                  = (known after apply)
         + system_disk_category       = "cloud_efficiency"
         + system_disk_size           = 40
         + volume_tags                = (known after apply)
       }

apply执行
-----------

执行一下命令运行Terraform计划::

   terraform apply

好吧，实际上云计算资源还要再复杂一点，此时提示创建失败::

   alicloud_instance.default: Creating...
   
   Error: [ERROR] terraform-provider-alicloud/alicloud/resource_alicloud_instance.go:373:
   [ERROR] terraform-provider-alicloud/alicloud/resource_alicloud_instance.go:844:
   The specified security_group_id sg-bp1ceir9l2mgph4bp5kx is in a VPC vpc-bp1kvl6pjf6wzwpifhcig, and `vswitch_id` is required when creating a new instance resource in a VPC.
   
     on main.tf line 6, in resource "alicloud_instance" "default":
      6: resource "alicloud_instance" "default" {

原因是VPC创建缺少相关信息 ``vswitch_id`` ，我这里再次使用通过WEB管理界面创建一个实例，然后检查样例所使用的vswitch信息，这样得到配置，在资源配置中添加::

   vswitch_id = "vsw-bp15z1k91emrdg2pqqkuo"

这样综上所述，较为完整的配置 ``main.cf`` 内容如下::

   provider "alicloud" {
       profile = "terraform"
       region = "cn-hangzhou"
   }
   
   resource "alicloud_instance" "default" {
      image_id = "centos_7_7_64_20G_alibase_20191008.vhd"
      instance_type = "ecs.t6-c4m1.large"
      instance_name = "terraform-demo"
      security_groups = ["sg-bp1ceir9l2mgph4bp5kx"]
      vswitch_id = "vsw-bp15z1k91emrdg2pqqkuo"
   }

现在我们执行 ``terraform apply`` 则提示创建实例::

   alicloud_instance.default: Creating...
   alicloud_instance.default: Still creating... [10s elapsed]
   alicloud_instance.default: Creation complete after 17s [id=i-bp1f6ny09icnetnvui0n]
   
   Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

现在登陆ECS console检查可以看到刚刚创建的实例 ``i-bp1f6ny09icnetnvui0n`` ，注意，这个实例只是简单默认配置：

- 单网卡，无公网IP地址
- 没有必要的配置，例如帐号

但我们至少已经创建了一个实例，可以开始进一步探索了。

参考
=======

- `Terraform 一分钟部署阿里云ECS集群（含视频） <https://developer.aliyun.com/article/720999?spm=a2c6h.12873581.0.0.31631f1e18J5nN&groupCode=openapi>`_
