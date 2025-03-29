// 传统匿名函数
(function (a, b) {
  return a + b + 100;
});

// 箭头函数
(a, b) => a + b + 100;

const a = 4;
const b = 2;

// 传统无参匿名函数
(function () {
  return a + b + 100;
});

// 无参箭头函数
() => a + b + 100;
