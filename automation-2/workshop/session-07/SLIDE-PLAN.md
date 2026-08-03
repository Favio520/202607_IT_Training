# Session 07 — slide plan

**13 slides · 60 minutes.** Reuse the Session 06 master, title layout, and footer
(`Jason Liao @ liaojason2 | AMAXST Bolivia Office, Cochabamba, Bolivia`).

Update the date on slides 1 and 13. Keep the Slido event code the same as Session 06
(**2919736**) so the poll history carries over.

Two things to know before you build:

- **This deck is scaffolding, not the session.** Slides 10 and 11 are the lab and are
  meant to *stay on screen* while people work — design them to be readable from the back
  of the room, not to be presented.
- **Every YAML block should be pasteable from the README, not the slide.** Slide text
  gets mangled by copy-paste. Say "copy from the README" out loud on slide 10.
- **All four teaching slides now come before the lab.** That is roughly 25 minutes of
  talking before anyone touches a keyboard, so keep each one tight and say the plan out
  loud on the agenda slide.

---

## Slide 1 — Title

**On slide**

> SESSION
> **07**
> Automation —
> Your First Pipeline
>
> Last time we talked about what CI/CD is. Today you build one.
>
> Fri · Aug 7 *(update)*

**Visual** — Session 06 title layout, unchanged.

**Notes** — Welcome back. One sentence of framing: Session 06 was the map, today is the
territory. By the end of the hour everyone will have a working pipeline running on their
own repository. Set the expectation immediately that this is a hands-on session and
laptops should be open. Confirm the pre-work: show of hands for who created their repo
from the template. If more than two people missed it, pair them with a neighbour rather
than stopping to fix it.

---

## Slide 2 — Slido

**On slide** — Identical to Session 06 slide 2. Same event code, same QR.

**Notes** — Leave it up for 20 seconds. Remind them questions can go in anonymously
during the lab, which is where people are most reluctant to raise a hand.

---

## Slide 3 — Agenda

**On slide**

> # Agenda
> Anatomy of a workflow
> Triggers — push, PR, manual
> Build your first pipeline
> Watch it fail

**Visual** — Session 06 agenda layout. Four lines, no timings.

**Notes** — Read the four lines, then hang a beat on the last one: "yes, we're going to
break it on purpose — that's the part that teaches you the most." No detail yet; the
words `workflow_dispatch` and `checkout` mean nothing to them for another five minutes.

Say the shape of the hour out loud: about 25 minutes of explaining, then they build.
Beginners get restless if they don't know when the keyboard part starts.

---

## Slide 4 — Where we left off

**On slide**

> ## Where we left off
>
> **CI** — every change gets built and tested automatically
> **CD** — releasing becomes a pipeline step, not a checklist
> **GitHub Actions** — YAML config, free on public repos, already where our code lives
>
> Today: the third one, in your hands.

**Visual** — Three stacked rows, each with an icon in a filled circle. Do **not**
re-show the platform comparison table — it did its job last session.

**Notes** — Sixty seconds, maximum. This slide exists so the two people who missed
Session 06 aren't lost, not to re-teach it. Then pull up the Session 06 closing Slido
answers — "what would you automate?" — read one aloud and connect it: "today we build
the skeleton of exactly that."

---

## Slide 5 — The runner is an empty computer

**On slide**

> ## Every job gets a brand-new computer
>
> GitHub creates a fresh virtual machine for your job.
> It runs your steps. Then it's destroyed.
>
> **It starts empty. It has never seen your code.**

**Visual** — This is the most important slide in the deck; give it a real diagram.
Three boxes left to right: *machine created (empty)* → *your steps run* → *machine
destroyed*. Put the emphasised line in the largest type on the slide.

**Notes** — Land this hard and slowly. Every beginner confusion in this session traces
back to not believing it — "why can't it find my file," "why do I need checkout," "why
did my file disappear between jobs." Ask the room directly: "if the machine has never
seen your code, how does it get there?" Let the silence sit. Don't answer — slide 9
answers it, and it lands better as their discovery than your fact.

Because the two trigger slides now sit in between, make the callback explicit when you
reach slide 9: "remember the question I left you with."

---

## Slide 6 — Anatomy of a workflow

**On slide** — The eight-line workflow, annotated with callouts:

```yaml
name: CI                    # what you see in the Actions tab
on: push                    # the event that starts it
jobs:
  hello:                    # a job — gets its own machine
    runs-on: ubuntu-latest  # which machine
    steps:
      - run: echo "Hello"   # a command, top to bottom
```

