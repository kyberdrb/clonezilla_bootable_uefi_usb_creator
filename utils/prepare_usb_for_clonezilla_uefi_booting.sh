#!/bin/sh

set -x

echo "Format USB to GPT partition table and one FAT32 partition and enable 'esp' and 'boot' flags with GParted"
echo "in order for the USB drive to be mounted automatically and shown in the file manager."
echo "When done, press any key to continue..."
read -r

sync
sudo sync
