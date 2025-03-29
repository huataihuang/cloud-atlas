# 好的案例
if [[ "${my_var}" = "some_string" ]]; then
  do_something
fi

# -z (字符串长度为0) and -n (字符串长度不为0) 是
# 推荐的检测空字符串的方法
if [[ -z "${my_var}" ]]; then
  do_something
fi

# 可用但不推荐的方法
if [[ "${my_var}" = "" ]]; then
  do_something
fi

# 不要使用填充字符进行对比的方法
if [[ "${my_var}X" = "some_stringX" ]]; then
  do_something
fi

