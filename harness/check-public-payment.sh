#!/usr/bin/env bash
set -euo pipefail

: "${BASE_URL:?Set BASE_URL, for example https://quybpdev.apps.drgdevlab.com}"
: "${MEMBER_CODE:?Set MEMBER_CODE, for example THOTV17094}"
YEAR="${YEAR:-$(date -u +%Y)}"

base="${BASE_URL%/}"
health_file="$(mktemp)"
history_file="$(mktemp)"
trap 'rm -f "$health_file" "$history_file"' EXIT

health_status="$(curl --silent --show-error --output "$health_file" --write-out '%{http_code}' \
  --retry 2 "$base/healthz")"
[ "$health_status" = 204 ] \
  || { printf 'FAIL frontend healthz returned HTTP %s\n' "$health_status"; exit 1; }

curl --fail --silent --show-error --retry 2 \
  "$base/api/v1/public/payment-history?memberCode=${MEMBER_CODE}&year=${YEAR}" > "$history_file"

jq -e '
  (.periods // [])
  | all(.[];
      (.amountDue >= 0 and .amountPaid >= 0 and .outstandingAmount >= 0)
      and ((.amountPaid <= .amountDue and
            (.amountPaid + .outstandingAmount) == .amountDue)
           or (.amountPaid > .amountDue and .outstandingAmount == 0)))
' "$history_file" >/dev/null \
  || { printf 'FAIL payment conservation invariant for %s/%s\n' "$MEMBER_CODE" "$YEAR"; exit 1; }

printf 'PASS frontend healthz: HTTP 204\n'
printf 'PASS backend public payment-history: HTTP 200\n'
jq -r '"PASS member: " + .memberCode + " year: " + ((.year // "") | tostring) + " totalDue: " + (.totalDue | tostring) + " totalPaid: " + (.totalPaid | tostring) + " outstanding: " + (.outstandingAmount | tostring)' "$history_file"
jq -r '.periods[] | select(.status == "PARTIAL") | "PARTIAL " + .month + " paid=" + (.amountPaid | tostring) + " due=" + (.amountDue | tostring) + " outstanding=" + (.outstandingAmount | tostring)' "$history_file"
