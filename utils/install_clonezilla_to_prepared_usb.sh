#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

if [ ! -r "/tmp/clonezilla_latest.zip" ]
then
  #latest_clonezilla_live_alternative_stable_version=$(curl --silent https://clonezilla.org/downloads/download.php?branch=alternative | grep "live version" | tr '<>' ' ' | cut -d' ' -f7)
  latest_clonezilla_live_alternative_stable_version=$(curl --silent https://clonezilla.org/downloads/download.php?branch=stable | grep "live version" | tr '<>' ' ' | cut -d' ' -f7)

  #printf "%s\n" "Downloading an alternative - the Ubuntu-based - version of Clonezilla zip-file from"
  #printf "%s\n\n" "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download"

  printf "%s\n" "Downloading the stable - the Debian-based - version of Clonezilla zip-file from"
  printf "%s\n\n" "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download"

  # example of a download URI:
  #   https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/20211116-impish/clonezilla-live-20211116-impish-amd64.zip/download?use_mirror=jztkft
  #   https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.2.0-5/clonezilla-live-3.2.0-5-amd64.zip/download

  #axel --verbose --num-connections=10 \
  #  https://sourceforge.net/projects/clonezilla/files/clonezilla_live_alternative/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download \
  #  --output="/tmp/clonezilla_latest.zip"

  axel --verbose --num-connections=10 \
    https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/"${latest_clonezilla_live_alternative_stable_version}"/clonezilla-live-"${latest_clonezilla_live_alternative_stable_version=}"-amd64.zip/download \
    --output="/tmp/clonezilla_latest.zip"
else
  printf "%s\n\n" "File already downloaded: the file is currently being present in the target directory"
  ls -l "/tmp/clonezilla_latest.zip"
  echo ""
fi

if [ ! -r "/tmp/clonezilla_latest.zip" ]
then
  printf "%s\n" "Downloading from main source failed. Trying direct download from:"
  #printf "%s\n" "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_alternative/${latest_clonezilla_live_alternative_stable_version}/clonezilla-live-${latest_clonezilla_live_alternative_stable_version}-amd64.zip?viasf=1"
   printf "%s\n" "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/${latest_clonezilla_live_alternative_stable_version}/clonezilla-live-${latest_clonezilla_live_alternative_stable_version}-amd64.zip?viasf=1"

  # Example of direct link download (lunar is the latest clonezilla version which boots into clonezilla environment: the newer versions - as for time of writing 2024/02/26 - were unable to boot into clonezilla environment and booted into gparted environment instead):
  #   https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_alternative/20230426-lunar/clonezilla-live-20230426-lunar-amd64.zip?viasf=1

  #axel --verbose --num-connections=10 \
  #  "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_alternative/${latest_clonezilla_live_alternative_stable_version}/clonezilla-live-${latest_clonezilla_live_alternative_stable_version}-amd64.zip?viasf=1" \
  #  --output="/tmp/clonezilla_latest.zip"

  axel --verbose --num-connections=10 \
    "https://master.dl.sourceforge.net/project/clonezilla/clonezilla_live_stable/${latest_clonezilla_live_alternative_stable_version}/clonezilla-live-${latest_clonezilla_live_alternative_stable_version}-amd64.zip?viasf=1" \
    --output="/tmp/clonezilla_latest.zip"
else
  printf "%s\n\n" "File already downloaded: the file is currently being present in the target directory"
  ls -l "/tmp/clonezilla_latest.zip"
  echo ""
fi

echo "Latest clonezilla ready for extraction"

# Verify checksum of the downloaded ZIP archive to ensure integrity
curl --silent https://clonezilla.org/downloads/stable/checksums.php | grep "$(sha256sum /tmp/clonezilla_latest.zip | awk '{print $1}')"
RETVAL=$?
echo ${RETVAL}
if [ $RETVAL -eq 0 ]
then
    echo "File integrity preserved: the file is downloaded correctly and valid"
else
    echo "File integrity compromised: the file had been corrupted during download"
fi

# Verify checksum of the downloaded ZIP archive to ensure integrity again
unset RETVAL
curl --silent https://clonezilla.org/downloads/stable/checksums.php | grep "$(sha256sum /tmp/clonezilla_latest.zip | cut --delimiter=' ' --fields=1)"
RETVAL=$?
echo ${RETVAL}
if [ $RETVAL -eq 0 ]
then
  echo "File integrity preserved: the file is downloaded correctly and valid"
else
  echo "File integrity compromised: the file had been corrupted during download"
fi

echo "Unmount all partitions of the device '/dev/${DISK_NAME}'"
PARTITION_NAME=$(grep "${DISK_NAME}" /proc/partitions | rev | cut -d' ' -f1 | rev | grep -v "^"${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"

udisksctl unmount --block-device ${PARTITION_DEVICE}
udisksctl mount --block-device ${PARTITION_DEVICE}
USB_MOUNT_DIR="$(lsblk -oNAME,MOUNTPOINTS "${PARTITION_DEVICE}" | tail --lines=1 | cut --delimiter=' ' --fields=1 --complement)/"

sudo 7z x -y "/tmp/clonezilla_latest.zip" -o"${USB_MOUNT_DIR}"

sync
sudo sync

udisksctl unmount --block-device ${PARTITION_DEVICE}

