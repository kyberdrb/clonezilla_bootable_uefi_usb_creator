#!/bin/sh

# TODO automatic mode with automatic USB detection + manual mode with user entered USB partition
#   I'll start with the noninteractive mode, because it's easier

# TODO maybe use 'cat /proc/partitions' to automatically detect device and/or partition name of newly inserted USB by comparing the file content before and after inserting the USB with diff - see the firstmost TODO task at the top of this script
# TODO check, if the entered partition name is different than the partition names of the boot drive - continue only if the entered/deducted partition/device name is different from the name of the boot drive/system disk (maybe with comparing 'cat /etc/fstab' before and after USB insertion by comparing changes with diff? or exclue boot drive with 'cat /etc/fstab | grep /'?) AND?/OR? when all entries in the fstab refer to the same disk (maybe with blkid and fdisk, to find the UUID to disk/partition name mapping)? or exclude all of them?

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

echo "------------------------------------------------------------"
echo "Unmount all partitions of the device '${DISK_DEVICE}'"
cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$" | xargs -I % sh -c 'sudo umount /dev/%'

echo "------------------------------------------------------------"
echo "Verification: before setting the disk label to gpt"
sudo fdisk "${DISK_DEVICE}" --list | grep Disklabel

sudo parted --script "${DISK_DEVICE}" -- mklabel "gpt"

echo "------------------------------------------------------------"
echo "Verification: after setting the disk label to gpt"
echo
sudo fdisk "${DISK_DEVICE}" --list | grep Disklabel

echo "------------------------------------------------------------"
echo "Verification: before removing existing partitions"
echo
sudo parted --script "${DISK_DEVICE}" print
echo 
lsblk --fs "${DISK_DEVICE}"
echo
cat /proc/partitions | grep "${DISK_NAME}"

output=$(sudo parted --script --machine "${DISK_DEVICE}" print)
total_num_of_lines=$(printf "${output}\n" | wc -l)
num_of_last_lines=$(( total_num_of_lines - 2))
partition_numbers="$(printf "${output}\n" | tail -n $num_of_last_lines | cut -d ':' -f 1)"
echo "$partition_numbers" | xargs sudo parted --script "${DISK_DEVICE}" rm

echo "------------------------------------------------------------"
echo "Verification: after removing existing partitions"
echo
sudo parted --script "${DISK_DEVICE}" print
echo 
lsblk --fs "${DISK_DEVICE}"
echo
cat /proc/partitions | grep "${DISK_NAME}"

echo "------------------------------------------------------------"
echo "Verification: before partitioning"
lsblk --fs "${DISK_DEVICE}"

sudo parted --script --align optimal "${DISK_DEVICE}" -- mkpart primary fat32 0% 100%

echo "------------------------------------------------------------"
echo "Verification: after partitioning"
lsblk --fs "${DISK_DEVICE}"

PARTITION="/dev/$(cat /proc/partitions | grep "${DISK_NAME}" | grep -v "${DISK_NAME}"$ | tr -s ' \t' | rev | cut -d' ' -f1 | rev)"
sudo mkfs.vfat "${PARTITION}"

echo "------------------------------------------------------------"
echo "Verification: after formatting the partition"
lsblk --fs "${DISK_DEVICE}"

echo "------------------------------------------------------------"
echo "Verification: before setting the bootable flag"
sudo parted --script "${DISK_DEVICE}" print

partition_number="$(sudo parted --machine --script "${DISK_DEVICE}" print | tail -n 1 | cut -d':' -f1)"
sudo parted --script "${DISK_DEVICE}" set "${partition_number}" "boot" "on"

echo "------------------------------------------------------------"
echo "Verification: after setting the bootable flag"
sudo parted --script "${DISK_DEVICE}" print

echo "------------------------------------------------------------"
echo "Verification: before setting partition label to show in 'lsblk' output"
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"
echo
sudo fdisk "${DISK_DEVICE}" --list -o +Name | grep ""${PARTITION}"" -B1

partition_label="CLONEZILLA"
sudo fatlabel "${PARTITION}" "${partition_label}"

echo "------------------------------------------------------------"
echo "Verification: after setting partition label to show in 'lsblk' output"
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"
echo
sudo fdisk "${DISK_DEVICE}" --list -o +Name | grep ""${PARTITION}"" -B1

sudo parted --script "${DISK_DEVICE}" name 1 "${partition_label}"

echo "------------------------------------------------------------"
echo "Verification: after setting partition label to show in 'fdisk --list-details' output"
sudo fdisk "${DISK_DEVICE}" --list -o +Name | grep ""${PARTITION}"" -B1
echo
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"

sync
sudo sync
