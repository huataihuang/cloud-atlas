lsof | awk '{print $2}' | sort | uniq -c | sort -n
