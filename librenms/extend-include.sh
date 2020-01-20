#!/usr/bin/env bash

# An include file for librenms-etc-snmp scripts, with common functions and variables.

# Dependencies:
# bash

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

#
# 20200103, joseph.tingiris@gmail.com, created
#

#
# Init
#

if [ "${0}" == "${BASH_SOURCE}" ]; then
    # this script was executed, it must be sourced
    exit 1
fi

#
# Functions
#

#
# aborting(): output all arguments to stderr and exit with non-zero return code
#

function aborting() {
    >&2 echo
    >&2 echo "aborting ... $@"
    >&2 echo
    exit 2
}

#
# cleanup(): if the file(s) exist (as a file) then remove the file(s)
#

function cleanup() {
    local files=($@)

    local files
    for file in "${files[@]}"; do
        if [ -f "${file}" ]; then
            debugecho removing ${file} 20
            rm -f "${file}" &> /dev/null
            if [ $? -ne 0 ]; then
                error "'${file}' failed to rm"
            fi
        fi
    done
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

Extend_Include_Env="${Dirname}/${Basename%.*}-include.env"

Tmp_File="/tmp/${Basename}.tmp"

PATH=/sbin:/bin:/usr/sbin:/usr/bin

#
# Main
#

debugecho ${BASH_SOURCE} sourced
debugecho "Tmp_File = ${Tmp_File}"
debugecho "Extend_Include_Env = ${Extend_Include_Env}"

cleanup "${Tmp_File}" # start with a clean tmp file
