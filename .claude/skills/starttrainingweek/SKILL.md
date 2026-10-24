---
name: starttrainingweek
description: Open a new training week. Loads the athlete profile, campaign summary, current phase template and the last few weeks, reconciles them against real training data, then briefs. Use when the user says /starttrainingweek, "start the week", "new training week", or asks where we left off.
---

# Start Training Week

Rebuild coaching context before touching the week. One session covers one training
week, Monday to Sunday.

## 1. Load the standing context

Read these in full, in this order:

```bash
cat athlete/profile.md
cat athlete/fuelling-protocol.md
ls campaigns/season-*.md                              # the season strategy (newest)
ls -d campaigns/*/ | grep -v -e archive -e upcoming   # find the active campaign
cat campaigns/<active>/summary.md
cat campaigns/<active>/plan.md
```

- **The season strategy** sets the goals, their priority, the checkpoints and the
  decision rules. **It wins where a campaign doc disagrees with it.** If there's more
  than one `season-*.md`, the newest is current.
- **Exactly one campaign should be active.** If there are none, the last one closed
  without the next being promoted. If there's more than one, a future campaign was put
  in the wrong place. Either way, flag it in the brief and stop; don't guess. Future
  campaigns live in `campaigns/upcoming/` (see its README).
- **The campaign summary names the current phase.** Read that phase document in
  `campaigns/<active>/phases/` too. It holds the **agreed day-of-week template and
  progression targets**. These are settled decisions, not a starting point for
  discussion.

## 2. Load the recent weeks

```bash
ls -d campaigns/<active>/weeks/week-*/ | sort | tail -4
```

Read each one's `plan.md` and `log.md`, oldest to newest, so later reversals overwrite
earlier decisions rather than the other way round. Four weeks is the default window;
`/endtrainingweek` rotates anything older into `weeks/archive/`.

**At the start of a campaign there will be fewer than four.** Top up the window from
the most recently archived campaign, so the brief sees across the boundary:

The previous campaign is the one listed before the active one in the season
strategy's structure table. For the first campaign of a season, it's the most recent
row in `campaigns/archive/README.md`. Don't infer it from file timestamps: git
checkouts reset them.

```bash
ls -d campaigns/archive/<previous>/weeks/week-*/ | sort | tail -<n>
```

Read that campaign's summary as well, especially its last campaign-history entry and
any end-of-block outputs its final phase doc lists. Those are what the new campaign
starts from.

If there are no week folders anywhere, say so plainly and work from the campaign
summary. That's the first week under the format, not an error. A week that started
mid-week (like a Week 00) is normal; read it like any other.

## 3. Reconcile against real data

The logs describe what was written down. The account describes what actually happened.

Call `get_training_context` for the week just completed. Compare it against the last
week's `log.md`:

- Sessions logged as done that don't appear in the data, or vice versa.
- Sessions completed materially longer, shorter, harder or easier than planned — check
  `athlete/profile.md` for known patterns (such as over-running easy sessions) and quantify them.
- Anything in the data the log doesn't mention at all.

Then check **Notion against `plan.md`** for this week (`CLAUDE.md` → "Writing to
Notion"; the IDs are in `config/notion.md`): query the Training Sessions rows for this week's Week label and compare them
by Session ID. Missing rows, extra rows, or a different date or main set mean the sync
was skipped or the athlete edited Notion directly. Don't fix it silently: name it in the
brief's Drift line and ask which version wins. Also flag if last week's changelog says
a Notion sync is outstanding.

Where a session's quality matters to this week's decisions, pull `get_activity_laps` or
`get_activity_streams` rather than trusting summary averages. Check
`athlete/profile.md` under "Data reliability" before treating HR or sleep figures as
sound.

## 4. Brief the athlete

Under 250 words. Synthesis, not recital — the athlete wrote these logs.

- **Trajectory** — one sentence naming the arc across the loaded weeks, not just the
  last one. What is the block actually doing, and is it working?
- **Last week** — what was completed against what was planned, with the gap named.
- **Live decisions** — standing decisions from the campaign summary that constrain this
  week, reasoning compressed to a clause each. Skip anything later overturned.
- **Open threads** — unchecked items from the campaign summary, most urgent first.
  Flag anything with a hard deadline explicitly. Also check:
  - **The season strategy's open decisions**, for any whose deadline falls within the
    next two weeks.
  - **The next upcoming campaign's summary** (`campaigns/upcoming/`, first in the
    README's order). If its phase docs are due to be written in this window, say so.
- **Checkpoints** — any race or time trial from the season strategy's checkpoint table
  that falls this week or next, with its "on track" figure and what happens if it's
  missed. Omit the line when there's none.
- **This week's plan** — it already exists (`/endtrainingweek` generated it last
  Sunday). Summarise it in a sentence and name anything in it that was written as
  conditional on this Monday's readiness markers.
- **Drift** — one line, always present, even when it's "none — logs match the data,
  Notion matches the plan".

## 5. Ask before proceeding

Do not start the next step. End the turn by asking whether to proceed with it or shift
focus. The brief is orientation, not a green light.

Typical first real action is locking any conditional sessions against Monday's morning
markers (RHR / HRV / sleep) and pushing the week's runs to the Garmin calendar — but
confirm, don't assume. Only runs and rides can be pushed; swims and gym sessions stay
in `plan.md`.

## 6. If you need more history

Older weeks are in `campaigns/<active>/weeks/archive/`. Completed campaigns are in
`campaigns/archive/`, and future ones in `campaigns/upcoming/`. Pull specific files only
when a question genuinely reaches back past the loaded window — don't preload them.
