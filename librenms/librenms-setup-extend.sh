#!/usr/bin/env bash

# This script runs /etc/snmp/librenms scripts and adds extend entries to snmpd.conf.

# Dependencies:
# curl
# realpath

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

function usage() {
    printf "\nusage: $0 [check|install]\n\n"
    exit 1
}

# for more, see extend.include.sh

#
# Globals
#

Basename=${0##*/}
Dirname=${0%/*}
Dirname=$(realpath "${Dirname}" 2> /dev/null)

if [ ${#Dirname} -eq 0 ]; then
    echo "aborting, realpath not found executable"
fi

#
# Main
#

# source extend-include.sh or exit
if [ -r "${Dirname}/extend-include.sh" ]; then
    source "${Dirname}/extend-include.sh"
else
    "aborting .. can't source extend-include.sh"
    exit 1
fi

if [ -r "${Extend_Include_Env}" ]; then
    source "${Extend_Include_Env}"
fi

debugecho "Basename = ${Basename}" 10
debugecho "Dirname = ${Dirname}" 10

Snmpd_Conf=/etc/snmp/snmpd.conf
if [ ! -w "${Snmpd_Conf}" ]; then
    aborting "${Snmpd_Conf} file not writable"
fi

if [ "$1" == "install" ]; then
    Install=0 # true
else
    if [ "$1" == "check" ] || [ "$1" == "" ]; then
        Install=1 # false
    else
        usage
    fi
fi

if [ -x "${Dirname}"/extend-info.sh ]; then
    for Extend_Name in distro hardware manufacturer serial; do
        "${Dirname}"/extend-info.sh "${Extend_Name}" &> /dev/null
        Extend_RC=$?
        if [ ${Extend_RC} -eq 0 ]; then
            if [ "${Extend_Name}" == "distro" ]; then
                Extend_OID=".1.3.6.1.4.1.2021.7890.1"
            fi

            if [ "${Extend_Name}" == "hardware" ]; then
                Extend_OID=".1.3.6.1.4.1.2021.7890.2"
            fi

            if [ "${Extend_Name}" == "manufacturer" ]; then
                Extend_OID=".1.3.6.1.4.1.2021.7890.3"
            fi

            if [ "${Extend_Name}" == "serial" ]; then
                Extend_OID=".1.3.6.1.4.1.2021.7890.4"
            fi

            if [ ${#Extend_OID} -gt 0 ]; then
                if [ ${Install} -eq 0 ]; then
                    sed -Ei "/extend(.*)${Extend_OID}[[:space:]]/d" "${Snmpd_Conf}"
                    if [ $? -eq 0 ]; then
                        echo "extend ${Extend_OID} ${Extend_Name} '${Dirname}/extend-info.sh ${Extend_Name}'" >> "${Snmpd_Conf}"
                        if [ $? -eq 0 ]; then
                            echo "+ extend ${Extend_OID} ${Extend_Name} installed."
                        else
                            echo "+ extend ${Extend_OID} ${Extend_Name} failed to install."
                        fi
                    fi
                else
                    echo "+ extend ${Extend_OID} ${Extend_Name} returns success."
                fi
            fi
        fi
        unset -v Extend_OID
    done
fi
unset -v Extend_Name Extend_RC

while read Extend_Check; do
    Extend_Basename=${Extend_Check##*/}
    Extend_Name=${Extend_Basename}
    Extend_Name=${Extend_Name//.bash/}
    Extend_Name=${Extend_Name//.sh/}
    Extend_Name=${Extend_Name//.php/}
    Extend_Name=${Extend_Name//.pl/}
    Extend_Conf="${Dirname}/${Extend_Name}.conf"
    Extend_Name=${Extend_Name/extend-/}

    if [ -r "${Extend_Conf}" ]; then
        Extend_Check_Args=" -c ${Extend_Conf}"
    fi

    debugecho "Extend_Check = ${Extend_Check}${Extend_Check_Args} (${Extend_Basename}) [${Extend_Name}]"

    ${Extend_Check}${Extend_Check_Args} &> /dev/null
    Extend_RC=$?
    if [ ${Extend_RC} -eq 0 ]; then
        if [ ${Install} -eq 0 ]; then
            sed -Ei "/extend(.*)${Extend_Name}[[:space:]]/d" "${Snmpd_Conf}"
            if [ $? -eq 0 ]; then
                echo "extend ${Extend_Name} '${Extend_Check}${Extend_Check_Args}'" >> "${Snmpd_Conf}"
                if [ $? -eq 0 ]; then
                    echo "+ extend ${Extend_Name} installed."
                else
                    echo "+ extend ${Extend_Name} failed to install."
                fi
            fi
        else
            echo "+ extend ${Extend_Name} returns success."
        fi
    fi
    unset -v Extend_Check_Args Extend_Basename Extend_Name Extend_RC
done <<< "$(find "${Dirname}" -name "extend-*" | egrep -ve 'extend-include|extend-info|conf$|example|cfg$' | xargs -r ls -1)"

