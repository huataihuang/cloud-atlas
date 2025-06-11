.. _redis_data_types:

===================
Redis数据结构类型
===================

Redis支持5种不同数据结构类型:

String字符串
==============

String字符串是最基本Redis值:

- Redis字符串数据可以存储任何类型数据(binary safe)，例如JPEG图形或者序列化Ruby对象
- 字符串类型最大存储512MB长度
- 可以对整个字符串或者字符串的一部分执行操作
- 整数和浮点数可以执行自增(increment)或者自减(decrement)操作

Redis的字符串数据常用操作命令:

- GET
- SET
- DEL

操作案例 - 以 ``hello world`` 为 ``key value`` ::

   $ redis-cli
   192.168.6.253:6379> set hello world
   OK
   192.168.6.253:6379> get hello
   "world"
   192.168.6.253:6379> del hello
   (integer) 1
   192.168.6.253:6379> get hello
   (nil)
   192.168.6.253:6379>

可以看到当 ``set`` 成功时，服务器端返回 ``OK`` ，对应的 :ref:`redis_dev_python` 中，Python客户端会将这个 ``OK`` 转换成 ``True`` 。

执行 ``del`` 成功时，服务器端返回 ``1`` 表示成功删除的值的数量，如果 ``del`` 2个key，则成功就会返回2::

   192.168.6.253:6379> set hello 1
   OK
   192.168.6.253:6379> set world 2
   OK
   192.168.6.253:6379> set redis 3
   OK
   192.168.6.253:6379> del hello world redisss
   (integer) 2
   192.168.6.253:6379> get hello
   (nil)
   192.168.6.253:6379> get world
   (nil)
   192.168.6.253:6379> get redis
   "3"

注意，上述 ``del`` 指令虽然尝试删除3个kv，但是只有2个命中，所以返回值是 ``2`` : ``redis`` 这个kv没有成功删除(key拼写错误)

当 ``get`` 失败时，服务器端返回 ``nil`` ，对应的 :ref:`redis_dev_python` 中，Python客户端会把这个 ``nill`` 转换成 ``None`` 。

List列表
============

List列表是一个链表( ``linked-list`` )，链表上的每个节点(索引/index)都包含了一个字符串:

- List列表只有一个key，就是列表名，这个列表中保存了多个有索引的值(其实就是数组)
- 从链表的两端推入( ``lpush`` / ``rpush`` )或者弹出( ``lpop`` / ``rpop`` )元素，元素可以重复
- 根据偏移量对链表进行裁剪(trim)
- 一次可以读取单个( ``lindex`` )或多个元素( ``lrange`` )
- 可以根据值查找或移除元素

.. note::

   List列表对应 开发语言 实际上是 ``数组`` ( ``Array Data Structure`` )，也就是带整数下标的字符串。根据数组的整数下标(key)，可以去除数组值(value)

以下案例以 ``hello-list`` 作为列表名字::

   192.168.6.253:6379> rpush hello-list item
   (integer) 1
   192.168.6.253:6379> rpush hello-list item2
   (integer) 2
   192.168.6.253:6379> rpush hello-list item
   (integer) 3
   192.168.6.253:6379> lrange hello-list 0 -1
   1) "item"
   2) "item2"
   3) "item"

这里使用了 ``rpush`` 表示从右边向列表中添加元素，一共添加了3个元素，并且元素值可以重复(key是数组下标即可以确保唯一)

最后一个命令使用 ``lrange`` 一次去除多个值，这里 起始key是 ``0`` 表示从第一个开始，结束key是 ``-1`` 表示最后一个，所以一次就可以把整个列表中所有值都取出来

以下案例取出指定索引的值::

   192.168.6.253:6379> lindex hello-list 1
   "item2"
   192.168.6.253:6379> lindex hello-list 2
   "item"

以下案例 ``左弹出`` (相当于删除)值，此时List列表所有值都顺序左移::

   192.168.6.253:6379> lpop hello-list
   "item"

以下案例 ``左推入`` 2个值，此时List列表中所有值都会顺序右移。注意，返回数字是 ``4`` 表示这个List中有4个值::

   > lpush hello-list newitem1 newitem2
   (integer) 4

现在我们一次取出整个列表所有值来看看::

   > lrange hello-list 0 -1
   1) "newitem2"
   2) "newitem1"
   3) "item2"
   4) "item"

可以看到，前面我们 ``左推入`` 的值就像压入 **弹夹** 的子弹一样，先 ``左推入`` 压入的 ``newitem1`` 被后 ``左推入`` 压入的 ``newitem2`` 挤到右边，并且所有链上的数据都依次右移位置。

Set集合
==========

Set集合是一个包含字符串对无序收集器(unordered collection):

