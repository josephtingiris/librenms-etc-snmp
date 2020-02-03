#!/usr/bin/env bash

# Output setup-snmpd version

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

function usage() {
    printf "\nusage: $0\n\n"
    exit 2
}

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

if [ -r "${Dirname}/../setup-snmpd.version" ]; then
    cat "${Dirname}/../setup-snmpd.version"
    exit 0
fi

exit 1
