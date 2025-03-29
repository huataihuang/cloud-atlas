# This is preferred:
var="$(command "$(command1)")"

# This is not:
var="`command \`command1\``"
