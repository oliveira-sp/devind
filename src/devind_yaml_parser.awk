#!/usr/bin/awk -f
#
# devind_yaml_parser.awk — Fast POSIX AWK YAML path extractor
# Usage:
#   devind_yaml_parser.awk value key1 key2 … < devind.yaml
#   devind_yaml_parser.awk list  key1 key2 … < devind.yaml
#   devind_yaml_parser.awk vars  key1 key2 … < devind.yaml
#   devind_yaml_parser.awk node  key1 key2 … < devind.yaml

BEGIN {
    mode = ARGV[1]
    if (mode != "value" && mode != "list" && mode != "vars" && mode != "node") {
        print "Invalid mode: " mode > "/dev/stderr"
        exit 1
    }

    target_key_depth = ARGC - 2
    
    if (target_key_depth <= 0) {
        print "No key specified." > "/dev/stderr"
        exit 1
    }

    for (i = 1; i <= target_key_depth; i++) {
        keys[i] = ARGV[i + 1]
        delete ARGV[i + 1]
    }
    delete ARGV[1]

    current_key_depth = 0
    target_key_found = 0
}

# Trim helpers (POSIX-compliant)
function ltrim(s) { sub(/^[ \t]+/, "", s); return s }
function rtrim(s) { sub(/[ \t]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)) }

# Extract key and value from a YAML line; sets k and v
function parse_key_value(line,   pos) {
    pos = index(line, ":")
    if (pos <= 0) return 0
    k = substr(line, 1, pos - 1)
    v = trim(substr(line, pos + 1))
    return 1
}

/^[[:space:]]*($|#)/ { next }  # Skip blank or comment lines

{
    raw = $0
    content = trim(raw)
    indent = length(raw) - length(ltrim(content))
    line_depth = indent / 2
    current_key = keys[current_key_depth + 1]

    # Current Key not found when stepping outside its own depth
    if (line_depth < current_key_depth) exit 0

    if (!target_key_found)
    {
        if (line_depth > current_key_depth) next
        
        if (substr(content, 1, length(current_key) + 1) == current_key ":")
        {
            current_key_depth++

            # Full path matched: Found Target Key
            if (current_key_depth == target_key_depth) {
                target_key_found = 1

                if (mode == "value") # Immediate inline value match
                {
                    rest = trim(substr(content, length(current_key) + 2))
                    if (length(rest) > 0) { print rest }
                    exit 0
                }
            }
        }

        next
    }

     # Now inside matched block
    if (mode == "list" && substr(content, 1, 2) == "- ") {
        print substr(content, 3)
    }
    else if (mode == "node" && line_depth == current_key_depth)
    {
        parse_key_value(content)
        print k
    }
    else if (mode == "vars") {
        if (parse_key_value(content)) {
            if (substr(k, length(k), 1) == "+") {
                print substr(k, 1, length(k) - 1) "+= " v
            } else {
                print k ":= " v
            }
        }
    }
    next
}
