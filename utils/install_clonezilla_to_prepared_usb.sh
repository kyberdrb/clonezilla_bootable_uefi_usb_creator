#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

ALREADY_DOWNLOADED_CLONEZILLA_ISO="$2:-"/tmp/clonezilla_latest.zip""

echo "Unmount all partitions of the device '/dev/${DISK_NAME}'"
PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"
sudo umount "${PARTITION_DEVICE}"

sudo mount "${PARTITION_DEVICE}" /mnt

#rm --force "/tmp/clonezilla_latest.zip"

# TODO download latest clonezilla alternative zip from the internet by default if no image is entered to a parameter locally

if [ ! -f "${ALREADY_DOWNLOADED_CLONEZILLA_ISO}" ]
then
  latest_clonezilla_live_alternative_stable_version=$(curl --silent https://clonezilla.org/downloads/download.php?branch=alternative | grep "live version" | tr '<>' ' ' | cut -d' ' -f7)
  #       https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/20211116-impish/clonezilla-live-20211116-impish-amd64.zip/download?use_mirror=jztkft

  printf "%s\n" "Downloading an alternative - the Ubuntu-based - version of Clonezilla zip-file from"
  printf "%s\n\n" "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download"

  axel --verbose --num-connections=10 https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download --output="/tmp/clonezilla_latest.zip"
  # end of alternative - Ubuntu-based section

  # stable - Debian-based
  #latest_clonezilla_live_stable_version=$(curl --silent https://clonezilla.org/downloads/download.php?branch=stable | grep "live version" | tr '<>' ' ' | cut -d' ' -f7)
  #curl -L https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/"${latest_clonezilla_live_stable_version}"/clonezilla-live-"${latest_clonezilla_live_stable_version=}"-amd64.zip/download -o"/tmp/clonezilla_latest.zip"

  # [optional-only for versions 'debian stable' and 'debian testing'] fix "invalid magic number" error [bug present on debian version of clonezilla in version 'clonezilla-live-2.8.0-27-amd64.zip' at uefi boot]
  #sudo sed --in-place 's:search --set -f /live/vmlinuz:#search --set -f /live/vmlinuz:g' /mnt/boot/grub/grub.cfg
  # end of stable - Debian-based section
fi

7z x -y "/tmp/clonezilla_latest.zip" -o/mnt

# [optional, but convenient - useful for compatibility with older computers/systems] Prepare for legacy BIOS booting
#sudo dd bs=440 count=1 conv=notrunc if=/mnt/utils/mbr/mbr.bin of=${DISK_DEVICE}
#sudo /mnt/utils/linux/x64/syslinux -d syslinux -f -i ${PARTITION_DEVICE}

sync
sudo sync
sudo umount "${PARTITION_DEVICE}"

