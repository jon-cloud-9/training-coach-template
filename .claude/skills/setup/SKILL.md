---
name: setup
description: Guided first-run setup for the training coach. Finishes installing the template, connects intervals.icu (Garmin) and Notion, interviews the athlete, writes their profile, season and first campaign, plans week 1, and sets up the phone. Resumable. Use when the user says /setup, "continue setup", "set up my training coach", or when the START-HERE starter message says to follow this file from step s04.
---

<!--
STARTER MESSAGE (START-HERE.md copies this text verbatim; keep the two in step).
The user pastes it into a new Code tab session opened on an empty "My Training" folder:

Please set up my training coach in this folder. Use curl -L to download https://github.com/jon-cloud-9/training-coach-template/archive/refs/heads/main.zip into this folder, unzip it, and move everything inside the training-coach-template-main folder into this folder, including the hidden files whose names start with a dot. Then delete the zip file and the empty training-coach-template-main folder. After that, read .claude/skills/setup/SKILL.md and follow it from step s04. I'm not technical, so explain each step in plain language before you do it.

Why it reads like this: the skill can't run until the template is in the folder, and a
skill downloaded mid-session may not be registered as /setup until the next session.
So the starter message does the download, and s04 below verifies it and finishes.
-->

# Setup

You are walking someone through setting up their own training coach. They are probably
not technical. Setup has 17 steps; steps 1–3 happened before Claude (signing up,
installing the app, pasting the starter message). This skill covers steps 4–17, with
IDs `s04` to `s17`. Progress is saved after each step, so it can stop and resume at any
point.

## How to run this skill

### At the start of every run

1. Run `bash scripts/setup-state.sh next`. It prints the first unfinished step
   (`s04`…`s17`) or `done`.
   - If the script doesn't exist, the template isn't in this folder yet: do the
     download from the starter message at the top of this file first, then start at s04.
   - If it prints `done`, tell the user setup is already complete, offer to re-check
     the connections (the two checks below), and stop.
