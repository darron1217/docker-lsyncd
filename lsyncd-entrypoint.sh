#!/bin/bash
set -e

if [ "$1" == 'dockerize' ]; then

    # Increase the maximum watches for inotify for very large repositories to be watched
    # Needs the privilegied docker option
    [ ! -z $MAXIMUM_INOTIFY_WATCHES ] && echo fs.inotify.max_user_watches=$MAXIMUM_INOTIFY_WATCHES | tee -a /etc/sysctl.conf && sysctl -p || true

    # Create a temporary rsync folder for each directory to sync
    IFS=':' read -ra sources <<< "${SOURCES}"
    i=0
    for source in "${sources[@]}"
    do
        mkdir -p /tmp/rsync-${i}
        i=$(($i+1))
    done

    # Check if a script is available in /lsyncd-entrypoint.d and source it
    for f in /lsyncd-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *)        echo "$0: ignoring $f" ;;
        esac
    done
fi

exec "$@"

