#!/usr/bin/env bash

# Output asterisk values for LibreNMS.

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
# Functions
#

# for more, see extend.include.sh

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

debugecho "Basename=${Basename}" 1
debugecho "Dirname=${Dirname}" 2

Asterisk=$(type -P asterisk 2> /dev/null)

if [ ${#Asterisk} -eq 0 ] || [ ! -x "${Asterisk}" ]; then
    exit 1
fi

${Asterisk} -rx "core show uptime" > /dev/null
if [ $? -ne 0 ]; then
    exit 1
fi

echo "<<<asterisk>>>"
${Asterisk} -rx "core show channels" | awk '/active calls/ { print "Calls=" $1 } /active channels/ { print "Channels=" $1}'
${Asterisk} -rx 'sip show peers' | awk '/sip peers/ { print "SipPeers=" $1 "\nSipMonOnline=" $5 "\nSipMonOffline=" $7 "\nSipUnMonOnline=" $10 "\nSipUnMonOffline=" $12}'
${Asterisk} -rx 'iax2 show peers' | awk '/iax2 peers/ { gsub("\\[",""); gsub("\\]",""); print "Iax2Peers=" $1 "\nIax2Online=" $4 "\nIax2Offline=" $6 "\nIax2Unmonitored=" $6}'

exit 0
