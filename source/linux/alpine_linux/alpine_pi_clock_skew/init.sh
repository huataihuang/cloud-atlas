...

if $mountproc; then
        ebegin "Mounting /proc"
        if ! fstabinfo --mount /proc; then
                mount -n -t proc -o noexec,nosuid,nodev proc /proc
        fi
        eend $?
fi

if [ -e /etc/init.d/.use-swclock ]; then
    "$RC_LIBEXECDIR"/sbin/swclock /etc/init.d
fi

...
