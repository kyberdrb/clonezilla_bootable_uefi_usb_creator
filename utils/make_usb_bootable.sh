#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

echo "Set the 'boot' flag"
partition_number="$(sudo parted --machine --script "${DISK_DEVICE}" print | tail -n 1 | cut -d':' -f1)"
sudo parted --script "${DISK_DEVICE}" set "${partition_number}" "boot" "on"

echo "Set the partition name for easier recognition in the file manager and in the terminal"
PARTITION="/dev/$(cat /proc/partitions | grep "${DISK_NAME}" | grep -v "${DISK_NAME}"$ | tr -s ' \t' | rev | cut -d' ' -f1 | rev)"
partition_label="CLONEZILLA"
sudo fatlabel "${PARTITION}" "${partition_label}"

echo "Verification"
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"
echo "========================================="
sudo parted --script "${DISK_DEVICE}" print
