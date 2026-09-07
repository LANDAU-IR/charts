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

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or improvements.
