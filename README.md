# Koala Freight cloud compliance dashboard (v0.1, hackathon build)

A small Powerpipe mod that runs three compliance benchmarks over a cloud and endpoint estate and shows the results on one dashboard:

- **CIS AWS Foundations Benchmark v3.0.0** – a 15-recommendation subset
- **ACSC Essential Eight, Maturity Level One** (Essential Eight Maturity Model, last reviewed 27 Nov 2023) – at least one check for each of the eight mitigation strategies
- **Koala Freight custom controls** – four org-policy checks plus three Azure starter checks

Results export to JSON and CSV, and a script turns the JSON into a Microsoft Teams Adaptive Card for a weekly summary (see `.github/workflows/weekly-compliance.yml`).

This is a configuration and posture check. It is not code or dependency vulnerability scanning; Snyk covers that and this doesn't replace it.

## Synthetic data disclaimer

**Every record here is synthetic.** Koala Freight Pty Ltd is a fictional company. The CSVs in `data/` come from `scripts/generate_data.py`, which uses a fixed seed (`20261101`) and a fixed snapshot date (2026-11-01), so every run gives the same files. Table names such as `aws_iam_users` or `azure_key_vaults` are chosen to read like the real thing, but they are **plain CSV files read by the Steampipe `csv` plugin**, not the official Steampipe AWS or Azure plugins. No cloud account, credential, or employer system was touched, and nothing was scanned. Account IDs are placeholders (`111111111111`, `222222222222`) and IPs use the documentation range `203.0.113.0/24`.

## Versions used (verified 2026-11-01)

| Tool | Version |
|---|---|
| Steampipe | v2.4.8 |
| Powerpipe | v1.5.6 |
| Steampipe plugin turbot/csv | 1.2.0 |
| Python | 3.13.5 |
| Playwright (screenshot only, in a local `.venv`, not shipped) | 1.64.1, driving Google Chrome 156 |

## Run it

Prerequisites: Steampipe and Powerpipe installed (`sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"`, and the same with `powerpipe.io/install/powerpipe.sh`), plus `steampipe plugin install csv`.

```bash
cd powerpipe-compliance                     # or koala-compliance-demo, if you unzipped the bundle
./scripts/run_benchmarks.sh                 # start steampipe, run 3 benchmarks on bundled data -> output/ (REGEN=1 to regenerate data/mod first)
python3 scripts/teams_card.py output/cis_aws_v300_subset.json output/essential_eight_ml1.json output/koala_freight_custom.json > output/teams-card.json
cd mod && powerpipe server --port 9033      # open http://localhost:9033 -> "Koala Freight - Compliance Overview"
```

Note: `run_benchmarks.sh` overwrites `~/.steampipe/config/csv.spc` so the csv connection points at `data/`.

**Demoing on a work laptop?** See `SETUP-WORK-LAPTOP.md`. The no-install path is to open `fallback/index.html` in Edge: it works offline.

## Layout

```
data/                     synthetic CSVs (generated)
scripts/generate_data.py  deterministic data generator
scripts/build_mod.py      single source of truth for controls -> writes mod/cis.pp, essential_eight.pp, custom.pp, all_results.sql
scripts/run_benchmarks.sh end-to-end run with exports
scripts/teams_card.py     benchmark JSON -> Teams Adaptive Card (optionally POST to $TEAMS_WEBHOOK_URL)
scripts/screenshot.py     headless screenshot of the dashboard
scripts/build_fallback.py builds fallback/index.html + output/failing-resources.csv from the exports
fallback/index.html       offline, self-contained results page (no install needed)
mod/                      Powerpipe mod (mod.pp, dashboard.pp + generated files)
output/                   benchmark exports (json/csv), reports/ (html/md), snapshots/ (.pps), teams-card.json, dashboard.png
```

Each control returns `resource`, `status` (ok / alarm / skip; info is supported but unused at the moment), `reason`, plus `scope` (account, subscription or device type) and `region` as dimensions. Each control carries tags for its framework and framework ID (`cis_item_id`, `e8_strategy` + `e8_maturity_level`, or `kf_control_id`). To change a control, edit `scripts/build_mod.py` and re-run it. Don't hand-edit the generated `.pp` files.

## Results on the synthetic estate (2026-11-01 run)

| Benchmark | Controls | OK | Alarm | Skip | Info | Error |
|---|---|---|---|---|---|---|
| CIS AWS v3.0.0 subset | 15 | 53 | 24 | 11 | 0 | 0 |
| Essential Eight ML1 | 9 | 100 | 33 | 12 | 0 | 0 |
| Koala Freight custom | 7 | 41 | 26 | 0 | 0 | 0 |
| **Total** | **31** | **194** | **83** | **23** | **0** | **0** |

The dashboard's pass rate is ok / (ok + alarm) = 194 / 277 = 70.0%. 29 of the 31 controls have at least one alarm; only CIS 3.1 and 3.2 are fully clean.

## Control mapping

### CIS AWS Foundations Benchmark v3.0.0

