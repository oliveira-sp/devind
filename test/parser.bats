#!/usr/bin/env bats

load test_helper.bash

# Path to the parser script inside the test temp copy
PARSER_SCRIPT="./.devind/devind_yaml_parser.awk"

parse_yaml() {
    local mode="$1"
    local path="$2"
    local file="$3"

    "$PARSER_SCRIPT" "$mode" $path < "$file"
}

@test "parser fails when mode is not valid" {
    run parse_yaml "dada" "" "$DEVIND_YAML_MINIMAL"
    [ "$status" -eq 1 ]
    assert_output "Invalid mode: dada"
}

@test "parser fails when mode and no key param are specified" {
    run parse_yaml "node" "" "$DEVIND_YAML_MINIMAL"
    [ "$status" -eq 1 ]
    assert_output "No key specified."
}

@test "parser successfully retrieve default_devtarget value from minimal-config.yaml" {
    run parse_yaml "value" "default_devtarget" "$DEVIND_YAML_MINIMAL"
    [ "$status" -eq 0 ]
    assert_output "dev-local"
}

@test "parser retrieve all profiles available from full-config.yaml" {
    run parse_yaml "node" "profiles" "$DEVIND_YAML_FULL"
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 5 ]
    assert_line 'docker'
    assert_line 'docker-interactive'
    assert_line 'docker-remove'
    assert_line 'docker-bind-workspace'
    assert_line 'dummy'
}

@test "parser retrieve all global variables from full-config.yaml" {
    run parse_yaml "vars" "global" "$DEVIND_YAML_FULL"
    
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 3 ]
    assert_line 'DEFAULT_CMD_EXEC:= make -f $(DEVIND_MAKEFILE_ENTRY) $(GOAL)'
    assert_line 'CMD_PREFIX:= '
    assert_line 'CMD_SUFFIX:= '
}

@test "parser retrieve all dev-docker variables from full-config.yaml" {
    run parse_yaml "vars" "devtargets docker var" "$DEVIND_YAML_FULL"
    
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 3 ]
    assert_line "DOCKER_IMAGE:= hello-devind:latest"
    assert_line 'CMD_PREFIX:= $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE)'
    assert_line 'CMD_EXEC:= $(DEFAULT_CMD_EXEC)'
}

@test "parser retrieve all dev-docker inherited profiles from full-config.yaml" {
    run parse_yaml "list" "devtargets docker profiles" "$DEVIND_YAML_FULL"
    
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 4 ]
    assert_line 'docker'
    assert_line 'docker-interactive'
    assert_line 'docker-remove'
    assert_line 'docker-bind-workspace'
}

@test "parser retrieve goals that have devtarget mapping from full-config.yaml" {
    run parse_yaml "node" "goals" "$DEVIND_YAML_FULL"
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 3 ]
    assert_line 'hello'
    assert_line 'clean'
    assert_line 'build'
}

@test "parser retrieve goal devtarget from full-config.yaml" {
    run parse_yaml "value" "goals hello" "$DEVIND_YAML_FULL"
    [ "$status" -eq 0 ]
    assert_output 'dev-docker'

    run parse_yaml "value" "goals clean" "$DEVIND_YAML_FULL"
    [ "$status" -eq 0 ]
    assert_output 'dev-local'

    run parse_yaml "value" "goals build" "$DEVIND_YAML_FULL"
    [ "$status" -eq 0 ]
    assert_output 'dev-docker'
}
