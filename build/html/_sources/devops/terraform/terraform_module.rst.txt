.. _terraform_module:

=====================
Terraform Module
=====================

.. note::

   当前对Terraform学习阶段，摘抄阿里云的文档，后续再重写实践笔记

Terraform Module是Terraform模板，对多个子节点，子资源，子架构模板的组合和抽象。

随着架构的不断扩展和复杂，Terraform模板所采用的Resource和DataSource也不断增加，模板编写的复杂度不断增加。为了能够使Terraform模板更加简单和重用，引入Module来简化Terraform的模板。

编写规则
==========

模板的编方法
---------------

- 将所有Resource放到一个模板中统一管理

所有资源在一个模板中管理，编写时就容易搞清楚资源之间的引用关系

- 分类管理，将目录作为单元化资源

很多资源是有层级关系的，但有些资源和其他资源又没有直接关联关系。所以，为了架构逻辑清晰，可以采用类似目录树的方式，对资源进行分类，将每一类资源用一个单独的目录进行管理，最后用一个模板来管理所有目录，进而完成对所有资源和资源关系的串联。

案例 - 资源分为网络（VPC），负载均衡（SLB），计算（ECS），数据库（RDS）和存储（OSS）::

   ├── main.tf
   ├── variables.tf
   ├── outputs.tf
   ├── modules/
   │   ├── vpc/
   │   │   ├── variables.tf
   │   │   ├── main.tf
   │   │   ├── outputs.tf
   │   ├── slb/
   │   │   ├── variables.tf
   │   │   ├── main.tf
   │   │   ├── outputs.tf
   │   ├── ecs/
   │   ├── rds/
   │   ├── oss/

然后使用统一的模板 ``main.tf`` 将这些目录关联::

   // VPC module
   module "vpc" {
     source = "./modules/vpc"
     name = "new-netwtok"
     ...
   }
   // Web Tier module
   module "web" {
     source = "./modules/ecs"
     instance_count = 2
     vswitch_ids = "${module.vpc.this_vswitch_ids}"
     ...
   }
   // Web App module
   module "app" {
     source = "./modules/ecs"
     instance_count = 2
     vswitch_ids = "${module.vpc.this_vswitch_ids}"
     ...
   }
   // SLB module(intranet)
   module "slb" {
     source = "./modules/slb"
     name = "slb-internal"
     vswitch_id = "${module.vpc.this_vswitch_ids.0.id}"
     instances = "${concat(module.web.instance_ids, module.app.instance_ids,)}"
     ...
   }
   // SLB module(internet)
   module "slb" {
     source = "./modules/slb"
     name = "slb-external"
     internet = true
     instances = "${module.web.instance_ids}"
     ...
   }
   // RDS module
   module "oss" {
     source = "./modules/rds"
     name = "new-rds"
     ...
   }
   // OSS module
   module "oss" {
     source = "./modules/oss"
     name = "new-bucket"
     ...
   }

在上述 ``main.tf`` 中采用了 ``module`` ，通过 ``module`` 将资源目录联系起来。

Module概念
=============

Module 是 Terraform 为了管理单元化资源而设计的，是子节点，子资源，子架构模板的整合和抽象。

`Terraform官方文档 - Modules <https://www.terraform.io/docs/configuration/modules.html>`_ 定义：将多种可以复用的资源定义为一个module，通过对module的管理简化模板的架构，降低模板管理的复杂度。

对开发者和用户而言，只需关心 module 的 input 参数即可，无需关心module中资源的定义，参数，语法等细节问题，抽出更多的时间和精力投入到架构设计和资源关系整合上。

Terraform提供了 `Terraform Registry <https://registry.terraform.io/>`_ 作为Terraform Modules注册，将自己开发的module上传到Github，并注册为Terraform Module之后，就可以将远端的Module应用到模板中。

.. note::

   我的理解和比喻，module就好像是js仓库，只要引用了某个module，你编写的模板就可以包含这部分功能，不需要自己再重复编写。

案例参考
===========

