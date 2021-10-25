#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

[[ ${#ARKLONE[@]} -gt 0 ]] || source "/opt/retropie/supplementary/arklone/src/config.sh"
[[ "$(type -t deletePathUnits)" = "function" ]] || source "${ARKLONE[installDir]}/src/systemd/scripts/functions/deletePathUnits.sh"

# Regenerate RetroArch savestates/savefiles units screen
function regenRAunitsScreen() {
    # Source the scripts in a subshell so it can exit without exiting this script
    (
        # Allow main script to pass non-zero exit code through pipe
        set -o pipefail

        # Delete old retroarch path units and generate new ones
        deletePathUnits "$(find "${ARKLONE[unitsDir]}/arkloned-retroarch"*".auto.path" 2>/dev/null)" \
            | . "${ARKLONE[installDir]}/src/dialogs/gauges/systemd/deletePathUnits.sh"

        . "${ARKLONE[installDir]}/src/systemd/scripts/generate-retroarch-units.sh" \
            | . "${ARKLONE[installDir]}/src/dialogs/gauges/systemd/generate-retroarch-units.sh"
    )
}

