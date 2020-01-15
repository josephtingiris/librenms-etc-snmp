#!/usr/bin/env php
<?php

# Output memcached values for LibreNMS.

# Dependencies:
# php
# memcached

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
# 20200114, joseph.tingiris@gmail.com, created
#

$Memcached = new Memcached();
$Memcached->addServer('localhost', 11211);
$Memcached_Stats = $Memcached->getStats();

if(!empty($Memcached_Stats) && is_array($Memcached_Stats)) {
    echo("<<<app-memcached>>>\n");
    echo(serialize($Memcached->getStats()));
    echo("\n");
} else {
    exit (1);
}
?>
