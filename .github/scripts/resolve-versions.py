#!/usr/bin/env python3
"""Resolve latest official public Plex Media Server release metadata from plex.tv."""

from __future__ import annotations

import json
import os
import urllib.request
from pathlib import Path


def fetch_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "dgcosenza-plex-docker-ci"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> None:
    override = os.environ.get("OVERRIDE_PLEX", "").strip()
    if override:
        ver = override
        notes = f"Manual override label: Plex Media Server {ver}."
    else:
        data = fetch_json("https://plex.tv/api/downloads/5.json")
        lin = data["computer"]["Linux"]
        ver = lin["version"]
        deb = next(
            (r for r in lin.get("releases", []) if r.get("distro") == "debian" and r.get("build") == "linux-x86_64"),
            {},
        )
        notes = (
            f"Latest official public Plex Media Server Debian x86_64 release: `{ver}` "
            f"(SHA-1 `{deb.get('checksum', 'unknown')}`). "
            "Note: binary is downloaded and verified at container runtime, never bundled in this image."
        )

    prev = {}
    vpath = Path("versions.json")
    if vpath.exists():
        prev = json.loads(vpath.read_text(encoding="utf-8"))
    prev_ver = prev.get("plex_tested_version", "")
    changed = ver != prev_ver

    md = [
        "# Upstream changes — Plex Media Server (Runtime Wrapper)",
        "",
        f"- **Latest tested public PMS release:** `{prev_ver or 'none'}` -> `{ver}`",
        f"- **Upstream version changed:** `{'yes' if changed else 'no'}`",
        "",
        "## Details",
        "",
        notes,
        "",
    ]
    Path("upstream-changes.md").write_text("\n".join(md), encoding="utf-8")

    outputs = {
        "plex_version": ver,
        "prev_plex_version": prev_ver,
        "upstream_changed": "true" if changed else "false",
    }
    gh_out = os.environ.get("GITHUB_OUTPUT")
    if gh_out:
        with open(gh_out, "a", encoding="utf-8") as fh:
            for k, v in outputs.items():
                fh.write(f"{k}={v}\n")
    for k, v in outputs.items():
        print(f"{k}={v}")


if __name__ == "__main__":
    main()
