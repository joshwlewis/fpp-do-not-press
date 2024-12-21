#!/bin/bash

# up.sh runs when the physical DO NOT PRESS button is released.
# This script is designed to trigger only one $TARGET_PLAYLIST item per push.
# Each successive run of this script should play the next $TARGET_PLAYLIST item
# or cycle back to the beginning.
# If $TARGET_PLAYLIST is already playing (probably from a previous button push),
# it won't enqueue another $TARGET_PLAYLIST item.
# If $TARGET_PLAYLIST is running and a long press is detected, that item will be
# stopped and  normally scheduled programming will resume.
# This script will only interrupt the $PRIMARY_PLAYLIST every $MIN_INT_FREQUENCY.
# This script will not interrupt the $EXCLUSIVE_PLAYLIST.

set -eux
shopt -s nullglob

PLUGIN_DIR=$(builtin cd "$(dirname $0)/.."; pwd)
PLUGIN_NAME=$(basename $PLUGIN_DIR)
TMPDIR="/var/tmp"
PLUGIN_CFGFILE="$FPPHOME/media/config/plugin.${PLUGIN_NAME}"
PRIMARY_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=PrimaryPlaylist")
TARGET_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=TargetPlaylist")
EXCLUSIVE_PLAYLIST=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=ExclusivePlaylist")
INT_COOLDOWN=$(readSetting.awk "$PLUGIN_CFGFILE" "setting=InterruptCooldown")
DOWN_FILE="$TMPDIR/$TARGET_PLAYLIST-down.txt"
INT_FILE="$TMPDIR/$TARGET_PLAYLIST-interrupt.txt"
LONG_PRESS_LENGTH=1500
UP_AT=$(date +%s.%N)
CURRENT_PLAYLIST=$(fpp -s | cut -d ',' -f 4)
NEXT_INT_AT=$(<"$INT_FILE")
if [[  "$CURRENT_PLAYLIST" == "$TARGET_PLAYLIST" ]]; then
  echo "Already playing $TARGET_PLAYLIST."
  DOWN_AT=$(<"$DOWN_FILE")
  PRESS_LENGTH=$(echo "(${UP_AT} * 1000) - (${DOWN_AT} * 1000)" | bc | cut -f1 -d\.)
  if (( $PRESS_LENGTH > $LONG_PRESS_LENGTH )); then
    echo "Stopping $TARGET_PLAYLIST playlist now"
    fpp -C "Stop Now"
  fi
  exit 0;
elif [[ "$CURRENT_PLAYLIST" == "$EXCLUSIVE_PLAYLIST" ]]; then
  echo "Not interrupting $REMOTE_PLAYLIST playlist"
  exit 0;
elif [[ "$CURRENT_PLAYLIST" == "$PRIMARY_PLAYLIST" ]]; then
  if [[ $(echo "$UP_AT < $NEXT_INT_AT" | bc -l) -eq 1 ]]; then
    echo "Not interrupting $PRIMARY_PLAYLIST playlist. It's happened recently."
    exit 0;
  fi
fi

COUNTER_FILE="$TMPDIR/$TARGET_PLAYLIST-count.txt"
if [ -f $COUNTER_FILE ]; then
  PLAY_COUNT=$(<$COUNTER_FILE)
else
  PLAY_COUNT="0"
fi
PLAY_COUNT=$(($PLAY_COUNT + 1))
echo -n "$PLAY_COUNT" > $COUNTER_FILE &

ITEM_COUNT=$(grep "total_items" "$MEDIADIR/playlists/$TARGET_PLAYLIST.json" | cut -d ':' -f 2 | xargs)
IDX=$((($PLAY_COUNT % $ITEM_COUNT) + 1))
echo "Playing $TARGET_PLAYLIST item $IDX"
fpp -C "Insert Playlist Immediate" $TARGET_PLAYLIST $IDX $IDX 0

# Store the timestamp at which the next interrupt can happen
printf %s "$(date --date="+$((INT_COOLDOWN/1000)) seconds" +%s.%N)" > $INT_FILE &
