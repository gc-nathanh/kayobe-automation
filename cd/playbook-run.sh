#!/bin/bash

set -eu
set -o pipefail

PARENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${PARENT}/../functions"

function main {
    log_info "Running custom playbook: $1"
    kayobe_init
    # Use eval so we can do something like: playbook-run.sh '$KAYOBE_CONFIG_PATH/ansible/test.yml'
    # NOTE: KAYOBE_CONFIG_PATH gets defined by kayobe_init
    local PLAYBOOK_PATH="$(eval echo $1)"
    if ! is_absolute_path "$PLAYBOOK_PATH"; then
        # Default to a path relative to repository root
        PLAYBOOK_PATH="$KAYOBE_CONFIG_PATH/../../$PLAYBOOK_PATH"
    fi
    if [ ! -f "$PLAYBOOK_PATH" ]; then
        die $LINENO "Playbook path does not exist: $PLAYBOOK_PATH"
    fi
    run_kayobe playbook run "$PLAYBOOK_PATH"
}

if [ "$#" -lt 1 ]; then
    die $LINENO "Error: You must provide a playbook to run" \
                "Usage: playbook-run.sh <playbook>"
fi

main "$1"
