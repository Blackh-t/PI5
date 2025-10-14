#!/bin/bash

cd
cd git/PI5
git pull

# Store git pull output
GIT_OUTPUT=$(git pull)
echo "$GIT_OUTPUT"

# Moved the new script to system bin in order to run.
if [[ "$GIT_OUTPUT" != *"Already up to date."* ]]; then
    cp -f git/PI5/run_on_pull /usr/local/bin/
    chmod +x /usr/local/bin/run_on_pull.sh
    echo "[UPDATED] run_on_pull.sh "
else
    echo "[SKIP] No changed."
fi
