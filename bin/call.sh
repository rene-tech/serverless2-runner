#!/bin/bash
# Main container of an endpoint-call job (API mode `async`): POST REQUEST_BODY to URL until it is
# accepted, with exponential backoff capped at 5 min. Retries for as long as the Job lives
# (no deadline unless the caller set timeout_s), so a saturated or scaled-to-zero endpoint is simply
# waited for. 4xx other than 408/429 are the caller's error: exit 2, which the Job's podFailurePolicy
# turns into an immediate FailJob (no pod retries).
set -uo pipefail
cd /work; mkdir -p out
n=0
while true; do
  code=$(curl -sS -o out/response.json -w '%{http_code}' -X POST "$URL" -H 'Content-Type: application/json' \
         ${AUTH_HEADER:+-H "Authorization: $AUTH_HEADER"} --data-binary "$REQUEST_BODY" --max-time "${CALL_TIMEOUT:-3600}" 2>out/last_error.txt) || code=000
  n=$((n + 1))
  echo "$(date -u +%FT%TZ) attempt $n -> HTTP $code"
  case "$code" in
    2*) printf '{"http_status":%s,"attempts":%s}\n' "$code" "$n" > out/call.json; exit 0;;
    408|429|000|5*) ;;
    4*) printf '{"http_status":%s,"attempts":%s}\n' "$code" "$n" > out/call.json; cat out/response.json; exit 2;;   # caller's error: FailJob
  esac
  e=$n; [ $e -gt 6 ] && e=6
  s=$(( 5 * (1 << e) )); [ $s -gt 300 ] && s=300
  sleep $s
done
