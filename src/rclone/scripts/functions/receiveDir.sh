#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

[[ ${#ARKLONE[@]} -gt 0 ]] || source "/opt/retropie/supplementary/arklone/src/config.sh"
[[ "$(type -t getFilterString)" = "function" ]] || source "${ARKLONE[installDir]}/src/rclone/scripts/functions/getFilterString.sh"

# Receive a directory from rclone remote
#
# @param $1 {string} Absolute path to local directory. No trailing slash.
#
# @param $2 {string} Path to remote dir. No opening or trailing slashes.
#
# @param [$3] {string} Optional list of pipe-delimited rclone filter names
#
# @returns Exit code of rclone process
function receiveDir() {
    [[ $1 ]] || return 64
    [[ $2 ]] || return 64

    local localDir="${1}"
    local remoteDir="${2}"
    local filters="${3}"

    local filterString="$(getFilterString "${filters}")"

    printf "\nReceiving ${ARKLONE[remote]}:arklone/${remoteDir}/ to ${localDir}/\n"

    rclone copy "${ARKLONE[remote]}:arklone/${remoteDir}/" "${localDir}/" ${filterString} -u -v --config "${ARKLONE[rcloneConf]}"

    return $?
}

