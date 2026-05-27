# 显式告诉 GCC：不要瞎猜型号，老老实实按标准的 x86-64-v3 规范编译
export CFLAGS="-march=x86-64-v3 -O2"
export CXXFLAGS="-march=x86-64-v3 -O2"
