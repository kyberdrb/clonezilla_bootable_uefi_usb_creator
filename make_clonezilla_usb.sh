#!/bin/sh

DISK_NAME="$1"

SCRIPT_DIR="$(dirname "$(readlink --canonicalize "$0")")"

"${SCRIPT_DIR}/utils/prepare_usb_for_clonezilla_uefi_booting.sh" "${DISK_NAME}"
"${SCRIPT_DIR}/utils/install_clonezilla_to_prepared_usb.sh" "${DISK_NAME}"
