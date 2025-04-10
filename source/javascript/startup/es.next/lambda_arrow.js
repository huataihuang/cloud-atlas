// 传统匿名函数
(function (a) {
  return a + 100;
});

// 1. 移除“function”，并将箭头放置于参数和函数体起始大括号之间
(a) => {
  return a + 100;
};

// 2. 移除代表函数体的大括号和“return”——返回值是隐含的
(a) => a + 100;

// 3. 移除参数周围的括号
a => a + 100;

