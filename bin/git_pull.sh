#!/bin/bash

cd /home/yoshi/git/PI5

# Store git pull output
GIT_OUTPUT=$(git pull)
echo "$GIT_OUTPUT"

# Moved the new script to system bin in order to run.
if echo "$GIT_OUTPUT" | grep -q "Fast-forward"; then
    cp -f bin/run_on_pull.sh /usr/local/bin/
    chmod +x /usr/local/bin/run_on_pull.sh
    echo "[UPDATED] run_on_pull.sh "
else
    echo "[SKIP] No changed."
fi
