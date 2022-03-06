#!/bin/sh

set -x

echo "Format USB to GPT partition table and one FAT32 partition with GParted."
echo "When done, press any key to continue..."
read -r

sync
sudo sync
