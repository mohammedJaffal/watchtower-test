#!/usr/bin/env bash

set -e

find_bash() {
    local candidate
    for candidate in \
        "${WATCHTOWER_BASH:-}" \
        /opt/homebrew/bin/bash \
        /usr/local/bin/bash \
        "$(command -v bash 2>/dev/null)"
    do
        if [[ -n "$candidate" && -x "$candidate" ]]; then
            if "$candidate" -lc '[[ ${BASH_VERSINFO[0]} -ge 4 ]]' >/dev/null 2>&1; then
                echo "$candidate"
                return 0
            fi
        fi
    done
    return 1
}

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

BASH_BIN="$(find_bash)" || {
    echo "No Bash 4+ executable found." >&2
    echo "Install bash 4+ or set WATCHTOWER_BASH to its path." >&2
    exit 1
}

KEY_FILE="$(find_key || true)"

CONFIG_FILE="servers.local.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cp servers.local.example.conf "$CONFIG_FILE"
    echo "Created $CONFIG_FILE from servers.local.example.conf"
    echo "Edit the server5 line with your real Windows VM IP, username, and optional password, then run again."
    exit 0
fi

if [[ -n "$KEY_FILE" ]]; then
    WATCHTOWER_SSH_KEY="$KEY_FILE" ./setup-docker-keys.sh
    echo "Using SSH key: $KEY_FILE"
else
    echo "No SSH key found. Continuing without key-based auth."
    echo "Any non-Docker servers must use the password column in $CONFIG_FILE."
fi

echo "Using Bash: $BASH_BIN"
echo "Using config: $CONFIG_FILE"

TERM=xterm WATCHTOWER_SSH_KEY="$KEY_FILE" "$BASH_BIN" ./watchtower -t -i 2 -l /tmp/watchtower_logs -c "$CONFIG_FILE"
