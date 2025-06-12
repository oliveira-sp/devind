#!/usr/bin/env bash

# Common setup for all tests
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  TMPDIR="$(mktemp -d)"
  cp src/* $TMPDIR
  cd "$TMPDIR"
}

teardown() {
  
  echo ""
  echo "Exit status: $status"
  echo "== Output =="
  printf "$output"

  rm -rf "$TMPDIR"
}