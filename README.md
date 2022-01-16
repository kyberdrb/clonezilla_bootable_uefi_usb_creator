# Clonezilla UEFI-Bootable USB

... with CSM compatibility to boot it with legacy BIOS.

## Usage

1. List USB devices before and after inserting the USB stick to determine the device name. Then choose this device for the Clonezilla installation.

      quick and sufficiently detailed listing

        $ lsblk -o NAME,FSTYPE,FSVER,UUID,MOUNTPOINT
        NAME   FSTYPE FSVER UUID                                 MOUNTPOINT
        sda                                                      
        ├─sda1 vfat   FAT32 220C-B8F7                            /boot
        └─sda2 ext4   1.0   cb217b7c-f7c0-4dae-b9a6-412e68b52408 /
        sdb                                                      
        └─sdb1 vfat   FAT32 B0F1-03FD                            


      or quick listing

        $ lsblk
        NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
        sda      8:0    0 238.5G  0 disk 
        ├─sda1   8:1    0   600M  0 part /boot
        └─sda2   8:2    0   220G  0 part /
        sdb      8:16   1   1.9G  0 disk 
        └─sdb1   8:17   1   1.9G  0 part

      or for more accurate output

        $ lsblk --fs
        NAME   FSTYPE FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
        sda                                                                                
        ├─sda1 vfat   FAT32            220C-B8F7                             356.3M    41% /boot
        └─sda2 ext4   1.0              cb217b7c-f7c0-4dae-b9a6-412e68b52408    7.5G    91% /
        sdb                                                                                
        └─sdb1 vfat   FAT32 CLONEZILLA B0F1-03FD

  In my case the USB stick I inserted has the name `sdb`

1. Prepare USB for UEFI booting. `sdb` is the device name of my USB stick. Your device name may vary, so make sure with `lsblk` before and after inserting the USB stick that the name of the device corresponds to the name you enter as an argument. **THIS IS A DESTRUCTIVE OPERATION! ALL DATA ON THE USB STICK WILL BE ERASED WITH THIS SCRIPT!**

        ./make_clonezilla_usb.sh sdb
        ./make_clonezilla_usb.sh <ENTER_USB_DEVICE_NAME>

- Sources - `prepare_usb_for_clonezilla_uefi_booting.sh`
  - https://www.unixmen.com/how-to-format-usb-drive-in-the-terminal/
  - https://duckduckgo.com/?q=mkfs+fat32&ia=web
  - https://www.redips.net/linux/create-fat32-usb-drive/
  - https://duckduckgo.com/?q=mkfs+fat32+noninteractive&ia=web
  - https://serverfault.com/questions/320590/non-interactively-create-one-partition-with-all-available-disk-size
  - https://www.gnu.org/software/parted/manual/html_chapter/parted_2.html
  - https://duckduckgo.com/?q=parted+mkpart+gpt&ia=web
  - https://www.gnu.org/software/parted/manual/html_node/mkpart.html
  - https://www.systutorials.com/making-gpt-partition-table-and-creating-partitions-with-parted-on-linux/
  - https://askubuntu.com/questions/1074515/create-one-partition-occupying-all-the-space-on-the-drive-with-gparted/1287643#1287643
  - https://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/
  - https://unix.stackexchange.com/questions/174157/parted-3-2-says-1024mib-is-outside-of-the-device-of-size-1024mib/174169#174169
  - Simply leave the calculation [of partition boundaries] to parted using percents as units - https://askubuntu.com/questions/701729/partition-alignment-parted-shows-warning/1145451#1145451
  - https://www.thegeekdiary.com/how-to-delete-disk-partition-using-parted-command/
  - https://www.tecmint.com/create-new-ext4-file-system-partition-in-linux/
  - https://serverfault.com/questions/614019/list-linux-partition-names-only-in-bash/614160#614160
  - https://linuxhint.com/uuid_storage_devices_linux/
  - https://devconnected.com/how-to-mount-and-unmount-drives-on-linux/#Unmounting_drives_on_Linux_using_umount
  - https://duckduckgo.com/?q=add+label+to+partition+parted+fat32&ia=web
  - https://www.preshweb.co.uk/2008/10/labelling-fatfat32-partitions-in-linux/
  - https://duckduckgo.com/?q=parted+change+fat+partition+name&ia=web
  - https://unix.stackexchange.com/questions/44095/how-to-change-the-volume-name-of-a-fat32-filesystem
  - **https://askubuntu.com/questions/1103569/how-do-i-change-the-label-reported-by-lsblk/1103592#1103592**
  - https://www.gnu.org/software/parted/manual/html_node/name.html
  - https://www.thegeekdiary.com/how-to-delete-disk-partition-using-parted-command/
  - ---
  - https://stackoverflow.com/questions/6901171/is-d-not-supported-by-greps-basic-expressions
  - https://stackoverflow.com/questions/11234858/how-do-you-grep-for-a-string-containing-a-slash
  - https://stackoverflow.com/questions/48131243/remove-digits-from-end-of-string
  - Use of xargs commands in Linux - https://www.programmerall.com/article/54662124051/


- Sources - `install_clonezilla_to_prepared_usb.sh`
  - https://clonezilla.org/downloads/download.php?branch=stable
  - Prepare for legacy BIOS booting - bootable Clonezilla USB for legacy and UEFI firmwares - https://kiljan.org/2019/12/24/clonezilla-live-legacy-bios-and-uefi-usb-boot/
  - https://clonezilla.org/clonezilla-live.php#make
  - https://clonezilla.org/liveusb.php
  - https://duckduckgo.com/?q=uefi+usb+partitioning+boot+linux+clonezilla&ia=web
  - http://www.miscdebris.net/blog/2010/04/06/use-curl-to-download-a-file-from-sourceforge-mirror/
  - https://sourceforge.net/p/clonezilla/bugs/349/#fromHistory
  - https://duckduckgo.com/?q=clonezilla+invalid+magic+number&ia=web
  - #222 EFI boot "error: invalid magic number" caused by search command - https://sourceforge.net/p/clonezilla/bugs/222/
  - search for first occurence of "Work-around" in the original post
  - https://sourceforge.net/p/clonezilla/discussion/Clonezilla_live/thread/fb77f6ae6e/
  - search for "Solution:" in the original post - solved with 'sed' which comments out the specific lines for me
  - https://duckduckgo.com/?q=clonezilla+uefi+secureboot&ia=web
  - https://sourceforge.net/p/clonezilla/discussion/Clonezilla_live/thread/6e62e6a7/
    - As mentioned here:

          http://clonezilla.org/downloads.php
          **"If your machine comes with uEFI secure boot enabled, you have to use AMD64 version of alternative (Ubuntu-based) Clonezilla live."** [emphasis mine]

          Therefore please use those Ubuntu-based Clonezilla live.
          BTW, for Windows 10, you have to make sure it is completely shut down so that it can be imaged. Here is the info about how to fully shut down Windows 10:
          http://windowsten.info/tutorials/5767-how-to-fully-shut-down-windows-10

          Steven
  - https://duckduckgo.com/?q=linux+terminal+download+accelerator&ia=web
  - https://www.tecmint.com/commandline-download-accelerators-for-linux/
  - https://archlinux.org/packages/community/x86_64/axel/
  - https://duckduckgo.com/?q=axel+no+state+file+cannot+resume&ia=web&iax=qa
      - one way to fix: delete the existing file before downloading
  - https://duckduckgo.com/?q=axel+no+state+file+cannot+resume&ia=web&iax=qa
  - https://stackoverflow.com/questions/13217700/dont-download-an-existing-file-with-axel

