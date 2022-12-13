# Prefer this:
addition=$(( X + Y ))
substitution="${string/#foo/bar}"

# Instead of this:
addition="$(expr "${X}" + "${Y}")"
substitution="$(echo "${string}" | sed -e 's/^foo/bar/')"
