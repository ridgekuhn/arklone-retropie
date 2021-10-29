#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

source "/opt/retropie/supplementary/arklone/src/config.sh"
source "${ARKLONE[installDir]}/src/functions/loadConfig.sh"

###########
# MOCK DATA
###########
cat <<EOF > "/dev/shm/test.cfg"
foo = "bar"
EOF

# Create a test config array
declare -A TESTARR

#####
# RUN
#####
loadConfig "/dev/shm/test.cfg" TESTARR

[[ $? = 0 ]] || exit $?

########
# TEST 1
########
# Check settings were loaded into array
[[ "${TESTARR[foo]}" = "bar" ]] || 70

echo "TEST 1 passed."

########
# TEST 1
########
rm "/dev/shm/test.cfg"

