# Runtime identity and image contract

Backend, frontend and optional backup jobs each have a dedicated ServiceAccount,
no RBAC grants, and disabled automatic API token mounting. Existing non-root,
read-only filesystem settings remain enabled. The two-replica backend keeps its
PDB and preferred anti-affinity; single-replica frontend has no misleading PDB.

Production tags are `commit@sha256:digest`, preserving the verified running images.
Release automation must update the full value with the newly built digest.
MongoDB native backup remains disabled pending verification of backup privileges,
capacity, and an isolated restore; Longhorn backup does not cover the external DB.
