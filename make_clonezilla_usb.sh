#!/bin/sh

DISK_NAME="$1"
ALREADY_DOWNLOADED_CLONEZILLA_ISO="$2"

SCRIPT_DIR="$(dirname "$(readlink --canonicalize "$0")")"

"${SCRIPT_DIR}/utils/prepare_usb_for_clonezilla_uefi_booting.sh" "${DISK_NAME}"
"${SCRIPT_DIR}/utils/install_clonezilla_to_prepared_usb.sh" "${DISK_NAME}" "${ALREADY_DOWNLOADED_CLONEZILLA_ISO}"
"${SCRIPT_DIR}/utils/make_usb_bootable.sh" "${DISK_NAME}"


  script_name="$(basename "$0")"
  ln -sf "${SCRIPT_DIR}/$script_name" "$HOME/$script_name"
  ln -sf "${SCRIPT_DIR}/utils/install_clonezilla_to_prepared_usb.sh" "$HOME/install_clonezilla_to_prepared_usb.sh"
  ln -sf "${SCRIPT_DIR}/utils/prepare_usb_for_clonezilla_uefi_booting.sh" "$HOME/prepare_usb_for_clonezilla_uefi_booting.sh"
  ln -sf "${SCRIPT_DIR}/utils/make_usb_bootable.sh" "$HOME/make_usb_bootable.sh"

echo "______________________________________"
echo
echo "Links to the"
echo "separate formatting script"
echo "separate clonezilla install script"
echo "and complete clonezilla install script"
echo "had been made in your home directory"
echo "for more convenient launching at"
echo
echo "~/${script_name}"
echo "$HOME/install_clonezilla_to_prepared_usb.sh"
echo "$HOME/prepare_usb_for_clonezilla_uefi_booting.sh"
echo

