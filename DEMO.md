# Demo Script

This 5-minute walkthrough demonstrates the compliance dashboard's capabilities. Have the dashboard open at http://localhost:9033 with a terminal next to it. Have `output/dashboard.png` ready as a backup.

**0:00–0:40 The Problem**
"Many organizations still export cloud settings manually, paste them into spreadsheets, and map findings to frameworks like CIS and Essential Eight. By the time the audit is done, the infrastructure has already changed. This project demonstrates an automated approach: a single dashboard that shows compliance status, identifies what's failing, and maps findings to specific framework controls."

**0:40–1:00 Disclaimer**
"Everything here is synthetic: Koala Freight Pty Ltd is a fictional company, generated from a fixed seed (20261101). No real cloud accounts, credentials, or systems were accessed. This demonstrates compliance-as-code architecture without exposing real infrastructure."

**1:00–2:30 Live dashboard (working demo).**
- Headline cards: 31 controls across three frameworks, 70.0% pass rate (194 ok out of 277 checked), alarms split as 24 CIS / 33 Essential Eight / 26 custom.
- Column chart: the custom bar has the most red relative to its size. Tagging debt shows up straight away.
- Essential Eight bar chart: "Patch operating systems" is the worst strategy. That's where the remediation effort should go first.
- Failing resources table: scroll to one row, for example `nonprod` root user with access keys (CIS 1.4) or `nsg-jump/allow-rdp` open to the Internet (KF-AZ-02). "Every row says what failed and why, in plain words."

**2:30–3:15 Code and Automation**
- `./scripts/run_benchmarks.sh` runs all three benchmarks in about a second and writes JSON/CSV to `output/`.
- **Offline fallback:** `fallback/index.html` works in any browser with no installation—same data, with framework filtering on the failing-resources table.
- Show `output/teams-card.json`: "This JSON is posted to Microsoft Teams via webhook for weekly summaries—per-framework counts and top findings."

**3:15–4:00 Technical Approach**
- **Single source of truth:** One Python file (`scripts/build_mod.py`) defines every control, mapped to official framework IDs (CIS v3.0.0 item numbers, ACSC Essential Eight strategies). This generates the Powerpipe benchmarks programmatically.
- **Cross-cloud unification:** AWS and Azure resources evaluated in the same dashboard with consistent dimensions.
- **Custom controls alongside frameworks:** Organizational policies (tagging, stale users, backup testing) reported alongside CIS and Essential Eight, unifying compliance and internal standards.

**4:00–4:40 Production Path**
"To move this to production, swap the synthetic CSVs for official Steampipe cloud plugins (AWS/Azure) with read-only service principals. Start in non-production environments, add Turbot's published CIS and Essential Eight mods, and integrate with Jira for automated issue creation. The GitHub Action already implements weekly scheduling and Teams webhooks." (See `PATH-TO-PROD.md`)

**4:40–5:00 Summary**
This demonstrates compliance-as-code at work: policy automation, framework mapping, and continuous visibility. The architecture scales from synthetic demos to production cloud estates with minimal changes to the control definitions.
