#!/usr/bin/env bash

set -eau

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

$SCRIPTPATH/../../switch --remote root@madoka .#madoka
$SCRIPTPATH/../../switch --remote root@homura .#homura