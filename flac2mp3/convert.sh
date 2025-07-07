#!/bin/bash

set -euo pipefail

SRC_DIR="/music"
DST_DIR="/music_mp3"

echo "[INFO] Watching '$SRC_DIR' for new FLAC files..."

inotifywait -m -r -e close_write,moved_to,create "$SRC_DIR" --format '%w%f' | while read -r FILE; do
	# Ignore non-FLAC files
	[[ "$FILE" != *.flac ]] && continue

	# Compute relative path and output path
	REL_PATH=$(realpath --relative-to="$SRC_DIR" "$FILE")
	OUT_PATH="$DST_DIR/${REL_PATH%.flac}.mp3"
	OUT_DIR="$(dirname "$OUT_PATH")"

	# Create output directory if it doesn't exist
	mkdir -p "$OUT_DIR"

	# Convert only if the output file doesn't already exist
	if [[ ! -f "$OUT_PATH" ]]; then
		echo "[INFO] Converting: $REL_PATH"
		ffmpeg -loglevel error -y -i "$FILE" -ab 320k "$OUT_PATH" &&
			echo "[INFO] Done: $OUT_PATH"
	else
		echo "[SKIP] Already exists: $OUT_PATH"
	fi
done
