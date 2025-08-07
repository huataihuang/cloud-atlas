#!/bin/sh

# Setup/variables:

# Each snapshot name must be unique, timestamp is a good choice.
# You can also use Solaris date, but I don't know the correct syntax.
snapshot_string=DO_NOT_DELETE_remote_replication_
timestamp=$(/usr/gnu/bin/date '+%Y%m%d%H%M%S')
source_pool=tank
destination_pool=tank
new_snap="$source_pool"@"$snapshot_string""$timestamp"
destination_host=remotehostname

# Initial send:

# Create first recursive snapshot of the whole pool.
zfs snapshot -r "$new_snap"
# Initial replication via SSH.
zfs send -R "$new_snap" | ssh "$destination_host" zfs recv -Fdu "$destination_pool"

# Incremental sends:

# Get old snapshot name.
old_snap=$(zfs list -H -o name -t snapshot -r "$source_pool" | grep "$source_pool"@"$snapshot_string" | tail --lines=1)
# Create new recursive snapshot of the whole pool.
zfs snapshot -r "$new_snap"
# Incremental replication via SSH.
zfs send -R -I "$old_snap" "$new_snap" | ssh "$destination_host" zfs recv -Fdu "$destination_pool"
# Delete older snaps on the local source (grep -v inverts the selection)
delete_from=$(zfs list -H -o name -t snapshot -r "$source_pool" | grep "$snapshot_string" | grep -v "$timestamp")
for snap in $delete_from; do
    zfs destroy "$snap"
done