Plus, small and off to the side: `.github/workflows/ci.yml` — the folder name is not
optional.

**Visual** — Monospaced code, left-aligned, with the five callout labels connected to
their lines. Syntax colouring helps; use it if your template supports it.

**Notes** — Walk the five words in order. Keep each to one sentence — they'll meet all
of them again in the lab, which is where they actually learn them. Say the folder path
out loud twice: `.github/workflows/`, with the leading dot. A typo there means nothing
runs and GitHub reports no error at all, and it will happen to someone today.

---

## Slide 7 — Triggers

**On slide**

> ## When should it run?

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

> `push` — every push to main
> `pull_request` — **the check appears on the PR itself**
> `workflow_dispatch` — a "Run workflow" button

**Visual** — YAML on the left, the three plain-language lines on the right. A screenshot
of the check on a pull request is worth including — that's the thing teams actually see
every day.

**Notes** — Demo the Run workflow button; it's satisfying and takes ten seconds. Then the
PR check: open a PR live and show the check appearing on it. That's the shape of how a
team actually blocks broken code from merging, and it's the most transferable thing on
this slide. Don't list other events here — the next slide does that.

---

## Slide 8 — The rest of the menu

**On slide**

> ## `on:` — more than 30 events
>
> You will use four of them.

| Event | Fires when | Use it for |
|---|---|---|
| `push` | Commits land on a branch or tag | The default. Test everything. |
| `pull_request` | A PR is opened or updated | Blocking broken merges |
| `workflow_dispatch` | You click a button | Manual deploys, one-off jobs |
| `schedule` | A cron time comes round | Nightly builds, dependency scans |
| `release` | You publish a release | Shipping artifacts |
| `issues`, `issue_comment` | Someone opens or comments | Triage bots, auto-labelling |
| `workflow_run` | Another workflow finishes | Chaining pipelines |

> Narrow any event with **`branches:`**, **`paths:`**, **`tags:`**, or **`types:`**

**Visual** — A table, but visually weight the first three rows — a tint or a heavier
rule — so the eye lands on what they'll actually use. The rest is there to show the
surface area exists, not to be memorised. Do not put all thirty-odd events on the slide.

**Notes** — The message is "the menu is long, your order is short." Read the top three,
then skim the rest at speed — the point is that Actions reacts to almost anything that
happens in a repository, not that they should remember `page_build` exists.

Two details worth saying out loud:

- **`types:` narrows an event.** `pull_request` defaults to firing on opened, reopened,
  and synchronize (new commits pushed to the PR). You can restrict it —
  `types: [opened]` — or extend it, e.g. `types: [closed]` to run something on merge.
- **`paths:` saves real money.** `paths: ['src/**']` means a README edit doesn't burn
  build minutes. On private repos this is the single easiest cost win, which ties back
  to the pricing table from Session 06.

If someone asks about `pull_request_target`: it exists, it runs in the context of the
base repository so forked PRs can't steal your secrets, and it is dangerous if you use
it to build PR code. Say "Session 09" and move on — it's a security topic, not a
triggers topic.

**Cron, if they ask** — five fields, minute first, **UTC by default**. So 9am in
Cochabamba is `0 13 * * *`, not `0 9 * * *`. You can now add an IANA
`timezone: "America/La_Paz"` alongside the cron instead, which is easier to read and
harder to get wrong. Four caveats for scheduled workflows: minimum interval is 5
minutes, they only run on the default branch, runs can be delayed when GitHub is busy
(so avoid the top of the hour), and on public repos the schedule is disabled after 60
days with no repository activity. Point at crontab.guru rather than explaining the
syntax; nobody has ever learned cron from a slide.

---

## Slide 9 — `run` vs `uses`

**On slide**

> ## Two kinds of step
>
> **`run:`** — a shell command. Something you'd type yourself.
> `run: npm test`
>
> **`uses:`** — someone else's packaged code, always with a version.
> `uses: actions/checkout@v4` — puts your repo on the machine
> `uses: actions/setup-node@v4` — installs Node

**Visual** — Two columns, clearly divided. Give `actions/checkout@v4` visual emphasis —
a highlight or a callout. It's the answer to the question you left open on slide 5.

**Notes** — Close the loop from slide 5 now, out loud: "remember the question — how does
your code get onto a machine that has never seen it?" This is the answer.

