#!/bin/sh
set -eu

# Install mise (skip if already present, e.g. provisioned by cloud-init)
[ -x "$HOME/.local/bin/mise" ] || curl https://mise.run | sh
