#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

if [ ! -r "/tmp/clonezilla_latest.zip" ]
then
  latest_clonezilla_live_alternative_stable_version=$(curl --silent https://clonezilla.org/downloads/download.php?branch=alternative | grep "live version" | tr '<>' ' ' | cut -d' ' -f7)

  printf "%s\n" "Downloading an alternative - the Ubuntu-based - version of Clonezilla zip-file from"
  printf "%s\n\n" "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download"

  # example of a download URI:
  #   https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/20211116-impish/clonezilla-live-20211116-impish-amd64.zip/download?use_mirror=jztkft

  axel --verbose --num-connections=10 \
      https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download --output="/tmp/clonezilla_latest.zip"
fi

if [ ! -r "/tmp/clonezilla_latest.zip" ]
then
  printf "%s\n" "Downloading from main source failed. Trying direct download from:"
  printf "%s\n" "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_alternative/20230426-lunar/clonezilla-live-20230426-lunar-amd64.zip?viasf=1"

  # Example of direct link download (lunar is the latest clonezilla version which boots into clonezilla environment: the newer versions - as for time of writing 2024/02/26 - were unable to boot into clonezilla environment and booted into gparted environment instead):
  #     https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_alternative/20230426-lunar/clonezilla-live-20230426-lunar-amd64.zip?viasf=1

  axel --verbose --num-connections=10 \
  "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_alternative/${latest_clonezilla_live_alternative_stable_version}/clonezilla-live-${latest_clonezilla_live_alternative_stable_version}-amd64.zip?viasf=1" \
  --output="/tmp/clonezilla_latest.zip"
fi

# TODO verify checksum of the downloaded ZIP archive to ensure integrity

echo "Unmount all partitions of the device '/dev/${DISK_NAME}'"
PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"

udisksctl unmount --block-device ${PARTITION_DEVICE}
udisksctl mount --block-device ${PARTITION_DEVICE}
USB_MOUNT_DIR="$(lsblk -oNAME,MOUNTPOINTS "${PARTITION_DEVICE}" | tail --lines=1 | cut --delimiter=' ' --fields=1 --complement)/"

sudo 7z x -y "/tmp/clonezilla_latest.zip" -o"${USB_MOUNT_DIR}"

sync
sudo sync

udisksctl unmount --block-device ${PARTITION_DEVICE}

