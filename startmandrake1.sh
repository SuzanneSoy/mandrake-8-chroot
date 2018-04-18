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

# hack to enable audio:
if true; then
  sudo killall pulseaudio || true
  # Note: a chmod +x on the directories on this path may be needed.
  chmod a+rwx ~georges/Documents/git/my/config-private-dot.config/pulse/
  chmod a+rwx ~georges/Documents/git/my/config-private-dot.config/pulse/cookie
  sudo killall pulseaudio || true
  sudo pulseaudio --daemonize=yes --system=yes

  pactl load-module module-switch-on-port-available
  
  sudo service osspd start
  sudo service osspd status
fi

if [ ! -e "$mnt/etc/mandrake-chroot-was-configured" ]; then
  sudo cp "$mnt/etc/X11/XF86Config" "$mnt/etc/X11/XF86Config.bak-$(date +%s)"
  sudo patch "$mnt/etc/X11/XF86Config" < XF86Config.patch
  sudo touch "$mnt/etc/mandrake-chroot-was-configured"
fi

echo -e "\033[1;31mNOTE: to access sound, the user inside the chroot must have the same UID as the user outside of the chroot!\033[m"

signal_x_ready="$(tempfile)"

sudo chroot "$mnt" /home/georges/Documents/git/my/config-mandrake-chroot/startmandrake2.sh "$signal_x_ready" &
chroot_startmandrake_pid="$!"

# Wait for the chrooted X to be ready
while [ ! -e "$mnt/$signal_x_ready" ]; do
  echo "Waiting for X to start up …"
  sleep 1
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
