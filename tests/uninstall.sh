#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

source "/opt/retropie/supplementary/arklone/src/config.sh"

# Test uninstaller
# @param $1 {boolean} Keep install dir if true
KEEP_INSTALL_DIR=$1

#####
# RUN
#####
# Run uninstaller
"${ARKLONE[installDir]}/uninstall.sh" $KEEP_INSTALL_DIR

########
# TEST 1
########
# Check units were removed from systemd
if systemctl list-unit-files | grep -E '^arklone'; then
    exit 78
fi

echo "TEST 1 passed."

########
# TEST 2
########
# arklone user config dir was removed
[[ ! -d "${ARKLONE[userCfgDir]}" ]] || exit 78

echo "TEST 2 passed."

########
# TEST 5
########
# arklone install dir was removed
if [[ $KEEP_INSTALL_DIR ]]; then
    [[ -d "${ARKLONE[installDir]}" ]] || exit 78
else
    [[ ! -d "${ARKLONE[installDir]}" ]] || exit 78
fi

echo "TEST 3 passed."

##########
# TEARDOWN
##########
echo "SUCCESS"

