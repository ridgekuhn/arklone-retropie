#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

[[ ${#ARKLONE[@]} -gt 0 ]] || source "/opt/retropie/supplementary/arklone/src/config.sh"

[[ "$(type -t editConfig)" = "function" ]] || source "${ARKLONE[installDir]}/src/functions/editConfig.sh"
[[ "$(type -t loadConfig)" = "function" ]] || source "${ARKLONE[installDir]}/src/functions/loadConfig.sh"
[[ "$(type -t printMenu)" = "function" ]] || source "${ARKLONE[installDir]}/src/dialogs/scripts/functions/printMenu.sh"

[[ "$(type -t rcloneRemoteCheckScreen)" = "function" ]] || source "${ARKLONE[installDir]}/src/dialogs/screens/rclone/rcloneRemoteCheckScreen.sh"

# Cloud service selection dialog
function setCloudScreen() {
    # Check for rclone remotes
    rcloneRemoteCheckScreen

    if [[ $? != 0 ]]; then
        return
    fi

    # Get list of rclone remotes
    local remotes=$(rclone listremotes | cut -d ':' -f 1)

    local selection=$(whiptail \
        --title "${ARKLONE[whiptailTitle]}" \
        --menu \
            "Choose a cloud service:" \
            16 60 8 \
            $(printMenu "${remotes}") \
        3>&1 1>&2 2>&3 \
    )

    # Save user selection and reload config
    if [[ ! -z "${selection}" ]]; then
        remotes=(${remotes})
        editConfig "remote" "${remotes[$selection]}" "${ARKLONE[userCfg]}"

        loadConfig "${ARKLONE[userCfg]}" ARKLONE
    fi
}

