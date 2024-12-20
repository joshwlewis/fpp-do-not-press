#!/bin/bash

# do-not-press-down.sh runs when the physical DO NOT PRESS button is depressed.
# This is designed to provide feedback as to whether or not the button release
# will activate a sequence. If the $TARGET_PLAYLIST is not already playing, this runs
# an ok sound + effect. If $TARGET_PLAYLIST is already playing (somebody is spamming
# the button), this runs an err sound + effect. Either way, the sound + effect
# will play in the background without interrupting anything already playing.
# For this reason, use short sounds and sequences with this script (under 1
# second).

shopt -s nullglob

PRIMARY_PLAYLIST="show"
TARGET_PLAYLIST="do-not-press"
REMOTE_PLAYLIST="remote"
TMPDIR=/var/tmp
DOWN_FILE="$TMPDIR/$TARGET_PLAYLIST-down.txt"
INT_FILE="$TMPDIR/$PRIMARY_PLAYLIST-interrupt.txt"
CURRENT_PLAYLIST=$(fpp -s | cut -d ',' -f 4)
NEXT_INT_AT=$(<"$INT_FILE")
DOWN_AT=$(date +%s.%N)
echo -n "$DOWN_AT" > "$DOWN_FILE" &

if [[ $CURRENT_PLAYLIST == "$TARGET_PLAYLIST"  ||
      $CURRENT_PLAYLIST == "$REMOTE_PLAYLIST" ||
    ( $CURRENT_PLAYLIST == "$PRIMARY_PLAYLIST" && $(echo "$DOWN_AT < $NEXT_INT_AT" | bc -l ) -eq 1 ) ]]; then
  echo "Selecting err media."
  EFFECTS=("$MEDIADIR/sequences/$TARGET_PLAYLIST-err"*)
  SOUNDS=("$MEDIADIR/music/$TARGET_PLAYLIST-err"*)
else
  echo "Selecting ok media."
  EFFECTS=("$MEDIADIR/sequences/$TARGET_PLAYLIST-ok"*)
  SOUNDS=("$MEDIADIR/music/$TARGET_PLAYLIST-ok"*)
fi

COUNT=$((${#EFFECTS[@]} < ${#SOUNDS[@]} ? ${#EFFECTS[@]} : ${#SOUNDS[@]}))
RAND_IDX=$(($RANDOM % $COUNT))

SOUND=${SOUNDS[$RAND_IDX]}
if [ -n "${SOUND}" ]; then
  echo "Playing $SOUND"
  fpp -C "Play Media" "$SOUND" 1 0
fi

EFFECT=${EFFECTS[$RAND_IDX]}
EFFECT_NAME=$(basename "$EFFECT" | cut -d "." -f1)
if [ -n "${EFFECT_NAME}" ]; then
  echo "Playing $EFFECT_NAME"
  fpp -C "FSEQ Effect Start" "$EFFECT_NAME" 0 1
fi
