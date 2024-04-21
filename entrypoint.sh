#!/bin/sh

# Check if alpine password is set
if [ -n "${ALPINE_PASSWORD}" ]; then
    # Set password for alpine user
    echo -e "${ALPINE_PASSWORD}\n${ALPINE_PASSWORD}" | passwd alpine
fi

# Check if TZ variable is set and valid
if [ -n "${TZ}" ] && [ -f "/usr/share/zoneinfo/$(echo "$TZ" | cut -d'/' -f2)" ]; then
    # Set Timezone
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
fi

# Start VNC server and prefix its output
/usr/bin/vncserver :99 2>&1 | sed  "s/^/[Xtigervnc ] /" &

# Wait for a second before starting PulseAudio
sleep 1

# Start PulseAudio and prefix its output
/usr/bin/pulseaudio 2>&1 | sed  "s/^/[pulseaudio] /" &

# Wait for a second before starting the Node.js script
sleep 1

# Start Node.js script and prefix its output
/usr/bin/node /opt/noVNC/audify.js 2>&1 | sed "s/^/[audify    ] /" &

# Check if SCREEN_RESOLUTION is in the format [digits]x[digits]
if echo "$SCREEN_RESOLUTION" | grep -E '^[0-9]+x[0-9]+$' >/dev/null; then
    # Set screen resolution if format is correct
    xrandr -s "$SCREEN_RESOLUTION" -d :99
fi

# Start noVNC proxy and prefix its output
/opt/noVNC/utils/novnc_proxy --vnc localhost:5999 2>&1 | sed "s/^/[noVNC     ] /"
