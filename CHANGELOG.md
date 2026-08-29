# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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

- Let `strictToken: false` reach the pod: Helm's `default` fires on `false`, so turning it off returned `true`. @vhidvz
- Point the ZarinPal callback fallback at the gateway's own route, not a frontend path that cannot resolve it. @vhidvz

### Changed

- Bump the landau chart to 1.0.5 and its frontend subchart to 1.0.2, and repackage the index. @vhidvz