2. **Re-check the steps that can break**, before going further:
   - **If s06 is done:** if s07 is also done, call `get_training_context` with
     `startDate` and `endDate` both set to today. If s07 isn't done yet, re-run s06's
     check command instead. If it fails, tell the user plainly ("I can't reach your
     Garmin data right now, so let's fix that first") and redo s06, then s07's check
     if the error says the key is missing or empty.
   - **If s09 is done:** run a Notion search (the Notion `search` tool, query
     `Training`). If it fails or the Notion tools are missing, say so plainly ("Your
     Notion connection has dropped, so let's reconnect it") and redo s09.
3. Jump to the step `next` printed. When resuming, greet them with where they are:
   "Welcome back. We're on step <N> of 17: <step title>."

### Rules for every step

- **One step at a time.** Do the step's **Tell the user** first, then **Do**, then
  **Check**. Only when the check passes, run `bash scripts/setup-state.sh mark sNN`
  and move on. If the check fails, follow **If it fails**; never mark a failed step.
- **Before any command runs, say what it does and what they'll see.** Claude's app
  shows a permission box before running a command or changing a file. The first time,
  explain it: "You'll see a box asking whether I can run this. Click Allow. If it
  offers 'Allow for this session' or 'Always allow', that's fine too and saves you
  clicks."
- **Plain, warm and short.** Define a term the first time it comes up. The words in
  "Tell the user" blocks are a script to adapt, not to read out stiffly; fill in the
  `<angle brackets>`. Never use these words with the user: npm, MCP, repo, env. Say
  "the bridge", "connector", "settings file", "backup" instead.
- **Terms to define the first time:**
  - **git:** a free tool that keeps a dated history of every change to your training
    notes, so nothing is lost and anything can be undone.
  - **Node:** a free program from nodejs.org that the bridge needs to run.
  - **the bridge:** a small helper that lets me read your Garmin data through
    intervals.icu, and put planned runs and rides on your watch.
  - **intervals.icu:** a free training website that collects your workouts from
    Garmin.
  - **API key:** a long password-like code that lets the bridge read your
    intervals.icu account.
  - **connector:** a link, set up in Claude's settings, that lets me read and write
    another app, such as Notion.
- **The API key never goes into the chat** (s07). Never ask for it, and never read,
  `cat` or print `config/intervals.env`. The only thing you do with it is open it in
  TextEdit for the user, in s07.
- **Before any commit**, run `git check-ignore -q config/intervals.env`. If it fails,
  stop: the key file must never be committed. Commit with `git add -A` only after that
  check passes.
- **If they want to stop:** "No problem. Your progress is saved. Just say 'continue
  setup' or run /setup any time, and I'll pick up right here."
- **If they want to skip a step:** explain what it's for and what won't work without
  it. Only s15, s16 and the backup in s17 can be skipped; mark those done when the user
  chooses to skip. Every other step is needed by the weekly routine.

---

## s04 — Finish the download and start the history

**Tell the user:**
> First I'll check the coaching files all arrived in your folder. You'll see a box
> asking whether I can run a command: click Allow.

Only after Do steps 1 and 2 pass:
> The coaching files are all in your folder. Next I'll switch on git, a free tool that
> keeps a dated history of every change to your training notes, so nothing is ever
> lost and anything can be undone.
>
> A quick question first: what name should I put on your training notes? Your first
> name is fine.

After they answer:
> Thanks, <name>. I'm about to run a few commands to start the history. You'll see a
> box asking whether I can run them: click Allow.

**Do:**
1. Check the folder's location: `pwd`. If the path contains `/Desktop/`,
   `/Documents/` or `Mobile Documents`, stop here and see "If it fails". Otherwise carry on.
2. Confirm the template arrived: `ls CLAUDE.md .mcp.json scripts/setup-state.sh`.
   Also confirm the hidden folder came across: `ls .claude/skills/setup/SKILL.md`.
3. Check git works: `git --version`. On a fresh Mac this can open Apple's "command
   line developer tools" window instead (see If it fails).
4. If the folder isn't already a git history (`git rev-parse --git-dir` fails):
   ```bash
   git init -b main
   git config user.name "<Name>"
   git config user.email "<name>@users.noreply.local"   # <name>: lowercase, letters only
   ```
   These settings are local to this folder.
5. Commit:
   ```bash
   git check-ignore -q config/intervals.env && git add -A && git commit -m "Start my training coach"
   ```
6. Remember what the shared files look like right now, so a later update can tell
   which ones the user has edited: `bash scripts/update-shared.sh --record-checksums`.
   Tell the user: "I've noted the starting state of the coaching files, so a future
   update never overwrites changes you've made."

**Check:** the three files exist, `git log --oneline -1` shows the commit, and
`config/.template-checksums` exists.

**If it fails:**
- **The folder is in Desktop, Documents or iCloud:** tell the user:
  > Your "My Training" folder is somewhere Apple may copy to iCloud (Desktop or
  > Documents do this on many Macs). iCloud can create duplicate files with "2" at the
  > end of their names and break your coaching files. Let's move the folder to your
  > home folder, the one with your name on it under Locations in Finder. In Finder, drag
  > "My Training" from here into that home folder. Then quit Claude (Cmd-Q), reopen it,
  > go to the **Code** tab, start a new session, choose the moved folder, and say
  > "continue setup".

  Don't continue in the old location.
- **Files missing:** the download or the move didn't finish. Redo the starter
  message's download (curl, unzip, move everything including dotfiles, delete the zip
  and the empty folder), then run this step again. Tell the user: "Some files didn't
  come across, so I'm going to download them again. Nothing you need to do."
- **A window pops up saying git needs the command line developer tools:** tell the
  user:
  > A window from Apple has popped up asking to install "command line developer
  > tools". That's a free Apple package that includes git. Click **Install**, then
  > **Agree** to Apple's licence. It takes about 5–10 minutes. Tell me when the window
  > says the software was installed, and I'll carry on.

  Then run `git --version` again. If they clicked "Get Xcode" by mistake, ask them to
  close the App Store and say so; re-running `git --version` brings the window back.
- **Commit fails because the name isn't set:** redo the two `git config` lines.

---

## s05 — Install Node if it's missing

**Tell the user:**
> Next I'll check for Node, a free program from nodejs.org that the bridge needs to
> run. (The bridge is a small helper that lets me read your Garmin data and put
> planned runs and rides on your watch.) I'm running one quick command to see if
> it's already installed; click Allow when asked.

If Node is missing or too old:
> You don't have Node yet (or it's an older version), so I'll download the official
> installer from nodejs.org into your Downloads folder. It's about <size> MB. Is that
> OK?

After they say yes and it downloads:
> I've opened the installer. Click **Continue** on each screen, **Agree** to the
> licence, then **Install**. Your Mac will ask for your Mac password (or Touch ID):
> that's the password you use to log in to this Mac, and it's normal for installing
> software. When it says the installation was successful, click **Close**. If it asks
> whether to move the installer to the Bin, either answer is fine. Tell me when it's
> done.

**Do:**
1. `node -v` (prints e.g. `v22.11.0`). It must be version 20 or higher.
2. If missing or below 20, find and size the current Node 22 installer, ask before
   downloading (see Tell the user), then download and open it:
   ```bash
   PKG=$(curl -s https://nodejs.org/dist/latest-v22.x/ | grep -o 'node-v22[^"]*\.pkg' | head -1)
   VER=${PKG#node-}; VER=${VER%.pkg}
   curl -sIL "https://nodejs.org/dist/$VER/$PKG" | grep -i '^content-length'   # size, for the question
   curl -L -o ~/Downloads/"$PKG" "https://nodejs.org/dist/$VER/$PKG"
   open ~/Downloads/"$PKG"
   ```
3. After they say the installer finished, run `node -v` again (if it isn't found, try
   `/usr/local/bin/node -v`).

**Check:** `node -v` prints `v20` or higher.

**If it fails:**
- **`PKG` comes back empty:** nodejs.org's listing changed. Open
  https://nodejs.org/en/download in their browser (`open https://nodejs.org/en/download`)
  and tell them: "Click the button for the macOS Installer (.pkg), then open it from
  your Downloads folder and click through as before."
