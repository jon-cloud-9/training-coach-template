---
name: endtrainingweek
description: Close the training week. Writes the week's log, updates the campaign summary, generates next week's plan from the phase template, syncs it to the Notion Training Sessions database, rotates old weeks, and commits. Use when the user says /endtrainingweek, "end the week", "close the week", or asks to wrap up and plan the next one.
---

# End Training Week

Close the week and generate the next one. This runs on a Sunday: the week just ended
gets its record, and next week's plan comes out of it.

## 1. Reconstruct the week from data, not memory

Call `get_training_context` for the full Monday–Sunday range. Do this **before**
writing anything — the conversation records what was discussed, the account records
what was done, and they diverge.

For any session whose quality bears on next week's plan, pull `get_activity_laps` or
`get_activity_streams`. Summary averages hide the thing that matters: output falling
while HR holds flat is fatigue; output falling with HR is pacing or terrain. Check
`athlete/profile.md` under "Data reliability" first — HR strap dropout and bad sleep
recording can both drive wrong decisions.

## 2. Write the week's log

Path: `campaigns/<active>/weeks/week-NN-YYYY-MM-DD/log.md`, in the folder whose
`plan.md` this week ran against. `NN` is the plan week number; the date is that week's
Monday.

```markdown
# Week NN — <Mon DD> to <Sun DD> · <short theme>

## How it went
Two or three sentences. The honest read, not a scoreboard.

## Sessions — planned vs actual

| Day | Planned | Actual | Read |
|---|---|---|---|
| Mon | Easy run, 60 min | 68 min, HR in range | On target, ran long as usual |
| Tue | — | — | — |

One row per planned session, plus rows for anything done that wasn't planned. "Read" is
the coaching interpretation, not a repeat of the numbers.

## What this changes
Concrete consequences for next week. If nothing changes, say so — don't invent.

## Decisions
### <The decision, stated plainly>
**Why:** the constraint or tradeoff that drove it.
**Revisit if:** the condition that would reopen it.

(Only decisions that closed off an alternative. "None this week" is a valid answer.)

## Flags
- Anything that would cost time or risk to rediscover: a data artefact, a niggle, a
  kit problem, a pattern showing up across sessions.
```

Length follows the week. A quiet week gets a short log; padding it is worse than
leaving it thin. Write what happened — never aspirations, never invented decisions.

## 3. Update the campaign summary

`campaigns/<active>/summary.md` is what lets an archived week stay archived. Update:

- **Campaign history** — one entry for the week just closed, two or three lines.
- **Open threads** — tick off what closed, add what opened, and re-state deadlines that
  moved closer. Anything with a hard date gets it written out.
- **Standing decisions** — add any decision from this week that constrains future
  weeks. Amend or strike any this week overturned; don't leave a superseded decision
  standing.
- **Status line** — advance the week number and phase.
- If a threshold was re-tested, equipment changed, or a durable behavioural pattern was
  established, that belongs in `athlete/profile.md` instead. Campaign summary is
  race-specific; the profile survives the campaign.
- **If the week held a checkpoint from the season strategy** (`campaigns/season-*.md`,
  checkpoint table), add a dated line to its Amendments section with the result and
  what the decision rule now says.

## 3b. If this was the campaign's last week, close it and promote the next

Skip this step in any other week. The campaign's last week is its final row in the
season strategy's structure table.

Do it **before** generating next week's plan, so that plan is written into the new
campaign, and in this order:

```bash
git mv campaigns/<finished> campaigns/archive/
bash .claude/skills/endtrainingweek/rotate.sh campaigns/archive/<finished>   # final INDEX, including this week
git mv campaigns/upcoming/<next> campaigns/
```

Then:
- **Finished campaign:** set its summary's status line to complete, with the result.
  Add a row to the table in `campaigns/archive/README.md`.
- **`campaigns/upcoming/README.md`:** remove the promoted campaign's row.
- **Promoted campaign:** set its summary's status line to active and fill in the open
  threads marked "at promotion" (paces, travel windows, targets) from the finished
  campaign's results.
- **Phase doc:** if the promoted campaign's first phase doc doesn't exist yet, write
  it now, from its `plan.md` outline and the results just recorded. Week numbering
  restarts at 01.

