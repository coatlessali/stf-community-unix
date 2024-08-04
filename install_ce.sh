#!/bin/bash

# REAL PS3 HANDLING
if [[ -n "$PS3_IP" ]]; then
	# Check for RPCS3_PATH_OVERRIDE, which isn't meant to be used with this mode
	if [[ -n "$RPCS3_PATH_OVERRIDE" ]]; then
		echo PS3_IP and RPCS3_PATH_OVERRIDE cannot be used together\!
		exit
	fi

	# Basically just seeing if the PS3 will connect. If it doesn't, the || is run and the script exits.
	echo Attempting to connect to PS3...
	curl --silent "ftp://$PS3_IP/dev_hdd0/game/" || exit
	echo Connection Established\!
	
	# Region checking, the && will only execute if the previous command is successful. This will set a variable that controls the region.
	curl --silent "ftp://$PS3_IP/dev_hdd0/game/NPEB01162/USRDIR/" && region="NPEB01162" && echo Set European Serial "[$region]".
	curl --silent "ftp://$PS3_IP/dev_hdd0/game/NPJB00250/USRDIR/" && region="NPJB00250" && echo Set Japanese Serial "[$region]".
	curl --silent "ftp://$PS3_IP/dev_hdd0/game/NPUB30927/USRDIR/" && region="NPUB30927" && echo Set North American Serial "[$region]".
	echo Attempting to download rom.psarc from "$region"...
	
	# Making a skeleton dev_hdd0 for interoperability with the other parts of the script.
	mkdir -p fake_dev_hdd0/game/"$region"/USRDIR
	cd fake_dev_hdd0/game/"$region"/USRDIR || exit
	
	# Try to download rom.psarc. If that fails, try to download original.psarc. If that fails, exit the script.
	curl -O "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom.psarc" || curl -O "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/original.psarc" || exit
	echo Downloaded your psarc file. If this is a rom.psarc it will be used for installation, if it is an original.psarc it will be used for an upgrade.
	
	echo Overriding a few things for later in the script...
	# A hack to make the later parts of the script work properly.
	cd ..
	stfdir=$(pwd)
fi

# Operating System detected. I plan to implement BSD at some point, since it is UNIX even if very few people use it.
if [[ "$OSTYPE" == "freebsd"* ]]; then
	if [[ -n "$RPCS3_PATH_OVERRIDE" ]]; then
		echo Note: RPCS3_PATH_OVERRIDE unavailable on this platform. Continuing.
	fi
    echo You must be really brave\!
    echo If you really want this, psarc can probably be compiled from source. Not sure about flips.
    
# GNU/Linux handling. This primarily targets Steam Deck and Arch Linux, but will apply to most Linux distributions. Might add musl systems at some point, but honestly if you're running one, you probably don't need help installing patches.
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
	# This if statement is just here to skip detecting the game path if you don't actually have it installed.
	if [[ -n "$PS3_IP" ]]; then
		echo Continuing with real PS3 setup via FTP...
	# This handles setting which RPCS3 installation you'd like to use.
	elif [[ -n "$RPCS3_PATH_OVERRIDE" ]]; then
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

	# Check for game presence and region. It will prioritize the North American version, then the European version, then the Japanese version.
    echo Checking for Sonic The Fighters...
    if [[ -n "$PS3_IP" ]]; then
    	echo StF Directory already set.
    elif [ -d "$gamedir/NPUB30927" ]; then
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

	# Check to see if we actually have curl installed. If more sanity checks are needed, they will be put here later.
	echo Running sanity checks...
	if ! command -v curl &> /dev/null 
	then
	    echo "curl not found!"
	    exit 1
	fi

	# Beginning actual install process.
	echo Entering Sonic The Fighters directory...
	cd "$stfdir/USRDIR" || exit
	
	echo Downloading needed files...
	curl -O https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/patches.tar.gz
	curl -O https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/flips
	curl -O https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/psarc

	# Make these executable, otherwise they can't run due to permissions issues.
	chmod +x ./psarc
	chmod +x ./flips
	
	# Check for original.psarc and if it's present, do an in-place upgrade rather than an installation.
	if [ -f original.psarc ]; then
		echo original.psarc found, assuming in-place upgrade and extracting it...
		# This will overwrite any patched rom contents with their original equivalent.
		mv -f original.psarc rom.psarc
		./psarc -x rom.psarc
		mv rom.psarc original.psarc
	# Otherwise, just extract it.
	else
		echo Extracting rom.psarc...
		./psarc -x rom.psarc
		echo Moving rom.psarc to original.psarc...
		mv rom.psarc original.psarc
	fi

	# Cleanup and patching. Most of the echo commands here should serve as decent comments.
	echo Deleting psarc tool...
	rm psarc
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
	echo Finalizing setup...
	cd "$stfdir" || exit

	# Download icons and such.
	echo Downloading Content Information Files...
	curl https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/cif.tar.gz | tar -xz

	# Skip printing this message if you're doing a real PS3 install over FTP.
	if [[ -z "$PS3_IP" ]]; then
		echo Installation Complete\! Have fun\!
		echo ...and remember: Tux Loves You\!
		echo " "
		curl https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/CREDITS.txt
	fi

