---
name: update
description: Updates the coaching system to the latest version of the template without touching the athlete's own data. Use when the user says /update, "update my coaching system", "get the latest version", or "check for updates".
---

# Update

You are updating the shared coaching files (the instructions, skills and helper scripts)
to the latest version. The user is probably not technical, so keep what you say to them
plain and short, and say what a command does before you run it. Their personal data
(`athlete/`, `campaigns/`, `config/`) is never changed by an update.

## Steps

1. **Tell the user:**
   > I'll check whether there's a newer version of the coaching system. I'm going to
   > download it to a temporary folder and compare; nothing changes yet. You'll see a
   > box asking whether I can run commands: click Allow.

2. **Download and unpack** (use `mktemp -d` and remember the folder as `<tmp>`):
   ```bash
   tmp="$(mktemp -d)"
   curl -L -o "$tmp/template.zip" https://github.com/jon-cloud-9/training-coach-template/archive/refs/heads/main.zip
   unzip -q "$tmp/template.zip" -d "$tmp"
   ```
   The new files are in `<tmp>/training-coach-template-main`. If the download fails,
   say: "I couldn't reach GitHub. Check your internet connection and ask me to try
   again." Then clean up (step 8) and stop.

3. **Compare versions.** Read `VERSION` in this folder and in
   `<tmp>/training-coach-template-main`. If they match, say "You're already on the
   latest version (<version>)", clean up, and stop.

4. **Show what would change**, in plain words. For each path listed in the new
   `TEMPLATE_FILES`, compare it with the copy here (`diff -rq` or `cmp`) and list the
   ones that differ or are new. Describe them by what they do ("the weekly planning
   instructions", "the setup guide"), not just by file name. Then say:
   > There's a newer version: <old> to <new>. These parts would change: <list>.
   > Your own training notes, profile and settings won't be touched. If you've edited
   > any of these files yourself, I'll keep a copy of your version first. Shall I go
   > ahead? (yes / no)

5. **Wait for an explicit "yes".** Anything else means stop: clean up (step 8) and
   say nothing was changed.

6. **Apply it:**
   ```bash
   bash scripts/update-shared.sh --from "<tmp>/training-coach-template-main"
   ```
   It prints `updated <n> files, backed up <m>, <old>→<new>`. If `<m>` is more than 0,
   tell the user which files were backed up and that the copies are in the
   `.backup/<date-time>` folder here, so they can compare or bring back their edits.
   If the script exits with an error, show the message in plain words, change nothing
   else, clean up, and stop.

7. **Commit** the update (set the history up first only if `git rev-parse --git-dir`
   fails):
   ```bash
   git add -A && git commit -m "Update coaching system to <new version>"
   ```
   Use the changed-file list from step 4: if any changed path starts with `.claude/`
   or equals `.mcp.json`, tell the user:
   > Some of my own instructions changed, so please close this session and start a new
   > one to pick them up.

8. **Clean up:** `rm -rf "<tmp>"`. Always do this, including when you stop early.

9. **Tell the user** it's done and which version they're on.
