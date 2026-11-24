# 0004 – Amazon Cognito for recruiter authentication

- Status: Accepted
- Date: 2026-11-21

## Context

Recruiters need sign-up, login, password reset and later MFA and SSO. Candidates do not
have accounts; they use a single-use invite link. Options: build own auth, Amazon
Cognito, Keycloak.

## Decision

- Recruiters authenticate with an Amazon Cognito user pool (one per environment).
- Services verify Cognito JWTs with a shared middleware and read `company_id` and role.
- Sign-up is invite-only at first (an invite code checked by a pre-sign-up Lambda or by
  the core API).
- Candidates use random invite tokens (32+ bytes, stored hashed), checked only by the
  candidate session service.

## Consequences

- No password storage or reset flows to build and secure.
- Some lock-in to Cognito; the services only depend on standard JWTs, so a later move is
  possible.
