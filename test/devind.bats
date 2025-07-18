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

@test "devind fails when default devtarget is not defined" {
  export DEVIND_YAML_FILE="$(mktemp)"
  export COLOR_ENABLED=0

  # Create an empty YAML file without a default devtarget
  echo "{}" > "$DEVIND_YAML_FILE"

  run ./devind e # e is not defined in the YAML, should use default

  [ "$status" -eq 2 ]
  assert_line '[ERROR] No devtarget defined and no default fallback found for goal `e`'

  # Clean up the temporary file
  rm -f "$DEVIND_YAML_FILE"
}

@test "devind executes the correct command for the clean target" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_FULL"
  export COLOR_ENABLED=0
  export V=1 # Enable verbose output

  run ./devind clean

  assert_output --partial '[EXEC] Running make target `clean` in devtarget: dev-local'
  assert_output --partial 'make -f Makefile clean'
}

@test "devind sets CMD_PREFIX correctly before CMD_EXEC for the 'hello' target" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_FULL"
  export COLOR_ENABLED=0
  export V=1 # Enable verbose output

  run ./devind hello

  # Assert that CMD_PREFIX is correctly set before CMD_EXEC
  assert_output --partial '[EXEC] Running make target `hello` in devtarget: dev-docker'
  assert_output --partial 'docker run --rm -it -v .:/work -w /work hello-devind:latest make -f Makefile hello'
}

@test "devind sets CMD_SUFFIX correctly after CMD_EXEC for the 'dummy' target" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_FULL"
  export COLOR_ENABLED=0
  export V=1 # Enable verbose output

  run ./devind dummy

  # Assert that CMD_SUFFIX is correctly set after CMD_EXEC
  assert_output --partial '[EXEC] Running make target `dummy` in devtarget: dev-dummy'
  assert_output --partial '[DUMMY_PREFIX] echo "dummy command" [DUMMY_SUFFIX]'
}

@test "devind generates global.mk with correct variables" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_FULL"
  export COLOR_ENABLED=0

  run ./devind clean

  # Check that the file was generated
  [ -f .devind/generated/global.mk ]

  # Check file content
  assert_file_lines_equal .devind/generated/global.mk \
    '#------------------------------------------------------------------------------' \
    '# This file is auto-generated by DevinD' \
    '#------------------------------------------------------------------------------' \
    '# DO NOT EDIT MANUALLY.' \
    '# Changes will be overwritten by ./devind.' \
    '# Retained by Makefile using .PRECIOUS to prevent deletion.' \
    '#------------------------------------------------------------------------------' \
    '' \
    '# Global Variables Definitions' \
    'DEFAULT_CMD_EXEC:= make -f $(DEVIND_MAKEFILE_ENTRY) $(GOAL)' \
    'CMD_PREFIX:= ' \
    'CMD_SUFFIX:= ' \
    ''
} 

@test "devind generates profile makefile correctly" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_FULL"
  export COLOR_ENABLED=0

  run ./devind build

  # Check that the file was generated
  [ -f .devind/generated/profile-docker.mk ]
  [ -f .devind/generated/profile-docker-interactive.mk ]
  [ -f .devind/generated/profile-docker-remove.mk ]
  [ -f .devind/generated/profile-docker-bind-workspace.mk ]

  # Check files content
  assert_file_lines_equal .devind/generated/profile-docker.mk \
    '#------------------------------------------------------------------------------' \
    '# This file is auto-generated by DevinD' \
    '#------------------------------------------------------------------------------' \
    '# DO NOT EDIT MANUALLY.' \
    '# Changes will be overwritten by ./devind.' \
    '# Retained by Makefile using .PRECIOUS to prevent deletion.' \
    '#------------------------------------------------------------------------------' \
    '' \
    '# Profile `docker` Variables Definitions' \
    'DOCKER_CMD:= docker run' \
    ''

    assert_file_lines_equal .devind/generated/profile-docker-interactive.mk \
    '#------------------------------------------------------------------------------' \
    '# This file is auto-generated by DevinD' \
    '#------------------------------------------------------------------------------' \
    '# DO NOT EDIT MANUALLY.' \
    '# Changes will be overwritten by ./devind.' \
    '# Retained by Makefile using .PRECIOUS to prevent deletion.' \
    '#------------------------------------------------------------------------------' \
    '' \
    '# Profile `docker-interactive` Variables Definitions' \
    'DOCKER_OPT+= -it' \
    ''
}

@test "devind generates dev-target makefile correctly" {
  export DEVIND_YAML_FILE="$DEVIND_YAML_FULL"
  export COLOR_ENABLED=0

  run ./devind build

  # Check that the file was generated
  [ -f .devind/generated/dev-docker.mk ]

  # Check file content
  assert_file_lines_equal .devind/generated/dev-docker.mk \
    '#------------------------------------------------------------------------------' \
    '# This file is auto-generated by DevinD' \
    '#------------------------------------------------------------------------------' \
    '# DO NOT EDIT MANUALLY.' \
    '# Changes will be overwritten by ./devind.' \
    '# Retained by Makefile using .PRECIOUS to prevent deletion.' \
    '#------------------------------------------------------------------------------' \
    '' \
    '# Devtarget `docker` Profiles Includes' \
    'include .devind/generated/profile-docker.mk .devind/generated/profile-docker-remove.mk .devind/generated/profile-docker-interactive.mk .devind/generated/profile-docker-bind-workspace.mk' \
    '' \
    '# Devtarget `docker` Variables Definitions' \
    'DOCKER_IMAGE:= hello-devind:latest' \
    'CMD_PREFIX:= $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE)' \
    'CMD_EXEC:= $(DEFAULT_CMD_EXEC)' \
    ''

  run ./devind dummy

  # Check that the file was generated
  [ -f .devind/generated/dev-dummy.mk ]

  # Check file content
  assert_file_lines_equal .devind/generated/dev-dummy.mk \
    '#------------------------------------------------------------------------------' \
    '# This file is auto-generated by DevinD' \
    '#------------------------------------------------------------------------------' \
    '# DO NOT EDIT MANUALLY.' \
    '# Changes will be overwritten by ./devind.' \
    '# Retained by Makefile using .PRECIOUS to prevent deletion.' \
    '#------------------------------------------------------------------------------' \
    '' \
    '# Devtarget `dummy` Profiles Includes' \
    'include ' \
    '' \
    '# Devtarget `dummy` Variables Definitions' \
    'CMD_PREFIX:= [DUMMY_PREFIX]' \
    'CMD_EXEC:= echo "dummy command"' \
    'CMD_SUFFIX:= [DUMMY_SUFFIX]' \
    ''
}
