#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

# Set defaults built-ins if run as root
[[ $SUDO_USER ]] && USER="${SUDO_USER}" || [[ $USER ]] || USER="$(getent passwd "1000" | cut -d ':' -f 1)"
HOME="/home/${USER}"

[[ "$(type -t loadConfig)" = "function" ]] || source "/opt/retropie/supplementary/arklone/src/functions/loadConfig.sh"
[[ "$(type -t getEnabledUnits)" = "function" ]] || source "/opt/retropie/supplementary/arklone/src/systemd/scripts/functions/getEnabledUnits.sh"

# Set default settings
declare -A ARKLONE
ARKLONE=(
    [installDir]="/opt/retropie/supplementary/arklone"
    [userCfgDir]="${HOME}/.config/arklone"

    # arklone config file
    [userCfg]="${ARKLONE[userCfgDir]}/arklone.cfg"

    # Dirty boot lock file
    [dirtyBoot]="${ARKLONE[userCfgDir]}/.dirtyboot"

    # rclone
    # [rcloneConf]="~/.config/rclone/rclone.conf"
    # [remote]=""
    [filterDir]="${ARKLONE[installDir]}/src/rclone/filters"

    # Log
    # [log]="/dev/shm/arklone.log"

    # RetroArch
    # [retroarchContentRoot]="~/RetroPie/roms"
    # [retroarchCfg]="~/.config/retroarch/retroarch.cfg"

    # systemd
    [enabledUnits]="$(getEnabledUnits)"
    [unitsDir]="${ARKLONE[installDir]}/src/systemd/units"
    [ignoreDir]="${ARKLONE[installDir]}/src/systemd/scripts/ignores"

    # Whiptail settings
    [whiptailTitle]="arklone cloud sync utility"
)

# Recreate userCfg if missing
if [[ ! -f "${ARKLONE[userCfg]}" ]]; then
    # Create arklone user config dir if missing
    # eg,
    # /home/user/.config/arklone
    if [[ ! -d "${ARKLONE[userCfgDir]}" ]]; then
        mkdir "${ARKLONE[userCfgDir]}"
        chown "${USER}":"${USER}" "${ARKLONE[userCfgDir]}"
    fi

    # Copy userCfg back to default path
    cp "${ARKLONE[installDir]}/src/arklone.cfg.orig" "${ARKLONE[userCfg]}"
    chown "${USER}":"${USER}" "${ARKLONE[userCfg]}"
fi

# Load the user's config file
loadConfig "${ARKLONE[userCfg]}" ARKLONE

