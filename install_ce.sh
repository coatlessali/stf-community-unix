#!/bin/bash
if [[ "$OSTYPE" == "freebsd"* ]]; then
    echo Why are you trying to game on FreeBSD?
    echo If you really want this, psarc can probably be compiled from source. Not sure about flips.
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
	if [[ -n "$RPCS3_PATH_OVERRIDE" ]]; then
		echo Overriding rpcs3 path...
		if [[ "$RPCS3_PATH_OVERRIDE" == "appimage" ]] || [[ "$RPCS3_PATH_OVERRIDE" == "native" ]]; then
			if [ -d "/home/$USER/.config/rpcs3/dev_hdd0/game" ]; then
				gamedir="/home/$USER/.config/rpcs3/dev_hdd0/game"
			else
				echo AppImage/Native directory not found. && exit
			fi
		elif [[ "$RPCS3_PATH_OVERRIDE" == "flatpak" ]]; then
			if [ -d "/home/$USER/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0/game" ]; then
				gamedir="/home/$USER/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0/game"
		    else
				echo Flatpak directory not found. && exit
			fi
		elif [[ "$RPCS3_PATH_OVERRIDE" == "emudeck_internal" ]]; then
		    if [ -d "/home/$USER/Emulation/storage/rpcs3/dev_hdd0/game" ]; then
		    	gamedir="/home/$USER/Emulation/storage/rpcs3/dev_hdd0/game"
		    else
		    	echo "EmuDeck (Internal Storage) directory not found." && exit
		    fi
		elif [[ "$RPCS3_PATH_OVERRIDE" == "emudeck_external" ]]; then
		    if [ -d "/run/media/mmcblk0p1/Emulation/storage/rpcs3/dev_hdd0/game" ]; then
		    	gamedir="/run/media/mmcblk0p1/Emulation/storage/rpcs3/dev_hdd0/game"
		    else
		    	echo "EmuDeck (External Storage) directory not found." && exit
		    fi
		else
		    echo Requested path override "$RPCS3_PATH_OVERRIDE" is invalid. Please select one of the following valid overrides:
		    echo appimage
		    echo native
		    echo flatpak
		    echo emudeck_internal
		    echo emudeck_external
		    exit
		fi
	else
    	echo Checking for rpcs3 path...
    	# Check for AppImage Path
		if [ -d "/home/$USER/.config/rpcs3/dev_hdd0/game" ]; then
	    	echo Found native/AppImage rpcs3 folder\!
	    	gamedir="/home/$USER/.config/rpcs3/dev_hdd0/game"
		# Check for Flatpak Path
		elif [ -d "/home/$USER/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0/game" ]; then
	    	echo Found Flatpak rpcs3 folder\!
	    	gamedir="/home/$USER/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0/game"
		# Check for Emudeck on Internal Storage
		elif [ -d "/home/$USER/Emulation/storage/rpcs3/dev_hdd0/game" ]; then
			echo Found Emudeck rpcs3 folder on Internal Storage\!
			gamedir="/home/$USER/Emulation/storage/rpcs3/dev_hdd0/game"
    	# Check for Emudeck on External Storage
    	elif [ -d "/run/media/mmcblk0p1/Emulation/storage/rpcs3/dev_hdd0/game" ]; then
   	    	echo Found Emudeck rpcs3 folder on External Storage\!
   	    	gamedir="/run/media/mmcblk0p1/Emulation/storage/rpcs3/dev_hdd0/game"
		else
	    	echo Could not find rpcs3 installed games folder. Make sure it is present at one of the following valid locations, and you have installed the PlayStation 3 firmware files.
	    	echo Note: Support for Emudeck is considered limited/experimental at this time.
	    	echo ""
	    	echo "/home/$USER/.config/rpcs3/dev_hdd0/game"
	    	echo "/home/$USER/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0/game"
	    	echo "/home/$USER/Emulation/storage/rpcs3/dev_hdd0/game"
	    	echo "/run/media/mmcblk0p1/Emulation/storage/rpcs3/dev_hdd0/game"
	    	exit
		fi
	fi
    echo Checking for Sonic The Fighters...
    if [ -d "$gamedir/NPUB30927" ]; then
        echo North American Sonic The Fighters found. "[NPUB30927]"
        stfdir="$gamedir/NPUB30927"
    elif [ -d "$gamedir/NPEB01162" ]; then
    	echo European Sonic The Fighters found. "[NPEB01162]"
    	stfdir="$gamedir/NPEB01162"
    elif [ -d "$gamedir/NPJB00250" ]; then
        echo Japanese Sonic The Fighters found. "[NPJB00250]"
        stfdir="$gamedir/NPJB00250"
    else
    	echo "Sonic The Fighters not found. Please make sure it is installed with one of the following valid serials: [NPUB30927], [NPEB01162], [NPJB00250]."
        exit
    fi
	echo Running sanity checks...
	if ! command -v curl &> /dev/null 
	then
	    echo "curl not found!"
	    exit 1
	fi
	echo Entering Sonic The Fighters directory...
	cd "$stfdir/USRDIR" || exit
	echo Downloading needed files...
	curl -O https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/patches.tar.gz
	curl -O https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/flips
	curl -O https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/psarc
	
	chmod +x ./psarc
	chmod +x ./flips
	echo Extracting rom.psarc...
	./psarc -x rom.psarc
	echo Deleting psarc tool...
	rm psarc
	echo Moving rom.psarc to original.psarc...
	mv rom.psarc original.psarc
	mv flips patches.tar.gz rom/
	echo Entering rom directory...
	cd rom || exit
	echo Extracting patches...
	tar -xaf patches.tar.gz
	rm patches.tar.gz
	mv rom_*.bps stf_rom/
	echo Patching string_array.farc...
	./flips --apply string_array.bps string_array.farc
	rm string_array.bps
	mv flips stf_rom/
	cd stf_rom || exit
	echo Patching rom_code1.bin...
	./flips --apply rom_code1.bps rom_code1.bin
	echo Patching rom_data.bin...
	./flips --apply rom_data.bps rom_data.bin
	echo Patching rom_tex.bin...
	./flips --apply rom_tex.bps rom_tex.bin
	echo Cleaning up...
	rm flips
	rm ./*.bps
	echo Installation Complete\! Have fun\!
	echo ...and remember: Tux Loves You\!
	exit
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo MacOS detected!
    # Check for StF
    gamedir="/Users/$USER/Library/Application Support/rpcs3/dev_hdd0/game"
    if [ -d "$gamedir/NPUB30927" ]; then
        echo North American Sonic The Fighters found. "[NPUB30927]"
        stfdir="$gamedir/NPUB30927"
    elif [ -d "$gamedir/NPEB01162" ]; then
    	echo European Sonic The Fighters found. "[NPEB01162]"
    	stfdir="$gamedir/NPEB01162"
    elif [ -d "$gamedir/NPJB00250" ]; then
        echo Japanese Sonic The Fighters found. "[NPJB00250]"
        stfdir="$gamedir/NPJB00250"
    else
    	echo Sonic The Fighters not found. Please make sure it is installed with one of the following valid serials: "[NPUB30927], [NPEB01162], [NPJB00250]."
        exit
    fi
    if [ -d $(xcode-select --install) ]; then
        echo xcode installed\!
    else
       echo Please install xcode and re-run this script afterwards...
       xcode-select --install
       exit
    fi
    echo Downloading psarc tool...
    curl http://ferb.fr/ps3/PSARC/psarc-0.1.3.tar.bz2 -O
    echo Extracting tarball...
    tar -xf psarc-0.1.3.tar.bz2
    echo Entering psarc directory...
    cd psarc-0.1.3 || exit
    echo Compiling...
    make
    echo Making ./psarc executable...
    chmod +x psarc
    echo Moving ./psarc into "$stfdir/USRDIR/"... 
    mv psarc "$stfdir/USRDIR/"
    echo Exiting psarc directory...
    cd ..
    echo Removing psarc directory...
    rm -rf psarc-0.1.3*
    echo Entering "$stfdir/USRDIR/"...
    cd "$stfdir/USRDIR/" || exit
    ./psarc -x rom.psarc && echo Extracted successfully\!
	echo Moving rom.psarc to original.psarc...
	mv rom.psarc original.psarc
	echo Removing psarc tool...
	rm psarc
	echo Entering rom directory...
	cd rom || exit
	echo Downloading patches...
	curl https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/patches.tar.gz -O
    echo Extracting patches...
    tar -xf patches.tar.gz
    rm patches.tar.gz
    echo Downloading Multipatch...
    curl https://projects.sappharad.com/multipatch/multipatch20_cmd.zip -O
    echo Extracting Multipatch...
    unzip multipatch20_cmd.zip
    rm multipatch20_cmd.zip
    echo Patching...
    ./cmdMultiPatch --apply rom_code1.bps stf_rom/rom_code1.bin stf_rom/rom_code1.bin > /dev/null && echo rom_code1 OK\! || rom_code1 FAIL\!
    ./cmdMultiPatch --apply rom_data.bps stf_rom/rom_data.bin stf_rom/rom_data.bin > /dev/null && echo rom_data OK\! || rom_data FAIL\!
    ./cmdMultiPatch --apply rom_tex.bps stf_rom/rom_tex.bin stf_rom/rom_tex.bin > /dev/null && echo rom_tex OK\! || rom_tex FAIL\!
    ./cmdMultiPatch --apply string_array.bps string_array.farc string_array.farc > /dev/null && echo string_array OK\! || string_array FAIL\!
    echo Cleaning up...
    rm ./*.bps
    rm cmdMultiPatch
    echo Sonic The Fighters: Community Edition has been installed\!
fi
