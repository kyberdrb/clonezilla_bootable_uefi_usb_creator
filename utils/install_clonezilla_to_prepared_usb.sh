#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

ALREADY_DOWNLOADED_CLONEZILLA_ISO="$2:-"/tmp/clonezilla_latest.zip""

echo "Unmount all partitions of the device '/dev/${DISK_NAME}'"
PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"

sudo umount "${PARTITION_DEVICE}"

mkdir --parent "${HOME}/clonezilla_usb_mount_directory/"
sudo mount "${PARTITION_DEVICE}" "${HOME}/clonezilla_usb_mount_directory/"


if [ ! -f "${ALREADY_DOWNLOADED_CLONEZILLA_ISO}" ]
then
  latest_clonezilla_live_alternative_stable_version=$(curl --silent https://clonezilla.org/downloads/download.php?branch=alternative | grep "live version" | tr '<>' ' ' | cut -d' ' -f7)

  printf "%s\n" "Downloading an alternative - the Ubuntu-based - version of Clonezilla zip-file from"
  printf "%s\n\n" "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download"

  # example of a download URI:         https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/20211116-impish/clonezilla-live-20211116-impish-amd64.zip/download?use_mirror=jztkft

  axel --verbose --num-connections=10 \
      https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download --output="/tmp/clonezilla_latest.zip"
fi

sudo 7z x -y "/tmp/clonezilla_latest.zip" -o"${HOME}/clonezilla_usb_mount_directory/"

sync
sudo sync

sudo umount "${PARTITION_DEVICE}"
rmdir "${HOME}/clonezilla_usb_mount_directory/"

