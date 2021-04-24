#!/usr/bin/env bash

# Prepare ansible artifacts for setup-snmpd and use ansible-play to install them

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
# ansible-playbook
# gzip
# tar

#
# 20200202, joseph.tingiris@gmail.com, created
#

#
# Init
#

#
# Functions
#

function usage() {
    printf "\nusage: $0 <check|install|upgrade> [inventory] <host limit pattern>\n\n"; exit 1
}

# for more, see extend.include.sh

#
# Globals
#

Basename=${0##*/}
Dirname=$(dirname "$(readlink -e "${0}")")

#
# Main
#

# source extend-include.sh or exit
if [ -r "${Dirname}/../librenms/extend-include.sh" ]; then
    source "${Dirname}/../librenms/extend-include.sh"
else
    "aborting .. can't source extend-include.sh"
    exit 1
fi

# if it exists and is readable then source $0.env
if [ -r "${Extend_Env}" ]; then
    source "${Extend_Env}"
fi

Limit=""

Check=1
Install=2
Inventory=1
Upgrade=1

while [[ $# -gt 0 ]]; do
    Argument="$1"
    shift
    case "$Argument" in
        "check" )
            Check=0
            Install=1
            ;;
        "install" )
            Install=0
            ;;
        "inventory" )
            Inventory=0
            ;;
        "upgrade" )
            Install=0
            Upgrade=0
            ;;
        *)
            Limit+="${Argument} "
            ;;
    esac
done

