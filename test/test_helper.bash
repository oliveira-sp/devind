#!/usr/bin/env bash

# Common setup for all tests
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  TMPDIR="$(mktemp -d)"
  export TMPDIR

  mkdir -p "$TMPDIR/.devind"

    # Copy scripts from src/
  cp "${BATS_TEST_DIRNAME}/../src/devind" "$TMPDIR/"
  cp "${BATS_TEST_DIRNAME}/../src/devind_yaml_parser.awk" "$TMPDIR/.devind/"

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