# MacOS handling. I wish apples were real.
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo MacOS detected!

    # RPCS3_PATH_OVERRIDE only applies to Linux.
    if [[ -n "$RPCS3_PATH_OVERRIDE" ]]; then
    	echo Note: RPCS3_PATH_OVERRIDE unavailable on this platform. Continuing.
    fi
    
    # Check for Sonic the Fighters directory.
    # On MacOS, this will always be stored in the same place, removing some complication.
    gamedir="/Users/$USER/Library/Application Support/rpcs3/dev_hdd0/game"
    if [[ -n "$PS3_IP" ]]; then
    	echo StF Directory already set.
    elif [ -d "$gamedir/NPUB30927" ]; then
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

	# Check if xcode is installed. We have to compile psarc manually.
    if [ -d $(xcode-select --install) ]; then
        echo xcode installed\!
    else
       echo Please install xcode and re-run this script afterwards...
       xcode-select --install
       exit
    fi

    # Download and compile psarc.
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
    
    # Check for original.psarc and if it's present, do an in-place upgrade rather than an installation
    if [ -f original.psarc ]; then
    	echo original.psarc found, assuming in-place upgrade and extracting it...
    	# This will overwrite any patched rom contents with their original equivalent.
    	mv -f original.psarc rom.psarc
    	./psarc -x rom.psarc
    	mv rom.psarc original.psarc
    # Otherwise, just extract.
    else
    	echo Extracting rom.psarc...
    	./psarc -x rom.psarc
    	echo Moving rom.psarc to original.psarc...
    	mv rom.psarc original.psarc
    fi

	# We don't need this anymore.    
	echo Removing psarc tool...
	rm psarc

	# Use curl to download patches, use cmdMultiPatch to apply them. Once again echos should serve as decent comments.
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
    cd "$stfdir" || exit

    # Download icons and whatnot.
    echo Downloading Content Information Files...
    curl https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/cif.tar.gz | tar -xz

    # If real PS3 install, move onto FTPing the files back over. If not, print success and credits.
    if [[ -z "$PS3_IP" ]]; then
    	echo Sonic The Fighters: Community Edition has been installed\!
    	echo " "
    	curl https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/CREDITS.txt
    fi
fi

if [[ -n "$PS3_IP" ]]; then
	cd "$stfdir" || exit

	# Sending icons and whatnot. Curl's ftp implementation is limited, so deleting the originals is necessary.
	echo Sending Content Information Files to PS3...
	curl -v "ftp://$PS3_IP/" -Q "DELE dev_hdd0/game/$region/ICON0.PNG"
	curl -v "ftp://$PS3_IP/" -Q "DELE dev_hdd0/game/$region/PIC0.PNG"
	curl -T ICON0.PNG "ftp://$PS3_IP/dev_hdd0/game/$region/" --ftp-create-dirs
	curl -T PIC0.PNG "ftp://$PS3_IP/dev_hdd0/game/$region/" --ftp-create-dirs

	# Send all of the files back upstream.
    cd "$stfdir/USRDIR" || exit
	echo Moving rom.psarc to original.psarc on PS3...
	curl -T original.psarc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/"
    curl -v "ftp://$PS3_IP/" -Q "DELE dev_hdd0/game/$region/USRDIR/rom.psarc"
    echo Sending ROM information to PS3...
    cd rom || exit
    # Goodness gracious
    curl -T fontmap.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/" --ftp-create-dirs
    curl -T string_array.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/" --ftp-create-dirs
    curl -T auth2d/aetdb.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/auth2d/" --ftp-create-dirs
    curl -T auth2d/n_advstf.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/auth2d/" --ftp-create-dirs
    curl -T auth2d/n_cmn.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/auth2d/" --ftp-create-dirs
    curl -T auth2d/n_info.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/auth2d/" --ftp-create-dirs
    curl -T auth2d/n_stf.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/auth2d/" --ftp-create-dirs
    curl -T sound/stf.acf "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sound/" --ftp-create-dirs
    curl -T sound/stf_all.acb "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sound/" --ftp-create-dirs
    curl -T sprite/n_advstf.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sprite/" --ftp-create-dirs
    curl -T sprite/n_cmn.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sprite/" --ftp-create-dirs
    curl -T sprite/n_fnt.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sprite/" --ftp-create-dirs
    curl -T sprite/n_info.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sprite/" --ftp-create-dirs
    curl -T sprite/n_stf.farc "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sprite/" --ftp-create-dirs
    curl -T sprite/sprdb.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/sprite/" --ftp-create-dirs
    curl -T stf_rom/rom_code1.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/stf_rom/" --ftp-create-dirs
    curl -T stf_rom/rom_data.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/stf_rom/" --ftp-create-dirs
    curl -T stf_rom/rom_ep.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/stf_rom/" --ftp-create-dirs
    curl -T stf_rom/rom_pol.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/stf_rom/" --ftp-create-dirs
    curl -T stf_rom/rom_tex.bin "ftp://$PS3_IP/dev_hdd0/game/$region/USRDIR/rom/stf_rom/" --ftp-create-dirs
    cd ../../../../../
    echo Installation Complete\!
    echo " "

    # Print credits.
    curl https://raw.githubusercontent.com/coatlessali/stf-community-unix/main/CREDITS.txt
fi