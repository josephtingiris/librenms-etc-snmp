#!/usr/bin/env bash

# Output NFS client & server values for LibreNMS.

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

PATH=/sbin:/bin:/usr/sbin:/usr/bin

#
# Functions
#

# for more, see extend.include.sh

function usage() {
    printf "\nusage: $0 <client|server>\n\n"
    exit 1
}

#
# Globals
#

Basename=${0##*/}
Dirname=${0%/*}

#
# Main
#

# source extend-include.sh or exit
if [ -r "${Dirname}/extend-include.sh" ]; then
    source "${Dirname}/extend-include.sh"
else
    exit 1
fi

if [ "$1" == "client" ]; then
    if [ -r "/proc/net/rpc/nfs" ]; then
        cat /proc/net/rpc/nfs
        exit $?
    else
        exit 1
    fi
fi

if [ "$1" == "server" ]; then
    if [ -r "/proc/net/rpc/nfsd" ]; then
        cat /proc/net/rpc/nfsd
        exit $?
    else
        exit 1
    fi
fi

# nothing matched
usage
