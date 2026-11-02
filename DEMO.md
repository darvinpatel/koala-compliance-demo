# 5-minute demo script

Judging: impact 30%, innovation 25%, working demo 20%, path to production 15%, collaboration 10%. Have the dashboard open at http://localhost:9033 with a terminal next to it. Have `output/dashboard.png` ready in case the live demo fails.

**0:00–0:40 Problem (impact).**
"Every audit, someone exports settings by hand, pastes them into a spreadsheet and maps them to CIS and the Essential Eight. By the time it's done, it's already out of date. We wanted one view that is always current: what's failing, against which framework, and why."

**0:40–1:00 Ground rules.**
"Everything you're about to see is synthetic: a made-up company called Koala Freight, generated from a fixed seed. No real accounts, no credentials, nothing scanned. It's posture checking, not code scanning. Snyk still does that."

**1:00–2:30 Live dashboard (working demo).**
- Headline cards: 31 controls across three frameworks, 70.0% pass rate (194 ok out of 277 checked), alarms split as 24 CIS / 33 Essential Eight / 26 custom.
- Column chart: the custom bar has the most red relative to its size. Tagging debt shows up straight away.
- Essential Eight bar chart: "Patch operating systems" is the worst strategy. That's where the remediation effort should go first.
- Failing resources table: scroll to one row, for example `nonprod` root user with access keys (CIS 1.4) or `nsg-jump/allow-rdp` open to the Internet (KF-AZ-02). "Every row says what failed and why, in plain words."

**2:30–3:15 Terminal (working demo).**
- `./scripts/run_benchmarks.sh` reruns all three benchmarks in about a second and writes JSON/CSV to `output/`.
- **No install on the day? Use `fallback/index.html` in Edge** (offline): same numbers, with a framework filter on the failing-resources table. Walk through it in the same order as the live dashboard.
- Show `output/teams-card.json`. "This is the weekly Teams summary: per-framework counts and the top three alarms."

**3:15–4:00 What's different (innovation).**
- One Python file defines every control, mapped to CIS v3.0.0 numbers and the Essential Eight strategy names from ASD's model. Azure and AWS resources sit in the same view.
- Custom org rules (tags, stale users, restore tests) sit alongside the frameworks, so policy and standards are reported in one place.

**4:00–4:40 Path to production.**
"On the day, we swap the CSVs for the official Steampipe Azure or AWS plugin with read-only access, starting with non-prod, and add Turbot's published CIS and Essential Eight mods. The GitHub Action already runs weekly and posts to Teams from a secret. Jira tickets for high-impact alarms are next." (PATH-TO-PROD.md)

**4:40–5:00 Collaboration and ask.**
"We need non-prod read-only access, one Teams channel, and a Jira project key. Security, cloud and service desk each own a piece."
