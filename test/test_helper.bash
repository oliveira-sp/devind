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
  rm -rf "$TMPDIR"
}