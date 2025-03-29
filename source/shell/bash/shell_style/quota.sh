# '单'引号表示不需要替换。
# “双”引号表示需要/容忍替换。

# 简单的例子
# "引用命令替换"
flag="$(some_command and its args "$@" 'quoted separately')"

# "引用变量"
echo "${flag}"

# "永远不要引用文字整数"
value=32
# "引用命令替换", 即使你期望整数
number="$(generate_number)"

# "prefer quoting words", not compulsory
readonly USE_INTEGER='true'

# "引用shell元字符"
echo 'Hello stranger, and well met. Earn lots of $$$'
echo "Process $$: Done making \$\$\$."

# "命令选项或路径名"
# ($1 假设包含一个变量)
grep -li Hugo /dev/null "$1"

# Less simple examples
# "quote variables, unless proven false": ccs might be empty
git send-email --to "${reviewers}" ${ccs:+"--cc" "${ccs}"}

# Positional parameter precautions: $1 might be unset
# Single quotes leave regex as-is.
grep -cP '([Ss]pecial|\|?characters*)$' ${1:+"$1"}

# 通常应该使用 $@ 传递参数

set -- 1 "2 two" "3 three tres"; echo $# ; set -- "$*"; echo "$#, $@")
set -- 1 "2 two" "3 three tres"; echo $# ; set -- "$@"; echo "$#, $@")
