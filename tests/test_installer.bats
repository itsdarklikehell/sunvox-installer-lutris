#!/usr/bin/env bats
#
# tests/test_installer.bats — Bats tests for sunvox-installer.sh
#
# Run with: bats tests/
#

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    INSTALLER="$SCRIPT_DIR/sunvox-installer.sh"
    chmod +x "$INSTALLER"
}

@test "script exists and is executable" {
    [ -f "$INSTALLER" ]
    [ -x "$INSTALLER" ]
}

@test "help flag shows usage" {
    run "$INSTALLER" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Options:"* ]]
    [[ "$output" == *"Examples:"* ]]
}

@test "version flag shows version" {
    run "$INSTALLER" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"version"* ]]
}

@test "no arguments shows error" {
    run "$INSTALLER"
    [ "$status" -ne 0 ]
    [[ "$output" == *"No version specified"* ]]
}

@test "invalid version format fails" {
    run "$INSTALLER" "not-a-version"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid version format"* ]]
}

@test "dry-run does not install" {
    run "$INSTALLER" --dry-run 2.1.1c
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY RUN"* ]]
    [[ "$output" == *"Would download"* ]]
    [[ "$output" == *"Would install"* ]]
}

@test "unknown option fails" {
    run "$INSTALLER" --unknown-option
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "script has proper shebang" {
    run head -1 "$INSTALLER"
    [ "$output" == "#!/usr/bin/env bash" ]
}

@test "script uses set -euo pipefail" {
    run grep -q "set -euo pipefail" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script has logging function" {
    run grep -q "^log()" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script has error handling" {
    run grep -q "^die()" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script detects architecture" {
    run grep -q "^detect_arch()" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script validates version" {
    run grep -q "^validate_version()" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script has uninstall function" {
    run grep -q "^uninstall()" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script has install function" {
    run grep -q "^install()" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script creates desktop files" {
    run grep -q "sunvox.desktop" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script creates symlinks" {
    run grep -q "ln -sf" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script uses sudo for system dirs" {
    run grep -q "sudo" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script has retry logic for downloads" {
    run grep -q "max_retries" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script cleans up temp files" {
    run grep -q "trap.*EXIT" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script has colored output" {
    run grep -q "RED=" "$INSTALLER"
    [ "$status" -eq 0 ]
}

@test "script logs to file" {
    run grep -q "LOG_FILE" "$INSTALLER"
    [ "$status" -eq 0 ]
}
