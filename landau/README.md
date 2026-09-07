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
upgrade thereafter — see `templates/secret.yaml` for the two deployment-method constraints that come
with that (a `helm template`-and-apply tool such as Argo CD needs the Secret managed out of band).