if [ ${#Limit} -eq 0 ] || [ ${Install} -eq 2 ]; then
    usage
fi

# multiple limits
Limit="${Limit// /,}"
Limit="${Limit%,*}"

echo "Limit=${Limit}, Check=${Check}, Install=${Install}, Inventory=${Inventory}, Upgrade=${Upgrade}"
echo

#
# Init Environment Defaults
#

# these may be set in $0.env, so check them before setting any defaults
[ ${#Ansible_Name} -eq 0 ] && Ansible_Name="setup_snmpd"
[ ${#Ansible_Inventory} -eq 0 ] && Ansible_Inventory="${Dirname}/inventory"
[ ${#Ansible_Files_Dir} -eq 0 ] && Ansible_Files_Dir="${Dirname}/files/${Ansible_Name}"
[ ${#Ansible_Files_Tar} -eq 0 ] && Ansible_Files_Tar="${Ansible_Files_Dir}/${Ansible_Name}.tar.gz"
[ ${#Ansible_Playbook} -eq 0 ] && Ansible_Playbook="${Dirname}/${Ansible_Name}.yml"
[ ${#Ansible_Tasks_Dir} -eq 0 ] && Ansible_Tasks_Dir="${Dirname}/roles/${Ansible_Name}/tasks"
[ ${#Ansible_Main} -eq 0 ] && Ansible_Main="${Ansible_Tasks_Dir}/main.yml"
[ ${#Backup_Dir} -eq 0 ] && Backup_Dir=/var/tmp/${Basename}
[ ${#Setup_Snmpd_Dir} -eq 0 ] && Setup_Snmpd_Dir=$(readlink -f "${Dirname}/../")
[ ${#Get_Templates} -eq 0 ] && Get_Templates="${Setup_Snmpd_Dir}/templates/get-templates.sh"

# if it exists and is readable then source $0.env
if [ -r "${Extend_Env}" ]; then
    source "${Extend_Env}"
fi

#
# Check ansible playbook exists
#

if [ -f "${Ansible_Playbook}" ]; then
    _echo "playbook '${Ansible_Playbook}' found"
else
    aborting "playbook '${Ansible_Playbook}' file not found"
fi

#
# Check ansible inventory exists
#

if [ -x /opt/librenms/bin/librenms-ansible-inventory ]; then
    if [ -f "${Ansible_Inventory}" ] && [ ${Inventory} -eq 0 ]; then
        rm -f "${Ansible_Inventory}"
        if [ $? -eq 0 ]; then
            _echo "removed '${Ansible_Inventory}'"
        else
            aborting "rm -f '${Ansible_Inventory}' failed"
        fi
    fi

    if [ ! -f "${Ansible_Inventory}" ]; then
        touch "${Ansible_Inventory}"
        if [ -f "$HOME/.ansible/inventory" ]; then
            cat "$HOME/.ansible/inventory" >> "${Ansible_Inventory}"
            echo >> "${Ansible_Inventory}"
        fi
        /opt/librenms/bin/librenms-ansible-inventory >> "${Ansible_Inventory}"
        if [ $? -eq 0 ]; then
            _echo "creaated '${Ansible_Inventory}'"
        else
            rm -f "${Ansible_Inventory}" &> /dev/null
            aborting "/opt/librenms/bin/librenms-ansible-inventory failed"
        fi
    fi
fi

if [ ! -f "${Ansible_Inventory}" ]; then
    aborting "inventory '${Ansible_Inventory}' file not found"
fi

#
# Check ansible tasks exists
#

if [ -d "${Ansible_Tasks_Dir}" ]; then
    _echo "using '${Ansible_Tasks_Dir}' for tasks"
else
    mkdir -p "${Ansible_Tasks_Dir}"
    if [ $? -eq 0 ]; then
        _echo "created '${Ansible_Tasks_Dir}' for tasks"
    else
        aborting "mkdir -p '${Ansible_Tasks_Dir}' failed"
    fi
fi

if [ -f "${Ansible_Main}" ]; then
    _echo "main '${Ansible_Main}' found"
else
    aborting "main '${Ansible_Main}' file not found"
fi

#
# Get (updated) templates
#

if [ -x "${Get_Templates}" ]; then
    _echo "running '${Get_Templates}'"
    ${Get_Templates} &> /dev/null
else
    _echo "'${Get_Templates}' file not found executable"
fi

#
# Generate (updated) .tar.gz
#

if [ -d "${Ansible_Files_Dir}" ]; then
    _echo "using '${Ansible_Files_Dir}' for files"
else
    mkdir -p "${Ansible_Files_Dir}"
    if [ $? -eq 0 ]; then
        _echo "created '${Ansible_Files_Dir}' for files"
    else
        aborting "mkdir -p '${Ansible_Files_Dir}' failed"
    fi
fi

# tar a tmp file, first, because ansible always consideres a file changed in the timestamps change ... meh
cleanup "${Tmp_File}.tar ${Tmp_File}.tar.gz"
cd "${Setup_Snmpd_Dir}"
tar --exclude='./.ansible' --exclude='./.git' -cf ${Tmp_File}.tar .
if [ $? -eq 0 ]; then
    gzip -n "${Tmp_File}.tar" # this is needed so gzip doesn't produce a different md5sum EVERY.SINGLE.TIME
    if [ $? -eq 0 ]; then
        _echo "created '${Tmp_File}.tar.gz'"
    else
        aborting "creating '${Tmp_File}.tar.gz' failed"
    fi
else
    aborting "creating '${Tmp_File}.tar' failed"
fi
cd "${Dirname}"

if [ -f "${Ansible_Files_Tar}" ]; then
    _echo "found '${Ansible_Files_Tar}'"
    diff -q "${Tmp_File}.tar.gz" "${Ansible_Files_Tar}" &> /dev/null
    diff_rc=$?
    if [ ${diff_rc} -eq 0 ]; then
        _echo "keeping '${Ansible_Files_Tar}'"
    else
        cp "${Tmp_File}.tar.gz" "${Ansible_Files_Tar}"
        if [ $? -eq 0 ]; then
            _echo "updated '${Ansible_Files_Tar}'"
        else
            aborting "copying '${Ansible_Files_Tar}' failed"
        fi
    fi
fi

if [ ! -f "${Ansible_Files_Tar}" ]; then
    cp "${Tmp_File}.tar.gz" "${Ansible_Files_Tar}"
    if [ $? -eq 0 ]; then
        _echo "copied '${Ansible_Files_Tar}'"
    else
        aborting "copying '${Ansible_Files_Tar}' failed"
    fi
fi

cleanup "${Tmp_File}.tar ${Tmp_File}.tar.gz"

if [ ! -r "${Ansible_Files_Tar}" ]; then
    aborting "'${Ansible_Files_Tar}' file not found readable}"
fi

#
# If found then use a particular ansible.cfg
#

if [ ${#Ansible_Cfg} -eq 0 ]; then
    if [ ${#ANSIBLE_CONFIG} -gt 0 ]; then
        Ansible_Cfg=${ANSIBLE_CONFIG}
    else
        Ansible_Cfg="${Dirname}/.ansible.cfg"
        if [ ! -r ${Ansible_Cfg} ]; then
            Ansible_Cfg="/home/$(logname)/.ansible.cfg"
            if [ ! -r ${Ansible_Cfg} ]; then
                unset -v Ansible_Cfg
            fi
        fi
    fi
fi

if [ ${#Ansible_Cfg} -eq 0 ]; then
    _echo "not using an Ansible_Cfg"
else
    _echo "using Ansible_Cfg '${Ansible_Cfg}'"
fi

if  [ ${Install} -eq 0 ]; then
    if  [ ${Upgrade} -eq 0 ]; then
        Setup_Snmpd_Action="upgrade"
    else
        Setup_Snmpd_Action="install"
    fi
else
    Setup_Snmpd_Action="check"
fi

echo
export ANSIBLE_CONFIG=${Ansible_Cfg}
echo ansible-playbook -i ${Ansible_Inventory} ${Ansible_Playbook} --limit "${Limit}"
echo
ansible-playbook -i ${Ansible_Inventory} ${Ansible_Playbook} --extra-vars "setup_snmpd_action=$Setup_Snmpd_Action" --limit "${Limit}" $@
echo
