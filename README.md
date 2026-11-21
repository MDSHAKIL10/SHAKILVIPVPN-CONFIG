# SHAKILVIPVPN-CONFIG

This repository publishes `servers.json` for the SHAKILVIPVPN Android client and hosts `config_maker.html`, a browser-based configuration editor.

## Read API

The client first fetches the GitHub Pages URL:

`https://mdshakil10.github.io/SHAKILVIPVPN-CONFIG/servers.json`

It falls back to the raw `server_script` branch. Enable GitHub Pages for this repository and select the `server_script` branch (root) for the Pages URL. The public file is read-only to clients; changes are published through GitHub's Contents API by the administrator tool. This is a static configuration read API, not a bespoke backend service.

## Schema

`servers.json` is public. Do not include UUIDs, passwords, private keys, or tokens. Each entry supports `name`, `address` (or IP), `port`, `protocol`, `payload`, `host`, `sni`, `wsPath`, `tls` (boolean), `countryFlag`, `category`, and per-entry `version`; the root has an integer `version`, `updatedAt`, and `servers` list. Protocols must remain explicit: VLESS/Xray uses WebSocket/TLS fields; Hysteria 2 is a UDP configuration and must never be passed to the Xray parser.

The Android client currently supports VLESS/Xray only. It displays but refuses UDP/Hysteria entries until a compatible Android Hysteria engine and its integration tests are added. This is intentional fail-closed behavior, not a claim that UDP VPN is working.

## Publish

Open `config_maker.html` through GitHub Pages. Use a fine-grained token scoped only to this repository with Contents read/write permission. The token is held in memory only, and the generator writes `servers.json` on `server_script`. Enable Pages as described above so clients can fetch the same published file. For organizational deployments, prefer a server-side publisher/proxy to avoid entering a GitHub token in a browser.
