#!/usr/bin/env bash

set -e

find_key() {
    local candidate
    for candidate in \
        "${WATCHTOWER_SSH_KEY:-}" \
        "$HOME/.ssh/watchtower_key" \
        "$HOME/.ssh/id_ed25519" \
        "$HOME/.ssh/id_rsa"
    do
        if [[ -n "$candidate" && -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

KEY_FILE="$(find_key)" || {
    echo "No SSH private key found." >&2
    echo "Set WATCHTOWER_SSH_KEY or create ~/.ssh/id_ed25519." >&2
    exit 1
}

CONFIG_FILE="servers.local.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cp servers.local.example.conf "$CONFIG_FILE"
    echo "Created $CONFIG_FILE from servers.local.example.conf"
    echo "Edit the server5 line with your real Windows VM IP and username, then run again."
    exit 0
fi

WATCHTOWER_SSH_KEY="$KEY_FILE" ./setup-docker-keys.sh

echo "Using SSH key: $KEY_FILE"
echo "Using config: $CONFIG_FILE"

TERM=xterm WATCHTOWER_SSH_KEY="$KEY_FILE" /opt/homebrew/bin/bash ./watchtower -t -i 2 -l /tmp/watchtower_logs -c "$CONFIG_FILE"
