#!/usr/bin/env bash

# Common setup for all tests
setup() {
  TMPDIR="$(mktemp -d)"
  cp src/* $TMPDIR
  cd "$TMPDIR"
}

teardown() {
  rm -rf "$TMPDIR"
}