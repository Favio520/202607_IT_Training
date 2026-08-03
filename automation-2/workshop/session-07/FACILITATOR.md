# Session 07 — Facilitator crib sheet

**Your first workflow** · 60 minutes · beginners · everything in the GitHub web UI

Carried over from Session 06: they already know what CI and CD are, the benefits,
and how the platforms compare. Do **not** re-explain any of that. Today is hands-on.

---

## Before you start

- [ ] Confirm everyone did the pre-work (template repo created). Ask for a show of
      hands in the first minute — if more than two people missed it, pair them up
      rather than waiting.
- [ ] Send everyone the link to `CHEATSHEET.md` (same folder as this file) — one page,
      and it stops mid-lab hands going up for "where do I click again?"
- [ ] Have your own demo repo open on a second tab, already at Step 1.
- [ ] Slido open, same event code as Session 06 (2919736).
- [ ] Have a broken commit ready to push in Step 3 so you don't fumble it live.

**Say this in the first two minutes:** the website in the repo is scenery today — it
becomes the real deploy target in Session 09. Otherwise a few people spend the whole
lab quietly wondering why the page isn't live, instead of watching the pipeline.

---

## Run of show

All the teaching happens up front, then they build. Say that out loud on the agenda
slide — beginners get restless if they don't know when the keyboard part starts.

| Time | Slides | Block | What you do |
|---|---|---|---|
| 0–5 | 1–4 | **Bridge** | Pull up the Session 06 closing question — "what would you automate?" Read one answer aloud, then: "today we build the skeleton of that." Show of hands on pre-work. |
| 5–10 | 5 | **The runner** | The empty-machine diagram. Land it hard and slowly. End on the open question — "so how does your code get onto it?" — and **do not answer it**. |
| 10–16 | 6 | **Anatomy** | The 8-line workflow. Walk `name` / `on` / `jobs` / `runs-on` / `steps`, one sentence each. Say `.github/workflows/` out loud twice. |
| 16–21 | 7 | **Triggers** | `push` / `pull_request` / `workflow_dispatch`. Demo the Run workflow button live — ten seconds and satisfying. |
| 21–25 | 8 | **The `on:` menu** | Skim it. "The menu is long, your order is short." Flag `paths:` as the cost win, tying back to Session 06's pricing table. Cut to 90 seconds if the room is restless. |
| 25–30 | 9 | **`run` vs `uses`** | Close the loop from slide 5 out loud: *this* is how the code gets onto the machine. Then hand over — they're about to write both kinds of step. |
| 30–46 | 10–11 | **Lab** | Demo Step 1 yourself first (~6 min), then release them. Everyone gets a green check, then adds checkout + setup-node + `npm test`. **This is the session.** Protect the time; cut anything else first. |
| 46–57 | 12 | **Break it** | You push the broken test first so everyone sees red together, then they do it in their own repo. Read the failure log bottom-up. Ask: "how long would this have taken in review?" |
| 57–60 | 13 | **Wrap** | Three-line recap. No homework — ask the room for one thing they didn't understand today and start Session 08 there. Tease it: "right now we test on one Node version. Next time, all three at once — and we make it fast." |

**The risk in this running order:** nobody touches a keyboard until minute 30. Watch the
room during slides 7 and 8 and compress ruthlessly if attention drops — the lab is what
they'll remember, and the cheat sheet covers triggers in full.

---

## The questions you will get

**"Where does this actually run?"**
A virtual machine in GitHub's cloud, created for this run and destroyed after.
Public repos: free. Private: 2,000 minutes/month on the Free plan — the table from
Session 06.

**"Why do I need `actions/checkout`? It's my repo."**
The runner starts empty. It doesn't know about your repo until you tell it to fetch
the code. This is the single most common beginner mistake — a workflow that "can't
find" files.

**"What's the difference between `run` and `uses`?"**
`run` is a shell command you write. `uses` is somebody else's packaged code. If you'd
type it in a terminal, use `run`.

**"Can it deploy?"**
Yes — Session 09. We'll put this site on a real URL with an approval gate.

**"What if I write invalid YAML?"**
GitHub shows an error in the Actions tab rather than running it. Indentation is the
usual culprit — two spaces, never tabs. Worth showing this on purpose if someone hits it.

**"Don't we need to install dependencies before `npm test`?"**
This is the sharpest question in the room — treat it as such. No: the tests use Node's
built-in test runner, so there is nothing to install. Almost every real project *does*
need an install step, which is exactly where Session 08 starts — `npm ci`, and then
caching so it doesn't cost you 30 seconds on every run. (The stretch lint workflow
*does* need an install, because eslint isn't built in. Good contrast if it comes up.)

**"Why did it run twice?"**
Someone dropped the `branches: [main]` filter under `push:`. Then opening a PR from a
branch fires *both* `push` (for the branch) and `pull_request` (for the PR) — two runs,
two sets of logs, much confusion. Put the filter back. Worth a sentence even if nobody
asks, because duplicate runs also quietly burn minutes on private repos.

**"What is the website actually for?"**
Today, nothing — it's scenery. In Session 09 it becomes a real deployed URL with an
approval gate in front of it. Saying this early saves you the question three times.

---

## Timing escape hatches

- **Behind at minute 21?** Trim the `on:` menu slide (8) to its top four rows and skip
  the cron detail entirely. It's awareness-only and the cheat sheet covers it in full.
- **Still behind at minute 30?** Merge slide 9 into your slide 6 walkthrough — one extra
  sentence about `uses:` — and start the lab. Do not arrive at the lab after minute 34.
- **Running short?** Hand out `stretch-lint.yml` (same folder) — a second workflow
  file that runs `npm run lint`. Then discuss the question in its header comment: why
  keep it separate from `ci.yml` instead of adding a lint step to the test job?
- **Someone finishes way early?** Same file. Or point them at `on: schedule` and ask
  what they'd run on a timer — good bridge material for later sessions.
- **Lost the whole trigger block to overrun?** Fine. They have it in the cheat sheet, and
  the pull request demo can open Session 08 instead.

---

## Things that will go wrong

- **`.github/worflows/`** — a typo in the folder name means nothing runs, with no
  error anywhere. Check this first when someone says "nothing happened."
- **Committed to a branch, not `main`** — the `on: push` in Step 1 has no branch
  filter so it still runs, but people get confused about where their file went.
- **Copy-paste from a slide breaks the indentation.** Put the YAML in the README
  and have them copy from there, not from your deck.
- **Private repo with minutes exhausted** — one reason the pre-work says public.
