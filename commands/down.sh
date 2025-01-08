#!/bin/bash

# down.sh runs when the physical DO NOT PRESS button is depressed.
# This is designed to provide feedback as to whether or not the button release
# will activate an item on the $TARGET_PLAYLIST. If $TARGET_PLAYLIST is already
# playing (somebody is spamming the button), $EXCLUSIVE_PLAYLIST is playing,
# or $PRIMARY_PLAYLIST is playing and has been interrupted within the last
# $COOLDOWN, this runs a sound+effect from
# $ERROR_PLAYLIST. Otherwise, this runs a sound+effect from the
# $SUCCESS_PLAYLIST. In either case, the sound+effect will play in the
# background without interrupting anything already playing.
# For this reason, use short sounds and sequences (under 1 second) for items
# in $SUCCESS_PLAYLIST and $ERROR_PLAYLIST.

set -eux
shopt -s nullglob

PLUGIN_DIR=$(
    builtin cd "$(dirname $0)/.."
    pwd
)
PLUGIN_NAME=$(basename $PLUGIN_DIR)
TMPDIR="/var/tmp"
PLUGIN_CFGFILE="$FPPHOME/media/config/plugin.${PLUGIN_NAME}"
PRIMARY_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=PrimaryPlaylist")
TARGET_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=TargetPlaylist")
EXCLUSIVE_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=ExclusivePlaylist")
DOWN_FILE="$TMPDIR/$TARGET_PLAYLIST-down.txt"
INT_FILE="$TMPDIR/$TARGET_PLAYLIST-interrupt.txt"
CURRENT_PLAYLIST=$(fpp -s | cut -d ',' -f 4)
DOWN_AT=$(date +%s.%N)
echo -n "$DOWN_AT" >"$DOWN_FILE" &
[ -r $INT_FILE ] && NEXT_INT_AT=$(<$INT_FILE) || NEXT_INT_AT="$DOWN_AT"

if [[ $CURRENT_PLAYLIST == "$TARGET_PLAYLIST" ||
    $CURRENT_PLAYLIST == "$EXCLUSIVE_PLAYLIST" ||
    ($CURRENT_PLAYLIST == "$PRIMARY_PLAYLIST" && $(echo "$DOWN_AT < $NEXT_INT_AT" | bc -l) -eq 1) ]]; then
    echo "Selecting error media."
    TRIGGER_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=ErrorPlaylist")
else
    echo "Selecting ok media."
    TRIGGER_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=SuccessPlaylist")
fi

TRIGGER_ITEM=$(cat "$FPPHOME/media/playlists/$TARGET_PLAYLIST.json" | python -c 'import json,sys,random;d=json.load(sys.stdin);i=random.choice(d["mainPlaylist"]);print(i["sequenceName"],i["mediaName"],sep="---");')

TRIGGER_SEQUENCE="$(cut -d '---' -f 1 <<<"$TRIGGER_ITEM")"
TRIGGER_MEDIA="$(cut -d '---' -f 2 <<<"$TRIGGER_ITEM")"

if [ -n "${TRIGGER_MEDIA}" ]; then
    echo "Playing $TRIGGER_MEDIA"
    fpp -C "Play Media" "$TRIGGER_MEDIA" 1 0
fi

if [ -n "${EFFECT_NAME}" ]; then
    echo "Playing $EFFECT_NAME"
    fpp -C "FSEQ Effect Start" "$EFFECT_NAME" 0 1
fi
