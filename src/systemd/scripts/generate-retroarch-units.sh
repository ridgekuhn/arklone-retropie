#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

# Generate systemd path units for save directories in all retroarch.cfg instances
#
# @param [$1] {boolean} Optionally delete all retroarch path units first

[[ ${#ARKLONE[@]} -gt 0 ]] || source "/opt/retropie/supplementary/arklone/src/config.sh"
[[ "$(type -t loadConfig)" = "function" ]] || source "${ARKLONE[installDir]}/src/functions/loadConfig.sh"
[[ "$(type -t newPathUnit)" = "function" ]] || source "${ARKLONE[installDir]}/src/systemd/scripts/functions/newPathUnit.sh"
[[ "$(type -t newPathUnitsFromDir)" = "function" ]] || source "${ARKLONE[installDir]}/src/systemd/scripts/functions/newPathUnitsFromDir.sh"

# Get array of all retroarch.cfg instances
RETROARCHS=(${ARKLONE[retroarchCfg]})


# @todo We should also be able to support screenshots and systemfiles
#		because they use the same naming scheme in retroarch.cfg
FILETYPES=("savefile" "savestate")

# Loop through retroarch instances
for retroarchCfg in ${RETROARCHS[@]}; do
    echo "====================================================================="
    echo "Now processing: ${retroarchCfg}"
    echo "---------------------------------------------------------------------"

    # Get the retroarch instance's basename
    # eg,
    # retroarchCfg="/path/to/retroarch32/retroarch.cfg"
    # retroarchBasename="retroarch32"
    retroarchBasename="$(basename "$(dirname "${retroarchCfg}")")"

    # If ${retroarchCfg}'s parent directory name doesn't contain "retroarch",
    # just default to "retroarch"
    if ! grep "retroarch" <<<"${retroarchBasename}"; then
        retroarchBasename="retroarch"
    fi

    # Create an array to hold retroarch.cfg settings plus a few of our own
    declare -A r

    # Load relevant settings into r
    # Last param passed to loadConfig()
    # is ${FILETYPES[@]} as a pipe | delimited list.
    # The pipes will become regex OR operators passed to grep
    # @see functions/loadConfig.sh
    loadConfig "${retroarchCfg}" r "$(tr ' ' '|' <<<"${FILETYPES[@]}")"

    for filetype in ${FILETYPES[@]}; do
        # If ${filetype}s_in_content_dir is enabled, it supercedes the other relevant settings
        # and ${filetype} will always appear next to the corresponding content file
        #
        # @todo I hate this syntax, is there anything that can be done about it?
        # Check if = "true" because it's a string, not an actual boolean
        if [[ "${r[${filetype}s_in_content_dir]}" = "true" ]]; then
            # Save/append the content dir parent filter string
            # so we can do newPathUnitsFromDir()
            # in one shot without waiting to check for duplicate units
            r[content_directory_filter]+="retroarch-${filetype}|"

            # Continue to next filetype, we will generate the content dir units later
            continue

        # Saves are stored directly in ${r[${filetype}_directory]}
        elif
            [[ "${r[sort_${filetype}s_by_content_enable]}" = "false" ]] \
            && [[ "${r[sort_${filetype}s_enable]}" = "false" ]]
        then
            # Make the path unit
            newPathUnit "${retroarchBasename}-$(basename "${r[${filetype}_directory]}").auto" "${r[${filetype}_directory]}" "${retroarchBasename}/$(basename "${r[${filetype}_directory]}")" "retroarch-${filetype}"

            # Continue to next filetype, nothing left to do
            continue

        # Saves are organized by either content dir or retroarch core
        # eg,
        # "${r[${filetype}_directory]}/nes"
        # or
        # "${r[${filetype}_directory]}/FCEUmm"
        elif [[ "${r[sort_${filetype}s_by_content_enable]}" != "${r[sort_${filetype}s_enable]}" ]]; then
            r[${filetype}_directory_depth]=1

        # Saves are organized by content dir, then by retroarch core
        # eg,
        # "${r[${filetype}_directory]}/nes/FCEUmm"
        else
            r[${filetype}_directory_depth]=2
        fi

        newPathUnitsFromDir "${r[${filetype}_directory]}" "${retroarchBasename}/$(basename "${r[${filetype}_directory]}")" "${r[${filetype}_directory_depth]}" true "retroarch-${filetype}"
    done

    # Process the retroarch content root
    if [[ ${r[content_directory_filter]} ]]; then
        newPathUnitsFromDir "${ARKLONE[retroarchContentRoot]}" "${retroarchBasename}/$(basename "${ARKLONE[retroarchContentRoot]}")" 1 true "${r[content_directory_filter]%%|}" "${ARKLONE[ignoreDir]}/retropie-retroarch-content-root.ignore"
    fi

    # Unset r to prevent conflicts on next loop
    unset r
done

