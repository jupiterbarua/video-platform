# 0006 – GitOps delivery with Argo CD

- Status: Accepted
- Date: 2026-11-21

## Context

Services run on Kubernetes in three environments. Options: the CI pipeline deploys with
`helm upgrade`, or GitOps (Argo CD or Flux) where a controller in each cluster applies
what is in Git.

## Decision

- Argo CD runs in every cluster (dev k3s, staging EKS, prod EKS).
- A separate repository, `video-platform-gitops`, holds what runs where:
  `bootstrap/`, `platform/` (add-ons), `apps/` (ApplicationSet), `envs/dev|staging|prod/`.
- CI builds images and commits the new image tag to the GitOps repo. CI has no access to
  any Kubernetes API.
- Dev and staging update automatically; prod changes only through a reviewed pull request
  to `envs/prod/` (CODEOWNERS).
- Terraform installs only Argo CD and the root application; Argo CD installs everything
  else.
- Secrets are never in Git; External Secrets Operator reads AWS Secrets Manager.
- Database migrations run as Argo CD PreSync hooks.

## Consequences

- Every change to a cluster is reviewed and recorded; rollback is `git revert`.
- Manual changes in a cluster are undone automatically (self-heal).
- One more repository and tool to run; Argo CD itself must be kept up to date.
