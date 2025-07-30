#!/bin/sh
# minimize_awk_parser.sh
# Usage: ./minimize_awk_parser.sh input.awk output.awk

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input.awk> <output.awk>"
  exit 1
fi

input="$1"
output="$2"

awk '
  /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
  {
    line = $0
    output_line = ""
    in_string = 0
    in_regex = 0

    # Remove comments and leading/trailing whitespace
    for (i = 1; i <= length(line); i++) {
      c = substr(line, i, 1)
      p = (i > 1) ? substr(line, i-1, 1) : ""
      
      # Stop parsing rest of line at comment, unless in string/regex
      if (!in_string && !in_regex && c == "#") break
      
      # Track string/regex state
      if (c == "\"" && p != "\\") in_string = !in_string
      if (c == "/" && p != "\\" && !in_string) in_regex = !in_regex
      output_line = output_line c
    }

    print output_line
  }
' "$input" | 
tr '\n' ' ' |
sed -E 's/[[:space:]]+/ /g'  > "$output"