Numbering and titles were checked against the v3.0.0 recommendation list (Tenable's CIS v3.0.0 L1/L2 audit pages) and AWS Security Hub's CIS mapping table.

| Control | CIS v3.0.0 | What it checks |
|---|---|---|
| cis_v300_1_4 | 1.4 | Root user has no access keys |
| cis_v300_1_5 | 1.5 | Root user has MFA |
| cis_v300_1_8 | 1.8 | Password policy minimum length is 14 or more |
| cis_v300_1_10 | 1.10 | Every IAM user with a console password has MFA (users without a console password are skipped) |
| cis_v300_1_12 | 1.12 | No password or access key unused for 45 days or more |
| cis_v300_1_14 | 1.14 | Active access keys are 90 days old or younger (users without keys are skipped) |
| cis_v300_2_1_4 | 2.1.4 | S3 bucket has Block Public Access turned on |
| cis_v300_2_2_1 | 2.2.1 | EBS volume is encrypted. *Proxy:* CIS audits the region-level "encrypt by default" setting; this checks each volume |
| cis_v300_2_3_1 | 2.3.1 | RDS instance storage is encrypted |
| cis_v300_2_3_3 | 2.3.3 | RDS instance is not publicly accessible |
| cis_v300_3_1 | 3.1 | CloudTrail trail is multi-region and logging |
| cis_v300_3_2 | 3.2 | CloudTrail log file validation is on |
| cis_v300_3_5 | 3.5 | CloudTrail logs are encrypted with a KMS key |
| cis_v300_5_2 | 5.2 | No security group rule allows 0.0.0.0/0 to port 22 or 3389 |
| cis_v300_5_3 | 5.3 | No security group rule allows ::/0 to port 22 or 3389 |

S3 default encryption is not a CIS v3.0.0 recommendation (2.1.1 in v3.0.0 is "deny HTTP requests"), so it lives in custom control KF-04.

### ACSC Essential Eight – Maturity Level One

The strategy names and requirement wording come from ASD/ACSC's *Essential Eight Maturity Model*, Appendix A (cyber.gov.au, last reviewed 27 Nov 2023). ISM control IDs are **not** included because I didn't verify them.

| Control | Mitigation strategy | ML1 requirement it approximates |
|---|---|---|
| e8_ml1_patch_applications | Patch applications | Office suites, browsers, email clients, PDF software and security products patched within two weeks of release (checks oldest missing app patch ≤ 14 days) |
| e8_ml1_patch_operating_systems | Patch operating systems | Internet-facing servers patched within two weeks (non-critical); workstations and other servers within one month (≤ 14 / ≤ 31 days) |
| e8_ml1_os_supported | Patch operating systems | Operating systems no longer supported by vendors are replaced |
| e8_ml1_multi_factor_authentication | Multi-factor authentication | MFA for users of the organisation's online services (AWS console users and Entra ID users) |
| e8_ml1_restrict_administrative_privileges | Restrict administrative privileges | Privileged accounts are prevented from accessing the internet, email and web services |
| e8_ml1_application_control | Application control | Application control is implemented on workstations (servers skipped) |
| e8_ml1_restrict_microsoft_office_macros | Restrict Microsoft Office macros | Macros in files originating from the internet are blocked (servers skipped) |
| e8_ml1_user_application_hardening | User application hardening | Web browsers don't process Java or web advertisements from the internet (servers skipped) |
| e8_ml1_regular_backups | Regular backups | Backups are performed and a restore has been tested. ML1 sets no interval, so the 12-month threshold is an org assumption |

These checks cover one or two requirements per strategy, not every ML1 requirement, so a clean result here doesn't mean ML1 has been achieved.

### Koala Freight custom

| Control | ID | What it checks | Rough external equivalent |
|---|---|---|---|
| kf_required_tags | KF-01 | S3, EBS, RDS and Azure storage carry `owner` and `data-classification` tags | Internal tagging policy |
| kf_iam_users_unused_90_days | KF-02 | No IAM user's most recent activity is more than 90 days ago | Stricter-to-delete companion to CIS 1.12 |
| kf_backups_tested_90_days | KF-03 | Servers and RDS instances had a restore test within 90 days (and RDS retention > 0) | Tighter than the E8 backup check |
| kf_s3_encrypted_versioned | KF-04 | S3 buckets have default encryption and versioning | Internal |
| kf_az_storage_secure | KF-AZ-01 | Azure storage requires secure transfer (HTTPS) and has blob public access off | CIS Microsoft Azure Foundations storage section* |
| kf_az_nsg_admin_ports | KF-AZ-02 | No NSG rule allows Internet/any/0.0.0.0/0 to port 22 or 3389 | CIS Azure networking section; Azure twin of CIS AWS 5.2* |
| kf_az_key_vault_recoverable | KF-AZ-03 | Key Vault has soft delete and purge protection on | CIS Azure Key Vault section* |

\*I haven't verified CIS Azure recommendation numbers, so none are cited. The Entra ID MFA check sits inside `e8_ml1_multi_factor_authentication`. On the day, the turbot `azure_compliance` mod has the numbered CIS Azure controls (see PATH-TO-PROD.md).

## Known limitations

- Synthetic data only. Each table is a flat snapshot, and ages are whole days counted from 2026-11-01.
- Essential Eight checks are proxies. Most ML1 requirements are about process (for example, validating privileged access when it's first requested) and can't be read from a CSV.
- The dashboard rebuilds all 31 control queries for each panel. That's fine at this size but not for a real estate. In production, read the benchmark results instead.
