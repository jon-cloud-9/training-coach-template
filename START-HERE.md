# Start here

This guide gets you from nothing to your own training coach. It takes about 50 minutes. You can stop and carry on later at any point.

You'll need a Mac, a Garmin watch, and a few spare minutes. You don't need to be technical. Claude does the fiddly parts and tells you what it's doing.

**The short version:** you sign up and install an app (Part 1, about 10 minutes). Then Claude walks you through the rest (Parts 2 to 4), one step at a time.

---

## Part 1: Before Claude (about 10 minutes)

You do these three steps yourself.

### 1. Sign up for Claude Pro

1. Go to **claude.ai** in your web browser.
2. Create an account and choose the **Pro** plan. It costs about £18 / $20 a month.
3. The free plan won't work for this.

### 2. Download the Claude desktop app and sign in

1. Go to **claude.ai/download** and download the app for Mac.
2. Open the downloaded file and drag Claude into your Applications folder.
3. Open Claude and sign in with the account you just made.

### 3. Open the Code tab and paste the starter message

1. In the Claude app, click the **Code** tab.
2. Create a new, empty folder called **My Training**. Make it in your home folder. That's the one with your name on it, shown under Locations in Finder. Please don't put it in Documents or Desktop, because on many Macs those are copied to iCloud, which can create duplicate files that break things. Choose the folder when Claude asks which folder to work in.
3. Copy all of this and paste it as your first message, then press Return:

```
Please set up my training coach in this folder. Use curl -L to download https://github.com/jon-cloud-9/training-coach-template/archive/refs/heads/main.zip into this folder, unzip it, and move everything inside the training-coach-template-main folder into this folder, including the hidden files whose names start with a dot. Then delete the zip file and the empty training-coach-template-main folder. After that, read .claude/skills/setup/SKILL.md and follow it from step s04. I'm not technical, so explain each step in plain language before you do it.
```

From here on, Claude leads. Come back to this guide if you want to know what's coming.

**If something looks different**

- If you can't see a **Code** tab, check you're signed in and on the Pro plan. Quit and reopen the app.
- If Claude says it can't find a folder, make sure you chose "My Training" and that it's empty.
- If you can't create a folder from the picker, make an empty folder called My Training in your home folder in Finder first, then choose it.

---

## About Claude's permission prompts

Before Claude runs something on your Mac, or changes a file, the app shows a box asking if it can. This is normal. It's the app keeping you in charge.

- It's fine to click **Allow** for things that work in your "My Training" folder.
- If the box offers "Allow for this session" or "Always allow", that's fine too. It just saves you clicks.
- If a box asks for something that doesn't look like it belongs to your training, or you're not sure, click Deny and ask Claude why it needs it.
- **Never paste passwords or keys into the chat.** Claude will never ask you to. When a key is needed, it opens a private file for you instead.

---

## Part 2: Claude sets up the system (about 20 minutes)

### s04 — Finish the download and start the history
*(step s04)*

**What Claude will do:** check that all the coaching files arrived. Then it switches on a free tool that keeps a dated history of every change to your training notes, so nothing is lost and anything can be undone.

**What you'll do:** click Allow on the permission boxes, and tell Claude what name to put on your notes. Your first name is fine.

**What you'll see:** Claude asks for your name, then confirms the history has started.

**If something looks different**

- If a window from Apple pops up asking to install "command line developer tools", that's expected on a new Mac. Click **Install**, then **Agree**. It takes 5 to 10 minutes. Tell Claude when it finishes.
- If you see a button for "Get Xcode", close it. You don't need it. Tell Claude and it will bring the Install window back.
- If Claude says some files are missing, it will download them again. Nothing for you to do.

### s05 — Install Node if it's missing
*(step s05)*

**What Claude will do:** check for Node, a free program that your Garmin helper needs. If it's missing, Claude downloads the official installer and opens it for you. It will ask before downloading.

**What you'll do:** say yes to the download. Then click through the installer: **Continue**, **Agree**, **Install**. Your Mac will ask for your Mac password (or Touch ID). That's the password you use to log in to your Mac, and it's normal for installing software. Click **Close** at the end.

**What you'll see:** an installer window, then "The installation was successful".

**If something looks different**

- If the installer asks whether to move itself to the Bin, either answer is fine.
- If Claude says it can't see Node yet, quit Claude completely (Claude menu, then Quit). Open it again, go to the **Code** tab, open your "My Training" session from the list on the left, and say "continue setup". If you're asked whether to use "intervals", choose to allow it. That's the helper.
- If the installer says it can't be opened, tell Claude what the message says. It will try again.

### s06 — Fetch the bridge
*(step s06)*

**What Claude will do:** set up a small helper that reads your Garmin data. (Claude calls this the bridge.) This is automatic. The first time can take up to a minute.

**What you'll do:** click Allow when asked.

**What you'll see:** the step ends with a message saying it can't find your settings file yet. That's expected. You create that file in the next step.

**If something looks different**

