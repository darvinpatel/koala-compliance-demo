# Running the Koala Freight demo on a work laptop (Windows first)

Everything in this folder is **synthetic** (Koala Freight Pty Ltd, made-up data). It contains no
cloud credentials, does not connect to any cloud account, and does not scan anything.

There are two ways to demo:

| | Option A: no install (primary) | Option B: live run in WSL2 |
|---|---|---|
| Needs | Edge (or any browser). | WSL2 + Ubuntu, then Steampipe, Powerpipe and the csv plugin |
| Admin / IT? | No | **Yes**: installing WSL needs admin, and IT may block it |
| Internet on the day? | No | No, once installed (see "Network" below) |

Use Option A unless IT has already approved and installed WSL2.

---

## Option A: no install, offline (primary demo path)

1. Copy `koala-compliance-demo.zip` to the laptop.
2. In File Explorer, right-click the zip, choose **Extract All...**, and extract it to, for example,
   `C:\Users\<you>\Documents\koala-compliance-demo`.
   Don't open the page from inside the zip; the links to the reports and the CSV need extracted files.
3. Open `fallback\index.html` in Edge (double-click it, or drag it into Edge).

What's on the page (it all works offline, from one self-contained file):

- **Results by benchmark**: 31 controls, 194 ok / 83 alarm / 23 skip (70.0% pass), with a row for each benchmark.
- **Failing resources**: all 83 alarm rows. Filter by framework with the drop-down, or type in the
  search box (try `nsg-jump`). Expected filter counts: CIS AWS v3.0.0 24, Essential Eight ML1 33,
  Koala Freight custom 26. The "Download CSV" link opens `output\failing-resources.csv` (opens in Excel).
- **Live dashboard screenshot**: what the Powerpipe dashboard looks like when it's running.
- **Full reports**: each benchmark's Powerpipe HTML report (`output\reports\*.html`), also offline.

Also in the folder:

- `output\reports\*.md`: Markdown versions of the reports.
- `output\*.csv` and `output\*.json`: raw benchmark exports.
- `output\snapshots\*.pps`: Powerpipe snapshots of the dashboard and each benchmark. These are
  **not** a no-install path. Per the Powerpipe docs, you view them in the Powerpipe dashboard
  (or Turbot Pipes), so they're only useful with Option B. They're kept as an archive of the run.

Tested: the page was opened from a fresh unzip in Microsoft Edge 156.0.4314.58 (Linux build), with the
network disabled. There were no network requests and no script errors, and all of the filters and
the search worked. Edge on Windows itself was not tested.

---

## Option B: live run inside Ubuntu on WSL2

Steampipe and Powerpipe have **no native Windows builds** (the official install scripts print
"Windows is not supported yet"). On Windows they run inside WSL2.

### B1. WSL2 (needs admin, so ask IT)

Source: Microsoft Learn, "How to install Linux on Windows with WSL"
(https://learn.microsoft.com/en-us/windows/wsl/install) and "Set up WSL for your company"
(https://learn.microsoft.com/en-us/windows/wsl/enterprise).

- First check whether it's already there. In a normal (non-admin) PowerShell, run `wsl --status` or
  `wsl -l -v`. If Ubuntu is listed with VERSION 2, skip to B2.
- Installing it means running `wsl --install` in PowerShell **as administrator**, then restarting.
  It needs Windows 10 version 2004+ (build 19041+) or Windows 11. Ubuntu is the default distribution.
- On a managed laptop, this is IT's job. IT can allow or block WSL through Intune or Group Policy, and
  Microsoft Defender for Endpoint has a WSL plug-in. IT can also give you an approved image
  (`wsl --import`).
- Behind a corporate proxy: Microsoft's enterprise doc covers `.wslconfig` options such as
  `autoProxy=true`, `networkingMode=mirrored` and `dnsTunneling=true`. Let IT decide these.

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

## IT approval list

| Item | Version | Publisher / licence | Admin? | Notes |
|---|---|---|---|---|
| WSL2 (Windows Subsystem for Linux) + Ubuntu | Current WSL from Microsoft; Ubuntu (default distro) | Microsoft / Canonical | **Yes** (`wsl --install`, then a restart) | Windows 10 2004+ (build 19041+) or Windows 11. Can be managed by Intune/GPO and Defender for Endpoint. Only needed for Option B. |
| Steampipe CLI | v2.4.8 | Turbot, AGPL-3.0 (GitHub repo licence) | No (user `~/bin`) | Single binary, inside WSL |
| Powerpipe CLI | v1.5.6 | Turbot, AGPL-3.0 (GitHub repo licence) | No | Single binary, inside WSL |
| Steampipe csv plugin | 1.2.0 | Turbot, Apache-2.0 | No | Reads only the local `data/*.csv` files |
| Steampipe embedded Postgres + FDW | Postgres 14.19.0, FDW 2.2.8 | Turbot (downloaded by Steampipe) | No | Downloaded automatically on first install; stored in `~/.steampipe` |
| Microsoft Edge | already installed | Microsoft | No | The only thing Option A needs |
| Python 3 | optional | | No | Not needed for the demo |

**Network endpoints** (HTTPS/443, seen through a logging proxy during a clean install on 2 Nov 2026):

| Endpoint | When | Why |
|---|---|---|
| `github.com`, `release-assets.githubusercontent.com` | Install | Steampipe and Powerpipe release downloads |
| `ghcr.io`, `pkg-containers.githubusercontent.com` | `steampipe plugin install csv` / first start | csv plugin, embedded Postgres and FDW images |
| `hub.steampipe.io` | `steampipe plugin install csv` | Plugin version lookup |
| `hub.powerpipe.io` | Each Powerpipe run, **unless** turned off | Contacted 4 times per run by default (probably the update check/telemetry). With `POWERPIPE_UPDATE_CHECK=false` and `POWERPIPE_TELEMETRY=none` (set by the scripts) a second run made **zero** outbound connections. |
| Microsoft endpoints for WSL / Ubuntu | WSL install | Not observed; IT to confirm |

**Local ports** (inside WSL): 9193 (Steampipe Postgres, localhost only) and 9033 (Powerpipe dashboard).

**What it doesn't do:** no cloud credentials, no connection to any cloud or employer account, no
network scanning, no code or dependency scanning. It evaluates synthetic CSV files only.
