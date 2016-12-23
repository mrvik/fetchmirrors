#!/bin/bash
### fetchmirrors.sh pacman mirrorlist update utility
### By: Dylan Schacht (deadhead) deadhead3492@gmail.com
### Website: http://arch-anywhere.org
#######################################################

usage() {

	echo "${Yellow} Usage:${Green} $this <opts> <args> ${Yellow}Ex: ${Green}${this} -s 4 -v -c US" # Display help / usage options menu
	echo
	echo "${Yellow} Updates pacman mirrorlist directly from archlinux.org"
	echo
	echo " Options:"
	echo "${Green}   -c --country"
	echo "${Yellow}   Specify your country code:${Green} $this -c US"
	echo "${Green}   -d --nocolor"
	echo "${Yellow}   Disable color prompts"
	echo "${Green}   -h --help"
	echo "${Yellow}   Display this help message"
	echo "${Green}   -l --list"
	echo "${Yellow}   Display list of country codes"
	echo "${Green}   -q --noconfirm"
	echo "${Yellow}   Disable confirmation messages (Run $this automatically without confirm)"
	echo "${Green}   -s --servers"
	echo "${Yellow}   Number of servers to add to ranked list (default is 6)"
	echo "${Green}   -v --verbose"
	echo "${Yellow}   Verbose output"
	echo
	echo "${Yellow}Use${Green} $this ${Yellow}without any option to prompt for country code${ColorOff}"
}

get_opts() {
		
	this=${0##*/} # Set 'this', 'rank_int', 'confirm', 'countries', and color variables
	rank_int="6"
	confirm=true
	Green=$'\e[0;32m';
	Yellow=$'\e[0;33m';
	Red=$'\e[0;31m';
	Magenta=$'\x1b[95m';
	ColorOff=$'\e[0m';
	countries=( "${Magenta}1) ${Green}AM ${Yellow}All-Mirrors - ${Magenta}2) ${Green}AS ${Yellow}All-Https - ${Magenta}3) ${Green}AT ${Yellow}Austria\n${Magenta}4) ${Green}AU ${Yellow}Australia - ${Magenta}5) ${Green}BE ${Yellow}Belgium - ${Magenta}6) ${Green}BG ${Yellow}Bulgaria\n${Magenta}7) ${Green}BR ${Yellow}Brazil - ${Magenta}8) ${Green}BY ${Yellow}Belarus - ${Magenta}9) ${Green}CA ${Yellow}Canada\n${Magenta}10) ${Green}CL ${Yellow}Chile - ${Magenta}11) ${Green}CN ${Yellow}China - ${Magenta}12) ${Green}CO ${Yellow}Columbia\n${Magenta}13) ${Green}CZ ${Yellow}Czech-Republic - ${Magenta}14) ${Green}DE ${Yellow}Germany - ${Magenta}15) ${Green}DK ${Yellow}Denmark\n${Magenta}16) ${Green}EE ${Yellow}Estonia - ${Magenta}17) ${Green}ES ${Yellow}Spain - ${Magenta}18) ${Green}FI ${Yellow}Finland\n${Magenta}19) ${Green}FR ${Yellow}France - ${Magenta}20) ${Green}GB ${Yellow}United-Kingdom - ${Magenta}21) ${Green}HU ${Yellow}Hungary\n${Magenta}22) ${Green}IE ${Yellow}Ireland - ${Magenta}23) ${Green}IL ${Yellow}Isreal - ${Magenta}24) ${Green}IN ${Yellow}India\n${Magenta}25) ${Green}IT ${Yellow}Italy - ${Magenta}26) ${Green}JP ${Yellow}Japan - ${Magenta}27) ${Green}KR ${Yellow}Korea\n${Magenta}28) ${Green}KZ ${Yellow}Kazakhstan - ${Magenta}29) ${Green}LK ${Yellow}Sri-Lanka - ${Magenta}30) ${Green}LU ${Yellow}Luxembourg\n${Magenta}31) ${Green}LV ${Yellow}Lativia - ${Magenta}32) ${Green}MK ${Yellow}Macedonia - ${Magenta}33) ${Green}NC ${Yellow}New-Caledonia\n${Magenta}34) ${Green}NL ${Yellow}Netherlands - ${Magenta}35) ${Green}NO ${Yellow}Norway - ${Magenta}36) ${Green}NZ ${Yellow}New-Zealand\n${Magenta}37) ${Green}PL ${Yellow}Poland - ${Magenta}38) ${Green}PT ${Yellow}Portugal - ${Magenta}39) ${Green}RO ${Yellow}Romania\n${Magenta}40) ${Green}RS ${Yellow}Serbia - ${Magenta}41) ${Green}RU ${Yellow}Russia - ${Magenta}42) ${Green}SE ${Yellow}Sweden\n${Magenta}43) ${Green}SG ${Yellow}Singapore - ${Magenta}44) ${Green}SK ${Yellow}Slovakia - ${Magenta}45) ${Green}TR ${Yellow}Turkey\n${Magenta}46) ${Green}TW ${Yellow}Taiwan - ${Magenta}47) ${Green}UA ${Yellow}Ukraine - ${Magenta}48) ${Green}US ${Yellow}United-States\n${Magenta}49) ${Green}UZ ${Yellow}Uzbekistan - ${Magenta}50) ${Green}VN ${Yellow}Viet-Nam - ${Magenta}51) ${Green}ZA ${Yellow}South-Africa" )	

	while (true) # Loop case statement on 1 parameter until something happens (break || exit 1)
	  do
		case "$1" in
			-d|--nocolor) # Disable color prompts
				unset Green Yellow Red ColorOff ; shift
			;;
			-q|--noconfirm) # Disable confirmation messages
				confirm=false ; shift
			;;
			-s|--server) # Specify number of servers to add to rank list output
				rank_int="$2"
				if ! (<<<"$rank_int" grep "^-\?[0-9]*$" &> /dev/null) || [ -z "$rank_int" ]; then
					echo "${Red}Error: ${Yellow} invalid number of servers specified ${rank_int}${ColorOff}"
					exit 1
				fi
				shift ; shift
			;;
			-v|--verbose) # Set verbose switch on
				rank_int="$rank_int -v" ; shift
			;;
			-l|--list) # Display a list of country codes to the user
				echo "${Yellow}Country codes:${ColorOff}"
				echo -e "$countries" | column -t
				echo "${Yellow}Note: Use only the upercase two character code in your command ex:${Green} $this -c US"
				echo "${Yellow}Or simply use:${Green} ${this}${ColorOff}"
				break
			;;
			-h|--help) # Display usage message
				usage ; break
			;;
			-c|--country) # Country parameter allows user to input country code (ex: US)
				if [ -z "$2" ]; then
					echo "${Red}Error: ${Yellow}You must enter a country code."
				elif (<<<"$countries" grep -w "$2" &> /dev/null); then
					country_code="$2"
					query="https://www.archlinux.org/mirrorlist/?country=${country_code}"
					get_list
				else
					echo "${Red}Error: ${Yellow}country code: $2 not found."
					echo "To view a list of country codes run:${Green} $this -l${ColorOff}"
				fi
				break
			;;
			"") # Empty 1 parameter means search for country code
				search ; break
			;;
			*) # Take anything else as invalid input
				echo "${Red}Error: ${Yellow}unknown input $1 exiting...${ColorOff}"
				exit 1
		esac
	done # End case options loop
	exit

}