- If Claude says it couldn't reach the internet, check your Wi-Fi is on and working, then tell Claude to try again.
- If it still doesn't work, say "continue setup" later and Claude will try again.

### s07 — Connect intervals.icu and save your key
*(step s07)*

**What Claude will do:** explain what to do on the intervals.icu website, then open a small private settings file in TextEdit for you. intervals.icu is a free training website that collects your workouts from Garmin.

**What you'll do:** in your web browser:

1. Create a free account at **intervals.icu**.
2. Link Garmin. Open **Settings**, then **Connections**, then **Garmin Connect**. Sign in to Garmin and allow access. If it offers to download your activities and to upload planned workouts, turn both on.
3. Copy your key. In **Settings**, scroll to **Developer Settings** and copy the **API key**. It's a long password-like code. Tell Claude when you've copied it.

Then, when Claude opens TextEdit, you'll see one line of text that ends with an equals sign (=). Click just after the = sign, paste your key (Cmd-V) with no spaces, save (Cmd-S) and close the window.

**Please don't paste the key into the chat.** The file stays on your Mac and is never included in your backups or history.

Claude will then ask you to quit and reopen the app, so the helper can read the key. Quit Claude completely (Cmd-Q), open it again, go to the **Code** tab, and open your "My Training" session. You may be asked whether to use "intervals", found in this folder. That's the helper, so choose to allow it. If you say no by mistake, tell Claude and it will switch it back on. Then say "continue setup".

**What you'll see:** TextEdit with one line of text, then Claude confirming the key is saved.

**If something looks different**

- If Claude says the key didn't save, open the file again and check the key is on the same line, straight after the `=` sign. Press Cmd-S.
- If you pasted the key into the chat by mistake, tell Claude. Go back to Developer Settings in intervals.icu and make a new key. Use the new one in the file.
- Your past workouts can take a while to appear in intervals.icu. That's normal.

### s08 — Test the connection
*(step s08)*

**What Claude will do:** read your last 90 days of training from intervals.icu. Nothing gets changed.

**What you'll do:** nothing, just watch.

**What you'll see:** a friendly line such as "It works! I can see 143 activities from the last 90 days."

**If something looks different**

- If Claude says the helper isn't available, it will check whether "intervals" was switched off earlier. Claude remembers a "no", so it won't ask again by itself. If it was switched off, Claude will ask to switch it back on (click Allow), then ask you to quit and reopen as in step s07. You can also type `/mcp` in the message box, pick "intervals" and switch it on.
- If it wasn't switched off, quit and reopen Claude as in step s07, and allow "intervals" when asked.
- If Claude says the key is empty or wrong, go back to step s07 and copy the key again.
- If it finds no activities, check your workouts show on the intervals.icu calendar. If your account is new, that's fine.

---

## Part 3: Notion and your plan (about 20 minutes)

### s09 — Connect Notion
*(step s09)*

**What Claude will do:** ask if you have a Notion account, then check the connection works. Each week Claude puts your plan in Notion, so you can see it on your phone or computer.

**What you'll do:** if you don't have an account, sign up free at **notion.so**. Then in Claude, open **Settings** (Claude menu, then Settings, or Cmd-comma), go to **Connectors**, find **Notion**, click **Connect**, sign in if asked, and allow access.

**What you'll see:** a Notion sign-in and permission page, then a confirmation that Notion is connected.

**If something looks different**

- If Claude can't see Notion, check Notion is switched on for this chat in the connectors menu next to the message box. If it still can't, quit and reopen Claude as in step s07.
- If you see an access error, go back to Settings, then Connectors, then Notion. Reconnect and make sure you click to allow.
- Claude may ask if you pay for Strava. You don't need to connect it. Your Garmin data already comes through intervals.icu.

### s10 — Create your Notion training section
*(step s10)*

**What Claude will do:** build your training section in Notion: a table of every session, and a "This week" view that shows just the current week.

**What you'll do:** choose where it goes (a page you already use, or a new page called "Training", which is the default). Say whether Claude can update your sessions each week without asking every time. Allow the changes when Notion asks.

**What you'll see:** Claude working for a minute or two, then a link to your new Training page. It's empty for now.

**If something looks different**

- If Claude can't find the page you named, give its exact name, or choose the default.
- If a view doesn't look quite right, Claude will tell you which setting to change and where.
- If you say no to automatic updates, Claude will ask each time. That's fine.

### s11 — Read your training history
*(step s11)*

**What Claude will do:** read your recent training so it knows where you're starting from. It only reads.

**What you'll do:** read the summary and see if it sounds like you.

**What you'll see:** a short summary in plain words, for example how much you run each week and how fast your easy runs are.

**If something looks different**

- If there isn't much history yet, Claude will say so and lean on what you tell it next. That's fine.
- If the summary looks wrong, tell Claude. It's only a starting point.

### s12 — Getting to know you
*(step s12)*

