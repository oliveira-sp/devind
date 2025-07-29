#!/bin/sh

# Usage: ./inject-placeholder.sh PLACEHOLDER REPLACEMENT_FILE TARGET_FILE

PLACEHOLDER="$1"
REPLACEMENT_FILE="$2"
TARGET_FILE="$3"

if [ ! -f "$REPLACEMENT_FILE" ]; then
  echo "Replacement file not found: $REPLACEMENT_FILE" >&2
  exit 1
fi

if [ ! -f "$TARGET_FILE" ]; then
  echo "Target file not found: $TARGET_FILE" >&2
  exit 1
fi

echo "Replacing placeholder '$PLACEHOLDER' in '$TARGET_FILE' with content from '$REPLACEMENT_FILE'..."

awk -v placeholder="$PLACEHOLDER" -v repl_file="$REPLACEMENT_FILE" '
BEGIN {
  while ((getline line < repl_file) > 0) {
    replacement = replacement line
  }
  close(repl_file)
}
{
  gsub(placeholder, replacement)
  print
}
' "$TARGET_FILE" > "$TARGET_FILE.new" && mv "$TARGET_FILE.new" "$TARGET_FILE"
