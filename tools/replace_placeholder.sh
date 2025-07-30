#!/bin/sh

print_help() {
  cat << EOF
Usage: $0 PLACEHOLDER [replacement_string | -f replacement_file] TARGET_FILE

Replace PLACEHOLDER in TARGET_FILE with a string or file contents.

Options:
  -f FILE    Use FILE contents as replacement
  -h, --help Show this help

Examples:
  $0 '__VERSION__' '1.2.3' target.txt
  $0 '__YAML__' -f parser.awk target.txt
EOF
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  print_help
  exit 0
fi

if [ "$#" -lt 3 ]; then
  echo "Error: Not enough arguments." >&2
  show_usage
  exit 1
fi

PLACEHOLDER="$1"
shift

REPLACEMENT_STRING=""
REPLACEMENT_FILE=""

if [ "$1" = "-f" ]; then
  shift
  REPLACEMENT_FILE="$1"
  shift
  if [ ! -f "$REPLACEMENT_FILE" ]; then
    echo "Error: Replacement file not found: $REPLACEMENT_FILE" >&2
    exit 1
  fi
else
  REPLACEMENT_STRING="$1"
  shift
fi

TARGET_FILE="$1"

if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: Target file not found: $TARGET_FILE" >&2
  exit 1
fi

awk -v placeholder="$PLACEHOLDER" \
    -v repl_file="$REPLACEMENT_FILE" \
    -v replacement_string="$REPLACEMENT_STRING" '
BEGIN {
  if (repl_file != "") {
    replacement = ""
    while ((getline line < repl_file) > 0) {
      replacement = replacement line
    }
    close(repl_file)
  } else {
    replacement = replacement_string
  }
}
{
  gsub(placeholder, replacement)
  print
}
' "$TARGET_FILE" > "$TARGET_FILE.new" && mv "$TARGET_FILE.new" "$TARGET_FILE"
