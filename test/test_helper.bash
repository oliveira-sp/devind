#!/usr/bin/env bash

assert_file_lines_equal() {
  local file=$1
  shift
  mapfile -t actual < "$file"
  local -a expected=("$@")

  for i in "${!expected[@]}"; do
    [ "${actual[$i]}" = "${expected[$i]}" ] || {
      echo "Mismatch at line $((i+1)):"
      echo "Expected: ${expected[$i]}"
      echo "Actual:   ${actual[$i]}"
      return 1
    }
  done
}

# Common setup for all tests
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  TMPDIR="$(mktemp -d)"
  export TMPDIR

  make build
  cp ${BATS_TEST_DIRNAME}/../.build/devind "$TMPDIR/"

  # Copy yaml parser from src/
  cp "${BATS_TEST_DIRNAME}/../src/devind_yaml_parser.awk" "$TMPDIR/"

  cd "$TMPDIR"

  # Define reusable fixture YAML paths
  export DEVIND_YAML_MINIMAL="${BATS_TEST_DIRNAME}/fixtures/minimal-config.yaml"
  export DEVIND_YAML_NO_EXEC="${BATS_TEST_DIRNAME}/fixtures/no-exec-config.yaml"
  export DEVIND_YAML_FULL="${BATS_TEST_DIRNAME}/fixtures/full-config.yaml"
}


teardown() {
  
  echo ""
  echo "Exit status: $status"
  echo "== Output =="
  printf "$output"

  rm -rf "$TMPDIR"
}