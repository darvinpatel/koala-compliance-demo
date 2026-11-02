#!/usr/bin/env python3
"""Turn Powerpipe benchmark JSON exports into a Microsoft Teams Adaptive Card payload.

Usage:
  python3 scripts/teams_card.py output/*.json > output/teams-card.json          # build only
  TEAMS_WEBHOOK_URL=... python3 scripts/teams_card.py --post output/*.json      # build and post (CI only)
"""
import json, os, sys, urllib.request

def summarise(path):
    d = json.load(open(path))
    bench = d["groups"][0]
    s = bench["summary"]["status"]
    fails = []
    for c in bench.get("controls") or []:
        if c["summary"]["alarm"]:
            fails.append((c["summary"]["alarm"], c["title"]))
    return bench["title"], s, len(bench.get("controls") or []), sorted(fails, reverse=True)[:3]

def card(paths):
    body = [{"type": "TextBlock", "size": "Large", "weight": "Bolder", "text": "Weekly compliance summary"},
            {"type": "TextBlock", "isSubtle": True, "wrap": True,
             "text": "Koala Freight (synthetic demo data). Status counts are per resource checked."}]
    for p in paths:
        title, s, n, fails = summarise(p)
        checked = s["ok"] + s["alarm"]
        pct = round(100 * s["ok"] / checked, 1) if checked else 0
        body.append({"type": "TextBlock", "weight": "Bolder", "spacing": "Medium", "text": title})
        body.append({"type": "FactSet", "facts": [
            {"title": "Controls", "value": str(n)},
            {"title": "OK / Alarm", "value": f"{s['ok']} / {s['alarm']}"},
            {"title": "Skip / Info / Error", "value": f"{s['skip']} / {s['info']} / {s['error']}"},
            {"title": "Pass %", "value": f"{pct}%"}]})
        if fails:
            body.append({"type": "TextBlock", "wrap": True, "size": "Small",
                         "text": "Top alarms: " + "; ".join(f"{t} ({a})" for a, t in fails)})
    return {"type": "message", "attachments": [{
        "contentType": "application/vnd.microsoft.card.adaptive", "contentUrl": None,
        "content": {"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    "type": "AdaptiveCard", "version": "1.4", "body": body}}]}

if __name__ == "__main__":
    args = sys.argv[1:]
    post = "--post" in args
    paths = [a for a in args if a != "--post"]
    payload = json.dumps(card(paths), indent=2)
    if not post:
        print(payload)
        sys.exit(0)
    url = os.environ["TEAMS_WEBHOOK_URL"]
    req = urllib.request.Request(url, data=payload.encode(), headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        print("Teams webhook responded", r.status)
