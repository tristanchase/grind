#!/usr/bin/env bash
#-----------------------------------
# Section 1.

# Low-tech debug mode
if [[ "${1:-}" =~ (-d|--debug) ]]; then
	set -o verbose
	set -o xtrace
	_debug_file=""${HOME}"/script-logs/$(basename "${0}")/$(basename "${0}")-debug-$(date -Iseconds)"
	mkdir -p $(dirname ${_debug_file})
        touch ${_debug_file}
	exec > >(tee "${_debug_file:-}") 2>&1
	shift
fi

# Same as set -euE -o pipefail
#set -o errexit
set -o nounset
set -o errtrace
#set -o pipefail
IFS=$'\n'
#shopt -o globstar

# End Section 1.
#-----------------------------------
#-----------------------------------
# Section 2.

#//Usage: grind [ {-d|--debug} ] [ {-h|--help} | <options>] [<arguments>]
#//Description: Grinds through your filesystem to find files and open them
#//Examples: grind foo; grind --debug bar
#//Options:
#//	-d --debug	Enable debug mode
#//	-h --help	Display this help message

# Created: 2020-08-18T21:56:42-04:00
# Tristan M. Chase <tristan.m.chase@gmail.com>

# Depends on:
#  list
#  of
#  dependencies

# End Section 2.
#-----------------------------------
#-----------------------------------
# Section 3.

# Low-tech logging function

readonly LOG_FILE=""${HOME}"/script-logs/$(basename "${0}")/$(basename "${0}").log"
mkdir -p $(dirname ${LOG_FILE})
function __info()    { echo "$(date -Iseconds) [INFO]    $*" | tee -a "${LOG_FILE}" >&2 ; }
function __warning() { echo "$(date -Iseconds) [WARNING] $*" | tee -a "${LOG_FILE}" >&2 ; }
function __error()   { echo "$(date -Iseconds) [ERROR]   $*" | tee -a "${LOG_FILE}" >&2 ; }
function __fatal()   { echo "$(date -Iseconds) [FATAL]   $*" | tee -a "${LOG_FILE}" >&2 ; exit 1 ; }

#-----------------------------------
# Trap functions

function __traperr() {
	__error "${FUNCNAME[1]}: ${BASH_COMMAND}: $?: ${BASH_SOURCE[1]}.$$ at line ${BASH_LINENO[0]}"
}

function __ctrl_c(){
	exit 130
}

function __cleanup() {
	case "$?" in
		0) # exit 0; success!
			#do nothing
			;;
		1) # exit 1; General error
			#do nothing
			;;
		2) # exit 2; Missing keyword or command, or permission problem
			__fatal "$(basename "${0}"): missing keyword or command, or permission problem."
			;;
		126) # exit 126; Cannot execute command (permission denied or not executable)
			#do nothing
			;;
		127) # exit 127; Command not found (problem with $PATH or typo)
			#do nothing
			;;
		128) # exit 128; Invalid argument to exit (integers from 0 - 255)
			#do nothing
			;;
		130) # exit 130; user termination
			__fatal ""$(basename $0).$$": script terminated by user."
			;;
		255) # exit 255; Exit status out of range (e.g. exit -1)
			#do nothing
			;;
		*) # any other exit number; indicates an error in the script
			#clean up stray files
			#__fatal ""$(basename $0).$$": [error message here]"
			;;
	esac

	if [[ -n "${_debug_file:-}" ]]; then
		echo "Debug file is: "${_debug_file:-}""
	fi
}

#-----------------------------------
# Main Script Wrapper

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
	trap __traperr ERR
	trap __ctrl_c INT
	trap __cleanup EXIT

#-----------------------------------
# Low-tech help option

function __usage() { grep '^#//' "${0}" | cut -c4- ; exit 0 ; }
expr "$*" : ".*-h\|--help" > /dev/null && __usage

#-----------------------------------
# Main Script goes here

files=( $(find / -iname *$1* 2>/dev/null | grep -Ev '.cache|~$' | grep "$1" ) )

count="$(printf '%b\n' "${files[@]}" | wc -l)"
if [[ $count -gt 1 ]]; then
	printf '%b\n' "${files[@]}" | sed = | sed 'N;s/\n/ /'
	printf "Choose file to open (enter number): "
	read number # handle incorrect input here
	rifle "$(printf '%b\n' "${files[@]:$number-1:1}")"
else
	rifle "$(printf '%b\n' "${files}")"
fi

# End Section 3.
#-----------------------------------
#-----------------------------------
# Section 4.

# Main Script ends here
#-----------------------------------

fi

# End of Main Script Wrapper
#-----------------------------------

exit 0

# End Section 4.
#-----------------------------------
#-----------------------------------
# Section 5.

# TODO (bottom up)
#
# * Update dependencies section
# * Update usage, description, and options section
# * Update __cleanup(); add debug lines (copy from ~/devel/new-script/boilerplate-3.sh)
# * Update first section with new debug section (copy from ~/devel/new-script/boilerplate-1.sh)
# * Enhance __traperr() (copy from ~/devel/new-script/boilerplate-3.sh)
# * Check that _variable="variable definition" (make sure it's in quotes)
# * Rename $variables to ${_variables} /\$\w+/s+1 @v (vEl,{n)
# * Rename function_name() to function __function_name() /\w+\(\)
# * Modify command substitution to "$(this_style)"
# * Clean up stray ;'s
# * Insert script

# End Section 5.
#-----------------------------------
