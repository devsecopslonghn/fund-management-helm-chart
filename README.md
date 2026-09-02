# Fund Management Helm Chart

This repository owns the deployable umbrella chart for the Fund Management
frontend and backend. Application source remains in
`devsecopslonghn/fund-management-frontend` and
`devsecopslonghn/fund-management-backend`.

Successful source workflows publish immutable GHCR images and update the
matching `frontend.image.tag` or `backend.image.tag` in this repository. Argo
CD tracks this chart at path `.` in the `fund-management` namespace.

The chart expects a namespace-local Docker registry Secret named `ghcr-pull`.
The Secret is created by cluster operations and is intentionally not committed
to Git.

## Local validation

```bash
helm lint .
helm template fund-management . --namespace fund-management
```
