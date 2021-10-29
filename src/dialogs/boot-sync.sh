#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

# Dialog shown to user on boot
#
# Checks for dirty boot state and configured network connection.
# If network is up, attempts to receive all save data from remote
# @see rclone/scripts/sync-all-saves.sh
#
# @returns Exit code of sync-all-saves.sh

[[ ${#ARKLONE[@]} -gt 0 ]] || source "/opt/retropie/supplementary/arklone/src/config.sh"

[[ "$(type -t killOnKeyPress)" = "function" ]] || source "${ARKLONE[installDir]}/src/functions/killOnKeyPress.sh"
[[ "$(type -t logScreen)" = "function" ]] || source "${ARKLONE[installDir]}/src/dialogs/screens/logScreen.sh"

#############
# SUB SCREENS
#############
# Warn if sync failed on previous boot
function dirtyBootScreen() {
    whiptail \
        --title "${ARKLONE[whiptailTitle]}" \
        --yesno "WARNING: There was a problem receiving save data from the cloud during a previous session. Please verify that your cloud copy is correct. Proceeding may overwrite data on your device if the cloud copy has a newer timestamp." \
        16 56 \
        --yes-button "Continue" \
        --no-button "Abort"
}

# Check for network config
#
# @returns 1 if no routes available
function networkCheckScreen() {
    # Check if ip reports configured router tables
    if [[ -z "$(ip route)" ]]; then
        whiptail \
            --title "${ARKLONE[whiptailTitle]}" \
            --yesno "No configured network devices detected. If you use a USB wifi dongle or ethernet cable, make sure it's plugged in and try again." \
            --yes-button "Try Again" \
            --no-button "Cancel" \
            16 56 8

        if [[ $? = 0 ]]; then
            networkCheckScreen
        else
            return 1
        fi
    fi
}

# Receive updates from cloud
#
# Wrapped with killOnKeypress so user can abort at any time
function receiveSavesScreen() {
    whiptail \
        --title "${ARKLONE[whiptailTitle]}" \
        --infobox "Attempting to receive new save data from the cloud.\nPress any key to abort at any time." \
        16 56 8
}

# Allow user to try to sync again on error
function tryAgainScreen() {
    whiptail \
        --title "${ARKLONE[whiptailTitle]}" \
        --yesno "There was a problem receiving save data from the cloud. Would you like to try again?" \
        --yes-button "Try Again" \
        --no-button "Cancel" \
        16 56 8
}

# Final error screen before exiting
function errorScreen() {
    whiptail \
        --title "${ARKLONE[whiptailTitle]}" \
        --yesno "WARNING: Could not receive all save data updates from the cloud. To minimize potential data loss, automatic syncing will be stopped for this session. Would you like to view the log?" \
        16 56
}

#############
# MAIN SCREEN
#############
# Main screen
#
# @returns 0 if all cloud syncs are successful
function mainScreen() {
    local exitCode=0

    # Notify user of dirty boot state and clean up
    if [[ -f "${ARKLONE[dirtyBoot]}" ]]; then
        dirtyBootScreen

        if [[ $? != 0 ]]; then
            return 1
        fi

        rm "${ARKLONE[dirtyBoot]}"

        . "${ARKLONE[installDir]}/src/systemd/scripts/enable-path-units.sh" 3>&1 1>/dev/null 2>&3 \
            | . "${ARKLONE[installDir]}/src/dialogs/gauges/systemd/enable-path-units.sh"
    fi

    # Check for network connection
    networkCheckScreen
    exitCode=$?

    # Receive cloud sync
    if [[ "${exitCode}" = 0 ]]; then
        receiveSavesScreen

        sleep 1

        # Allow main script to pass non-zero exit code through pipe
        set -o pipefail

        killOnKeypress . "${ARKLONE[installDir]}/src/rclone/scripts/sync-all-dirs.sh" "receive" \
            | . "${ARKLONE[installDir]}/src/dialogs/gauges/rclone/sync-all-dirs.sh"

        exitCode=$?

        # Reset bad whiptail stty options
        # @see https://unix.stackexchange.com/questions/673625/no-keyboard-output-on-terminal-after-running-a-script-using-read-and-whiptail/673719
        stty sane
    fi

    # Try again if there were any errors
    if [[ "${exitCode}" != 0 ]]; then
        # Wait for sync-all-saves.sh to die
        sleep 2
        clear

        tryAgainScreen

        # Allow user to start over
        if [[ $? = 0 ]]; then
            mainScreen
            # Get recursion process return code
            # so it doesn't get overwritten by the current value
            exitCode=$?

        else
            # Warn user of error
            errorScreen

            # Show log
            if [[ $? = 0 ]]; then
                logScreen
            fi

            # Disable all units except boot service
            . "${ARKLONE[installDir]}/src/systemd/scripts/disable-path-units.sh" 3>&1 1>/dev/null 2>&3 \
                | . "${ARKLONE[installDir]}/src/dialogs/gauges/systemd/disable-path-units.sh"

            # Set dirty boot lock
            touch "${ARKLONE[dirtyBoot]}"
        fi
    fi

    return $exitCode
}

#####
# RUN
#####
# Change the virtual terminal to tty2.
# This script is called by arkloned-receive-saves-boot.service,
# which runs on tty2 to temporarily override the display-manager
# on systems with a graphical environment.
# @see systemd/units/arkloned-receive-all-saves-boot.service
chvt 2

mainScreen

EXIT_CODE=$?

# Reset the virtual terminal
chvt 1

exit $EXIT_CODE

