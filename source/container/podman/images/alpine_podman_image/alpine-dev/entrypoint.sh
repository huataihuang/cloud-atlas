#!/bin/bash

# get HOST UID/GID dynamic (inject by env, default is 1000)
USER_ID=${NEW_UID:-1000}
GROUP_ID=${NEW_GID:-1000}

# if UID changed, fix admin's ID in container
if [ "$USER_ID" != "1000" ]; then
    echo "Updating admin UID to $USER_ID..."
    sed -i "s/^admin:x:1000:1000:/admin:x:$USER_ID:$GROUP_ID:/" /etc/passwd
    sed -i "s/^admin:x:1000:/admin:x:$GROUP_ID:/" /etc/group
fi

# WorkSpace owner right( podman can do it, so remove)
#CURRENT_OWNER=$(stat -c '%u' /workspace)
#if [ "$CURRENT_OWNER" != "$USER_ID" ]; then
#    echo "Adjusting permissions for /workspace..."
#    chown -R admin:admin /workspace
#fi

# switch to admin, then run commands
# using exec to confirm signal has been forward to sub process
# exec su-exec admin "$@" REPORT ERROR => su-exec: setgroups: Operation not permitted
exec doas -u admin "$@"
