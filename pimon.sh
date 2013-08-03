#!/bin/bash

DB='/var/www/pimon/database-pimon.rrd'

declare -i SUM
declare -i COUNT
declare -i now

now=$(date +%s)

# resolution | duration
#------------+----------
# 2 min      | 525600 * 2 min = 2 years

# DS | source
# mem_used | free -m: row: -/+, column: used
# mem_cached | free -m: row: Mem, column: used
# mem_swap | free -m: row: Swap, column: used
# loadavg | /proc/loadavg
# rootfs_used | df | grep rootfs
# clock_arm | vgcencm measure_clock arm
# temp | vcgencmd measure_temp

# create RRD if not existent
if [ ! -e ${DB} ]; then
    mkdir -pv "$(dirname ${DB})"

    rrdtool create ${DB} \
                   --step 120 \
                   --start=${now} \
                   "DS:mem_used:GAUGE:240:0:1024" \
                   "DS:mem_cached:GAUGE:240:0:1024" \
                   "DS:mem_swap:GAUGE:240:0:32000" \
                   "DS:loadavg:GAUGE:240:0:1000" \
                   "DS:rootfs_used:GAUGE:240:0:512000000000" \
                   "DS:clock_arm:GAUGE:240:0:2000" \
                   "DS:temp:GAUGE:240:0:100" \
                   "RRA:AVERAGE:0.5:1:525600" \
                   "RRA:MAX:0.5:1:525600" \
                   "RRA:MIN:0.5:1:525600"

    if [ "$?" != "0" ]; then
        echo >&2 "database ${DB} could not be created"
        exit 1
    fi
fi

# memory 
OUTPUT=( $(free -m) )
CACHED=${OUTPUT[8]}
USED=${OUTPUT[15]}
SWAP=${OUTPUT[19]}

# loadavg
OUTPUT=( $(cat /proc/loadavg) )
LOAD=${OUTPUT[0]}

# rootfs usage
OUTPUT=( $(df | grep rootfs) )
ROOTFS=${OUTPUT[2]}
ROOTFS=$(echo "${ROOTFS}*1000" | bc -l) # multiply by 1000

# arm frequency
CLOCK=$(vcgencmd measure_clock arm | cut -d "=" -f 2)
CLOCK=$(echo "${CLOCK}/1000000" | bc -l) # divide by 1e6

# temperature
TEMP=$(vcgencmd measure_temp | cut -d "=" -f 2)
TEMP=${TEMP%??} # remove unit "'C"

# make variables 'unknown' which have no value
: ${CACHED:="-1"}
: ${USED:="-1"}
: ${SWAP:="-1"}
: ${LOAD:="-1"}
: ${ROOTFS:="-1"}
: ${CLOCK:="-1"}
: ${TEMP:="-1"}

rrdupdate ${DB} N:${USED}:${CACHED}:${SWAP}:${LOAD}:${ROOTFS}:${CLOCK}:${TEMP}

if [ "$?" != "0" ]; then
    echo >&2 "rrdupdate failed (N:${USED}:${CACHED}:${SWAP}:${LOAD}:${ROOTFS}:${CLOCK}:${TEMP})"
fi
