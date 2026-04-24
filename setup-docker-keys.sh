#!/usr/bin/env bash

set -e

KEY_FILE="${WATCHTOWER_SSH_KEY:-$HOME/.ssh/id_ed25519}"
PUBLIC_KEY=$(ssh-keygen -y -f "$KEY_FILE")

for container in server1 server2 server3 server4; do
    docker exec "$container" bash -lc "
        mkdir -p /home/test/.ssh
        grep -qxF '$PUBLIC_KEY' /home/test/.ssh/authorized_keys 2>/dev/null || echo '$PUBLIC_KEY' >> /home/test/.ssh/authorized_keys
        chown -R test:test /home/test/.ssh
        chmod 700 /home/test/.ssh
        chmod 600 /home/test/.ssh/authorized_keys
    "
    echo "Key installed in $container"
done