- Set集合对每个包含字符串都是独一无二、各不相同对
- 可以添加( ``SADD`` )、获取、移除( ``SREM`` )单个元素
- 可以检查一个元素是否存在于集合中( ``SISMEMBERS`` )
- 可以计算集合的交集、并集、差集
- 可以从集合中随机获取元素

注意，Set集合是无序的，也就是说无法像 List列表 一样将元素从集合的某一端推入或弹出。

以下命令组合向 ``hello-set`` 集合添加数据，注意，最后一个 ``sadd`` 是失败的(返回数字是 ``0`` )，这是因为重复添加了元素(集合不允许重复元素)::

   192.168.6.253:6379> sadd hello-set item
   (integer) 1
   192.168.6.253:6379> sadd hello-set item2
   (integer) 1
   192.168.6.253:6379> sadd hello-set item3
   (integer) 1
   192.168.6.253:6379> sadd hello-set item
   (integer) 0

可以一次性检查所有元素(也就是 ``smembers`` 没有参数)::

   192.168.6.253:6379> smembers hello-set
   1) "item3"
   2) "item2"
   3) "item"

检查元素是否存在于集合中，注意返回值 ``0`` 表示不存在(如 ``item4`` 就不存在)::

   192.168.6.253:6379> sismember hello-set item4
   (integer) 0
   192.168.6.253:6379> sismember hello-set item3
   (integer) 1

可以移除集合中的元素，注意，如果重复移除相同元素，则只有第一次返回值是 ``1`` 表示成功，后续都是返回 ``0`` 表示失败::

   192.168.6.253:6379> srem hello-set item2
   (integer) 1
   192.168.6.253:6379> srem hello-set item2
   (integer) 0

现在检查集合就会看到只剩下2个元素::

   192.168.6.253:6379> smembers hello-set
   1) "item3"
   2) "item"

可以对于集合进行 ``交`` ( ``SINTER`` ) ``并`` ( ``SUNION`` ) ``差`` ( ``SDIFF`` ) 运算

Hash散列
============

Hash散列是一个包含键值对的无序散列表:

- 可以添加、获取、移除单个键值对
- 可以获取所有键值对

Hash散列和 List列表的差异是， 散列的key 由 无序排列的字符串承担，而List列表只有一个一维数组

以下命令设置Hash散列，注意最后一条设置值失败，因为重复设置相同kv::

   192.168.6.253:6379> hset hello-hash sub-key1 value1
   (integer) 1
   192.168.6.253:6379> hset hello-hash sub-key2 value2
   (integer) 1
   192.168.6.253:6379> hset hello-hash sub-key1 value1
   (integer) 0

获取散列的所有键值对，注意Python客户端会把整个散列转换成Python字典::

   192.168.6.253:6379> hgetall hello-hash
   1) "sub-key1"
   2) "value1"
   3) "sub-key2"
   4) "value2"

删除hash散列的某个kv::

   192.168.6.253:6379> hdel hello-hash sub-key2
   (integer) 1
   192.168.6.253:6379> hdel hello-hash sub-key2
   (integer) 0

获取hash散列的某个kv::

   192.168.6.253:6379> hget hello-hash sub-key1
   "value1"
   192.168.6.253:6379> hgetall hello-hash
   1) "sub-key1"
   2) "value1"

Zset有序集合
=============

Zset有序集合是字符串成员(member)与浮点数分值(score)中间的有序映射:

- 元素的排列顺序由分值(score)的大小决定
- 可以添加、获取、删除单个元素
- 可以根据分值范围(range)或者成员来获取元素

有序集合是Redis中唯一一个既可以根据成员访问元素(和散列相同)，又可以根据分值以及分值的排列顺序来访问元素的结构。

添加有序集合元素，注意不能重复添加相同kv::

   192.168.6.253:6379> zadd hello-zset 728 member1
   (integer) 1
   192.168.6.253:6379> zadd hello-zset 982 member0
   (integer) 1
   192.168.6.253:6379> zadd hello-zset 982 member0
   (integer) 0

按范围获取整个有序集合::

   192.168.6.253:6379> zrange hello-zset 0 -1 withscores
   1) "member1"
   2) "728"
   3) "member0"
   4) "982"

在获取有序集合包含的所有元素是，多个元素会按照分值大小进行排序，并且Python可灰度会将元素的分值转换成浮点数

可以按照分值范围来获取元素::

   192.168.6.253:6379> zrangebyscore hello-zset 0 800 withscores
   1) "member1"
   2) "728"

可以移除元素::

   192.168.6.253:6379> zrem hello-zset member1
   (integer) 1
   192.168.6.253:6379> zrem hello-zset member1
   (integer) 0

获取整个有序集合::

   192.168.6.253:6379> zrange hello-zset 0 -1 withscores
   1) "member0"
   2) "982"

参考
=======

- `Redis官方文档: Data types <https://redis.io/topics/data-types>`_
- 「Redis实战」
