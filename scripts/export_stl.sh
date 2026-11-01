#!/bin/sh
# Render and validate the repository's printable STL from its OpenSCAD source.
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE="$ROOT_DIR/positive_cover.scad"
OUTPUT="$ROOT_DIR/positive_cover.stl"

if [ -n "${OPENSCAD_BIN:-}" ]; then
    OPENSCAD=$OPENSCAD_BIN
elif command -v openscad >/dev/null 2>&1; then
    OPENSCAD=$(command -v openscad)
elif [ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]; then
    OPENSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
else
    echo "Error: OpenSCAD CLI not found. Install OpenSCAD or set OPENSCAD_BIN." >&2
    exit 1
fi

if [ ! -f "$SOURCE" ]; then
    echo "Error: source SCAD not found: $SOURCE" >&2
    exit 1
fi

LOG=$(mktemp "${TMPDIR:-/tmp}/batposcover-openscad.XXXXXX")
trap 'rm -f "$LOG"' EXIT HUP INT TERM

echo "Rendering $SOURCE"
if ! "$OPENSCAD" -o "$OUTPUT" "$SOURCE" >"$LOG" 2>&1; then
    cat "$LOG" >&2
    echo "Error: OpenSCAD render failed." >&2
    exit 1
fi
cat "$LOG"

if grep -E '(^|[[:space:]])(WARNING|ERROR):' "$LOG" >/dev/null 2>&1; then
    echo "Error: OpenSCAD reported warnings or errors; inspect diagnostics above." >&2
    exit 1
fi

if [ ! -s "$OUTPUT" ]; then
    echo "Error: STL was not created or is empty: $OUTPUT" >&2
    exit 1
fi

echo "Export successful: $OUTPUT ($(wc -c < "$OUTPUT" | tr -d ' ') bytes)"