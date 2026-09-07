# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Give the chart a README of its own, naming what a real deployment must set beyond the safe defaults. @vhidvz
- Carry the dispatch guarantee gate and the POS auto-reconcile flag, which the backend has read since plans 82 and 84. @vhidvz
- Give every workload resource requests, a memory limit, a dropped-capability context and a disruption budget. @vhidvz
- Probe the frontend and assets pods, which had no liveness or readiness check at all. @vhidvz
- Roll the pods when the resolved secret changes, by checksumming it onto the pod template. @vhidvz
- Carry the PSP provider, its fake opt-in, merchant, callback and timeout, so money enters through a named gateway. @vhidvz
- Mint the PSP callback-signing secret per install, beside the AES and Altcha keys the backend refuses to boot without. @vhidvz
- Carry the in-shop POS flag and its unreconciled ceiling, and say on both sides that the two must agree. @vhidvz
- Carry the order auto-reject, dispute-window and self-supply settings a deployment tunes per market. @vhidvz
- Carry the dispatch radius, wave, detour, routing and default-parcel settings the offer sweep reads. @vhidvz
- Carry the operations tick and lock, and the wholesale restock terms a distributor has not declared. @vhidvz
- Carry the Altcha work ceiling, the ZarinPal timeout, and the mail identities that default off `ROOT_DOMAIN`. @vhidvz
- Carry the VAPID pair, public half as plain env and private half as a secret, with no generated fallback. @vhidvz
- Carry the seed admin password as an optional secret, for `platform:seed` run by hand against a pod. @vhidvz
- Serve the frontend its tenant auth domain, without which every token request is refused. @vhidvz
- Serve the frontend the POS flag and the till's own bridge address, without which the button cannot settle. @vhidvz

### Fixed

- Refuse to mint over a key absent from an existing `lnd-secrets`, rather than orphaning what it encrypted. @vhidvz
- Hash only the stable secret inputs, so the deployments agree on one checksum and a dry run stops churning. @vhidvz
- Survive a values file leaving a secret or a boolean explicitly empty, instead of aborting or flipping it. @vhidvz
- Budget disruptions with `maxUnavailable`, so a single-replica install cannot wedge a node drain. @vhidvz
- Keep the AES, altcha and PSP keys across an upgrade: they were re-minted on every render, orphaning encrypted data. @vhidvz
- Serve the map tile as `NUXT_PUBLIC_MAP_TILE_URL`, the only name Nuxt applies at runtime. @vhidvz
- Probe liveness on the port, not `/status`: a Redis, NATS or platform outage no longer restarts every healthy pod. @vhidvz
- Let `strictToken: false` reach the pod: Helm's `default` fires on `false`, so turning it off returned `true`. @vhidvz
- Point the ZarinPal callback fallback at the gateway's own route, not a frontend path that cannot resolve it. @vhidvz

### Changed

- Default `NODE_ENV` to production, which is what stops stack traces being returned in error replies. @vhidvz
- Ship quiet: `DEBUG` and the NATS credentials are emitted only when set, never as an overriding empty string. @vhidvz
- Sample one trace in ten rather than four in five. @vhidvz
- Bump the chart and all four subcharts to 1.1.0, onto the wenex chart line, and repackage the index. @vhidvz
- Bump the landau chart to 1.0.5 and its frontend subchart to 1.0.2, and repackage the index. @vhidvz

### Removed

- Drop `DISPATCH_OVERSIZE_KM`, which decision 122 replaced with a registry row on 2026-09-04. @vhidvz
- Drop the committed ZarinPal sandbox merchant id, so an install cannot believe it is taking real money. @vhidvz
- Drop the committed `lnd`/`lnd` NATS credentials. @vhidvz
