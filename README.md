# FAF on Linux

A set of scripts to automatically set up Supreme Commander: Forged Alliance with [Forged Alliance Forever](https://faforever.com/) on Linux. Tested on Ubuntu, Fedora, and Arch, should work on other distributions as well.

## Setup instructions

1. Install prerequisites from your distribution's package manager:
   - Debian and derivatives (Ubuntu, Pop!\_OS, Linux Mint, etc):
     - Ensure `i386` architecture is enabled: `sudo dpkg --add-architecture i386`
     - `sudo apt install git wget jq cabextract libxcomposite1:amd64 libxcomposite1:i386 libfreetype6:amd64 libfreetype6:i386`
   - Fedora and Red Hat-based:
     - `sudo dnf install git wget jq cabextract patch libXcomposite.x86_64 libXcomposite.i686 freetype.x86_64 freetype.i686`
   - Arch Linux and derivatives (Manjaro, EndeavourOS, etc):
     - `sudo pacman -Syu git wget jq cabextract libxcomposite lib32-libxcomposite freetype2 lib32-freetype2`
   - Other distributions:
     - Commands needed: `git`, `wget`, `jq`, `cabextract`, `patch`
     - Libraries needed:
       - Both 32-bit and 64-bit versions of `libXcomposite.so.1`
       - Both 32-bit and 64-bit versions of `libfreetype.so.6`
1. Install Steam, then install Supreme Commander: Forged Alliance from Steam
   - In Properties -> Compatibility, check "Force the use of a specific Steam Play compatibility tool", and select "Proton Experimental"
   - Start the game from Steam. This step is needed to download and unpack Proton Experimental.
   - **Note:** the game may lag horribly or not even start. This is fine, as the rest of this guide should still work.
   - If you want to play Forged Alliance on Steam, set `PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 %command%` in launch options. If you only wish to play on FAF, this step is not necessary.
1. Clone this repository
   - Open a terminal where the installation should be located, then run `git clone https://github.com/FAForever/faf-linux`
   - This will create a new folder named faf-linux, where the client will be installed.
1. Run `./setup.sh` to set up the local wine prefix, the FAF client, java, and others
   - Note: the script will install everything into the path where you cloned this repository. If you wish to move the installation later, edit the paths in `common-env` then re-run `./set-client-paths.sh` and `./install-shortcut.sh`.
1. Start the FAF client with `./run` and log in
1. After logging in, close the FAF client and run `./set-client-paths.sh`
1. To launch FAF, run `./run`
1. If you wish to launch FAF without using the terminal, run `./install-shortcut.sh`. FAF will show up as "Forged Alliance Forever" in your application launcher.

## How to update after installation

1. Run `./update.sh perform` to update necessary components automatically
1. The update script will not automatically remove old versions currently. If new versions work, old versions are safe to delete.

## Manually updating individual components

The script `./update-component.sh` is provided for convenient updating of certain parts. Generally you do not need to use this.

- To update dxvk, run `./update-component.sh dxvk <new version>`. Versions look like "1.9.3".
- To update the FAF client, run `./update-component.sh faf-client <new version>`. Versions look like "2021.10.0".
- To update java, run `./update-component.sh java "<java url>"`.
  - The FAF client (at time of writing) wants Java 17.
  - Java URL is currently <https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.5%2B8/OpenJDK17U-jdk_x64_linux_hotspot_17.0.5_8.tar.gz>
  - These may change in the future. Check the `versions` file for current working URLs.

## Help, it doesn't work!

Please ping `@iczero#8740` on the [FAF Discord guild](https://discord.com/invite/hgvj6Af), channel `#linux-support`.

## Weird issues and other nonsense

- Mouse cursor stuck, can't click things in lobby: quit out of the game and the FAF client, run `./run-offline`, click past the intro videos until you get to the main menu, exit the game, then try starting a game from FAF again
- Forged Alliance minimizes itself on Alt-Tab: run `./launchwrapper winecfg`, go to "Graphics", then check the "Emulate a virtual desktop" box. Note: This may cause everything to break. If it does, just run `winecfg` again and uncheck the box.
  - Warning: as of 2022-10-24, this *does* cause everything to break. You have been warned.
  - Gamescope is an alternative, see below
- Game crashes with "Unable to create Direct3D", logs have wine error "Application requires child window rendering": libXcomposite is missing or failed to initialize, try installing `libxcomposite` or `libXcomposite` from package manager (the 32-bit version as well)
  - on Debian and derivatives (including Ubuntu), install `libxcomposite:amd64` and `libxcomposite:i386`
  - on Fedora and Red Hat derivatives, install `libXcomposite` and `libXcomposite.i686`
  - on Arch and derivatives, install `libxcomposite` and `lib32-libxcomposite`
  - see <https://github.com/ValveSoftware/wine/blob/46a904624f1c3f62df806e9f0bff2bfda6bdf727/dlls/winex11.drv/vulkan.c#L276>, <https://github.com/ValveSoftware/wine/blob/46a904624f1c3f62df806e9f0bff2bfda6bdf727/dlls/winex11.drv/x11drv_main.c#L501>
- FAF client crashes on launch with massively enormous error message, at the bottom it says something along the lines of "cannot use an unresolved DNS server address" chances are there's something in your /etc/resolv.conf that netty does not understand (for example, scoped IPv6 addresses). Install `systemd-resolved` if possible.
- Install script errors in dxvk, game is rendered wrong: the dxvk install script currently has issues with spaces. Move `faf-linux` to a path without spaces, then try again. There is an open PR for this.
- If you encounter strange display issues, consider using gamescope. In `common-env`, set `use_gamescope="1"` (or add that line if it does not already exist)
- Mod selector in client doesn't work: this has been fixed by a recent commit, however it only takes effect on new installations. To fix the problem without a reinstall, find `game_data_path` in `common-env`, then replace `Local Settings/Application Data` with `AppData/Local`.
- Failed to create vulkan instance
  - May appear as:
    - `0024:err:vulkan:__wine_create_vk_instance_with_callback Failed to create instance`
    - `0024:err:vulkan:wine_vk_instance_load_physical_devices Failed to enumerate physical devices, res=-3`
    - `terminate called after throwing an instance of 'dxvk::DxvkError'`
  - Possible issues:
    - Vulkan drivers are not installed. Please install the appropriate Vulkan drivers for your GPU and distribution and install them.
    - 32-bit graphics drivers (including Vulkan libraries) are not installed. Please ensure both 32-bit and 64-bit graphics drivers, including Vulkan support, are installed.
    - You are on Arch and have accidentally installed `lib32-amdvlk`. AMDVLK is the old AMD Vulkan driver and causes many issues. Unless you are sure you need AMDVLK, uninstall `lib32-amdvlk`, and if necessary, install `lib32-vulkan-radeon` (newer AMD RADV driver) in its place.
- No adapters found
  - May appear as:
    - `Skipping Vulkan 1.2 adapter`
    - `DXVK: No adapters found.`
    - "Requested display count exceeds those available."
  - Your graphics driver lacks support for features required by the installed dxvk version. Please update your graphics drivers if possible.
  - If updating graphics drivers is not an option, manually downgrade dxvk (`./update-component.sh dxvk 1.10.3`) then add the line `dxvk_pin_version="1"` at the bottom of `common-env` to prevent the updater script from reverting to a newer version of dxvk.

## Why should you use this
﻿
- Years of my own suffering have culminated in this massive pile of hacks
- I will literally fix your issues with you over discord because I have no life
- I suck at faf so I literally spend more time maintaining these scripts than playing faf
