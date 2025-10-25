## Getting Started

1. Clone the repository.
2. Place your Helm charts in the designated directory.
3. Update the Helm repository index using:

```sh
helm lint copd
helm lint phc
helm lint rsch

helm template copd
helm template phc
helm template rsch

helm package copd
helm package phc
helm package rsch

helm repo index .
```