## 4. Generate next week's plan

Path: `campaigns/<active>/weeks/week-NN+1-YYYY-MM-DD/plan.md`.

**Start from the phase template, not a blank page.** The phase document holds the
agreed day-of-week assignments and the progression targets (long-run ladder, ride
duration, S&C split). Those are settled. Your job is to instantiate them against what
actually happened this week — not to redesign the week.

Adjust for:

- **Sessions missed or cut.** Don't silently restore the ladder as if the week was
  clean. A missed long run means the next step down the ladder may be too big.
- **Execution quality.** Several brick runs running hot is a signal; so is a
  long run held perfectly at target.
- **Recovery markers** — RHR, HRV, Form entering the week.
- **Fixtures** — anything already committed (a club session, a race, travel, a test
  with a hard deadline).

Where a session depends on Monday's morning markers, **write both branches into the
plan** rather than leaving it vague — "if HRV is at or above your usual range, X; if below, Y".

Follow `CLAUDE.md` → "Formatting the weekly plan": one header per activity, S&C always
its own header, headers not numbered lists, full warm-up / main-set / cool-down detail.

**Give every session a Session ID** in a comment on its header, as described in
`CLAUDE.md` → "Writing to Notion": `### Run — Tempo (45 min) <!-- id: w05-run-tempo -->`.
The ID never includes the day.

End the file with a `## Changelog` section — mid-week edits get a dated line each.

## 5. Sync to Notion and present the plan

Follow `CLAUDE.md` → "Writing to Notion" (IDs are in `config/notion.md`). This runs under the athlete's standing
permission; don't ask first.

1. **Close last week's rows.** Set each one's Status from the step 1 reconciliation:
   Done, Changed (done differently) or Missed. Fill **Actual** with one line from the
   data (e.g. "52 min, 9.1km, HR in range"). Leave any Status the athlete set by hand.
2. **Write next week's rows.** Add the new Week option (and Campaign or Block options
   when one starts), then one row per session in
   the new `plan.md`, matched by Session ID. If rows for that week already exist (the
   skill was re-run), update them rather than adding duplicates.
3. **Update the Dashboard.** Rewrite the heading under "Training Programme"
   (campaign and block, then week number and dates; nothing else) and move the "This
   week" view filter to the new Week label.

Then show the week in chat as a rendered table, so it's readable at a glance:

| Day | Session | Main set | Target | Fuelling |
|---|---|---|---|---|

One row per session. Where a day has two sessions, give it two rows. Keep cells short —
the detail lives in `plan.md`; this is the overview. Link the Notion Dashboard under it.

**If Notion is unavailable or a write fails**, say so plainly and give the same table in
a fenced code block instead, so it can be pasted by hand. Note in the week's changelog
that the Notion sync is outstanding, so the next session picks it up.

## 6. Rotate

```bash
bash .claude/skills/endtrainingweek/rotate.sh
```

Keeps the 4 most recent week folders in `weeks/` of the active campaign, moves older
ones to `weeks/archive/`, and regenerates `weeks/INDEX.md` listing both sets. Nothing is
deleted. After a promotion (step 3b), this runs on the newly promoted campaign.

If it reports more than one active campaign, or none, stop and fix the layout before
committing. Exactly one campaign sits directly under `campaigns/`; future ones live in
`campaigns/upcoming/`.

## 7. Commit and push

This repo commits **directly to `main`** — no branch, no PR. Do this without asking;
it's documentation and it's the point of automating the close.

```bash
git add athlete/ campaigns/
git status --short                    # confirm nothing unexpected is staged
git commit -m "Week NN: <short theme>; plan Week NN+1"
if git remote get-url origin >/dev/null 2>&1; then git push origin main; fi   # only if a remote is configured
```

If the push is rejected, the remote has moved — `git pull --ff-only origin main` and
push again. If that still fails, stop and surface it. Never force-push.

## 8. Report back

- File paths written, the commit SHA, and whether it was pushed (a local-only repo has no remote).
- Notion: rows written and statuses set, or that the sync failed and is outstanding.
- Two or three lines on the week.
- What changed in next week's plan **and why** — this is the part the athlete will actually read.
- Anything still unresolved, especially open threads with a hard deadline.

Then stop. Don't roll into planning the week after next.
