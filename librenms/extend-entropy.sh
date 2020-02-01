#!/usr/bin/env bash

# Output /proc/sys/kernel/random/entropy_avail for LibreNMS

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
# 20200114, joseph.tingiris@gmail.com, created
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


if [ -r /proc/sys/kernel/random/entropy_avail ]; then
    cat /proc/sys/kernel/random/entropy_avail
    exit 0
else
    debugecho "/proc/sys/kernel/random/entropy_avail file not found readable"
    exit 1
fi
