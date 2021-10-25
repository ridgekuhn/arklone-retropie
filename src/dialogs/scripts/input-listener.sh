#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

# Listen to input and convert to keycodes for command input
#
# @param $1 Absolute path to the command to run

[[ ${#ARKLONE[@]} -gt 0 ]] || source "/opt/retropie/supplementary/arklone/src/config.sh"

RUNCOMMAND="${1}"

# Path to joy2key wrapper
# Replaces rp_isInstalled and rp_getInstallPath functions in upstream version,
# since we are not using retropie_packages.sh
# @see https://github.com/RetroPie/RetroPie-Setup/blob/b3acb001fcf6276a2ef5c5b4caca135b399797f8/scriptmodules/helpers.sh#L1253
JOY2KEY_WRAPPER="/opt/retropie/admin/joy2key/joy2key"

# Override joystick autodetection
# @see https://github.com/RetroPie/RetroPie-Setup/blob/b3acb001fcf6276a2ef5c5b4caca135b399797f8/scriptmodules/admin/joy2key.sh#L49
# __joy2key_dev="/dev/input/js0"

#########
# HELPERS
#########

## @fn joy2keyStart()
## @param left mapping for left
## @param right mapping for right
## @param up mapping for up
## @param down mapping for down
## @param but1 mapping for button 1
## @param but2 mapping for button 2
## @param but3 mapping for button 3
## @param butX mapping for button X ...
## @brief Start joy2key process in background to map joystick presses to keyboard
## @details Arguments are curses capability names or hex values starting with '0x'
## see: http://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html
function joy2keyStart() {
    # don't start on SSH sessions
    # (check for bracket in output - ip/name in brackets over a SSH connection)
    [[ "$(who -m)" == *\(* ]] && return

    local params=("$@")

    # if joy2key is installed, run it
    if [[ -f "${JOY2KEY_WRAPPER}" ]]; then
        "${JOY2KEY_WRAPPER}" start "${params[@]}" 2>/dev/null && return 0
    fi

    return 1
}

## @fn joy2keyStop()
## @brief Stop previously started joy2key process.
function joy2keyStop() {
    # if joy2key is installed, stop it
    if [[ -f "${JOY2KEY_WRAPPER}" ]]; then
        "${JOY2KEY_WRAPPER}" stop
    fi
}

######
# MAIN
######

joy2keyStart

# Run/source the command in a subshell so it has access to ${ARKLONE[@]}
# but can still use `exit` without exiting this script
(. "${RUNCOMMAND}")

EXIT_CODE=$?

joy2keyStop

exit $EXIT_CODE

