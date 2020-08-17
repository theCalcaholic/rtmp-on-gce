#!/usr/bin/env bash

echo "Starting script..." | tee -a /tmp/script.log
echo $@ | tee -a /tmp/script.log
DIRNAME="${1?}"
BASENAME="${2?}"

{
  set -eu
  echo "Executing... ffmpeg -f concat -safe 0 -i <(for f in \$(ls -1 /mnt/record/\*.flv); do echo \"file '\$f'\"; done) -c copy $DIRNAME/$BASENAME.mp4"
  ffmpeg -f concat -safe 0 -i <(for f in $(ls -1 $DIRNAME/*.flv); do echo "file '$f'"; done) -c copy $DIRNAME/$BASENAME.mp4
} 2>&1 | tee -a /tmp/script.log