**What Claude will do:** ask you about 13 questions, one at a time. It's about 10 minutes. Your goal and race dates, running, cycling and swimming history, recent best times, injuries, the days you can train, your rest day, your equipment, and anything that tends to derail you.

**What you'll do:** answer in your own words. "I don't know" and "skip" are fine answers.

**What you'll see:** one question per message.

**If something looks different**

- If you want to stop part-way, just stop. Claude saves your answers. Say "continue setup" later.
- If a question doesn't apply to you, say so and Claude will skip it.

### s13 — Write your plan
*(step s13)*

**What Claude will do:** write your athlete profile, your season plan and your first training block. This takes a few minutes. Then it shows you a short summary to check.

**What you'll do:** read the summary. Ask for anything to be changed, or say "looks good".

**What you'll see:** a summary of under 200 words: your goal, how the season is split up, what a typical week looks like, and what the first block focuses on.

**If something looks different**

- If the goal or race is wrong, say so. Claude will go back over the relevant questions and rewrite it.
- Nothing is final until you say it looks good.

### s14 — Plan week 1 and put it in Notion
*(step s14)*

**What Claude will do:** write your first week in detail and add each session to your Notion table. Week 1 starts today if it's a Monday, otherwise next Monday.

**What you'll do:** allow the changes when Notion asks. Then look at the week.

**What you'll see:** a table of the week in the chat, and a link to Notion where the "This week" view now shows your sessions.

**If something looks different**

- If Notion doesn't update, Claude shows the week in the chat instead and tries again later. Your plan is safe either way.
- Until week 1 starts, carry on as you are, keeping things easy.

---

## Part 4: Watch, phone and finishing (about 10 minutes)

### s15 — Put workouts on your watch
*(step s15)*

**What Claude will do:** show you which of your runs and rides it would add to your watch. Nothing goes on your watch until you say yes. Swims and gym sessions can't go on the watch this way. They'll be in Notion. Runs without a pace target yet, and rides if you don't have a power meter, stay in Notion only.

**What you'll do:** say yes to all, pick some, or say no. You can skip this step.

**What you'll see:** a list such as "This will put 'Easy run, 40 min' on your watch calendar for Tuesday."

**If something looks different**

- Workouts reach your watch the next time it syncs with your phone. On the day, look under Training, then Workouts, on your watch. The exact name depends on the model.
- If a workout doesn't appear after a few minutes, check intervals.icu, then Settings, then Connections, then Garmin Connect. Uploading planned workouts should be switched on.

### s16 — Coach from your phone
*(step s16)*

**What Claude will do:** switch on Remote Control, a feature that lets you carry on these chats from the Claude app on your phone. For example, "my calf's tight, change today's run" from the park.

**What you'll do:** click to approve the card that pops up. Install the **Claude** app on your phone from the App Store and sign in with the same account. Find this chat under Code and send "hello". You can skip this step.

**What you'll see:** your "hello" arrives on your Mac, and Claude replies "Got it! That came from your phone."

**If something looks different**

- If you can't find the chat, check you're signed in to the same account on both.
- You can do this later. Just say "set up my phone".
- The Mac needs to be awake and plugged in, with the lid open. If it's asleep, your message waits until it wakes.

### s17 — How the weekly rhythm works
*(step s17)*

**What Claude will do:** explain the weekly routine (see "Using it every week" below). It also offers an optional free online backup of your training notes. Without it, everything still lives safely on your Mac with its full history.

**What you'll do:** decide whether you want the backup. Skipping is completely fine. If you want it, Claude guides you one step at a time. You'll make a free account on GitHub, a website for storing projects like this. You'll create a private project, and make an access code for your Mac. Don't paste the code into the chat. It goes into a small window beside the chat that Claude opens for you, or Claude will tell you what to open instead.

**What you'll see:** Claude says setup is complete.

**If something looks different**

- If the upload rejects your password, you may have used your GitHub password instead of the access code. Claude will walk you through it again.
- If you give up on the backup, tell Claude. Your notes are safe on your Mac either way.

---

## Pausing and coming back

You can stop at any point. Your progress is saved after each step. When you want to carry on, open your "My Training" session and say **"continue setup"**, or type **/setup**. Setup picks up where it stopped.

---

## Using it every week

- **Sunday:** type `/endtrainingweek`. Claude looks at how your week went, writes it up and plans the next one.
- **Monday:** type `/starttrainingweek`. Claude briefs you on the week ahead and offers to put your runs and rides on your watch.
- **Any time in between:** just chat. "I'm ill", "I've only got 30 minutes today", "how did yesterday's run look?" Claude adjusts the plan.
- **Your plan appears in Notion.** It's updated as the week changes.
- **Workouts reach your watch only after you say yes.** Claude always asks first.
- **From your phone:** your Mac must be awake and plugged in, with the lid open.
- **Updates:** when improvements come out, say **"update my coaching system"**. Claude shows you what's changed before applying anything, and never touches your own notes.

---

## Important

This is a training aid, not medical advice. If you have pain or an injury, stop and see a professional.
