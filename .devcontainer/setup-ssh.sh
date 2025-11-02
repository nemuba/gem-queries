#!/bin/sh
# Setup SSH keys from host to container

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Try to mount SSH keys from host (if available)
# This will work if the .ssh directory is mounted from the host
if [ -d /tmp/.ssh-host ]; then
    cp -r /tmp/.ssh-host/* ~/.ssh/ 2>/dev/null || true
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/* 2>/dev/null || true
    chmod 644 ~/.ssh/*.pub 2>/dev/null || true
fi

# Try to use SSH agent socket if available
if [ -S "${SSH_AUTH_SOCK:-}" ]; then
    export SSH_AUTH_SOCK
fi

