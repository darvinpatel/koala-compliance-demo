# Running the Demo on Windows

**Reminder:** Everything in this repository is **synthetic** (Koala Freight Pty Ltd, fictional data). No cloud credentials, no real accounts, nothing scanned.

There are two ways to run the demo:

| | Option A: No Install (Primary) | Option B: Live Run in WSL2 |
|---|---|---|
| Requirements | Any modern browser | WSL2 + Ubuntu, then Steampipe, Powerpipe and the csv plugin |
| Administrator access? | No | **Yes** (WSL2 installation requires admin privileges) |
| Internet required? | No (fully offline) | No (once installed; see "Network" section below) |

**Recommendation:** Use Option A for quick demos and reviews. Use Option B to explore the live dashboard and modify controls.

---

## Option A: No Install, Offline (Primary Demo Path)

1. Download or clone this repository to your local machine
2. In File Explorer, navigate to the repository folder (e.g., `C:\Users\<you>\Documents\koala-compliance-demo`)
3. Open `fallback\index.html` in any browser (Edge, Chrome, Firefox)—double-click the file or drag it into your browser

**What's included (all works offline from one self-contained HTML file):**

- **Results by benchmark**: 31 controls, 194 ok / 83 alarm / 23 skip (70.0% pass rate)
- **Failing resources table**: All 83 findings with framework filter dropdown and search
  - Expected filter counts: CIS AWS v3.0.0 (24), Essential Eight ML1 (33), Koala Freight custom (26)
  - "Download CSV" exports `output\failing-resources.csv`
- **Dashboard screenshot**: Visual preview of the live Powerpipe dashboard
- **Full reports**: Each benchmark's detailed HTML report (`output\reports\*.html`)

**Additional artifacts in the repository:**

- `output\reports\*.md`: Markdown versions of the reports
- `output\*.csv` and `output\*.json`: Raw benchmark exports
- `output\snapshots\*.pps`: Powerpipe snapshots (require Powerpipe or Turbot Pipes to view; kept as run archives)

**Testing:** The offline page was validated in Microsoft Edge 156 with network disabled—no external requests, all filters and search working correctly.

---

## Option B: live run inside Ubuntu on WSL2

Steampipe and Powerpipe have **no native Windows builds** (the official install scripts print
"Windows is not supported yet"). On Windows they run inside WSL2.

### B1. WSL2 Setup (Requires Admin)

**Prerequisites:** Windows 10 version 2004+ (build 19041+) or Windows 11

**Check if already installed:**
```powershell
wsl --status
# or
wsl -l -v
```
If Ubuntu is listed with VERSION 2, skip to B2.

**Installation:**
1. Open PowerShell **as administrator**
2. Run: `wsl --install`
3. Restart your computer when prompted
4. Ubuntu will be installed as the default distribution

**Enterprise considerations:**
- WSL can be managed via Intune or Group Policy
- Microsoft Defender for Endpoint supports WSL integration
- Behind corporate proxies, configure `.wslconfig` with `autoProxy=true`, `networkingMode=mirrored`, and `dnsTunneling=true`
- Organizations can deploy custom WSL images using `wsl --import`

