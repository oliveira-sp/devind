#!/usr/bin/env bats

load test_helper.bash

@test "can run devind like a script" {
    ./devind
}

@test "can run devind with make -f" {
    make -f devind
}

@test "devind help prints expected usage" {
  run ./devind help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage: ./devind [options] [target]" ]]
}