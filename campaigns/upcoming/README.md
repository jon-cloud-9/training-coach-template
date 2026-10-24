# Upcoming campaigns

Future campaigns in the current season, written in outline. The order and dates come
from the season strategy in `campaigns/season-YYYY-YY.md`.

| Campaign | Dates | Promoted when |
|---|---|---|

**Only one campaign sits directly under `campaigns/` at a time.** `rotate.sh` and
`/starttrainingweek` both treat that one as active.

**When a campaign closes**, `/endtrainingweek` runs:

```bash
git mv campaigns/<finished> campaigns/archive/
git mv campaigns/upcoming/<next> campaigns/
```

**Detailed phase docs are written later.** Each upcoming campaign has a summary and a
block outline. The day-by-day phase docs get written in the last two weeks of the
previous campaign, once the checkpoint results they depend on are known.
