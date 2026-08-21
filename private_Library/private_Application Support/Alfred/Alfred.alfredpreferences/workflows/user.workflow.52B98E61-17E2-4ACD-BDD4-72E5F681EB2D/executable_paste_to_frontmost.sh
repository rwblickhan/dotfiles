#!/bin/bash
set -euo pipefail

osascript -e 'delay 0.1
tell application "System Events" to keystroke "v" using command down'
