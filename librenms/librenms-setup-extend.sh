#!/usr/bin/env bash

# This script outputs apache server-status output for LibreNMS.

# Dependencies:
# curl or wget

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
# Local Functions
#

#
# Functions
#

# see extend.include.sh

#
# Globals
#

# Debug=on; use environment, i.e. Debug=on apache-stats.sh
if [ "${DEBUG}" != "" ]; then
    Debug=${DEBUG}
else
    if [ "${Debug}" != "" ]; then
        Debug=${Debug}
    fi
fi

#
# Main
#

# clean up
if [ -f ${Tmp_File} ]; then
    rm -f ${Tmp_File} &> /dev/null
fi


