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

The shipped defaults are safe rather than complete — a bare install runs against the ZarinPal
**sandbox** and takes no real money. A production deployment names at least:

| Value | Why |
| --- | --- |
| `global.environments.zarinpal.{url,redirectUrl,merchantId}` | All three together, or payments fail with `424`. The sandbox default is deliberate. |
| `global.environments.nats.{user,pass}` | No credential ships in this chart. |
| `global.environments.mongo.pass`, `global.environments.redis.password` | Datastore credentials. |
| `global.secrets.vapid.privateKey` + `global.environments.vapid.publicKey` | Both halves or neither; unset keeps the backend's committed dev pair. |
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
