#!/bin/sh
set -e
sudo losetup -o $((512*63)) /dev/loop0 mandrake.raw
sudo losetup -o $((512*6843753)) /dev/loop1 mandrake.raw
sudo mount /dev/loop0 /mnt
sudo mount /dev/loop1 /mnt/home
sudo mount -t devpts devpts /mnt/dev/pts
sudo mount -t proc proc /mnt/proc