**References:**
- [Microsoft Learn: Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Microsoft Learn: WSL for Enterprise](https://learn.microsoft.com/en-us/windows/wsl/enterprise)

### B2. Steampipe, Powerpipe and the csv plugin (no sudo, inside Ubuntu)

Sources: the official GitHub releases (https://github.com/turbot/steampipe/releases,
https://github.com/turbot/powerpipe/releases) and https://steampipe.io/downloads /
https://powerpipe.io/downloads. The official install scripts (`steampipe.sh` and `powerpipe.sh`) write
to `/usr/local/bin`, so they need sudo. The steps below put the same official binaries in `~/bin`
instead. Each release archive holds a single binary.

These are the versions this demo was tested with: Steampipe v2.4.8, Powerpipe v1.5.6 and the csv plugin 1.2.0.
Newer releases (Steampipe v2.4.9, Powerpipe v1.5.7) came out on 1 Nov 2026 and have **not** been
tested with this demo.

In the Ubuntu terminal:

```bash
mkdir -p ~/bin && cd ~/bin
curl -fsSLO https://github.com/turbot/steampipe/releases/download/v2.4.8/steampipe_linux_amd64.tar.gz
curl -fsSLO https://github.com/turbot/powerpipe/releases/download/v1.5.6/powerpipe.linux.amd64.tar.gz
# SHA-256 values from each release's checksums.txt
echo "60490a8f101bfa3da5686cace09503105f8cd23909b4cec78324d097d3d8ac44  steampipe_linux_amd64.tar.gz" | sha256sum -c
echo "2fa14f0d972cb82a7eda961b7cdb2f50e40ffae094b6ea5364d497120349a227  powerpipe.linux.amd64.tar.gz" | sha256sum -c
tar -xzf steampipe_linux_amd64.tar.gz && tar -xzf powerpipe.linux.amd64.tar.gz && rm ./*.tar.gz
grep -q 'HOME/bin' ~/.bashrc || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:$PATH"
steampipe plugin install csv
```

Use `steampipe plugin install csv`, **not** `csv@1.2.0`. The demo's config uses `plugin = "csv"`
(meaning "latest"), and a version-pinned install doesn't satisfy it. Every control errors with
"plugin not installed". (`csv` resolved to 1.2.0 when this was tested.)

The first plugin install also downloads Steampipe's embedded Postgres (14.19.0) and its FDW (2.2.8).

### B3. Copy the demo folder in and run it

Run it from the Linux file system, not from `/mnt/c`:

```bash
cp -r /mnt/c/Users/<you>/Documents/koala-compliance-demo ~/
cd ~/koala-compliance-demo
bash scripts/run_benchmarks.sh
```

(Use `bash scripts/...`, because files copied from Windows can lose their "executable" bit.)

**Where the csv plugin reads from:** `run_benchmarks.sh` writes `~/.steampipe/config/csv.spc` and
points it at *this folder's* `data/*.csv`, using whatever path you copied the folder to. The template is
`config/csv.spc`. To set it by hand, edit `~/.steampipe/config/csv.spc`:

```hcl
connection "csv" {
  plugin = "csv"
  paths  = ["/home/<you>/koala-compliance-demo/data/*.csv"]
}
```

The script starts the Steampipe service on localhost only (`--database-listen local`). It turns off
update checks and telemetry for both tools, so it needs no internet once installed. Python isn't needed:
the CSVs are pre-generated. (`REGEN=1 bash scripts/run_benchmarks.sh` regenerates them if Python 3
is present.)

Open the live dashboard:

```bash
cd ~/koala-compliance-demo/mod
POWERPIPE_UPDATE_CHECK=false POWERPIPE_TELEMETRY=none powerpipe server
```

Then, in Edge on Windows, go to http://localhost:9033. Microsoft's WSL networking doc says Windows apps
can reach Linux apps in WSL2 via `localhost`. This wasn't tested on a real Windows laptop. If it doesn't
connect, try `powerpipe server --listen network` and use the WSL IP from `hostname -I`.

### B4. Five-command smoke test (inside Ubuntu)

| # | Command | Expected |
|---|---|---|
| 1 | `steampipe -v && powerpipe -v` | `Steampipe v2.4.8` and `Powerpipe v1.5.6` |
| 2 | `steampipe plugin list` | a `hub.steampipe.io/plugins/turbot/csv@latest` row, version `1.2.0`, connection `csv` |
| 3 | `cd ~/koala-compliance-demo && bash scripts/run_benchmarks.sh` | `csv tables visible: 12/12`. Then CIS 53 ok / 24 alarm / 11 skip, Essential Eight 100 ok / 33 alarm / 12 skip, Custom 41 ok / 26 alarm / 0 skip, and 0 errors. "Alarm" makes powerpipe exit 1 for each benchmark; that's expected. |
| 4 | `bash scripts/totals.sh` | `31,194,83,23` (controls, ok, alarm, skip) |
| 5 | `cd mod && (powerpipe server > /tmp/pp.log 2>&1 &) && sleep 8 && curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9033/` | `200`, then open http://localhost:9033 in Edge |

To stop afterwards: `pkill -f "powerpipe server"; steampipe service stop`.

---

## macOS (short)

- With Homebrew: `brew install turbot/tap/steampipe turbot/tap/powerpipe`. Installing Homebrew itself
  usually needs admin.
- Without admin: download `steampipe_darwin_arm64.zip` and `powerpipe.darwin.arm64.tar.gz`
  (use `amd64` on Intel Macs) from the same release pages into `~/bin`, extract them, and add `~/bin` to `PATH`. Then follow
  B2 from `steampipe plugin install csv`, B3 and B4.
- Not tested on macOS. Files downloaded in a browser can be blocked by Gatekeeper; `curl` downloads
  usually aren't.

---

## Dependencies and Requirements

| Component | Version | License | Admin Required? | Notes |
|---|---|---|---|---|
| WSL2 + Ubuntu | Current WSL from Microsoft | Microsoft / Canonical | **Yes** | Windows 10 2004+ or Windows 11. Required for Option B only. |
| Steampipe CLI | v2.4.8 | Turbot, AGPL-3.0 | No | Single binary, installed in user space (`~/bin`) |
| Powerpipe CLI | v1.5.6 | Turbot, AGPL-3.0 | No | Single binary, installed in user space (`~/bin`) |
| Steampipe csv plugin | 1.2.0 | Turbot, Apache-2.0 | No | Reads only local `data/*.csv` files |
| Steampipe embedded PostgreSQL | 14.19.0 + FDW 2.2.8 | Turbot | No | Downloaded automatically on first plugin install; stored in `~/.steampipe` |
| Modern web browser | Any | Various | No | Required for Option A (offline HTML) |
| Python 3 | Optional | PSF | No | Only needed to regenerate synthetic data |

**Network Endpoints** (HTTPS/443, observed during clean install on 2 Nov 2026):

| Endpoint | When | Purpose |
|---|---|---|
| `github.com`, `release-assets.githubusercontent.com` | Binary installation | Steampipe and Powerpipe release downloads |
| `ghcr.io`, `pkg-containers.githubusercontent.com` | Plugin installation | CSV plugin, embedded PostgreSQL and FDW images |
| `hub.steampipe.io` | Plugin installation | Plugin version lookup |
| `hub.powerpipe.io` | Each Powerpipe run | Update checks and telemetry (4 requests/run by default) |
| Microsoft endpoints | WSL installation | Package downloads for Ubuntu |

**Disabling telemetry:**
- Set `POWERPIPE_UPDATE_CHECK=false` and `POWERPIPE_TELEMETRY=none` (already configured in included scripts)
- With telemetry disabled, subsequent runs make zero outbound connections

**Local Ports** (inside WSL only):
- 9193: Steampipe PostgreSQL (localhost only)
- 9033: Powerpipe dashboard server

**Security boundaries:**
- No cloud credentials required or requested
- No connections to AWS, Azure, or any cloud provider
- No network scanning or port scanning
- No code or dependency vulnerability scanning
- Evaluates synthetic CSV files only
