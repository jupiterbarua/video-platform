# 0001 – Standard video format

- Status: Accepted
- Date: 2026-11-21

## Context

Question videos come from three sources: recruiter uploads, generated videos (Polly voice
+ slide) and later AI avatars. Candidate answers come from browsers: Chrome and Firefox
usually record WebM (VP8/VP9 + Opus), iPhone Safari records MP4 (H.264 + AAC). The final
merge (question 1 → answer 1 → question 2 → …) only works without re-encoding problems
when every part has the same codecs, resolution, frame rate and audio settings.

## Decision

Every video stored for playback or merging uses this format:

| Property | Value |
| --- | --- |
| Container | MP4, `faststart` (moov atom at the front, for streaming) |
| Video codec | H.264, High profile, level 4.0, `yuv420p` |
| Resolution | 1280×720, letterboxed or padded if the source has another aspect ratio |
| Frame rate | 30 fps, constant |
| Audio codec | AAC-LC |
| Audio | 48 kHz, stereo, 128 kbit/s |

- The question video generator writes this format directly (from M1).
- Uploaded question videos and candidate answers are transcoded to it (M3).
- The merge step concatenates parts that are already in this format.

## Consequences

- Merging is simple and predictable; a broken merge points to a broken transcode.
- Every source is re-encoded once, which costs CPU time on the media worker.
- 720p keeps files small; raising it later means re-encoding stored questions.