.. note::

   `【最佳实践】通过Terraform 管理OSS资源 <https://yq.aliyun.com/articles/674174?spm=a2c4e.11153940.0.0.3a471970fBdKAn>`_ 提供了一个很好的起点，可以模仿其配置结构。

   `利用Packer和Terraform，一键创建即拿即用的迷你并行计算集群 <https://yq.aliyun.com/articles/657716?spm=a2c4e.11153940.0.0.3a471970fBdKAn>`_ 也提供了一个批量创建小型集群的案例。

   `Terraform Module 编写指南 <https://yq.aliyun.com/articles/642624?spm=a2c4e.11153940.0.0.131a702278ND5o>`_ 详细介绍了如何编写和注册Module的方法，本文将参考实践。

创建Module的GitHub仓库
=======================

在Terraform官方 `Terraform Registry <https://registry.terraform.io/>`_ 注册module，之支持GitHub仓库，所以首先创建一个GitHub仓库：

- 仓库必须是Public
- 仓库名必须符合格式: ``terraform-<PROVIDER>-<NAME>`` ，我创建了一个 `terraform-alicloud-gluster <https://github.com/huataihuang/terraform-alicloud-gluster>`_

编写Module
============

- 将仓库clone出来::

   git clone git@github.com:huataihuang/terraform-alicloud-gluster.git

- Terraform官方提供了一个 `Terraform Standard Module Structure <https://www.terraform.io/docs/modules/index.html#standard-module-structure>`_ 指南，建议参考构建自己的module

编写原则
------------

- 每个Module不宜包含过多的资源，要尽可能只包含同一产品的相关资源，这样带来的好处是Module的复杂度不高，便于维护和阅读
- 对于统一产品的不同资源，应该分别放在不同的子module中，然后在最外层的main.tf中组织所有的子资源
- 每个module要尽可能单元化，以便可以在实际使用过程中自由添加和删除而不影响其他resource

module结构
-------------

- main.tf

每个module都有一个用于存放resource 和 datasource 的main.tf 。resource和datasource的参数禁止使用硬编码，必须通过变量进行引用。

- variables.tf

每个变量都要添加该参数对应的描述信息，这个信息最终是要呈现在terraform registry官网上的。

- outputs.tf

module中output的作用是被其他模板和module引用，因此，每个module要讲一些重要的信息输出出来，如资源ID，资源name 等

- README

描述当前Module是用来干什么的，涉及哪些resource和data source 增加 Usage，指明该如何使用这个 Module。

.. note::

   阿里云提供了一个 `terraform-alicloud-demo <https://github.com/terraform-alicloud-modules/terraform-alicloud-demo>`_ 可参考学习

   不过，我感觉还是需要综合不少文档和实践才能真正掌握。

Terraform在运行时，会读取该目录空间下所有 ``.tf`` 以及 ``.tfvars`` 文件。因此，没有必要将所有配置信息写在1个配置文件中::

   provider.tf                -- provider 配置
   terraform.tfvars           -- 配置 provider 要用到的变量
   varable.tf                 -- 通用变量
   resource.tf                -- 资源定义
   data.tf                    -- 包文件定义
   output.tf                  -- 输出

.. note::

   如果变量文件命名不是 ``terraform.tfvars`` 或者 ``*.auto.tfvars`` ，则需要传递 ``-var-file`` 参数给terraform命令，例如::

      terraform apply -var-file=myvars.tfvars

   此外，支持多个 ``.tfvars`` 文件::

      terraform apply \
      -var-file=non-secret-variables.tfvars \
      -var-file=secret-variables.tfvars

- provider.tf::

   provider "alicloud" {
       profile = "terraform"
       region = "cn-hangzhou"
   }

provider.tf 提供用户身份认证信息，这里同上配置使用 profile 来引用凭证。



参考
=======

- `Terraform Module 编写指南 <https://yq.aliyun.com/articles/642624?spm=a2c4e.11153940.0.0.131a702278ND5o>`_
- `Module 让 Terraform 使用更简单 <https://yq.aliyun.com/articles/642625?spm=a2c4e.11153940.0.0.26167e08kHpsc0>`_
