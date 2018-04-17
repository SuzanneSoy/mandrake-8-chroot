#!/bin/bash

set -e

mnt=/mnt
cd "$(dirname "$0")"

if [ "$(sudo ls -A "$mnt" | wc -l)" = 0 ]; then
  ./mount.sh
fi
if [ "$( (sudo ls -A "$mnt/home/georges/Documents" || true) | wc -l)" = 0 ]; then
  sudo mkdir -p "$mnt/home/georges/Documents"
  sudo mount --bind /home/georges/Documents "$mnt/home/georges/Documents"
fi
if [ "$( (sudo ls -A "$mnt/home/georges/outside_of_chroot" || true) | wc -l)" = 0 ]; then
  sudo mkdir -p "$mnt/home/georges/outside_of_chroot"
  sudo mount --rbind / "$mnt/home/georges/outside_of_chroot"
fi

signal_x_ready="$(tempfile)"

sudo chroot "$mnt" /home/georges/Documents/git/my/config-mandrake-chroot/startmandrake2.sh "$signal_x_ready" &
chroot_startmandrake_pid="$!"

# Wait for the chrooted X to be ready
while [ ! -e "$mnt/$signal_x_ready" ]; do
  echo "Waiting for X to start up …"
  sleep 0.5
done

# Start a terminal with access to the outer config & files.
echo =================================
echo =================================
echo =================================
echo =================================
echo =================================
echo =================================
set -x
set +e
(source /home/georges/.profile; sleep 8; cd /home/georges/; DISPLAY=:1 xfce4-terminal --geometry=80x25) &
echo ---------------------------------
echo ---------------------------------
echo ---------------------------------
echo ---------------------------------
echo ---------------------------------
echo ---------------------------------
echo ---------------------------------
echo ---------------------------------

wait $chroot_startmandrake_pid