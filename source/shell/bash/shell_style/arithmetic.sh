# Simple calculation used as text - note the use of $(( … )) within
# a string.
echo "$(( 2 + 2 )) is 4"

# When performing arithmetic comparisons for testing
if (( a < b )); then
  …
fi

# Some calculation assigned to a variable.
(( i = 10 * j + 400 ))

# N.B.: Remember to declare your variables as integers when
# possible, and to prefer local variables over globals.
local -i hundred=$(( 10 * 10 ))
declare -i five=$(( 10 / 2 ))

# Increment the variable "i" by three.
# Note that:
#  - We do not write ${i} or $i.
#  - We put a space after the (( and before the )).
(( i += 3 ))

# To decrement the variable "i" by five:
(( i -= 5 ))

# Do some complicated computations.
# Note that normal arithmetic operator precedence is observed.
hr=2
min=5
sec=30
echo $(( hr * 3600 + min * 60 + sec )) # prints 7530 as expected
