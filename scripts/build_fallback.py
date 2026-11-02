#!/usr/bin/env python3
"""Build the no-install fallback: output/failing-resources.csv and fallback/index.html.

Reads the benchmark exports in output/ (run scripts/run_benchmarks.sh first).
The HTML is a single self-contained file (screenshot embedded, inline CSS/JS, no network).
"""
import base64, csv, html, json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "output")
BENCHES = [  # (export name, framework label, column holding the framework ID)
    ("cis_aws_v300_subset", "CIS AWS v3.0.0", "cis_item_id"),
    ("essential_eight_ml1", "Essential Eight ML1", "e8_strategy"),
    ("koala_freight_custom", "Koala Freight custom", "kf_control_id"),
]

summary, failing = [], []
for name, label, id_col in BENCHES:
    bench = json.load(open(os.path.join(OUT, name + ".json")))["groups"][0]
    s = bench["summary"]["status"]
    checked = s["ok"] + s["alarm"]
    summary.append({"label": label, "title": bench["title"], "report": name,
                    "controls": len(bench.get("controls") or []), **s,
                    "pass": f"{100 * s['ok'] / checked:.1f}" if checked else "n/a"})
    for r in csv.DictReader(open(os.path.join(OUT, name + ".csv"), newline="")):
        if r["status"] == "alarm":
            failing.append({"framework": label, "framework_id": r.get(id_col, ""),
                            "control": r["control_title"], "resource": r["resource"],
                            "reason": r["reason"], "scope": r["scope"], "region": r["region"]})

cols = ["framework", "framework_id", "control", "resource", "reason", "scope", "region"]
with open(os.path.join(OUT, "failing-resources.csv"), "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=cols)
    w.writeheader()
    w.writerows(failing)

tot = {k: sum(b[k] for b in summary) for k in ("controls", "ok", "alarm", "skip", "info", "error")}
tot_pass = f"{100 * tot['ok'] / (tot['ok'] + tot['alarm']):.1f}"
png = base64.b64encode(open(os.path.join(OUT, "dashboard.png"), "rb").read()).decode()

rows = "".join(
    f"<tr><td><a href=\"../output/reports/{b['report']}.html\">{html.escape(b['title'])}</a></td>"
    f"<td>{b['controls']}</td><td class=ok>{b['ok']}</td><td class=alarm>{b['alarm']}</td>"
    f"<td>{b['skip']}</td><td>{b['info']}</td><td>{b['error']}</td><td>{b['pass']}%</td></tr>"
    for b in summary)
rows += (f"<tr class=total><td>Total</td><td>{tot['controls']}</td><td class=ok>{tot['ok']}</td>"
         f"<td class=alarm>{tot['alarm']}</td><td>{tot['skip']}</td><td>{tot['info']}</td>"
         f"<td>{tot['error']}</td><td>{tot_pass}%</td></tr>")
options = "".join(f"<option>{html.escape(b['label'])}</option>" for b in summary)
data = json.dumps(failing).replace("</", "<\\/")

page = f"""<!doctype html>
<html lang="en-AU"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Koala Freight - Compliance Overview (synthetic data, offline)</title>
<style>
body{{font-family:Segoe UI,Arial,sans-serif;margin:0;background:#f3f4f6;color:#111}}
header{{background:#1f2937;color:#fff;padding:14px 24px}} header h1{{margin:0;font-size:22px}}
main{{padding:16px 24px;max-width:1400px;margin:auto}}
.note{{background:#fff7d6;border:1px solid #e5c100;padding:8px 12px;border-radius:4px;font-size:14px}}
section{{background:#fff;border-radius:6px;padding:14px 18px;margin:16px 0;box-shadow:0 1px 2px #0002}}
h2{{font-size:17px;margin:0 0 10px}} table{{border-collapse:collapse;width:100%;font-size:14px}}
th,td{{text-align:left;padding:6px 8px;border-bottom:1px solid #e5e7eb;vertical-align:top}}
th{{background:#f9fafb}} .ok{{color:#15803d;font-weight:600}} .alarm{{color:#b91c1c;font-weight:600}}
tr.total td{{font-weight:700;border-top:2px solid #9ca3af}}
img{{max-width:100%;border:1px solid #e5e7eb}} .controls{{margin-bottom:10px;display:flex;gap:10px;flex-wrap:wrap;align-items:center}}
select,input{{font-size:14px;padding:4px 6px}} #count{{color:#555;font-size:14px}}
</style></head><body>
<header><h1>Koala Freight - Compliance Overview</h1></header>
<main>
<p class="note"><b>Synthetic demo data only.</b> Koala Freight Pty Ltd is fictional. No real cloud accounts were connected and nothing was scanned.
This page is a static, offline copy of the live Powerpipe results from snapshot date 2026-11-01. Counts are per resource checked.</p>

<section><h2>Results by benchmark</h2>
<table><thead><tr><th>Benchmark (opens full report)</th><th>Controls</th><th>OK</th><th>Alarm</th><th>Skip</th><th>Info</th><th>Error</th><th>Pass % (ok / ok+alarm)</th></tr></thead>
<tbody>{rows}</tbody></table></section>

<section><h2>Failing resources</h2>
<div class="controls">
<label>Framework <select id="fw"><option value="">All frameworks</option>{options}</select></label>
<label>Search <input id="q" type="search" placeholder="resource, reason, control..."></label>
<span id="count"></span>
<a href="../output/failing-resources.csv">Download CSV</a></div>
<table><thead><tr><th>Framework</th><th>Framework ID</th><th>Control</th><th>Resource</th><th>Reason</th><th>Scope</th><th>Region</th></tr></thead>
<tbody id="rows"></tbody></table></section>

<section><h2>Live dashboard (screenshot from the Powerpipe server)</h2>
<img alt="Powerpipe dashboard screenshot" src="data:image/png;base64,{png}"></section>

<section><h2>Full reports (offline)</h2>
<p>Powerpipe HTML reports: <a href="../output/reports/cis_aws_v300_subset.html">CIS AWS</a> |
<a href="../output/reports/essential_eight_ml1.html">Essential Eight ML1</a> |
<a href="../output/reports/koala_freight_custom.html">Koala Freight custom</a>.
Raw exports (JSON/CSV), Markdown reports and Powerpipe snapshots (.pps) are in the <code>output</code> folder.</p></section>
</main>
<script id="data" type="application/json">{data}</script>
<script>
var all = JSON.parse(document.getElementById('data').textContent);
var cols = {json.dumps(cols)};
function render() {{
  var fw = document.getElementById('fw').value, q = document.getElementById('q').value.toLowerCase();
  var body = document.getElementById('rows'); body.innerHTML = '';
  var shown = 0;
  all.forEach(function (r) {{
    if (fw && r.framework !== fw) return;
    if (q && cols.map(function (c) {{ return r[c]; }}).join(' ').toLowerCase().indexOf(q) < 0) return;
    var tr = document.createElement('tr');
    cols.forEach(function (c) {{ var td = document.createElement('td'); td.textContent = r[c]; tr.appendChild(td); }});
    body.appendChild(tr); shown++;
  }});
  document.getElementById('count').textContent = shown + ' of ' + all.length + ' failing resources';
}}
document.getElementById('fw').onchange = render;
document.getElementById('q').oninput = render;
render();
</script></body></html>
"""
os.makedirs(os.path.join(ROOT, "fallback"), exist_ok=True)
open(os.path.join(ROOT, "fallback", "index.html"), "w").write(page)
print(f"wrote fallback/index.html and output/failing-resources.csv ({len(failing)} failing rows)")
