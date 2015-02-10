#!/bin/bash
set -e

CACHE_MAX_SIZE=${CACHE_MAX_SIZE:-100}
CACHE_MAX_OBJECT_SIZE=${CACHE_MAX_OBJECT_SIZE:-4}
CACHE_MAX_MEM=${CACHE_MAX_MEM:-256}

PROXY_USER=${PROXY_USER:-proxy}
PROXY_PASSWORD=${PROXY_PASSWORD:-proxy}

OVERALL_SPEED_KBPS=${OVERALL_SPEED_KBPS:--1}
if [ ${OVERALL_SPEED_KBPS} -gt 0 ]; then
  OVERALL_SPEED_KBPS=$((${OVERALL_SPEED_KBPS} * 1000  / 8))
fi

INDIVIDUAL_SPEED_KBPS=${INDIVIDUAL_SPEED_KBPS:--1}
if [ ${INDIVIDUAL_SPEED_KBPS} -gt 0 ]; then
  INDIVIDUAL_SPEED_KBPS=$((${INDIVIDUAL_SPEED_KBPS} * 1000  / 8))
fi

# Apply squid config
sed 's/{{CACHE_MAX_SIZE}}/'"${CACHE_MAX_SIZE}"'/' -i /etc/squid3/squid.conf
sed 's/{{CACHE_MAX_OBJECT_SIZE}}/'"${CACHE_MAX_OBJECT_SIZE}"'/' -i /etc/squid3/squid.conf
sed 's/{{CACHE_MAX_MEM}}/'"${CACHE_MAX_MEM}"'/' -i /etc/squid3/squid.conf

sed 's/{{INDIVIDUAL_SPEED_KBPS}}/'"${INDIVIDUAL_SPEED_KBPS}"'/g' -i /etc/squid3/squid.conf
sed 's/{{OVERALL_SPEED_KBPS}}/'"${OVERALL_SPEED_KBPS}"'/g' -i /etc/squid3/squid.conf

# Initialize the cache_dir
if [ ! -d /var/spool/squid3/00 ]; then
  /usr/sbin/squid3 -N -f /etc/squid3/squid.conf -z
fi

htpasswd -b -c /etc/squid3/passwd ${PROXY_USER} ${PROXY_PASSWORD}

exec /usr/sbin/squid3 -NYC -d 1 -f /etc/squid3/squid.conf