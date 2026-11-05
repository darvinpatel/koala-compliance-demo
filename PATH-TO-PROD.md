# Path to Production

This document outlines how to migrate from the synthetic CSV demonstration to a production compliance monitoring system. The core architecture—controls, dashboard, exports, and Teams integration—remains the same; primarily the data source changes.

## 1. Swap the Data Source

| Synthetic Demo | Production Implementation |
|---|---|
| `csv` plugin over `data/*.csv` | Official Steampipe `turbot/azure` + `turbot/azuread` plugins, or `turbot/aws` for AWS environments |
| Custom 15 CIS AWS controls | `aws_compliance.benchmark.cis_v300` (Turbot's published mod supports v3.0.0 through v6.0.0) or `azure_compliance.benchmark.cis_v300` (v3.0.0 through v5.0.0) |
| Custom 9 Essential Eight checks | `aws_compliance.benchmark.acsc_essential_eight` (ML1–ML3) for AWS. For Azure, keep the custom E8 checks and point them at real Entra ID and endpoint data (Turbot's `azure_compliance` mod had no Essential Eight benchmark as of 2026-11-01) |
| Endpoint CSV (patch age, app control, macros) | Export from endpoint management tool (e.g., Intune, Defender for Endpoint), loaded via `csv` plugin until a native integration is available |
| Custom organizational controls | Rewrite SQL queries against real plugin tables (e.g., `azure_storage_account`, `azure_network_security_group`, `azure_key_vault`) |

Verify available benchmarks: Run `powerpipe benchmark list` after installing the production mods.

## 2. Cloud Access: Read-Only, Non-Production First

**Recommended approach:**
- Start with a **non-production** environment to validate controls and dashboards before connecting to production.
- Use least-privilege, read-only access with no write permissions.

**Azure:**
- Service principal or workload identity with **Reader** role at subscription scope
- Additional Entra ID read permissions for user and MFA checks
- No Contributor or write roles; never store credentials in the repository

**AWS:**
- IAM role with `SecurityAudit` or `ReadOnlyAccess` managed policy
- Use GitHub OIDC or SAML federation—avoid long-lived access keys
- Consider AWS Organizations SCPs to enforce read-only boundaries

**Security considerations:**
- Steampipe is read-only by design and does not modify cloud resources
- Document access grants and treat compliance tooling like any other read-only integration
- Rotate service principal credentials on a defined schedule

## 3. Scheduling and Reporting

**GitHub Actions (included):**
- `.github/workflows/weekly-compliance.yml` runs weekly (configurable schedule) and can be triggered manually
- Exports JSON/CSV as build artifacts (retained for 90 days by default)
- Posts Adaptive Card summaries to Microsoft Teams via webhook (`TEAMS_WEBHOOK_URL` secret)

**Teams integration:**
- Use Teams **Workflows** connector ("When a Teams webhook request is received")
- Note: Microsoft has been deprecating older Office 365 connector webhooks
- The Adaptive Card format has been validated locally; production deployments should test with actual Teams channels

**Alternative deployment:**
- For environments where GitHub Actions cannot reach cloud APIs, run the same `scripts/run_benchmarks.sh` as a cron job on an internal runner or VM
- Store results in a shared location and post to Teams from the same environment

## 4. Jira link (next step, not built)

- For each new alarm on a high-impact control (root MFA, public storage, admin ports open to the internet), open or update one Jira issue per control, keyed by control ID so reruns don't create duplicates. Link the issue key back in the Teams card.
- To be built with the Jira Cloud REST API and a scoped API token stored as a secret. Not done in v0.1.

## 5. Current Limitations and Future Enhancements

**Essential Eight coverage:**
- The current checks are technical proxies; Essential Eight maturity levels require process validation (e.g., documented access request workflows) that technical scans cannot fully verify
- Consider these checks as indicators requiring manual process review for formal ML1 assessment

**Performance optimization:**
- The dashboard rebuilds all control queries for each panel—acceptable for demonstration but should be refactored in production
- Recommended: Point dashboards at cached benchmark results or use Turbot's published mod dashboards for better performance at scale

**Historical tracking:**
- No time-series data or trend analysis in current version
- Recommended enhancement: Store each run's JSON output and build trend panels showing compliance posture over time
- Consider integrating with time-series databases (e.g., PostgreSQL with TimescaleDB, CloudWatch, or Azure Monitor) for long-term trend analysis
