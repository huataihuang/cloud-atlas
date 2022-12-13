total=0
# Only do this if there are no spaces in return values.
for value in $(command); do
  total+="${value}"
done
