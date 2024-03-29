.. _skywalking_opensource_talk:

==============================
SkyWalking吴昊开源演讲(摘要)
==============================

吴昊在 介绍SkyWalking开源的历程时，可能其开源运作值得大家借鉴:

- 切中用户需求: SkyWalking 是在满足多个厂商用户集成调试性能，为了理清问题场景下诞生的
- 选择合适的架构(体量): 

  - SkyWalking 既没有像早期的Zipkin那样过于简陋(无法适应真正的生产环境)，也没有选择过于复杂的集成架构(例如依赖大数据架构，而大数据本身可能比被监控分析系统更复杂更难以调试维护)
  - 初始阶段就是为了解决问题，并且不断迭代

- 选择合适的开源线路(吴昊的演讲解析了在skywalking的开源中遇到的各种不同人和事，挺有意思和启发): 

  - 选择Apache而不是CNCF是因为SkyWalking主要是社区推动的业余项目，属于个人IP(CNCF则主要是企业推动)
  - 选择Apache v2 License，而不是GPL v3，是因为SkyWalking倾向于商业化运作，需要大型互联网企业的推广使用(类似阿里这样的互联完企业和GPL协议是冲突的)
  - SkyWalking作为分布式Tracing系统，本身就是适合大型软件公司或互联网公司使用，很多开发者就是在企业中作为职业开发者来开发SkyWalking的(并非以爱好为主)
  - 作为职业开发者和非职业开发者在开源项目上会采用不同的方式：职业开发者会考虑商业利益，非职业开发者可能会考虑名声和未来(吴昊举了一个东欧人开发的需要大量代码投入但看不到商业场景的子项目例子)

.. note::

   SkyWalking的远程协作开发模式:

   - 远程协作是异步的工作模式，所以在社区你要尽可能 **一次** 用文字表达清楚，这样你才可能把工作和生活区分开，合理安排进度
   - **不是** 不断check进度汇报工作: 国内互联网大厂在疫情期间被迫远程工作的场景，就是不断汇报和同步进展，来回沟通但不能系统化把事情安排清楚，导致效率低下(中国的微信文化、QQ文化、实时通讯文化最大问题就是被联系人频繁地被打断)

- 开源最看重的是代码，文档只是辅助。除非提供商业服务(收费)，否则不能要求开源按照商业要求提供服务
- 吴昊提出的观点值得思考: 中国工程师并不缺少开源的能力，但是缺少正确的协作方法

  - 耐心: 开源需要非常长时间的投入，有些目标可能需要几年才能实现
  - 同意一些不同的意见(agree to disagree): 社区可以有不同的意见，可以按照自己的诉求去做，去探索

参考
=====

- `吴晟：SkyWalking 与 Apache 软件基金会的那些事 | DEV. Together 2021 中国开发者生态峰会 <https://developer.aliyun.com/article/805796>`_ 吴昊的演讲介绍了SkyWalking的开源成功的原因，其选择的方式方法非常重要;此外对开源运作的不同立场、差异，应该怎么参与开源社区协作，非常推荐阅读