- **Installed, but `node -v` still isn't found:** this session started before Node
  was installed, so it can't see it yet. Tell the user:
  > Node is installed, but this chat started before it was there, so I need a fresh
  > start to see it. Please quit Claude completely (Claude menu → Quit, or press
  > Cmd-Q), open it again, go to the **Code** tab, and open your "My Training" session
  > from the list on the left (or start a new one in the My Training folder). Then
  > just say "continue setup" and I'll pick up right here.
- **The installer says it can't be opened or failed:** ask them to describe or
  screenshot the message. Retry the download once; if it fails again, use the
  nodejs.org download page as above.

---

## s06 — Fetch the bridge

**Tell the user:**
> Now I'll fetch the bridge, the small helper that connects me to your Garmin data
> through intervals.icu. This is automatic. The first time can take up to a minute.
> You'll see one more box asking to run a command: click Allow. It will finish with a
> message saying it can't find your settings file yet. That's expected: we create that
> file in the next step.

**Do:** run the bridge once against a settings file that deliberately doesn't exist, so
it downloads, starts, and exits straight away with its "can't find the file" message.
This works whether or not `config/intervals.env` exists yet, and never touches it.
```bash
npx -y intervals-training-bridge@^0.2 --stdio --settings-file config/.setup-check-missing.env </dev/null 2>&1 | tail -3
```

**Check:** the output contains `Could not find your intervals.icu settings file`. That
proves the bridge was downloaded and runs. The full connection test is s08.

**If it fails:**
- **`npx: command not found`:** Node isn't visible to this session. Give the restart
  instructions from s05 ("Installed, but `node -v` still isn't found"), or redo s05 if
  `node -v` also fails.
- **A network error (it mentions `ENOTFOUND`, `ETIMEDOUT` or "network"):** tell the
  user: "I couldn't reach the internet to fetch the bridge. Can you check your Wi-Fi is
  on and working? Then I'll try again." Retry.
- **Anything else:** retry once. If it fails again, show the last few lines in plain
  words and offer to try again later ("say 'continue setup' when you're ready").

---

## s07 — Connect intervals.icu and save your key

**Tell the user:**
> Now we'll connect your Garmin. I read your training through intervals.icu, a free
> training website that collects your workouts from Garmin and can send planned
> workouts back to your watch. Three things to do in your web browser:
>
> 1. **Create an account** at https://intervals.icu (it's free).
> 2. **Link Garmin.** In intervals.icu, open **Settings**, find **Connections**, and
>    click **Garmin Connect**. Sign in to Garmin and allow access. If it offers
>    options to download your activities and to upload planned workouts, turn both on.
>    Your past workouts can take a little while to appear; that's normal.
> 3. **Copy your API key.** Still in **Settings**, scroll down to **Developer
>    Settings** and copy the **API key**. An API key is a long password-like code that
>    lets the bridge read your intervals.icu account.
>
> **Please don't paste the key here in the chat.** Instead, I'll open a small private
> settings file for you in TextEdit. It lives only on this Mac and is never included
> in your backups or history. Tell me when you've copied the key.

When they've copied it:
> I'm opening TextEdit now (click Allow when asked). You'll see one line of text:
> `INTERVALS_API_KEY=`
> Click just after the `=` sign, paste your key (Cmd-V) with no spaces, then save
> (Cmd-S) and close the window. Tell me when it's saved.

**Do:**
1. Create the file only if it doesn't already hold a key, and confirm it's excluded
   from the history:
   ```bash
   mkdir -p config
   grep -q '^INTERVALS_API_KEY=[[:space:]]*[^[:space:]]' config/intervals.env 2>/dev/null || printf 'INTERVALS_API_KEY=' > config/intervals.env
   git check-ignore -q config/intervals.env && echo "excluded from history"
   open -a TextEdit config/intervals.env
   ```
2. After they say it's saved, run the check below. **Never read, `cat`, print or open
   the file yourself**, and never ask for the key.
3. When the check passes, mark the step, then ask for a restart so the bridge starts
   with the key:
   > Your key is saved. I need a fresh start so the bridge can read it. Please quit
   > Claude completely (Claude menu → Quit, or Cmd-Q), open it again, go to the
   > **Code** tab, and open your "My Training" session from the list on the left. When
   > it opens, you may be asked whether to use "intervals", found in this folder:
   > that's the bridge, so choose to allow it. Then say "continue setup".

**Check:** `grep -c '^INTERVALS_API_KEY=[[:space:]]*[^[:space:]]' config/intervals.env`
prints `1`. This counts the line without printing the key, and a key of only spaces
doesn't count.

**If it fails:**
- **The count is 0:** the file wasn't saved, or the key went onto a new line. Run
  `open -a TextEdit config/intervals.env` again and tell them: "It looks like the key
  didn't save. In TextEdit, make sure the key is on the same line, straight after the
  `=` sign, then press Cmd-S." Don't read the file to diagnose it.
