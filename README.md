# arklone #

rclone cloud sync utility for [RetroPie](https://github.com/RetroPie/)

Watches save directories for RetroArch, and select standalone games.

This project offers no warranties or guarantees. Always make extra backup copies of your data. Use at your own risk!

arklone is released under a GNU GPLv3 license. See [LICENSE.md](/LICENSE.md) for more information.

rclone, RetroArch, EmulationStation, and RetroPie are the properties of their respective owners.

---

**Table of Contents**

1. [Installation](#installation)
2. [rclone Configuration](#configuration)
3. [First Run](#first-run)
4. [Settings Dialog](#settings-dialog)
5. [Syncing with the Cloud](#syncing-with-the-cloud)
6. [Advanced RetroArch Configuration](#settings-dialog)
7. [Recommended RetroArch Configuration](#known-bugs)
8. [Advanced arklone Configuration](#advanced-arklone-configuration)
9. [Troubleshooting](#troubleshooting)
10. [Developers](/DEVELOPERS.md)
11. [FAQ](#FAQ)

&nbsp;

---

# Installation #

This module has been submitted to be included in the RetroPie setup script. See [this pull request](https://github.com/RetroPie/RetroPie-Setup/pull/3421) for updates.

To test:

* Fork the project's [RetroPie-Setup arklone branch](https://github.com/ridgekuhn/RetroPie-Setup/tree/arklone).

or

* Download the [RetroPie module script](https://raw.githubusercontent.com/ridgekuhn/RetroPie-Setup/arklone/scriptmodules/supplementary/arklone.sh) and place in `~/RetroPie-Setup/scriptmodules/supplementary/`.

Then, run the RetroPie setup script, and navigate to Manage Packages -> Manage optional packages -> arklone

*If you are using RetroPie 4.7.1 or older, and have never updated RetroArch, you must do so if you want to use the `sort_savefiles_by_content_enable` and `sort_savestates_by_content_enable` options in retroarch.cfg!*

&nbsp;

---

# rclone Configuration #

To begin using arklone, you must create an rclone config file. For [most cloud providers](https://rclone.org/remote_setup/), this will involve installing `rclone` to a computer with a web browser, like your desktop or laptop. See the [rclone docs](https://rclone.org/docs/#configure) for more information on how to do this for your specific provider. Make sure you [install the latest version of rclone](https://rclone.org/downloads/), (1.56.2 as of this writing) to your desktop or laptop. *If you use a package manager like `apt`, the repository version will be outdated.*

Once you have completed this process, copy the `rclone.conf` file from your computer to `~/.config/rclone/rclone.conf` on your RetroPie device. Your `rclone.conf` can be located by running:

```
rclone config file
```

&nbsp;

---

# First Run #

From EmulationStation, navigate to RetroPie -> Arklone. Or, from the RetroPie setup script, navigate to Configuration/Tools -> arklone or Manage Packages -> Manage optional packages -> arklone.

On first run, you will be greeted by a prompt asking if you'd like to change your RetroArch configurations to the recommended settings.

Obviously, this is recommended!

This will set the following settings in your retroarch.cfg (and your retroarch32/retroarch.cfg):

```
savefile_directory = "~/.config/retroarch/saves"
savefiles_in_content_dir = "false"
sort_savefiles_enable = "false"
sort_savefiles_by_content_enable = "true"

savestate_directory = "~/.config/retroarch/saves"
savestates_in_content_dir = "false"
sort_savestates_enable = "false"
sort_savestates_by_content_enable = "true"
```

This will result in savefiles and savestates being stored in the same directory hierarchy as your RetroArch content root, in `~/.config/retroarch/saves`

eg,
`~/.config/retroarch/saves/nes/TheLegendOfZelda.srm`
`~/.config/retroarch/saves/nes/TheLegendOfZelda.savestate0`

![First run screen](/.github/arklone1.png)

&nbsp;

---

# Settings Dialog #

* **Set cloud remote**
		Allows you to select from the remotes you set up in `rclone.conf`
* **Manually sync saves**
		Manually send/receive from the cloud remote
* **Enable/Disable automatic saves sync**
		Watches directories for changes and syncs them to your selected remote.
* **Regenerate RetroArch path units**
		Re-scans for new RetroArch directories to watch and generates path units for them.
* **View log file**
		Shows the log file.

![Arklone main menu](/.github/arklone2.png)

&nbsp;

---

# Syncing with the Cloud #

Keeping multiple devices synced can be difficult. arklone tries to do its best, but you should always keep an extra backup copy just in case.

## Automatic Syncing ##

If you enable automatic syncing in the settings dialog, arklone assumes the copy of your data stored in the cloud is the canonical and "always correct" version. On system boot, arklone will run before EmulationStation and attempt to receive updates from the cloud remote. *If the remote contains a newer version of a file, it will overwrite the local copy.* On this initial sync, *arklone only receives updates and does not send anything back*.

If the boot sync process succeeds, arklone will begin watching all your save directories, and *send updates any time a write is detected, overwriting older versions on the cloud remote*. It will also receive updates at the interval set when you enabled automatic syncing.

If the boot process fails or is cancelled by the user, the user is given the chance to try again, or the [dirty boot state](#dirty-boot-state) is set.

## Manual Syncing ##

The manual sync dialog allows you to send or receive any directory which has a path module registered with arklone.

&nbsp;

---

# Dirty Boot State #

If automatic syncing is enabled and the boot sync process fails, the dirty boot state is set. Automatic syncing is disabled for the rest of the session, and will resume after the next boot. On the next boot, the user is shown a warning message about potential data loss before the boot sync proceeds.

To manually reset the dirtyboot state, delete the lock file located at:
`~/.config/arklone/.dirtyboot`

&nbsp;

---

# Advanced RetroArch Configuration #

This section is for users who wish to have more control over their retroarch.cfg settings and save directories.


## Supported RetroArch Configuration ##

RetroPie's RetroArch configuration file is stored at `/opt/retropie/configs/all/retroarch.cfg`.

Since RetroPie allows you to save configuration overrides on a per-system basis, make sure that none of them override the global `retroarch.cfg`.

The following settings are supported:

```
savefile_directory
savefiles_in_content_dir
sort_savefiles_enable
sort_savefiles_by_content_enable

savestate_directory
savestates_in_content_dir
sort_savestates_enable
sort_savestates_by_content_enable
```

For the next examples, `filetype` refers to either `savefile` or `savestate`.

If `filetypes_in_content_dir = "true"`, it will override the other related settings, and create save data next to the content file.

Otherwise, if `sort_filetypes_enable = "true"`, save data will be organized by libretro core inside `filetype_directory`.
eg,
`/path/to/filetype_directory/FCEUmm/TheLegendOfZelda.srm`

If `sort_filetypes_by_content_enable = "true"`, save data will be organized by the parent directory of the content file.
eg,
`/path/to/filetype_directory/nes/TheLegendOfZelda.srm`

If both `sort_filetypes_enable = "true"` and `sort_filetypes_by_content_enable = "true"`, save data will be organized by the parent directory of the content file, then by libretro core.
eg,
`/path/to/filetype_directory/nes/FCEUmm/TheLegendOfZelda.srm`

## Recommended RetroArch Configuration ##

```
savefile_directory = "~/.config/retroarch/saves"
savefiles_in_content_dir = "false"
sort_savefiles_enable = "false"
sort_savefiles_by_content_enable = "true"

savestate_directory = "~/.config/retroarch/states"
savestates_in_content_dir = "false"
sort_savestates_enable = "false"
sort_savestates_by_content_enable = "true"
```

Also see [First Run](#first-run).

&nbsp;

---

# Advanced arklone Configuration #

Arklone has a few settings that can be changed by the user, mostly paths where arklone looks for various files. The user configuration file is stored at `~/.config/arklone/arklone.cfg`.


## Resetting to "First Run" State ##

Setting `remote` to an empty string forces the settings dialog to show the [First Run](#first-run) screen again.

&nbsp;

**arklone.cfg**

```
remote = ""
```

## Changing RetroArch Content Root ##

Where `filetype` refers to either `savefile` or `savestate`:

If your `retroarch.cfg` contains the settings `filetypes_in_content_dir = "true"` or `sort_filetypes_by_content_enable = "true"`, arklone expects your RetroArch content to be organized in a directory hierarchy with one level of subdirectories, where each contains all content for a particular platform.
eg,
`retroarchContentRoot/nes/TheLegendOfZelda.rom`

&nbsp;

**arklone.cfg**

```
retroarchContentRoot = "/absolute/path/to/retroarchContentRoot"
```

RetroPie's default RetroArch Content Root is `~/RetroPie/roms`. We do not recommending changing this setting.

arklone also supports select standalone software and "ports". See the [systemd/units](/systemd/units) for a list, and the [Path Units](/DEVELOPERS.md#path-units) section of the developer docs for more info.

## Multiple RetroArch Instances ##

arklone supports multiple instances of RetroArch, in case your distro has both 64-bit and 32-bit builds installed. Set `retroarchCfg` to a space-delimited list of absolute paths to each `retroarch.cfg`.

&nbsp;

**arklone.cfg**

```
retroarchCfg = "/home/user/.config/retroarch/retroarch.cfg /home/user/.config/retroarch32/retroarch.cfg"
```

## rclone Filters ##

arklone passes various filter lists to `rclone` when a sync script is run. See the [Path Units](/DEVELOPERS.md#path-units) and [rclone Filters](/DEVELOPERS.md#rclone-filters) sections of the developer docs for more info.

&nbsp;

---

# Troubleshooting #

## RetroArch Saves Not Syncing ##

arklone only watches the RetroArch save directories it knew about when it first generated the corresponding path units. If you selected "Set Recommended Settings" on your first run, arklone will automatically generate path units for all your RetroArch content directories which are not empty. If you've added games since then and some of your save directories are not being synced automatically, try manually regenerating them from the arklone dialog menu.

If you change any of the above settings in `retroarch.cfg`, you must also manually regenerate the path units.


## Ports, Standalone Apps, or Other Game Saves Not Syncing ##

RetroPie supports a variety of standalone apps and ports, and we probably haven't caught up to them yet. Please [create a new issue](https://github.com/ridgekuhn/arklone-arkos/issues) so we can include it in a future update.


## Logging ##

To save unnecessary writes to your SD card or hard drive, arklone writes logs to the RAM filesystem at `/dev/shm/arklone.log`. This file disappears when the system is powered down, but you can view it by opening the arklone settings dialog and selecting "View log file".

&nbsp;

---

# Developers #

Contributions are welcome! Please see the [developer docs](/DEVELOPERS.md).

&nbsp;

---

# FAQ #

## Can I use it on Windows, MacOS, or other Linux Distros? ##

**Linux**

arklone is written in bash, and relies on tools like `apt`, `dpkg`, and `inotify-tools`. It should theoretically work on any Debian-based distro using RetroArch, as long as your content is organized in the [expected directory hierarchy](#changing-retroarch-content-root). See [Advanced arklone Configuration](#advanced-arklone-configuration) for more info. If you are using a Debian-based distro like Ubuntu or Mint, we strongly recommend installing RetroArch via the [RetroPie setup script for PC](https://retropie.org.uk/docs/Debian/). 

**Windows and MacOS**

If your cloud provider offers a desktop client, you should install and use that instead.

## Can I add my own custom directories? ##

See the [Path Units](/DEVELOPERS.md#path-units) section of the developer docs.

## Can I Use arklone to Sync ROMs or BIOS files? ##

Not unless you want to [set it up yourself](/DEVELOPERS.md). Many users' game libraries are massive and would probably exceed the storage limit on your cloud account several times over. There are also system performance implications for keeping this much data synced on low-power devices, like the ones ArkOS is designed for, where the background sync operations may affect gameplay. It's probably much faster/efficient to transfer your game libraries from device-to-device via USB or over your LAN.

## Why Am I Seeing "Directory Not Found" Errors in the Log? ##

If you have automatic syncing enabled, arklone attempts to download all the different save directories it knows about from the cloud remote. If they don't exist on the cloud remote, these messages are generated for logging and debugging purposes. If there are any actual problems downloading save data from the cloud, you will be presented with a dialog screen, and asked if you want to proceed or view the log file. If you don't see this dialog screen and your device boots straight into EmulationStation, then everything is ok!

