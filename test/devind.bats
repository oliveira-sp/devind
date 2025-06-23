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
  assert_line 'Usage: ./devind [options] [target]'
}

@test "dev-target is correctly selected depending on the target" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_NO_EXEC"
  export COLOR_ENABLED=0 # Disable color for easier output comparison

  run ./devind a

  assert_line '[EXEC] Running make target `a` in devtarget: dev-a'

  run ./devind b

  assert_line '[EXEC] Running make target `b` in devtarget: dev-default'

  run ./devind c
  assert_line '[EXEC] Running make target `c` in devtarget: dev-b'
}

@test "default devtarget is correctly selected when not specified" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_NO_EXEC"
  export COLOR_ENABLED=0

  run ./devind d # d is not defined in the YAML, should use default

  assert_line '[EXEC] Running make target `d` in devtarget: dev-default'
}
