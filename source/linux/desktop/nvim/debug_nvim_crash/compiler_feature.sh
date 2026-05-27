# 允许使用 AVX2 和 SSE4.2，但死死锁住引发 132 报错的几个高危脑补盲区
export CFLAGS="-march=x86-64 -msse4.2 -mavx -mavx2 -maes -mpopcnt -mno-bmi -mno-bmi2 -mno-fma -O2"
export CXXFLAGS="-march=x86-64 -msse4.2 -mavx -mavx2 -maes -mpopcnt -mno-bmi -mno-bmi2 -mno-fma -O2"
