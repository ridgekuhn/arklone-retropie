#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

source "/opt/retropie/supplementary/arklone/src/config.sh"

###########
# MOCK DATA
###########
# Configure lock file pre-requisites
# Install rclone so install script sets lock file
if ! rclone --version >/dev/null 2>&1; then
    sudo apt update && sudo apt install rclone -y
fi

# Install inotifywait so install script sets lock file
if ! which inotifywait >/dev/null 2>&1; then
    sudo apt install inotify-tools -y
fi

# Make backup dir so install script sets lock file
[[ -d "${ARKLONE[backupDir]}" ]] || mkdir "${ARKLONE[backupDir]}"

#####
# RUN
#####
"${ARKLONE[installDir]}/install.sh"

########
# TEST 1
########
# User config directory exists
# eg, /home/user/.config/arklone
[[ -d "${ARKLONE[userCfgDir]}" ]] || exit 72

echo "TEST 1 passed."

########
# TEST 2
########
# User config file exists
[[ -f "${ARKLONE[userCfg]}" ]] || exit 72

echo "TEST 2 passed."

########
# TEST 3
########
# rclone lock exists
[[ -f "${ARKLONE[userCfgDir]}/.rclone.lock" ]] || exit 72

echo "TEST 3 passed."

########
# TEST 4
########
# rclone.conf exists
[[ -f "${HOME}/.config/rclone/rclone.conf" ]] || exit 72

echo "TEST 4 passed."

########
# TEST 5
########
# inotifywait exists
if ! which inotifywait >/dev/null 2>&1; then
    exit 72
fi

echo "TEST 5 passed."

########
# TEST 6
########
# Check script executable permissions
SCRIPTS=($(find "${ARKLONE[installDir]}" -type f -name "*.sh"))

for script in ${SCRIPTS[@]}; do
    if ! ls -al "${script}" | grep -E '^-..x..x..x' >/dev/null; then
        exit 77
    fi
done

echo "TEST 6 passed."

########
# TEST 7
########
# systemd units directory is owned by user
if ! ls -al "${ARKLONE[installDir]}/src/systemd/units" | grep -E "${USER}\s*${USER}" >/dev/null; then
    exit 77
fi

echo "TEST 7 passed."

echo "SUCCESS"
