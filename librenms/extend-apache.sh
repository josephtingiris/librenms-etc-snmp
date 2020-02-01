#!/usr/bin/env bash

# Output apache server-status values for LibreNMS.

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
# bash
# curl or wget

#
# 20200102, joseph.tingiris@gmail.com, created
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

# set (used) server-status default values to U; not all apache's have all stats
Total_Accesses="U"
Total_kBytes="U"
CPULoad="U"
Uptime="U"
ReqPerSec="U"
BytesPerSec="U"
BytesPerReq="U"
BusyWorkers="U"
IdleWorkers="U"
Scoreboard="U"

# set server-status default scoreboard counters to 0
let Scoreboard_=0
let ScoreboardDot=0
let ScoreboardC=0
let ScoreboardD=0
let ScoreboardG=0
let ScoreboardI=0
let ScoreboardK=0
let ScoreboardL=0
let ScoreboardR=0
let ScoreboardS=0
let ScoreboardW=0

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

wget "http://localhost/server-status?auto" -o /dev/null -O ${Tmp_File} &> /dev/null # wget is slightly faster than curl
RC=$?
if [ ${RC} -ne 0 ]; then
    curl --silent --fail "http://localhost/server-status?auto" -o ${Tmp_File} &> /dev/null
    RC=$?
    if [ ${RC} -ne 0 ]; then
        debugecho "curl failed, RC=${RC}"
        exit 1
    fi
fi

if [ ! -s ${Tmp_File} ]; then
    debugecho "${Tmp_File} is empty"
    exit 1
fi

while read Line; do
    Field=${Line%:*}
    Value=${Line#*: }

    debugecho "Line: ${Line}"
    debugecho "Field: ${Field}"
    debugecho "Value: ${Value}"
    debugecho

    if [ "${Field}" == "Total Accesses" ]; then
        Total_Accesses=${Value}
    fi

    if [ "${Field}" == "Total kBytes" ]; then
        Total_kBytes=${Value}
    fi

    if [ "${Field}" == "CPULoad" ]; then
        CPULoad=${Value}
    fi

    if [ "${Field}" == "Uptime" ]; then
        Uptime=${Value}
    fi

    if [ "${Field}" == "ReqPerSec" ]; then
        ReqPerSec=${Value}
    fi

    if [ "${Field}" == "BytesPerSec" ]; then
        BytesPerSec=${Value}
    fi

    if [ "${Field}" == "BytesPerReq" ]; then
        BytesPerReq=${Value}
    fi

    if [ "${Field}" == "BusyWorkers" ]; then
        BusyWorkers=${Value}
    fi

    if [ "${Field}" == "IdleWorkers" ]; then
        IdleWorkers=${Value}
    fi

    if [ "${Field}" == "Scoreboard" ]; then
        Scoreboard=${Value}
    fi

done < ${Tmp_File}

# for LibreNMS, value output order must be as follows ...
echo "${Total_Accesses}"
echo "${Total_kBytes}"
echo "${CPULoad}"
echo "${Uptime}"
echo "${ReqPerSec}"
echo "${BytesPerSec}"
echo "${BytesPerReq}"
echo "${BusyWorkers}"
echo "${IdleWorkers}"

debugecho "Scoreboard = ${Scoreboard}"
for (( c=0; c<${#Scoreboard}; c++ )); do

    if [ "${Scoreboard:$c:1}" == "_" ]; then
        let Scoreboard_=${Scoreboard_}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "." ]; then
        let ScoreboardDot=${ScoreboardDot}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "C" ]; then
        let ScoreboardC=${ScoreboardC}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "D" ]; then
        let ScoreboardD=${ScoreboardD}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "G" ]; then
        let ScoreboardG=${ScoreboardG}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "I" ]; then
        let ScoreboardI=${ScoreboardI}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "K" ]; then
        let ScoreboardK=${ScoreboardK}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "L" ]; then
        let ScoreboardL=${ScoreboardL}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "R" ]; then
        let ScoreboardR=${ScoreboardR}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "S" ]; then
        let ScoreboardS=${ScoreboardS}+1
        continue
    fi

    if [ "${Scoreboard:$c:1}" == "W" ]; then
        let ScoreboardW=${ScoreboardW}+1
        continue
    fi

    debugecho "${Scoreboard:$c:1}"
done

# for LibreNMS, scoreboard output order must be as follows ...
echo ${Scoreboard_}
echo ${ScoreboardS}
echo ${ScoreboardR}
echo ${ScoreboardW}
echo ${ScoreboardK}
echo ${ScoreboardD}
echo ${ScoreboardC}
echo ${ScoreboardL}
echo ${ScoreboardG}
echo ${ScoreboardI}
echo ${ScoreboardDot}

cleanup "${Tmp_File}"
