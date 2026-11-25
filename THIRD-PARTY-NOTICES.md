# Third-Party Notices

## Published Container Image Contents

This container image contains **only** official Debian 13 (`trixie`) open-source packages (`tini`, `curl`, `jq`, `xmlstarlet`, `uuid-runtime`, `tzdata`, `ca-certificates`, `procps`, `util-linux`) and MIT-licensed wrapper scripts authored for this repository.

- **Debian 13 (`trixie`) packages:** Various DFSG-compatible open-source licenses (`https://deb.debian.org/debian/`)
- **tini:** MIT License

## Runtime-Fetched Software (Not Redistributed)

Plex Media Server is **not** included in this repository or published container image. When a user runs the container, `/init` downloads the official Debian package directly from `plex.tv` / `downloads.plex.tv` on behalf of the user. Use of Plex Media Server is governed by the [Plex Terms of Service](https://www.plex.tv/about/privacy-legal/plex-terms-of-service/).

---

This repository's own build definitions, CI workflows, wrapper scripts, tests, and documentation are licensed under the MIT License — Copyright (c) 2026 Daniel G. Cosenza from FNX Labs (see [LICENSE](LICENSE)).
