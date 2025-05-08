#!/bin/bash
# Image build bootstrap script.

set -euxo pipefail

# Install DNF5 and Fish
rpm-ostree install fish

fish /ctx/build.fish
