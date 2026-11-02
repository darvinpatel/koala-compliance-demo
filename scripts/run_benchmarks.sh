#!/usr/bin/env bash
# Run all three benchmarks against the bundled synthetic CSVs and export results to ./output.
# Needs only steampipe, powerpipe and the csv plugin. Python is optional:
#   REGEN=1 ./scripts/run_benchmarks.sh   # also regenerate data/ and mod/ from the Python sources
set -uo pipefail
cd "$(dirname "$0")/.."
# No update checks or telemetry, so runs after install need no internet.
export STEAMPIPE_UPDATE_CHECK="${STEAMPIPE_UPDATE_CHECK:-false}" STEAMPIPE_TELEMETRY="${STEAMPIPE_TELEMETRY:-none}"
export POWERPIPE_UPDATE_CHECK="${POWERPIPE_UPDATE_CHECK:-false}" POWERPIPE_TELEMETRY="${POWERPIPE_TELEMETRY:-none}"
REPO="$PWD"
if [ "${REGEN:-0}" = "1" ]; then
  python3 scripts/generate_data.py
  python3 scripts/build_mod.py
fi
SP_DIR="${STEAMPIPE_INSTALL_DIR:-$HOME/.steampipe}"
mkdir -p "$SP_DIR/config" output/snapshots output/reports
# Point the csv plugin at this folder's data/ (overwrites $SP_DIR/config/csv.spc).
sed "s#__REPO__#$REPO#" config/csv.spc > "$SP_DIR/config/csv.spc"
echo "csv plugin reads: $REPO/data/*.csv (config: $SP_DIR/config/csv.spc)"
# 'service status' exits 0 even when stopped, so check its text. Listen on localhost only.
steampipe service status 2>/dev/null | grep -q 'is running' || steampipe service start --database-listen local
# The csv plugin reloads its schema when files change; wait until every CSV is visible as a table.
want=$(ls data/*.csv | wc -l)
for _ in $(seq 1 30); do
  have=$(steampipe query --output csv --header=false \
    "select count(*) from information_schema.tables where table_schema = 'csv'" 2>/dev/null | tr -dc '0-9')
  [ "${have:-0}" -ge "$want" ] && break
  sleep 1
done
echo "csv tables visible: ${have:-0}/$want"
if [ "${have:-0}" -lt "$want" ]; then
  echo "ERROR: the csv connection is not ready. Connection state:" >&2
  steampipe query "select name, plugin, state, error from steampipe_internal.steampipe_connection" >&2
  echo "Hint: config/csv.spc uses plugin \"csv\" (= csv@latest), so install it with: steampipe plugin install csv" >&2
  exit 1
fi
cd mod
for b in cis_aws_v300_subset essential_eight_ml1 koala_freight_custom; do
  # powerpipe exits non-zero when alarms exist; that is expected here
  powerpipe benchmark run "$b" --output brief \
    --export "../output/$b.json" --export "../output/$b.csv" \
    --export "../output/reports/$b.html" --export "../output/reports/$b.md" \
    --export "../output/snapshots/$b.pps" || true
done
powerpipe dashboard run compliance_overview --output none --export ../output/snapshots/compliance_overview.pps
cd ..
if command -v python3 >/dev/null; then python3 scripts/build_fallback.py; fi
