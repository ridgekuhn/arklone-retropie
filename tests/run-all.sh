#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

source "/opt/retropie/supplementary/arklone/src/config.sh"

###########
# MOCK DATA
###########
# Uninstall first, to reset to defaults
"${ARKLONE[installDir]}/uninstall.sh" true || exit $?

#####
# RUN
#####
# Run install test
"${ARKLONE[installDir]}/tests/install.sh" || exit $?

# Get all tests
TESTS=($(find "${ARKLONE[installDir]}/tests" -type f -name "*.sh"))

# Run all tests, except this one
for test in ${TESTS[@]}; do
    # Avoid running undesirable tests
    if
        [[ "${test}" != "${ARKLONE[installDir]}/tests/run-all.sh" ]] \
        && [[ "${test}" != "${ARKLONE[installDir]}/tests/install.sh" ]] \
        && [[ "${test}" != "${ARKLONE[installDir]}/tests/uninstall.sh" ]]
    then
        echo "===================================================================="
        echo "Now running ${test}"
        echo "--------------------------------------------------------------------"

        "${test}"

        exitCode=$?

        if [[ $exitCode != 0 ]]; then
            "${test} failed with exit code ${exitCode}"
            "Please manually clean /dev/shm/ before continuing"
            exit

        elif systemctl list-unit-files arkloned* 1>/dev/null 2>&1 | grep arklone; then
            echo "${test} did not clean up systemd"
            exit

        elif find /dev/shm/* 2>/dev/null; then
            echo "${test} did not clean up /dev/shm"
            exit

        else
            echo "SUCCESS!"
        fi
    fi
done

##########
# TEARDOWN
##########
# Run uninstall test
"${ARKLONE[installDir]}/tests/uninstall.sh" true || echo $?

echo "All tests ran successfully"

