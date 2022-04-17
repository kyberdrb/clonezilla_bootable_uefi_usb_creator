#!/bin/sh

DISK_NAME="$1"
ALREADY_DOWNLOADED_CLONEZILLA_ISO="$2"

SCRIPT_DIR="$(dirname "$(readlink --canonicalize "$0")")"

"${SCRIPT_DIR}/utils/prepare_usb_for_clonezilla_uefi_booting.sh" "${DISK_NAME}"
"${SCRIPT_DIR}/utils/install_clonezilla_to_prepared_usb.sh" "${DISK_NAME}" "${ALREADY_DOWNLOADED_CLONEZILLA_ISO}"
"${SCRIPT_DIR}/utils/make_usb_bootable.sh" "${DISK_NAME}"


  script_name="$(basename "$0")"
  ln -sf "${SCRIPT_DIR}/$script_name" "$HOME/$script_name"

echo "______________________________________"
echo
echo "Links to the complete clonezilla install script"
echo "had been made in your home directory for more convenient launching at"
echo
echo "${HOME}/${script_name}"
echo

