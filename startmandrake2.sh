#!/bin/bash
source /etc/profile

signal_x_ready="$1"

X -bpp 32 :1 &
x_pid="$!"

export DISPLAY=:1

while ! xsetroot -solid gray; do
  sleep 0.1
done

xhost +local:

# Fix the sound permissions
chmod g+rw /dev/dsp

touch "$signal_x_ready" # tell the outer system that our X is ready.

su georges -c "startkde"

sleep 5
kill "$x_pid"