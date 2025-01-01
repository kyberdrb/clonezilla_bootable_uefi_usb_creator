#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

PARTITION_TABLE_TYPE="$2"

if [ "${PARTITION_TABLE_TYPE}" = "mbr" ] || [ "${PARTITION_TABLE_TYPE}" = "legacy" ]
then
  echo "Set the 'boot' flag"
  partition_number="$(sudo parted --machine --script "${DISK_DEVICE}" print | tail -n 1 | cut -d':' -f1)"

  # Setting partition flags with quotes...
  sudo parted --script "${DISK_DEVICE}" set "${partition_number}" "boot" on

  # ...or without quotes ;)
  sudo parted --script "${DISK_DEVICE}" set "${partition_number}" lba on

  # SYSLINUX left here as a fallback in case the USB doesn't boot

  printf "%s\n" "Download lates 'syslinux' package"
  sudo pacman --sync --downloadonly --noconfirm --cachedir "/tmp/" syslinux

  syslinux_package_in_latest_version="$(find /tmp/ -maxdepth 1 -type f -name "syslinux*" | sort | head --lines=1)"
  sudo rm "${syslinux_package_in_latest_version}.sig"

  sudo chown --reference "${HOME}" "${syslinux_package_in_latest_version}"
  7z x -y "${syslinux_package_in_latest_version}" -o/tmp/syslinux_latest

  syslinux_inner_package="$(find /tmp/syslinux_latest -type f)"
  7z x -y "${syslinux_inner_package}" -o/tmp/syslinux_inner_package

  echo "Unmount the single partition that is now on the USB '${DISK_DEVICE}'"
  PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
  PARTITION_DEVICE="/dev/${PARTITION_NAME}"

  udisksctl unmount --block-device "${PARTITION_DEVICE}"

  printf "%s\n" "Installing bootloader with 'syslinux'"
  chmod +x "/tmp/syslinux_inner_package/usr/bin/syslinux"

  sudo "/tmp/syslinux_inner_package/usr/bin/syslinux" --install "${PARTITION_DEVICE}"

  printf "%s\n\n" "SYSLINUX bootloader successfully installed onto "${PARTITION_DEVICE}""

  printf "%s\n" "Patching 'libcom32.c32' to prevent error with failed to load 'vesamenu.c32' by copying the all Syslinux files"
  udisksctl mount --block-device "${PARTITION_DEVICE}"
  CLONEZILLA_DEVICE_MOUNTPOINT="$(lsblk --output KNAME,MOUNTPOINT | grep "${PARTITION_NAME}" | cut --delimiter=' ' --fields=1 --complement | sed 's/^\s*//g')"
  cp /tmp/syslinux_inner_package/usr/lib/syslinux/bios/* "${CLONEZILLA_DEVICE_MOUNTPOINT}/syslinux/"

  udisksctl unmount --block-device "${PARTITION_DEVICE}"

  # Fix non-bootability of the USB drive even with Syslinux installed
  sudo dd bs=440 count=1 conv=notrunc if=/tmp/syslinux_inner_package/usr/lib/syslinux/bios/mbr.bin of="${DISK_DEVICE}"
  printf "%s\n\n" "Bootable MBR has been successfully flashed onto "${DISK_DEVICE}""
fi

# Not necesarry to flash the GPT bootability binary - the UEFI boots from the USB drive regardless of the boot sector
#  mentioned here only for reference
#if [ -z "$PARTITION_TABLE_TYPE" ] || [ "${PARTITION_TABLE_TYPE}" = "gpt" ] || [ "${PARTITION_TABLE_TYPE}" = "uefi" ]
#then
  #sudo dd bs=440 count=1 conv=notrunc if=/tmp/syslinux_inner_package/usr/lib/syslinux/bios/gptmbr.bin of="${DISK_DEVICE}"
  #printf "%s\n\n" "Bootable GPT has been successfully flashed onto "${DISK_DEVICE}""

  #partnum=$(sudo parted /dev/sdb --script print | tail --lines=2 | head --lines=1 | awk '{print $1}')
  #sudo parted "${DISK_DEVICE}" --script set ${partnum} boot on set ${partnum} esp on
  #sudo parted --script "${DISK_DEVICE}" print
#fi

echo "Set the partition name for easier recognition in the file manager and in the terminal"
PARTITION="/dev/$(cat /proc/partitions | grep "${DISK_NAME}" | grep -v "${DISK_NAME}"$ | tr -s ' \t' | rev | cut -d' ' -f1 | rev)"
partition_label="CLONEZILLA"
sudo fatlabel "${PARTITION}" "${partition_label}"

echo "Verification"
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"
echo "========================================="
sudo parted --script "${DISK_DEVICE}" print
