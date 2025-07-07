#!/bin/bash

set -euo pipefail

SRC_DIR="/music"
DST_DIR="/music_mp3"
SRC_DIR="${SRC_DIR%/}"
DST_DIR="${DST_DIR%/}"

# Extensions à copier directement sans conversion
COPY_EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "cue" "log" "txt" "nfo")

convert_flac() {
	local FILE="$1"
	local REL_PATH="${FILE#$SRC_DIR/}"
	local OUT_PATH="$DST_DIR/${REL_PATH%.flac}.mp3"
	local OUT_DIR
	OUT_DIR="$(dirname "$OUT_PATH")"

	mkdir -p "$OUT_DIR"

	if [[ ! -f "$OUT_PATH" ]]; then
		echo "[INFO] Converting: $REL_PATH"
		ffmpeg -loglevel error -y -i "$FILE" -ab 320k "$OUT_PATH" &&
			echo "[INFO] Done: $OUT_PATH"
	else
		echo "[SKIP] Already exists: $OUT_PATH"
	fi
}

copy_file() {
	local FILE="$1"
	local REL_PATH="${FILE#$SRC_DIR/}"
	local OUT_PATH="$DST_DIR/$REL_PATH"
	local OUT_DIR
	OUT_DIR="$(dirname "$OUT_PATH")"

	mkdir -p "$OUT_DIR"

	if [[ ! -f "$OUT_PATH" ]]; then
		cp "$FILE" "$OUT_PATH"
		echo "[COPY] $REL_PATH"
	else
		echo "[SKIP] Already exists: $REL_PATH"
	fi
}

echo "[INIT] Initial scan of $SRC_DIR..."
find "$SRC_DIR" -type f -print0 | while IFS= read -r -d '' FILE; do
	EXT="${FILE##*.}"
	EXT_LOWER="${EXT,,}"
	if [[ "$EXT_LOWER" == "flac" ]]; then
		convert_flac "$FILE"
	elif [[ " ${COPY_EXTENSIONS[*]} " =~ " $EXT_LOWER " ]]; then
		copy_file "$FILE"
	fi
done
echo "[INIT] Initial scan complete."

echo "[WATCH] Watching $SRC_DIR for new FLAC or media files..."
inotifywait -m -r -e close_write,moved_to,create --format '%w%f' "$SRC_DIR" | while read -r FILE; do
	EXT="${FILE##*.}"
	EXT_LOWER="${EXT,,}"
	if [[ "$EXT_LOWER" == "flac" ]]; then
		convert_flac "$FILE"
	elif [[ " ${COPY_EXTENSIONS[*]} " =~ " $EXT_LOWER " ]]; then
		copy_file "$FILE"
	fi
done
