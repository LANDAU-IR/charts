# Landau

Follow these steps to install the artifacts hub Helm chart package:

**Add the Helm Repository:**  

  ```sh
  helm repo add landau https://landau-ir.github.io/charts
  helm repo update
  ```

**Install the Chart:**  

  ```sh
  helm install landau landau/landau
  ```

## Deploying for real

The shipped defaults are safe rather than complete — a bare install runs against Zibal's
**sandbox** (`psp.provider: zibal`, merchant `zibal`) and takes no real money. A production deployment
names at least:

| Value | Why |
| --- | --- |
| `global.environments.zibal.merchant` | Zibal's live merchant, in the release's own values (or its secret store) — never committed. The sandbox default is deliberate. |
| `global.environments.psp.callbackUrl` | On the domain registered for the gateway in Zibal's panel: a callback anywhere else is refused `106` and no payment opens. |
| The frontend's own domain | Zibal's `/start` page needs a `Referer` from the registered site. The payer leaves from an `lnd-frontend` page, which sets no `Referrer-Policy`, so the browser sends its origin — keep it that way (`no-referrer` in front of the app stops every payment). |
| The cluster's egress IP | Registered in Zibal's panel when the merchant is IP-restricted, or every call answers `115`. |
| `global.environments.zarinpal.{url,redirectUrl,merchantId}` | Only with `psp.provider: zarinpal` — all three together, or payments fail with `424`. |
| `global.environments.nats.{user,pass}` | No credential ships in this chart. |
| `global.environments.mongo.pass`, `global.environments.redis.password` | Datastore credentials. |
| `global.secrets.vapid.privateKey` + `global.environments.vapid.publicKey` | Both halves or neither; unset keeps the backend's committed dev pair. |
| `global.environments.sentry.{dsn,moneyDsn}`, `frontend.environments.nuxt.public.sentry.dsn` | Empty reports nothing. Keys, limits and alert rules: *Error reporting* below. |
| `resources`, per subchart | The defaults are a starting point, not a sizing. |

`AES_KEY`, `HMAC_KEY` and `PSP_SECRET` are minted on first install and carried forward on every
upgrade thereafter — `templates/secret.yaml` reads the `lnd-secrets` already in the namespace before
it mints, and a value set under `global.secrets` wins over both and stays once set (it reaches the
pods on their next restart: `kubectl rollout restart deployment`, nothing rolls them for you). Two
constraints come with that, both about *how* the chart is applied: a tool that renders without the
cluster and applies what it rendered — Argo CD, plain `helm template` — mints on every render, so on
that path the three values must be set explicitly under `global.secrets` (from the tool's own secret
store), or every sync re-mints them; and the Secret survives `helm uninstall` on purpose, so a
reinstall under the same release name adopts it while a different release name — or a second release
in the namespace — fails Helm's ownership check (`--take-ownership` overrides it, deliberately).

**Upgrading an install older than 1.0.8:** every earlier release re-minted the three on each upgrade
while the pods kept the key they started with, so the Secret may not hold the key a running pod is
using. `1.0.8` freezes whatever the Secret holds. Before the upgrade, read the key the pods run —
`kubectl exec deploy/lnd-services -- printenv AES_KEY` — and pass it as `global.secrets.aes` (same
for `ALTCHA_HMAC_KEY` → `altcha.hmacKey`, `PSP_SECRET` → `psp.secret`); a supplied value wins and stays.

## Error reporting (Sentry)

Both apps report to a self-hosted Sentry, 25.9.0 or 26.10 (SDK 10.78.0; SDK 11 needs a server at 26.4.2 or later).
Nothing is sent while a DSN is empty, and an unreachable server slows no request and no tick.

**Server requirements.** A server on the `sentry-kubernetes` chart needs two values its defaults leave off, or uploads
and replays fail while every event still answers `200`: `filestore.filesystem.persistence.persistentWorkers: true`, or
other storage all its pods share (without it a source-map upload fails with `internal server error` and a replay stores
an empty recording), and `symbolicator.enabled: true` (without it frames stay minified, with no error on the event).

**Keys.** Three projects, one client key each. Each key's rate limit is set on the server (the project's
*Client Keys* → *Rate Limits*); review the limits after the first pilot week. Error events are never sampled, so
the limit is the only volume control.

| Value | Project and key | Starting limit | Carries |
| --- | --- | --- | --- |
| `global.environments.sentry.dsn` | backend-main | 300/min | every backend error, tagged `layer` (gateway, services, workers) |
| `global.environments.sentry.moneyDsn` | backend-money | none | money incidents and lock bypasses only, so a storm that rate-limits the main key cannot drop one. Empty sends them on the main key, with a warning at boot |
| `frontend.environments.nuxt.public.sentry.dsn` | frontend | 300/min | browser errors and their masked replays. The key ships to every browser, so its limit is what bounds abuse |

**Environment and release.** `global.environments.sentry.environment` names the environment of both apps; empty, it
is `nodeEnv`. The frontend takes the same name unless `frontend.environments.nuxt.public.sentry.environment` sets its
own, so the browser's half and the backend's half of one trace sit under one filter. The backend's release is
`lnd-backend@<global.image.tag>`; the frontend's is baked into its image at build. Frames read against the source
only for a build whose source maps its release pipeline uploaded; otherwise they point into the bundle.

**Alert rules** (issue alerts):

- `money:true`, on backend-money — any event, immediately, to whoever settles money by hand. The event's `money`
  context names the order, invoice or track id and the code `site`. Each one also leaves a JSON line
  `"event":"money_incident"` on the pod's stderr, which is the record when the event itself is lost.
- `lock:bypassed`, on backend-money — immediately. The operations tick ran without its Redis lock, which is a risk on
  the money halves.
- `job:*`, on backend-main — on frequency. A sweep failing on one item sends one warning per hour, and an order a money
  sweep has failed on for longer than `global.environments.sentry.stuckAfterMinutes` (60) becomes one `money:true`
  incident a day, on backend-money.
- A new issue in a release — all three projects, to the developers.

**Server-side scrubbing** (*Security & Privacy*, all three projects): *Data Scrubber* on, *Use Default Scrubbers* on,
*Prevent Storing of IP Addresses* on, and *Additional Sensitive Fields*, **one per line**: `phone`, `mobile`, `otp`,
`sheba`, `card`, `national`. A comma-separated line is stored as one field that matches nothing. A field matches by
substring, so `code` would strip `status_code` from HTTP breadcrumbs. Both apps scrub before they send; these settings
are the second net.

**Replay.** The browser records only the sessions an error happens in (`replaysOnErrorSampleRate: 1.0`), with all
text and inputs masked and media blocked, and never on `/pay/*`, `/reset-password`, `/register/confirm` or `/oauth`.
Raise `replaysSessionSampleRate` above 0 only once the server has a retention period, deletes expired replay files
physically, and alerts on Kafka lag and disk.

**Upgrading from 1.0.13 or older:** `SENTRY_TRACES_SAMPLE_RATE` and `SERVICE_NAME` are no longer shipped; only the
reporter in images before Landau plan 127 read them. Run 1.0.14 with an image that carries plan 127's backend: an
older image under it traces every request if its DSN is set. Keep `global.environments.sentry.dsn` empty until such
an image runs — the old reporter sent request headers, `authorization` among them.
