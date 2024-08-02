# stf-community-unix
Unix installer for Sonic The Fighters: Community Edition

## Windows Notice
This installer is **not** the same as the Windows installer, and will not work with Windows systems. You have been warned.

## Prerequisites
- xcode (if on Mac)
- RPCS3 installed
- Have installed and booted Sonic The Fighters at least once

## Mac Instructions
1. Open a terminal and type `xcode-select --install` and hit Enter to make sure you have xcode installed.
2. Download `install_ce.sh`.
3. Open a terminal, and type `cd ~/Downloads/`, and hit Enter.
4. Type `chmod +x ./install_ce.sh`, and hit Enter.
5. Type `./install_ce.sh`, and hit Enter.
6. Have fun!

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
- A: Remove CE, then reinstall Sonic the Fighters, and *then* reinstall CE.
- Q: Why are you like this?
- A: Bill Michaelsoft 4P+K > P+K > P+K > P+K > P+B'd my dog.

## credits
All CE Contributors: [CREDITS.txt](https://github.com/coatlessali/stf-community-unix/blob/main/CREDITS.txt)
psarc tool: http://ferb.fr/ps3/PSARC/psarc-0.1.3.tar.bz2 - compiled on Ubuntu 18.04

flips: https://github.com/Alcaro/Flips

## legal notices
Flips is licensed under the GNU General Public License v3. You can find it's source code, as well as individual downloads at the link above.
psarc did not come with a license. It has been provided here, precompiled and unmodified for convenience in installation on Linux systems. This was not done with the intent to infringe on the author's copyright. There is no contact information provided.
