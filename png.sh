#!/bin/bash

DIR="/var/www/pimon"
DB="${DIR}/database-pimon.rrd"

COLOR="--color BACK#000000 \
    --color FONT#FFFFFF \
    --color MGRID#FFFFFF \
    --color CANVAS#000000 \
    --color AXIS#FFFFFF \
    --color ARROW#FFFFFF \
    --color SHADEA#000000 \
    --color SHADEB#000000"

if [ ! -e "${DIR}/png" ]; then
    mkdir -pv "${DIR}/png"
fi

function output_mem() {
    filename=${1}
    start=${2}
    end=${3}
    title=${4}

    rrdtool graph \
            "${DIR}/${filename}" \
            ${COLOR} \
            --start=${start} \
            --end=${end} \
            --title "${title}" \
            --alt-autoscale \
            --width 600 \
            --units-length 5 \
            "DEF:cached=${DB}:mem_cached:${CS}" \
            "DEF:used=${DB}:mem_used:${CS}" \
            "DEF:swap=${DB}:mem_swap:${CS}" \
            "AREA:cached#FFA500:cached" \
            "AREA:used#FF0000:used" \
            "LINE1:swap#0000FF:swap" \
            1>/dev/null
}

function output() {
    filename=${1}
    start=${2}
    end=${3}
    title=${4}
    which=${5}
    color=${6}
    length=${7}
    extra=${8}

    rrdtool graph \
            "${DIR}/${filename}" \
            ${COLOR} \
            --start=${start} \
            --end=${end} \
            --title "${title}" \
            --width 600 \
            --no-legend \
            --units-length ${length} \
            ${extra} \
            "DEF:data=${DB}:${which}:${CS}" \
            "LINE1:data#${color}" \
            1>/dev/null
}

now=$(date +%s)
hour=$(date --date "now -1 hour" +%s)
day=$(date --date "now -1 day" +%s)
week=$(date --date "now -1 week" +%s)
month=$(date --date "now -1 month" +%s)
month6=$(date --date "now -6 month" +%s)
year=$(date --date "now -1 year" +%s)

###########
# AVERAGE #
###########
CS="AVERAGE"

# order:
# mem_used
# mem_cached
# mem_swap
# rootfs_used
# loadavg
# clock_arm
# temp

# 1 hour
output_mem "png/mem_usage_hour.png" ${hour} ${now} "Memory Usage Last Hour"
output "png/disk_usage_hour.png" ${hour} ${now} "Disk Space Usage Last Hour" rootfs_used "0000FF" 7
output "png/loadavg_hour.png" ${hour} ${now} "Load Average Last Hour" loadavg "FF0000" 5 "-X 1"
output "png/clock_arm_hour.png" ${hour} ${now} "Frequency Last Hour" clock_arm "00FF00" 5
output "png/temp_hour.png" ${hour} ${now} "Temperature Last Hour" temp "FF0000" 4

# 1 day
output_mem "png/mem_usage_day.png" ${day} ${now} "Memory Usage Last Day"
output "png/disk_usage_day.png" ${day} ${now} "Disk Space Usage Last Day" rootfs_used "0000FF" 7
output "png/loadavg_day.png" ${day} ${now} "Load Average Last Day" loadavg "FF0000" 5 "-X 1"
output "png/clock_arm_day.png" ${day} ${now} "Frequency Last Day" clock_arm "00FF00" 5
output "png/temp_day.png" ${day} ${now} "Temperature Last Day" temp "FF0000" 4

# 1 week
output_mem "png/mem_usage_week.png" ${week} ${now} "Memory Usage Last Week"
output "png/disk_usage_week.png" ${week} ${now} "Disk Space Usage Last Week" rootfs_used "0000FF" 7
output "png/loadavg_week.png" ${week} ${now} "Load Average Last Week" loadavg "FF0000" 5 "-X 1"
output "png/clock_arm_week.png" ${week} ${now} "Frequency Last Week" clock_arm "00FF00" 5
output "png/temp_week.png" ${week} ${now} "Temperature Last Week" temp "FF0000" 4

# 1 month
output_mem "png/mem_usage_month.png" ${month} ${now} "Memory Usage Last Month"
output "png/disk_usage_month.png" ${month} ${now} "Disk Space Usage Last Month" rootfs_used "0000FF" 7
output "png/loadavg_month.png" ${month} ${now} "Load Average Last Month" loadavg "FF0000" 5 "-X 1"
output "png/clock_arm_month.png" ${month} ${now} "Frequency Last Month" clock_arm "00FF00" 5
output "png/temp_month.png" ${month} ${now} "Temperature Last Month" temp "FF0000" 4

# 6 months
output_mem "png/mem_usage_month6.png" ${month6} ${now} "Memory Usage Last 6 Months"
output "png/disk_usage_month6.png" ${month6} ${now} "Disk Space Usage Last 6 Months" rootfs_used "0000FF" 7
output "png/loadavg_month6.png" ${month6} ${now} "Load Average Last 6 Months" loadavg "FF0000" 5 "-X 1"
output "png/clock_arm_month6.png" ${month6} ${now} "Frequency Last 6 Months" clock_arm "00FF00" 5
output "png/temp_month6.png" ${month6} ${now} "Temperature Last 6 Months" temp "FF0000" 4

# 1 year
output_mem "png/mem_usage_year.png" ${year} ${now} "Memory Usage Last Year"
output "png/disk_usage_year.png" ${year} ${now} "Disk Space Usage Last Year" rootfs_used "0000FF" 7
output "png/loadavg_year.png" ${year} ${now} "Load Average Last Year" loadavg "FF0000" 5 "-X 1"
output "png/clock_arm_year.png" ${year} ${now} "Frequency Last Year" clock_arm "00FF00" 5
output "png/temp_year.png" ${year} ${now} "Temperature Last Year" temp "FF0000" 4
