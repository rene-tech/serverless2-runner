#!/bin/bash
# Init container: sync the inputs prefix into /work/in once. On a resumed attempt (same PVC) the
# marker exists and the inputs and checkpoints on the volume are kept untouched.
set -euo pipefail
cd /work
mkdir -p out
if [ -f .inputs-fetched ]; then echo "FETCH SKIP $(date -u +%FT%TZ): resumed attempt, inputs already on the volume"; exit 0; fi
if [ -n "${INPUT_PREFIX:-}" ]; then
  echo "FETCH START $(date -u +%FT%TZ) $INPUT_PREFIX"
  aws s3 sync "${INPUT_PREFIX%/}/" /work/in/ --no-progress
  du -sh /work/in | sed 's/^/FETCHED /'
fi
date -u +%FT%TZ > .inputs-fetched
echo "FETCH END $(date -u +%FT%TZ)"
