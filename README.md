# stf-community-unix
Unix installer for Sonic The Fighters: Community Edition

## THIS IS OSBOLETE
Don't use this unless you really have no other way of installing CE. Use [HoneyPatcher](https://github.com/coatlessali/HoneyPatcher/) instead.

## Windows Notice
This installer is **not** the same as the Windows installer, and will not work with Windows systems. You have been warned.

## Prerequisites
- MacOS 12+ / Linux with GLIBC >= Ubuntu 20.04 / SteamOS
- ~~xcode (if on Mac)~~ This is no longer necessary as of 09/25/2024.
- RPCS3 installed
- Have installed and booted Sonic The Fighters at least once

## Mac Instructions
1. Download `install_ce.sh`.
2. Open a terminal, and type `cd ~/Downloads/`, and hit Enter.
3. Type `chmod +x ./install_ce.sh`, and hit Enter.
4. Type `./install_ce.sh`, and hit Enter.
5. Have fun!

## Linux/Steam Deck Instructions
1. Download `install_ce.sh`.
2. Open your favorite Terminal Emulator (GNOME Terminal, Konsole, etc).
3. Type `cd ~/Downloads/` and hit Enter.
4. Type `chmod +x ./install_ce.sh` and hit Enter.
5. Type `./install_ce.sh` and hit Enter.
6. Have fun!

## RPCS3_PATH_OVERRIDE Variable
When executing the script on Linux/Steam Deck, you can override where the script checks for a valid RPCS3 installation, like so: `RPCS3_PATH_OVERRIDE=native ./install_ce.sh`.

Valid values for `RPCS3_PATH_OVERRIDE` are:
- `appimage`
- `native`
- `flatpak`
- `emudeck-internal`
- `emudeck-external` 

## Real PS3 Install
When executing the script on MacOS/Linux/Steam Deck, you can set the environment variable `PS3_IP` to your PS3's IP Address to install the game on your real PS3.

This will require a PS3 with an FTP server already running, and the computer must be on the same network. Get the IP Address of the PS3 and plug it in like so: `PS3_IP=1.2.3.4 ./install_ce.sh`.

This may be unreliable depending on your network conditions.

## FAQ
- Q: How do I know what version I have?
- A: The installer is rolling release and will not have a version number. You can see when updates happen [here](https://github.com/coatlessali/stf-community-unix/commits/main/).
- Q: How do I remove CE?
- A: In RPCS3, right click Sonic The Fighters -> Remove -> Remove HDD Game. Then reinstall your pkg file.
- Q: How do I update?
- A: Simply rerun the script.
- Q: Why are you like this?
- A: Bill Michaelsoft 4P+K > P+K > P+K > P+K > P+B'd my dog.
- Q: What is GLIBC? How do I know it's new enough?
- A: GLIBC is the standard C library used in most (if not all) programs on Linux. You can usually run programs compiled for an old GLIBC on a new GLIBC, but not the other way around. I decided to settle on Ubuntu 20.04, as it's currently the oldest LTS version of Ubuntu in mainstream support. Any modern distro should be able to match the version of GLIBC it provides. Basically, if you don't know what this means, don't worry about it.
- Q: Why MacOS 12?
- A: For similar reasons to the above. You should be able to run any basic binaries compiled on MacOS 12 on anything MacOS 12+. MacOS 12 is the latest supported version of MacOS, the version I have forcefully installed on my MacBook Pro 9,2 using [Dortania OpenCore Legacy Patcher](https://dortania.github.io/OpenCore-Legacy-Patcher/), and at the time of writing is soon to go end-of-life. **RPCS3 no longer supports MacOS 12 anyways.** If you run an outdated Mac and still want to run this script i.e. for real HW installs, I'd suggest moving to Linux for not only this purpose, but also to ensure you have an up-to-date computer.

## credits
All CE Contributors: [CREDITS.txt](https://github.com/coatlessali/stf-community-unix/blob/main/CREDITS.txt)
psarc tool: http://ferb.fr/ps3/PSARC/psarc-0.1.3.tar.bz2 - compiled on Ubuntu 18.04

flips: https://github.com/Alcaro/Flips

## legal notices
Flips is licensed under the GNU General Public License v3. You can find it's source code, as well as individual downloads at the link above.
psarc did not come with a license. It has been provided here, precompiled and unmodified for convenience in installation. This was not done with the intent to infringe on the author's copyright. There is no contact information provided.
