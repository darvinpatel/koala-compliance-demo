#!/usr/bin/env bash
# Print overall totals across all 31 controls (expected: 31,194,83,23 on the bundled data).
cd "$(dirname "$0")/.."
export STEAMPIPE_UPDATE_CHECK="${STEAMPIPE_UPDATE_CHECK:-false}" STEAMPIPE_TELEMETRY="${STEAMPIPE_TELEMETRY:-none}"
steampipe query --output csv "select count(distinct control) as controls,
  count(*) filter (where status = 'ok') as ok, count(*) filter (where status = 'alarm') as alarm,
  count(*) filter (where status = 'skip') as skip from ($(cat mod/all_results.sql)) r"
