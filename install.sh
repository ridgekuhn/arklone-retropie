#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

source "/opt/retropie/supplementary/arklone/src/config.sh"

echo "Now installing arklone cloud sync utility..."

############
# FILESYSTEM
############
# Create arklone user config dir
# eg,
# /home/user/.config/arklone
# This step is actually redundant since it's already handled by config.sh
# but should stay since it is required for install
if [[ ! -d "${ARKLONE[userCfgDir]}" ]]; then
    mkdir "${ARKLONE[userCfgDir]}"
    chown "${USER}":"${USER}" "${ARKLONE[userCfgDir]}"
fi

########
# RCLONE
########
# Get the system architecture
SYS_ARCH=$(uname -m)

case $SYS_ARCH in
    armv6*)
        SYS_ARCH="arm"
    ;;
    armv7*)
        SYS_ARCH="arm-v7"
    ;;
    aarch64 | arm64)
        SYS_ARCH="arm64"
    ;;
    i386 | i686)
        SYS_ARCH="386"
    ;;
    x86_64)
        SYS_ARCH="amd64"
    ;;
esac

#Get the rclone download URL
RCLONE_PKG="rclone-current-linux-${SYS_ARCH}.deb"
RCLONE_URL="https://downloads.rclone.org/${RCLONE_PKG}"

# Check if user already has rclone installed
if rclone --version >/dev/null 2>&1; then
    # Set a lock file so we can know to restore user's settings on uninstall
    touch "${ARKLONE[userCfgDir]}/.rclone.lock"
fi

# Upgrade the user to the latest rclone
wget "${RCLONE_URL}" -O "${HOME}/${RCLONE_PKG}" \
    && sudo dpkg --force-overwrite -i "${HOME}/${RCLONE_PKG}"

rm "${HOME}/${RCLONE_PKG}"

# Make rclone config directory if it doesn't exit
if [[ ! -d "${HOME}/.config/rclone" ]]; then
    mkdir "${HOME}/.config/rclone"
    chown "${USER}":"${USER}" "${HOME}/.config/rclone"
fi

# Backup user's rclone.conf
if [[ -f "${HOME}/.config/rclone/rclone.conf" ]]; then
    cp "${HOME}/.config/rclone/rclone.conf" "${HOME}/.config/rclone/rclone.conf.arklone$(date +%s).bak"
else
    touch "${HOME}/.config/rclone/rclone.conf"
    chown "${USER}":"${USER}" "${HOME}/.config/rclone/rclone.conf"
fi

###############
# INOTIFY-TOOLS
###############
# Check if user already has inotify-tools installed
if which inotifywait >/dev/null 2>&1; then
    # Set a lock file so we can know to not remove on uninstall
    touch "${ARKLONE[userCfgDir]}/.inotify-tools.lock"
else
    # Install inotify-tools
    sudo apt update && sudo apt install inotify-tools -y
fi

#########
# ARKLONE
#########
# Make scripts executable
SCRIPTS=($(find "${ARKLONE[installDir]}" -type f -name "*.sh"))
for script in ${SCRIPTS[@]}; do
    sudo chmod a+x "${script}"
done

# Make systemd units directory writeable for user
sudo chown "${USER}":"${USER}" "${ARKLONE[installDir]}/src/systemd/units"

