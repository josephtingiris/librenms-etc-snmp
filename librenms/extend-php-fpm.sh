#!/usr/bin/env bash

# Output php-fpm status values for LibreNMS.

# Dependencies:
# bash
# curl or wget
# pm.status_path = /status # in php-fpm.d/www.conf

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
# 20200102, joseph.tingiris@gmail.com, modified original LibreNMS phpfpmsp script
#

#
# Globals
#

Basename=${0##*/}
Dirname=${0%/*}

# the URL to fetch, change as needed
url="http://localhost/status?full"
opts=""

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
# GPL v3+
#
# Contributed by @safeie with PR #276
# Modified to work as a SNMP extend by Zane C. Bowers-Hadley

declare -A phpfpm_urls=()
declare -A phpfpm_curl_opts=()

# _update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
phpfpm_update_every=
phpfpm_priority=60000

declare -a phpfpm_response=()
phpfpm_pool=""
phpfpm_start_time=""
phpfpm_start_since=0
phpfpm_accepted_conn=0
phpfpm_listen_queue=0
phpfpm_max_listen_queue=0
phpfpm_listen_queue_len=0
phpfpm_idle_processes=0
phpfpm_active_processes=0
phpfpm_total_processes=0
phpfpm_max_active_processes=0
phpfpm_max_children_reached=0
phpfpm_slow_requests=0

#
# Main
#

# source extend-include.sh or exit
if [ -r "${Dirname}/extend-include.sh" ]; then
    source "${Dirname}/extend-include.sh"
else
    exit 1
fi

PATH=/sbin:/bin:/usr/sbin:/usr/bin

phpfpm_response=($(curl --silent --fail ${opts} "${url}" 2> /dev/null))
[ $? -ne 0 -o "${#phpfpm_response[@]}" -eq 0 ] && exit 1

if [[ "${phpfpm_response[0]}" != "pool:" \
    || "${phpfpm_response[2]}" != "process" \
    || "${phpfpm_response[5]}" != "start" \
    || "${phpfpm_response[12]}" != "accepted" \
    || "${phpfpm_response[15]}" != "listen" \
    || "${phpfpm_response[16]}" != "queue:" \
    || "${phpfpm_response[26]}" != "idle" \
    || "${phpfpm_response[29]}" != "active" \
    || "${phpfpm_response[32]}" != "total" \
    ]]
then
    debugecho "invalid response from phpfpm status server: ${phpfpm_response[*]}"
    exit 1;
fi

phpfpm_pool="${phpfpm_response[1]}"
phpfpm_start_time="${phpfpm_response[7]} ${phpfpm_response[8]}"
phpfpm_start_since="${phpfpm_response[11]}"
phpfpm_accepted_conn="${phpfpm_response[14]}"
phpfpm_listen_queue="${phpfpm_response[17]}"
phpfpm_max_listen_queue="${phpfpm_response[21]}"
phpfpm_listen_queue_len="${phpfpm_response[25]}"
phpfpm_idle_processes="${phpfpm_response[28]}"
phpfpm_active_processes="${phpfpm_response[31]}"
phpfpm_total_processes="${phpfpm_response[34]}"
phpfpm_max_active_processes="${phpfpm_response[38]}"
phpfpm_max_children_reached="${phpfpm_response[42]}"

if [ "${phpfpm_response[43]}" == "slow" ]; then
    phpfpm_slow_requests="${phpfpm_response[45]}"
else
    phpfpm_slow_requests="-1"
fi

if [[ -z "${phpfpm_pool}" \
    || -z "${phpfpm_start_time}" \
    || -z "${phpfpm_start_since}" \
    || -z "${phpfpm_accepted_conn}" \
    || -z "${phpfpm_listen_queue}" \
    || -z "${phpfpm_max_listen_queue}" \
    || -z "${phpfpm_listen_queue_len}" \
    || -z "${phpfpm_idle_processes}" \
    || -z "${phpfpm_active_processes}" \
    || -z "${phpfpm_total_processes}" \
    || -z "${phpfpm_max_active_processes}" \
    || -z "${phpfpm_max_children_reached}" \
    ]]; then
    debugecho "empty values got from phpfpm status server: ${phpfpm_response[*]}"
    exit 1
fi

# In order the returned values are.
#
# pool
# start_time
# start_since
# accepted_conn
# listen_queue
# max_listen_queue
# listen_queue_len
# idle_processes
# active_processes
# total_processes
# max_active_processes
# max_children_reached
# slow_requests


echo $phpfpm_pool
echo $phpfpm_start_time
echo $phpfpm_start_since
echo $phpfpm_accepted_conn
echo $phpfpm_listen_queue
echo $phpfpm_max_listen_queue
echo $phpfpm_listen_queue_len
echo $phpfpm_idle_processes
echo $phpfpm_active_processes
echo $phpfpm_total_processes
echo $phpfpm_max_active_processes
echo $phpfpm_max_children_reached
echo $phpfpm_slow_requests
