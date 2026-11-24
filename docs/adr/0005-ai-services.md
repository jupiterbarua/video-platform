# 0005 – AI services: Bedrock, Polly, Transcribe

- Status: Accepted
- Date: 2026-11-21

## Context

The platform needs three AI capabilities: generating interview questions from a job
description in any language, turning question text into a video, and transcribing
candidate answers. Candidate data is personal data under GDPR.

## Decision

| Need | Service | When |
| --- | --- | --- |
| Questions from a job description | Claude on Amazon Bedrock, eu-central-1 | M1 |
| Question text → video | Amazon Polly voice + generated slide, combined with ffmpeg | M1 |
| Speech to text | Amazon Transcribe, German and English, language auto-detected | M3 |
| AI avatar videos | HeyGen API, as a premium option | After M4 |

- The LLM returns structured output per question: text, type, answer time, and what a
  good answer should cover (later used for AI scoring).
- Recruiters always review and approve generated questions before use (human oversight).
- Video providers sit behind one internal "text to video" interface.
- Each company has a monthly AI usage limit.

## Consequences

- Data stays in AWS and in the EU for the core features; billing goes through AWS.
- Polly gives no human face; avatars come later at extra cost.
- whisper.cpp can replace Transcribe later to cut cost.
