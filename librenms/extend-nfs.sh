#!/usr/bin/env bash

# Output NFS client & server values for LibreNMS

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
# extend-include.sh

#
# 20200103, joseph.tingiris@gmail.com, created
#

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

if [ -r "${Extend_Include_Env}" ]; then
    source "${Extend_Include_Env}"
fi

if [ "${Basename}" == "extend-nfs-client.sh" ]; then
    Client_Or_Server="client"
else
    if [ "${Basename}" == "extend-nfs-server.sh" ]; then
        Client_Or_Server="server"
    else
        Client_Or_Server="$1"
    fi
fi

if [ "${Client_Or_Server}" == "client" ]; then
    if [ -r "/proc/net/rpc/nfs" ]; then
        cat /proc/net/rpc/nfs
        exit $?
    else
        exit 1
    fi
fi

if [ "${Client_Or_Server}" == "server" ]; then
    if [ -r "/proc/net/rpc/nfsd" ]; then
        cat /proc/net/rpc/nfsd
        exit $?
    else
        exit 1
    fi
fi

# nothing matched
usage
