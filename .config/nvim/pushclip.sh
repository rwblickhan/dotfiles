#!/bin/bash
# Find a filename to use as a temp file
TEMPFILE="`tempfile 2>/dev/null`"
if [ $? -ne 0 ]; then
	TEMPFILE="/tmp/_clip_temp_yssh$USER"
fi
# Save stdin to file
cat > "$TEMPFILE"
# Load tmux buffer
tmux load-buffer -w "$TEMPFILE"
# Remove file
rm -f "$TEMPFILE"
