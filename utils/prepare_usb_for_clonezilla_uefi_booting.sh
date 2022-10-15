#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

PARTITION_TABLE_TYPE="$2"

echo "Verification before"
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"

echo "Unmount all partitions of the device ${DISK_DEVICE}"
cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$" | xargs -I % sh -c 'sudo umount /dev/%'

if [ -z "$PARTITION_TABLE_TYPE" ] || [ "${PARTITION_TABLE_TYPE}" == "gpt" ] || [ "${PARTITION_TABLE_TYPE}" == "uefi" ]
then
  echo "Create GPT partition table"
  sudo parted --script "${DISK_DEVICE}" -- mklabel "gpt"
fi

if [ "${PARTITION_TABLE_TYPE}" == "mbr" ] || [ "${PARTITION_TABLE_TYPE}" == "legacy" ]
then
  echo "Create MBR partition table"
  sudo parted --script "${DISK_DEVICE}" -- mklabel "msdos"
fi

echo "Add one FAT32 partition"
sudo parted --script --align optimal "${DISK_DEVICE}" -- mkpart primary fat32 0% 100%
 
echo "Format that partition"
PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"
sudo mkfs.vfat "${PARTITION_DEVICE}"

sync
sudo sync

