#!/usr/bin/env bash

set -eau

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

$SCRIPTPATH/../../switch --remote root@arumi --build-on-remote .#arumi