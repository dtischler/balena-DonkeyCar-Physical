#!/usr/bin/bash
export DISPLAY=:0
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
X &
xfce4-session &
cd /usr/src/app/mysim && python3 manage.py drive
