#!/usr/bin/env python3
"""Screenshot the running dashboard (needs `powerpipe server` on :9033). Uses installed Google Chrome."""
import sys
from playwright.sync_api import sync_playwright

url = "http://localhost:9033/koala_compliance.dashboard.compliance_overview"
out = sys.argv[1] if len(sys.argv) > 1 else "output/dashboard.png"
with sync_playwright() as p:
    b = p.chromium.launch(channel="chrome", headless=True)
    pg = b.new_page(viewport={"width": 1600, "height": 1000})
    pg.goto(url)
    pg.wait_for_selector("text=Failing resources", timeout=60000)
    pg.wait_for_timeout(6000)  # let cards/charts finish their queries
    body = pg.inner_text("body")
    pg.screenshot(path=out, full_page=True)
    print("error text present:", "error" in body.lower())
    print(body[:1500])
    b.close()
