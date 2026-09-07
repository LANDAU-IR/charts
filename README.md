This repository hosts the Helm chart that deploys Landau to Kubernetes clusters.

## Getting Started

1. Clone the repository.
2. Place your Helm charts in the designated directory.
3. Update the Helm repository index using:

```sh
helm lint landau

helm template landau

helm package landau && helm repo index .
```

Run `helm repo index` **without** `--url` — that is what yields the relative urls the existing
entries carry, and it rewrites every entry's `created` stamp. A chart edit is a `Chart.yaml`
version bump, a repackage and a re-index, committing the new `landau-<version>.tgz` alongside.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or improvements.
