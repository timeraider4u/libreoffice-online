#!/bin/bash
#

GNPM_DIR=~/workspace/g-npm
REPO_DIR=~/workspace/npm-repo

${GNPM_DIR}/dist/build/g-npm/g-npm --overlay="${REPO_DIR}" \
	--pkg-name="jake" --pkg-version="8.0.12"