search() {
	
	while (true)
	  do
		echo "${Yellow}Country codes:${ColorOff}"
		echo -e "$countries" | column -t
		echo -n "${Yellow}Enter the number corresponding to your country code ${Green}[1,2,3...]${Yellow}:${ColorOff} "
		read input

		if ! (<<<$input grep "^-\?[0-9]*$" &>/dev/null) || [ "$input" -gt "51" ]; then
			echo "${Red}Error: ${Yellow}please select a number from the list.${ColorOff}"
		else
			break
		fi
	done
			
	if [ "$input" -eq "1" ]; then
		country_code="All"
		query="https://www.archlinux.org/mirrorlist/all/"
	elif [ "$input" -eq "2" ]; then
		country_code="All HTTPS"
		query="https://www.archlinux.org/mirrorlist/all/https"
	else
		country_code=$(echo "$countries" | grep -o "$input.*" | awk 'NR==1 {print $2}')
		query="https://www.archlinux.org/mirrorlist/?country=${country_code}"
	fi

	if "$confirm" ; then
		echo -n "${Yellow}You have selected the country code:${Green} $country_code ${Yellow}- is this correct ${Green}[y/n]:${ColorOff} "
		read input
		case "$input" in
			y|Y|yes|Yes|yY|Yy|yy|YY|"")
				get_list
			;;
			*)
				search
			;;
		esac
	else
		get_list
	fi

}

get_list() {

	echo "${Yellow}Fetching new mirrorlist from:${Green} ${query}${ColorOff}"
	
	if [ -f /usr/bin/wget ]; then wget -O /tmp/mirrorlist "$query" &> /dev/null
	else curl -o /tmp/mirrorlist "$query" &> /dev/null
	fi
	
	sed -i 's/#//' /tmp/mirrorlist
	echo "${Yellow}Please wait while ranking${Green} $country_code ${Yellow}mirrors...${ColorOff}"
	rankmirrors -n "$rank_int" /tmp/mirrorlist > /tmp/mirrorlist.ranked
	
	if [ "$?" -gt "0" ]; then
		echo "${Red}Error: ${Yellow}an error occured in ranking mirrorlist exiting..."
		rm /tmp/{mirrorlist,mirrorlist.ranked} &> /dev/null
		exit 1
	fi

	if "$confirm" ; then
		echo -n "${Yellow}Would you like to view new mirrorlist? ${Green}[y/n]: ${ColorOff}"
		read input

		case "$input" in
			y|Y|yes|Yes|yY|Yy|yy|YY|"")
				echo ; cat /tmp/mirrorlist.ranked
			;;
		esac

		echo
		echo -n "${Yellow}Would you like to install the new mirrorlist backing up existing? ${Green}[y/n]:${ColorOff} "
		read input
	else
		input=""
	fi
		
	case "$input" in
		y|Y|yes|Yes|yY|Yy|yy|YY|"")
			sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
			sudo mv /tmp/mirrorlist.ranked /etc/pacman.d/mirrorlist
			echo "${Green}New mirrorlist installed ${Yellow}- Old mirrorlist backed up to /etc/pacman.d/mirrorlist.bak${ColorOff}"
			rm /tmp/mirrorlist &> /dev/null
		;;
		*)
			echo "${Yellow}Mirrorlist was not installed - exiting...${ColorOff}"
			rm /tmp/{mirrorlist,mirrorlist.ranked} &> /dev/null
		;;
	esac

}

get_opts "$@"
