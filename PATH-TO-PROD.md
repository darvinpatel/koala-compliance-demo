# Path to production

v0.1 is a working demo on synthetic CSVs. Getting to production mostly means swapping the data source. The controls, dashboard, exports and Teams card stay the same. This is a configuration and posture check that sits beside Snyk, not a replacement for it.

## 1. Swap the data source (day one)

| v0.1 (synthetic) | Production |
|---|---|
| `csv` plugin over `data/*.csv` | Official Steampipe `turbot/azure` + `turbot/azuread` plugins (Azure is the default cloud), or `turbot/aws` if the non-prod account turns out to be AWS |
| Our 15 CIS AWS controls | `aws_compliance.benchmark.cis_v300` (the mod also has cis_v400 to cis_v600) or `azure_compliance.benchmark.cis_v300` (also has cis_v400, cis_v500) |
| Our 9 Essential Eight checks | `aws_compliance.benchmark.acsc_essential_eight` (ML1–ML3) for AWS. `azure_compliance` has no Essential Eight benchmark (checked the repo on 2026-11-01), so for Azure, keep our E8 checks and point them at real Entra ID and endpoint data |
| Endpoint CSV (patch age, app control, macros) | An export from Intune / Defender / the endpoint tool, loaded with the csv plugin until there's a proper plugin or API |
| Custom KF-* controls | Keep them and rewrite the SQL against real plugin tables (for example `azure_storage_account`, `azure_network_security_group`, `azure_key_vault`) |

The benchmark names above were checked against the turbot mod repos on 2026-11-01. Run `powerpipe benchmark list` after installing to confirm.

## 2. Access: read-only, non-prod first

- Start with the **non-prod** subscription or account, after written approval from its owner.
- Azure: a service principal or workload identity with **Reader** (and Entra ID read permissions for users and MFA) at subscription scope. No Contributor, no secrets in the repo.
- AWS: a role with `SecurityAudit` / `ReadOnlyAccess`, assumed through GitHub OIDC. No long-lived keys.
- Steampipe only reads cloud APIs and changes nothing. Even so, make sure the run is approved and logged like any other read-only tooling.

## 3. Scheduling and reporting

- `.github/workflows/weekly-compliance.yml` runs every Monday at 09:00 AEDT (Sun 22:00 UTC) and can also be started by hand. It exports JSON/CSV as a build artefact (kept for 90 days) and posts an Adaptive Card to Teams from the `TEAMS_WEBHOOK_URL` repo secret.
- The webhook should be a Teams **Workflows** ("When a Teams webhook request is received") URL. Microsoft has been retiring the older Office 365 connector webhooks. The payload format (`message` with an Adaptive Card attachment) was tested here against a local stub only, not real Teams.
- If GitHub Actions isn't allowed to reach the cloud, the same script runs as a cron job on an internal runner.

## 4. Jira link (next step, not built)

- For each new alarm on a high-impact control (root MFA, public storage, admin ports open to the internet), open or update one Jira issue per control, keyed by control ID so reruns don't create duplicates. Link the issue key back in the Teams card.
- To be built with the Jira Cloud REST API and a scoped API token stored as a secret. Not done in v0.1.

## 5. What's honestly not ready

- The Essential Eight checks are proxies and don't amount to an ML1 assessment.
- The dashboard rebuilds every control query. In production, point it at stored benchmark results or use the mods' own dashboards.
- No history or trend yet. Storing each week's JSON makes a trend line the obvious next panel.
