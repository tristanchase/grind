#!/usr/bin/env bash

#-----------------------------------
# Usage Section

#<usage>
#//Usage: grind [ {-d|--debug} ] {-h|--help} | <file>
#//Description: Grinds through your filesystem to find files and open them
#//Examples: grind foo; grind --debug bar
#//Options:
#//	-d --debug	Enable debug mode
#//	-h --help	Display this help message
#</usage>

#<created>
# Created: 2020-08-18T21:56:42-04:00
# Tristan M. Chase <tristan.m.chase@gmail.com>
#</created>

#<depends>
# Depends on:
#  rifle (comes with ranger)
#</depends>

#-----------------------------------
# TODO Section

#<todo>
# TODO
# 1. Rewrite __main_script__
# 	Look to super-grep for good example
# 2. Refactor chooser section into a function
# 	Look to gen-keys for inspiriation
# 3. Create better way to exclude directories from being searched in $_chooser_array
# 	Maybe a list in a config file

# DONE
# + Insert script
# + Clean up stray ;'s
# + Modify command substitution to "$(this_style)"
# + Rename function_name() to function __function_name__ /\w+\(\)
# + Rename $variables to "${_variables}" /\$\w+/s+1 @v vEl,{n
# + Check that _variable="variable definition" (make sure it's in quotes)
# + Update usage, description, and options section
# + Update dependencies section

#</todo>

#-----------------------------------
# License Section

#<license>
# Put license here
#</license>

#-----------------------------------
# Runtime Section

#<main>
# Initialize variables
#_temp="file.$$"

# List of temp files to clean up on exit (put last)
#_tempfiles=("${_temp}")

# Put main script here
function __main_script__ {

# If <arg> is empty, print help
if [[ -z "${_arg}" ]]; then
	__usage__
fi

# Generate a list of files matching <arg>, but don't include the items in the "grep -Ev" statement below
_chooser_array=( $(find / -type f -iname "*${_arg}*" 2>/dev/null | grep -Ev '/mnt|/proc|/sbin|/snap|/sys|/usr(/local)?/[s]bin|/var/cache|$HOME/(.cache|Dropbox|Music|Pictures|Videos|Wallpapers)?|~$|.swp' | grep "${_arg}" | sort) )

# If there is more than one file, generate an numbered list and allow user to choose by number
_chooser_count="${#_chooser_array[@]}"
_chooser_array_keys=(${!_chooser_array[@]})
function __chooser_message__ {
	printf "%q %q\n" $((_key + 1)) "${_chooser_array[$_key]}"
}
_chooser_command="rifle"

if [[ -z "${_chooser_array}" ]]; then
	printf "%b\n" "\"${_arg}\" not found."
	exit 1
fi

if [[ "${_chooser_count}" -gt 1 ]]; then
	for _key in "${_chooser_array_keys[@]}"; do
		__chooser_message__
	done | more -e
	printf "Choose file to open (enter number 1-"${_chooser_count}", anything else quits): "
	read _chooser_number
	case "${_chooser_number}" in
		''|*[!0-9]*) # not a number
			exit 0
			;;
		*) # not in range
			if [[ "${_chooser_number}" -lt 1 ]] || [[ "${_chooser_number}" -gt "${_chooser_count}" ]]; then
				exit 0
			fi
			;;
	esac
	"${_chooser_command}" "$(printf "%b\n" "${_chooser_array[@]:$_chooser_number-1:1}")"
else
	"${_chooser_command}" "$(printf "%b\n" "${_chooser_array}")"
			fi



		} #end __main_script__
#</main>

#-----------------------------------
# Local functions

#<functions>
function __local_cleanup__ {
	:
}
#</functions>

#-----------------------------------
# Source helper functions
for _helper_file in functions colors git-prompt; do
	if [[ ! -e ${HOME}/."${_helper_file}".sh ]]; then
		printf "%b\n" "Downloading missing script file "${_helper_file}".sh..."
		sleep 1
		wget -nv -P ${HOME} https://raw.githubusercontent.com/tristanchase/dotfiles/main/"${_helper_file}".sh
		mv ${HOME}/"${_helper_file}".sh ${HOME}/."${_helper_file}".sh
	fi
done

source ${HOME}/.functions.sh

#-----------------------------------
# Get some basic options
# TODO Make this more robust
#<options>
if [[ "${1:-}" =~ (-d|--debug) ]]; then
	__debugger__
elif [[ "${1:-}" =~ (-h|--help) ]]; then
	__usage__
else
	_arg="${1:-}"
fi
#</options>

#-----------------------------------
# Bash settings
# Same as set -euE -o pipefail
#<settings>
#set -o errexit
#set -o nounset
#set -o errtrace
#set -o pipefail
IFS=$'\n\t'
#</settings>

#-----------------------------------
# Main Script Wrapper
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
	trap __traperr__ ERR
	trap __ctrl_c__ INT
	trap __cleanup__ EXIT

	__main_script__


fi

exit 0
