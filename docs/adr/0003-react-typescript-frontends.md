# 0003 – React + TypeScript for both web apps

- Status: Accepted
- Date: 2026-11-21

## Context

There are two front ends: the recruiter app and the candidate app. The candidate app
records video with browser APIs (`getUserMedia`, `MediaRecorder`) and uploads in parts.
Options considered: React + TypeScript, SvelteKit, Leptos (Rust/WebAssembly).

## Decision

Both apps use React + TypeScript, built with Vite, served as static files from S3 through
CloudFront.

## Consequences

- Recording and upload use browser APIs directly, which is easiest from JavaScript.
- React is the most requested front-end skill in job ads.
- A second language in the repo; API types are generated from the OpenAPI specs to keep
  front end and back end in sync.
