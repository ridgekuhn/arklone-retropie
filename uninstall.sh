#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

source "/opt/retropie/supplementary/arklone/src/config.sh"

# Uninstall arklone
# @param $1 {boolean} Keep install dir if true
KEEP_INSTALL_DIR=$1

#########
# SYSTEMD
#########
# Get list of installed units
UNITS=($(systemctl list-unit-files | grep "arklone" | cut -d ' ' -f 1))

# Remove arklone from systemd
if [[ "${#UNITS[@]}" -gt 0 ]]; then
    for unit in ${UNITS[@]}; do
        sudo systemctl disable "${unit}"
    done
fi

###############
# INOTIFY-TOOLS
###############
if [[ ! -f "${ARKLONE[userCfgDir]}/.inotify-tools.sh" ]]; then
    sudo apt remove inotify-tools -y
fi

########
# RCLONE
########
# Uninstall rclone if installed by arklone
if [[ ! -f "${ARKLONE[userCfgDir]}/.rclone.lock" ]]; then
    sudo dpkg -P rclone
    rm -rf "${HOME}/.config/rclone"
fi

#########
# ARKLONE
#########
# Remove arklone user config dir
rm -rf "${ARKLONE[userCfgDir]}"

# Remove arklone
if [[ ! $KEEP_INSTALL_DIR ]]; then
    sudo rm -rf "${ARKLONE[installDir]}"
fi

echo "Uninstallation complete. Thanks for trying arklone!"

