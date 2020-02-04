#!/usr/bin/env bash

# An include file for librenms-etc-snmp scripts, with common functions and variables

# Copyright (C) 2020 Joseph Tingiris (joseph.tingiris@gmail.com)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Dependencies:
# bash v4+
# date

#
# 20200103, joseph.tingiris@gmail.com, created
#

#
# Init
#

if [ "${BASH_VERSINFO}" == "" ]; then
    printf "\naborting ... this script requires bash.\n\n"; exit 1
fi

if [ "${BASH_VERSINFO}" -lt 4 ]; then
    printf "\naborting ... this script requires bash version 4 or greater.\n\n"; exit 1
fi

if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\naborting ... this script was executed, it must be sourced\n\n"; exit 1
fi

#
# Functions
#

#
# _echo(): output a consistent message
#

function _echo() {
    [ ${#Steps} -eq 0 ] && Steps=0 # counter
    [ ${#Warnings} -eq 0 ] && Warnings=0 # counter

    local status_message
    if [ ${#2} -gt 0 ]; then
        status_message="[${2^^}]"
    fi

    [ ${#WHostname} -eq 0 ] && Hostname=$(hostname -s)

    let Steps=${Steps}+1
    printf "[$(date)] ${Hostname} %2s %-71s %s\n" "${Steps}" "${1}" "${status_message}"
    export Steps

    if [ "${status_message}" == "[WARNING]" ]; then
        let Warnings=${Warnings}+1
    fi
}

#
# aborting(): output all arguments to stderr and exit with non-zero return code
#

function aborting() {
    >&2 echo
    >&2 echo "aborting ... $@"
    >&2 echo
    cleanup "${Tmp_File}"
    exit 2
}

#
# cleanup(): if the file(s) exist (as a file) then remove the file(s)
#

function cleanup() {
    local files=($@)

    local rc=0

    local files
    for file in "${files[@]}"; do
        if [ -f "${file}" ]; then
            debugecho "removing ${file}" 20
            rm -f "${file}" &> /dev/null
            if [ $? -ne 0 ]; then
                error "'${file}' failed to rm"
                rc=1
            fi
        fi
    done

    return $rc
}

#
# debugecho(): if debug_level is less than Debug then output all arguments to stderr, prefix with 'debug',
#              and respect the last argument as a potential debug level.
#

function debugecho() {
    local debug_message=(${@})

    if [ ${#Debug} -eq 0 ] || [ ${Debug} -eq 0 ] || [ ${#debug_message} -eq 0 ]; then
        return
    fi

    local debug_level=${debug_message[@]: -1}

    if [[ ! "${debug_level}" =~ [0-9]+$ ]]; then
        # debug_level is not in debug_message
        debug_level=1
    else
        # debug_level is in debug_message; use it
        unset 'debug_message[ ${#debug_message[@]}-1 ]' # remove debug_level
    fi

    if [ ${debug_level} -le ${Debug} ]; then
        >&2 echo debug[${debug_level}:${Debug}]: ${debug_message[@]} # echo debug to stderr
    fi
}

#
# error(): output all arguments to stderr
#

function error() {
    >&2 echo
    >&2 echo "error ... $@"
    >&2 echo
    return 1
}

#
# Globals
#

# Debug=<integer greater than 0>; set using environment, i.e. Debug=10 apache-stats.sh
if [[ "${DEBUG}" =~ [0-9]+$ ]]; then
    Debug=${DEBUG}
else
    if [[ "${Debug}" =~ [0-9]+$ ]]; then
        Debug=${Debug}
    else
        Debug=0 # disabled
    fi
fi

[[ ${#Basename} -eq 0 ]] && Basename=${0##*/}
[[ ${#Dirname} -eq 0 ]] && Dirname=${0%/*}

Dirname=$(readlink -f "${Dirname}" 2> /dev/null)

if [ ${#Dirname} -eq 0 ]; then
    aborting "invalid Dirname (readlink not found?)"
fi

Extend_Include_Env="${Dirname}/${Basename%.*}.env"

[ ${#Tmp_Dir} -eq 0 ] && Tmp_Dir="/var/tmp"
[ ! -w "${Tmp_Dir}" ] && Tmp_Dir="/tmp"
Tmp_File="${Tmp_Dir}/${Basename}.$(date +%s).tmp"

PATH=/sbin:/bin:/usr/sbin:/usr/bin

#
# Main
#

debugecho "${BASH_SOURCE} sourced" 1
debugecho "Tmp_File = ${Tmp_File}" 2
debugecho "Extend_Include_Env = ${Extend_Include_Env}" 3

debugecho "Basename = ${Basename}" 10
debugecho "Dirname = ${Dirname}" 10

cleanup "${Tmp_File}" # start with a clean tmp file
