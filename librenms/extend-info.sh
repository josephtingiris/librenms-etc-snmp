#!/usr/bin/env bash

# Output various informational values.

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
    printf "\nusage: $0 <distro|hardware|manufacturer|serial|vendor>\n\n"
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

# .1.3.6.1.4.1.2021.7890.1 distro
if [ "$1" == "distro" ]; then
    if [ -x "${Dirname}/distro" ]; then
        # a wrapper, for now, around the original LibreNMS distro script
        "${Dirname}/distro"
        exit $?
    else
        echo "No distro"
    fi
fi

# .1.3.6.1.4.1.2021.7890.2 hardware
if [ "$1" == "hardware" ]; then
    if [ -r /sys/devices/virtual/dmi/id/product_name ]; then
        cat /sys/devices/virtual/dmi/id/product_name
        exit $?
    else
        echo "No hardware"
    fi
fi

# .1.3.6.1.4.1.2021.7890.3 manufacturer (or vendor)
if [ "$1" == "manufacturer" ] || [ "$1" == "vendor" ]; then
    if [ -r /sys/devices/virtual/dmi/id/sys_vendor ]; then
        cat /sys/devices/virtual/dmi/id/sys_vendor
        exit $?
    else
        if [ "$1" == "manufacturer" ]; then
            echo "No manufacturer"
        else
            echo "No vendor"
        fi
    fi
fi

# .1.3.6.1.4.1.2021.7890.4 serial
if [ "$1" == "serial" ]; then
    if [ -r /sys/devices/virtual/dmi/id/product_serial ]; then
        cat /sys/devices/virtual/dmi/id/product_serial
        exit $?
    else
        echo "No serial"
    fi
fi

# nothing matched
usage