Note that `uses` is the whole reason Actions is pleasant — thousands of these exist and
you rarely write your own. Mention the `@v4` matters and Session 09 covers why pinning
versions is a security question, not a style one. Don't go further; that's a later session.

This is also the last slide before the lab, so end by handing over: they're about to
write both kinds of step themselves.

---

## Slide 10 — LAB: your first workflow

**On slide** — Big, high-contrast, readable from the back. This slide stays up.

> ## Lab — 1 of 2
>
> 1. Your repo → **Add file** → **Create new file**
> 2. Filename: `.github/workflows/ci.yml`
> 3. Paste the workflow from the README
> 4. **Commit changes** → to `main`
> 5. Open the **Actions** tab and watch it run
>
> Stuck? → CHEATSHEET.md · Ask in Slido · Raise a hand

**Visual** — Numbered steps, generous type. Repo URL and the cheat sheet link in the
footer. No decoration — this is a working reference, not a presentation slide.

**Notes** — Demo it yourself first, start to finish, ~8 minutes: create the file, commit,
open Actions, click into the run, click into the job, expand the step, show the echo
output. Narrate the 20-second queue wait — silence feels much longer than it is, and
they need to know waiting is normal. Then release them and leave this slide up. Walk the
room; don't watch your screen. First green check gets called out by name.

---

## Slide 11 — LAB: make it test the code

**On slide** — Same layout as slide 8. Also stays up.

> ## Lab — 2 of 2
>
> Replace your workflow with the Step 2 version from the README.
>
> Three new lines:
> - `uses: actions/checkout@v4` — get the code
> - `uses: actions/setup-node@v4` — install Node
> - `run: npm test` — run the tests
>
> Goal: **3 passing tests, green check.**

**Visual** — Consider a small screenshot of the green check in the Actions tab. That
image is the target state and it helps people know when they're done.

**Notes** — The bridge into this slide is the question from slide 5: your first workflow
echoed a string, but it never touched your code — because the machine was empty. Now we
fix that. This is the moment the pipeline becomes real. Anyone who finishes early gets
pointed at `stretch-lint.yml`. Protect this block: if you're running out of time, cut
slides 11 and 12 before you cut this.

---

## Slide 12 — Watch it fail

**On slide**

> ## Now break it
>
> In `src/format.test.js`, change the first expected value:
>
> `'hello-world'` → `'hello_world'`
>
> Commit. Watch it go red.
> Open the failed step and find two numbers: **expected** and **actual**.

**Visual** — A screenshot of the red X and the failure output, with `expected:` and
`actual:` circled. If you only make one screenshot for this deck, make it this one.

**Notes** — Push your own broken commit first so the whole room sees red at the same
moment, then let them do it in their own repo. Read the log together, from the bottom
up. Then ask the question that sells the entire practice: "how long would it have taken
someone to notice this in code review?" Let them answer. This six minutes is the highest
value in the session — it is why they'll write a workflow next week without being asked.

---

## Slide 13 — Thank you

**On slide** — Session 06's closing layout, three recap lines:

> SESSION
> **07**
> **Thank you**
>
> A workflow is a YAML file, a job is a fresh machine, a step is a command.
> `actions/checkout` exists because the machine starts empty.
> A red check in two minutes beats a bug in production.
>
> Questions? Slido — code 2919736

**Notes** — Keep the recap to those three lines; resist adding a fourth. Then tee up
Session 08 with a concrete hook: "right now you test on one Node version. Next time,
three at once — and we make the whole thing faster instead of slower." Leave the Slido
code up while questions come in.

No homework — these sessions run on consecutive days and the pipeline they built is the
takeaway. If you want a hook for the Session 08 opener, ask the room out loud for one
thing they noticed or didn't understand today, and start next session there. For anyone
who *wants* more, the README has an optional "go further" section; mention it exists
rather than assigning it.

---

## If you're short on build time

Cut in this order — the session still works:

1. **Slide 4** (recap) — fold its one useful line into slide 1
2. **Slide 8** (the `on:` menu) — trim the table to the top four rows
3. **Slide 9** (`run` vs `uses`) — merge into slide 6's callouts

Never cut 5, 10, 11, or 12. Slide 5 is the mental model everything else depends on,
10 and 11 are the lab, and 12 is the reason they'll care.

**One risk to watch, now that both trigger slides come before the lab:** nobody touches
a keyboard until roughly the 30-minute mark. If the room is visibly restless by slide 8,
skim it in 90 seconds and move on — they'll get triggers again in the cheat sheet.