- **They paste the key into the chat anyway:** don't use it and don't repeat it.
  > No harm done, but a key that's been shown in a chat shouldn't be kept. In
  > intervals.icu, go back to Settings → Developer Settings and generate a new key.
  > Then put the new one in the TextEdit file instead. Never reuse the one you pasted
  > here.

  Then reopen TextEdit as above.
- **`check-ignore` fails:** the history exclusion is missing. Add `config/intervals.env`
  to `.gitignore` before going further, and don't commit until it's fixed.

---

## s08 — Test the connection

**Tell the user:**
> Let's see if it works. I'm going to read your last 90 days of training from
> intervals.icu. Nothing gets changed.

**Do:** call `get_training_context` with `startDate` 90 days ago and `endDate` today
(yyyy-MM-dd). Count the completed activities and find the most recent one.

**Check:** the call succeeds. Report it in one friendly sentence, e.g. "It works! I
can see 143 activities from the last 90 days. The most recent is a 10km run on
Tuesday."

**If it fails:**
- **The bridge's tools aren't available at all:** the session wasn't restarted, or the
  "intervals" server wasn't allowed. Give the restart instructions from s07 again.
- **An error saying the settings file can't be found, or the key is empty:** show the
  bridge's message in plain words ("The bridge says your key is empty") and go back to
  s07.
- **An error saying access was denied (401 or 403):** the key is wrong or was
  regenerated. Go back to s07 and ask them to copy the key again.
- **It works but finds 0 activities:** Garmin may still be sending history to
  intervals.icu. Ask them to check their workouts appear on intervals.icu's calendar.
  If they do, try again; if the account is genuinely new, that's fine: say so, and
  mark the step done.

---

## s09 — Connect Notion

**Tell the user:**
> Next, Notion. Each week I'll put your plan in Notion, so you can see it on your
> phone or computer at a glance. Do you already have a Notion account?

If yes (the usual case):
> Great, we'll use that one. Nothing will be created in Notion until the next step.
> To connect it:
> 1. Open Claude's **Settings** (Claude menu → Settings, or Cmd-comma).
> 2. Go to **Connectors**, find **Notion**, and click **Connect**. A connector is a
>    link that lets me read and write another app.
> 3. Sign in to Notion if asked, and click to **allow access**.
>
> Tell me when it says Notion is connected.

If no:
> No problem. Go to https://www.notion.so and sign up for a free account (the free
> plan is all you need). Tell me when you're in, and I'll talk you through connecting
> it.

Then give the "If yes" connection steps.

Once Notion is connected, ask: "Do you pay for Strava?" Only if they say yes, add:
> Optional: since you have Strava, you can connect it the same way (Settings →
> Connectors → Strava). It isn't needed: your Garmin data already comes through
> intervals.icu, so skip it if you like.

**Do:** once they say it's connected, run a Notion search (query `Training`).

**Check:** the search call returns without an error (it can return no results).

**If it fails:**
- **No Notion tools are available:** this session may have started before the
  connection. Check the connectors menu next to the message box (if there is one) and
  make sure Notion is switched on for this session. If that doesn't help, give the
  restart instructions from s05 and resume.
- **An access error:** ask them to go back to Settings → Connectors → Notion and
  reconnect, making sure to click allow.

---

## s10 — Create your Notion training section

