# Completed campaigns

| Campaign | Race | Result | Archived |
|---|---|---|---|

When a campaign finishes, move its whole folder in here:

```bash
git mv campaigns/<finished> campaigns/archive/
```

Nothing is rewritten or trimmed on the way in — the phases, the week logs and the
campaign summary stay exactly as they were, so the reasoning behind a past block is
still readable years later.

What does **not** move is `athlete/`. Thresholds, injury history, equipment
constraints and the validated fuelling protocol carry forward to the next campaign;
that is the point of keeping them outside this folder.