**Tell the user:**
> Now I'll build your training section in Notion: a table of every session
> (I'll call it Training Sessions) and a "This week" view that shows just the current
> week. Where would you like it?
> - On a page you already use, such as a dashboard: tell me its name.
> - Or on a new page called "Training" (that's the default, if you're not sure).
>
> Either way, the table itself lives on its own new page called "Training". If you
> pick an existing page, that page just gets a weekly section added at the bottom,
> showing this week's sessions. I won't change anything that's already on it.
>
> While I set this up, Notion may ask you to allow each change. It's fine to allow
> them.

Then ask for the standing permission the weekly routine relies on:
> One more thing. Each week I'll update your sessions in Notion: adding next week's,
> marking last week's done or missed, and moving the "This week" view on. Is it OK for
> me to do that without asking each time? I'll never touch anything else in Notion
> without asking. (Putting workouts on your watch will still always need your yes.)

If they say no:
> That's fine. I'll ask you each time before I update Notion, usually once a week
> when we plan the next week.

**Do:**
1. **Training page.** Create a page titled "Training" with the Notion create-pages tool
   (a private page in their workspace). The database always lives here.
2. **Database.** Use the Notion create-database tool with `parent` = the Training page,
   title `Training Sessions`, and exactly this `schema`:
   ```
   CREATE TABLE ("Session" TITLE, "Date" DATE, "Day" FORMULA('formatDate(prop("Date"), "ddd")'), "Order" NUMBER, "Type" SELECT('Run':blue, 'Bike':orange, 'Swim':purple, 'Gym':brown, 'Race':red, 'Rest':gray), "Intensity" SELECT('Easy':green, 'Threshold':yellow, 'Interval':orange, 'Long':blue, 'Race':red, 'Strength':brown, 'Rest':gray), "Warm-up" RICH_TEXT, "Main set" RICH_TEXT, "Cool-down and recovery" RICH_TEXT, "Target" RICH_TEXT, "Fuelling" RICH_TEXT, "Status" SELECT('Planned':gray, 'Done':green, 'Changed':yellow, 'Missed':red, 'Dropped':brown), "Actual" RICH_TEXT, "Last change" RICH_TEXT, "Week" SELECT(), "Campaign" SELECT(), "Block" SELECT(), "Garmin event" RICH_TEXT, "Session ID" RICH_TEXT)
   ```
   If the empty `SELECT()` lists are rejected, seed one placeholder option in each
   (`SELECT('Setup':gray)` for Week, Campaign and Block) and note it: s14 removes the
   placeholders once the real options exist. Keep the `<data-source>` ID the result
   returns.
3. **Dashboard page.** The page holding the section is the one they chose, or the
   Training page if they took the default. Append (Notion update-page tool,
   `insert_content` at the end, never `replace_content`):
   ```
   ## Training Programme
   ### Setting up
   Your first week appears here at the end of setup.
   ```
   `/endtrainingweek` later rewrites the `###` heading and the line under it, and
   nothing else.
4. **"This week" view.** Notion create-view tool with `parent_page_id` = the dashboard
   page (it appends an inline linked view under the heading), `data_source_id` from
   step 2, `type` `table`, `name` `This week`, and:
   ```
   GROUP BY "Week"; SORT BY "Date" ASC, "Order" ASC; SHOW "Day", "Session", "Warm-up", "Main set", "Cool-down and recovery", "Target", "Fuelling", "Status"; HIDE "Date"; WRAP CELLS true
   ```
   The `Week` filter is added in s14, once week 1's label exists. If `HIDE` or
   `WRAP CELLS` is rejected on create, create without them and apply them with the
   update-view tool.
5. **"All weeks" view.** Notion create-view tool with `database_id` = the database
   (a tab on the database), `type` `table`, `name` `All weeks`, and:
   ```
   GROUP BY "Week"; SORT BY "Date" DESC, "Order" ASC; SHOW "Day", "Session", "Type", "Main set", "Target", "Status", "Actual", "Last change", "Block"; HIDE "Date"
   ```
6. **Write `config/notion.md`** (fetch the database if a view ID wasn't returned):
   ```markdown
   # Notion IDs

   Written by /setup. Read by CLAUDE.md → "Writing to Notion" before any Notion write.

   | Key | Value |
   |---|---|
   | dashboard_page | <page URL or ID holding the Training Programme section> |
   | database | <Training Sessions database URL or ID> |
   | data_source | <collection://… data source ID> |
   | this_week_view | <view://… ID of the "This week" view> |
   | standing_permission | <yes or no: their answer to the weekly-updates question> |
   ```
   `CLAUDE.md` → "Writing to Notion" reads `standing_permission` before every Notion
   write: `yes` means go ahead; `no` or missing means ask first.
   Record in the file whether placeholder select options need removing in s14.

**Check:** `config/notion.md` has all five values filled in, and fetching the dashboard
page shows the "Training Programme" heading and the "This week" view.

Tell the user, with a link to the page:
> Done. Your training section is in Notion. It's empty for now; week 1 lands there
> near the end of setup.

**If it fails:**
- **Creating the database fails:** read the error. An "empty select" error means use
  the placeholder options above. A permissions error means go back to s09 and
  reconnect Notion with access allowed. Never delete anything you didn't create in
  this step.
- **A view can't be configured as specified:** create it plain, then set the pieces
  one at a time with the update-view tool. If something still won't apply, tell the
  user which setting is missing and how to set it by hand in Notion (the view's
  "..." menu → Group, Sort or Properties).
- **Their chosen page can't be found:** ask for its exact name, or suggest the default
  Training page.

---

## s11 — Read your training history

**Tell the user:**
> Now the interesting part: I'm going to read your training history so I can see
> where you're starting from. This only reads; nothing changes.

**Do:**
1. Call `get_training_context` for the last 12 weeks (reuse s08's result for the last
   90 days if it's still in this conversation).
2. Work out, in plain terms:
   - weekly volume per sport (run, bike, swim): typical hours or distance per week,
     and the trend
   - best efforts, if visible (fastest 5k/10k, longest run or ride, any race)
   - typical easy-run heart rate and pace; pull `get_activity_laps` on two or three
     easy runs if the summary isn't enough
   - consistency: weeks missed, typical training days
3. Save the summary to `config/setup-notes.md` under `## Training history`, so it
   survives a restart.

**Check:** the summary is shown to the user in plain words, for example: "You've been
running about 20km a week, mostly easy, with a long run on Saturdays of around 10km.
Your easy runs sit around 138 bpm. No rides or swims in the last three months."

**If it fails:** if the bridge errors, follow s08's If it fails. If there's very little
history, say so kindly ("There isn't much here yet, so I'll lean on what you tell me
next") and mark the step done.

---

## s12 — Getting to know you

**Tell the user:**
> Next I'd like to ask you some questions, one at a time. Answer in your own words;
> "I don't know" and "skip" are fine answers. It takes about 10 minutes.

**Do:** ask **one question per message**, in plain language, and wait for the answer
before the next. Skip questions that don't apply (no power meter question if they
don't ride). Append each answer to `config/setup-notes.md` under `## Interview` as you
go, so a restart doesn't lose it. Cover:

1. How they'd like to be addressed.
2. Their goal: which race or races, the dates, the distance, and any target time. If
   there's more than one, which matters most.
3. Their running history: how long they've been running and what a normal week looks
   like now.
4. Cycling history (if they ride): how long, indoor or outdoor, typical rides.
5. Swimming history (if they swim): how comfortable, pool or open water.
6. Recent best times: for example a 5k, 10k or half marathon; a 20-minute power or FTP
   test if they ride with power; a 100m or 400m swim time.
7. Injuries: past ones and anything bothering them now, and what tends to flare up.
8. Medical considerations they'd like the coach to know (optional; say so).
9. Weekly availability: which days they can train and roughly how long each day, and
   which day suits a long session.
10. Their preferred rest day.
11. Equipment: their watch, whether they have a heart-rate strap (chest or arm), a
    power meter on the bike, an indoor trainer, pool access.
12. Strength training: gym access, or happy with home exercises.
13. Anything that tends to derail them: work travel, going too hard on easy days,
    losing motivation.

**Check:** every topic that applies has an answer (or a "skip"), and the notes are
saved in `config/setup-notes.md`.

**If it fails:** if they want to stop part-way, the saved notes let you resume at the
next unanswered question. If an answer is unclear, ask one short follow-up, no more.

---

## s13 — Write your plan

**Tell the user:**
> Thanks. Now I'll write everything up: your athlete profile, your season plan and
> your first training block. This takes a few minutes. When it's ready I'll show you
> a short summary to check before anything is final.

**Do:** read `config/setup-notes.md`, then write these files. The weekly skills depend
on the sections named here, so keep the headings exactly.

1. **`athlete/profile.md`:** fill every section of the template. Thresholds and
   benchmarks carry the date they were set; anything estimated from s11's data says
   "estimate, from <month> data; confirm with a test in week <N>". Record whether they
   have a power meter and HR strap under "Equipment and data availability". Put
   injuries and the stop-the-session signals under "Health and injury"; medical notes
   only if they gave them.
2. **`athlete/fuelling-protocol.md`:** fill the sections that apply to their races;
   for legs they don't do, write "Not part of your races." Keep the section numbers.
3. **`campaigns/season-YYYY-YY.md`** (the year the season starts, then the two-digit
   year it ends; e.g. `season-2026-27.md`), with these sections:
   - `## Goals and priority`: each goal with its date and target, ranked.
   - `## Season structure`: a table with one row per campaign/block, with dates:
     `| Campaign | Block | Dates | Weeks | Focus |`. A campaign's last row ends on its
     last week; `/endtrainingweek` uses this to know when to close a campaign.
   - `## The weekly template`: the typical week by day, including the rest day.
   - `## Checkpoints and decision rules`: a table
     `| Date | Checkpoint | On track if | If missed |`.
   - `## Open decisions`: checkbox list, each with a deadline.
   - `## Amendments`: "None yet."
4. **`campaigns/<first-campaign>/summary.md`** (`<first-campaign>` is short and
   lowercase with hyphens, e.g. `spring-10k`):
   - a **Status** line at the top naming the current block and week, e.g.
     `**Status:** Active · Block 1 (Base) · Week 01 of 12 · starts 2 Nov`
   - `## Targets`
   - `## What this campaign exists to do`
   - `## Standing decisions`: each as `### <decision>` followed by `**Why:** …`.
     Include the rest day.
   - `## Open threads`: a checkbox list (`- [ ] …`), with dates where there's a
     deadline.
   - `## Campaign history`: "None yet."
5. **`campaigns/<first-campaign>/plan.md`:** a week-by-week table
   (`| Week | Dates | Block | Focus | Key session | Volume |`), the paces or heart-rate
   zones in use, and strength and swim sections if relevant.
6. **`campaigns/<first-campaign>/phases/<block>.md`** (e.g. `block-1-base.md`): a weekly
   shape table (`| Day | Session(s) | Purpose |`) and the progression targets by week,
   then the day-by-day sessions for this block in the format required by `CLAUDE.md`
   → "Formatting the weekly plan": a header per day, a header per activity (strength
   always its own header), warm-up / main set / cool-down detail, and a Session ID
   comment on each activity header with `wNN` standing for the week number, e.g.
   `### Run — Easy (40 min) <!-- id: wNN-run-easy -->`.
7. **Later campaigns**, only if the season has more than one. Each goes in
   `campaigns/upcoming/<name>/`, and `/endtrainingweek` step 3b promotes it from
   there, so it needs the same shape as the first campaign:
   - `summary.md` with the **same sections** as item 4:
     - a **Status** line: `**Status:** Upcoming · starts <date>, when <previous campaign> closes`
     - `## Targets`
     - `## What this campaign exists to do`
     - `## Standing decisions`, each with `**Why:** …`
     - `## Open threads` (checkboxes). Anything to settle at hand-over (paces, travel
       windows, targets that depend on the previous campaign's result) is tagged
       `(at promotion)`.
     - `## Campaign history`: "None yet."
   - `plan.md`: a week-by-week outline in the same table as item 5. Phase docs are
     written later, near the end of the previous campaign.
   - A row in the table in `campaigns/upcoming/README.md`, in its format:
     `| <name> | <start> – <end> | When <previous campaign> closes (<date>) |`.

Then show a plain-language summary, under 200 words: the goal, how the season is split
up, what a typical week looks like, what the first block focuses on, and anything you've
assumed. End with:
> Does this look right? Tell me anything you'd like changed, or say "looks good".

Make any changes they ask for and show the summary again. When they approve, commit:
```bash
git check-ignore -q config/intervals.env && git add -A && git commit -m "Athlete profile, season and first campaign"
```

**Check:** the user has said it looks good, all the files above exist with their
required sections (`grep -c '^## ' <file>` against the lists above), and the commit
succeeded.

**If it fails:** if they want big changes (a different goal or race), go back to the
relevant s12 questions, then rewrite. Never mark the step done without their approval.

---

## s14 — Plan week 1 and put it in Notion

**Tell the user:**
> Now I'll write your first week in detail and put it in Notion. Week 1 starts on
> <Monday's date>. Until then, carry on as you are, keeping things easy.
>
> Notion may ask you to allow each change as I add your sessions. It's fine to allow
> them.

**Do:**
1. Week 1 starts today if today is Monday, otherwise next Monday. Create
   `campaigns/<first-campaign>/weeks/week-01-YYYY-MM-DD/plan.md` (the date is that
   Monday) using the same procedure as `/endtrainingweek` step 4
   (`.claude/skills/endtrainingweek/SKILL.md`): start from the phase doc, adjust for
   s11's data, Session IDs on every activity header, rest days included, and a
   `## Changelog` section at the end.
2. Sync it to Notion following `CLAUDE.md` → "Writing to Notion" (IDs in
   `config/notion.md`):
   - Add the Week option `<Campaign> · Block 1 · Week 01 (D–D Mon)`, plus the
     Campaign and Block options.
   - Create one row per session (rest days too), Status Planned, with Date, Order,
     Type, Intensity, Session ID, Week, Campaign and Block set. Gym sessions carry the
     exercise table in the row's page body.
   - Replace the placeholder heading on the dashboard page:
     `### Setting up` / `Your first week appears…` becomes
     `### <Campaign> · Block 1: <Block name>` followed by `Week 01 · D–D Mon`.
   - Set the "This week" view's filter: `FILTER "Week" = "<the Week label>"`.
   - If s10 added placeholder select options, remove them now.
3. Show the week in chat as the table from `/endtrainingweek` step 5
   (`| Day | Session | Main set | Target | Fuelling |`), with the Notion link under it.
4. Commit:
   ```bash
   git check-ignore -q config/intervals.env && git add -A && git commit -m "Plan week 01"
   ```

**Check:** the plan file exists, the Notion rows for week 1 match its Session IDs, the
"This week" view shows them, and the commit succeeded.

**If it fails:** if a Notion write fails, say so plainly, show the week as a table in
chat instead, add a line to the week's Changelog that the Notion sync is outstanding,
and retry the sync before marking the step done. If it still fails, mark it done
anyway with the outstanding note: `/starttrainingweek` picks it up.

---

## s15 — Put workouts on your watch

**Tell the user:**
> Your runs and rides can go straight onto your watch, so it guides you through each
> session. I'll show you what I'd add first. Nothing goes on your watch until you say
> yes. Swims and gym sessions can't go on the watch this way; they'll be in Notion.

**Do:**
1. For each run, and each ride if they have a power meter, call `push_workout` with
   `dryRun: true`. Runs use pace targets; rides use power. A workout uses one kind of
   target throughout (`CLAUDE.md` → "Writing to the calendar"). If a run has no pace
   target yet (threshold unknown), leave it off the watch and say it's in Notion.
2. Describe each dry run in plain words, one line each, e.g. "This will put 'Easy run,
   40 min' on your watch calendar for Tuesday." Then ask:
   > Shall I add these to your watch? You can say yes to all, or pick some.
3. Only after an explicit yes, call `push_workout` with `dryRun: false` for the ones
   they approved. Record each returned event ID in the row's "Garmin event" column in
   Notion.
4. Tell them how it reaches the watch:
   > They're on your intervals.icu calendar now and will appear in Garmin Connect,
   > then on your watch the next time it syncs with your phone. On the day, find them
   > on your watch under Training → Workouts (or the calendar), depending on the model.

**Check:** every approved workout was pushed without error, or the user chose not to
push any (that's fine; mark the step done).

**If it fails:** show the error in plain words. If the workout doesn't appear in Garmin
Connect after a few minutes, ask them to check intervals.icu → Settings → Connections →
Garmin Connect has uploading planned workouts switched on. Never retry a write without
their yes.

---

## s16 — Coach from your phone

**Tell the user:**
> Last bit of setup: talking to me from your phone. A feature called Remote Control
> lets you continue these chats from the Claude app on your phone, for example to say
> "my calf's tight, change today's run" from the park.

**Do:**
1. If a settings tool is available (`get_settings` / `set_setting`), set
   `connect_new_sessions_to_remote_control` to `true`. The user approves it on a card:
   > A card will pop up asking to turn on "Connect new sessions to Remote Control".
   > Click to approve it.

   Also turn Remote Control on for this session (`set_remote_control`, `self`, on) if
   that tool exists. If neither tool is available, guide them:
   > Open Claude's **Settings**, go to **Claude Code**, and switch on **Connect new
   > sessions to Remote Control**. Then, in this chat, switch on Remote Control from
   > the toolbar at the top.
2. Then:
   > Now on your phone: install the **Claude** app from the App Store (or Google Play),
   > and sign in with the same account you use here. Find this chat in the app (it's
   > listed under Code), and send me "hello".
   >
   > One thing to know: your Mac needs to be awake with Claude open for this to work.
   > If your Mac is asleep or the lid is closed, your message will wait until it wakes.

**Check:** their "hello" arrives in this session from the phone. Reply so they see it
work: "Got it! That came from your phone."

**If it fails:**
- **They can't find the chat on the phone:** check they're signed in to the same
  account, and that Remote Control is on for this session.
- **Still not working:** reassure them it's optional and can be done any time ("say
  'set up my phone' later"). If they choose to skip it, mark the step done.

---

## s17 — How the weekly rhythm works

**Tell the user:**
> You're all set up! Here's how it works from now on:
>
> - **Sunday:** type `/endtrainingweek`. I'll look at how your week actually went,
>   write it up, and plan next week in Notion.
> - **Monday:** type `/starttrainingweek`. I'll brief you on the week ahead and offer
>   to put the runs and rides on your watch.
> - **Any time in between:** just chat. "I'm ill", "I've only got 30 minutes today",
>   "how did yesterday's run look?" I'll adjust the plan and keep Notion up to date.
> - **Updates:** when improvements to this coaching system come out, say "update my
>   coaching system". I'll show you what's changed before applying anything, and I
>   never touch your own notes.

Then offer the backup:
> One optional extra: a free online backup of your training notes on GitHub, a
> website for storing projects like this. Without it, everything still lives safely
> on this Mac with its full history. Would you like to set it up? It takes about 10
> minutes, and skipping it is completely fine.

**Do:**
- **If they skip:** mark the step done.
- **If they want the backup**, guide them one step at a time:
  1. Sign up for a free account at https://github.com.
  2. Create a new repository (GitHub's word for a project folder): click **+** → **New
     repository**, name it `my-training`, choose **Private**, leave everything else
     unticked, and click **Create repository**. Ask them for their GitHub username
     (not their password).
  3. Create an access code for this Mac: on GitHub, profile picture → **Settings** →
     **Developer settings** → **Personal access tokens** → **Fine-grained tokens** →
     **Generate new token**. Name it "My Training Mac", under repository access choose
     **Only select repositories** → `my-training`, under permissions set **Contents**
     to **Read and write**, then generate it and copy it. Tell them not to paste it
     into the chat.
  4. Run:
     ```bash
     git remote add origin https://github.com/<username>/my-training.git
     ```
  5. The first upload needs them to sign in once, so it runs in the Terminal panel
     beside this chat (open a terminal tab and run `git push -u origin main` there), not
     through your own command tool:
     > I've opened a terminal panel next to our chat: a small window where you can type
     > commands. It will ask for your username: type your GitHub username
     > and press Return. Then it asks for a password: paste the access code you just
     > copied (nothing shows as you paste; that's normal) and press Return. Your Mac
     > remembers it, so you won't need it again.

     If there's no terminal panel, ask them to open the Terminal app, `cd` into the
     My Training folder (offer the exact command), and run it there.
- **Finish**, once the check below passes:
  ```bash
  bash scripts/setup-state.sh mark s17
  git check-ignore -q config/intervals.env && git add -A && git commit -m "Setup complete"
  if git remote get-url origin >/dev/null 2>&1; then git push origin main; fi
  ```

**Check:** they skipped the backup, or `git ls-remote origin` succeeds and their
first push went through. Then run the Finish commands and close with:
> That's it. Welcome to your training coach! One last thing: this is a training aid,
> not medical advice. If you have pain or an injury, stop and see a professional.

**If it fails:**
- **The push asks for a password and rejects it:** they pasted their GitHub password
  instead of the access code, or the code lacks "Contents: Read and write". Redo step 3
  and try again.
- **"Repository not found":** check the username and repository name, and that the
  access code includes `my-training`.
- **They give up on it:** remove the half-set-up link (`git remote remove origin`),
  reassure them the notes are safe on this Mac, and mark the step done.
