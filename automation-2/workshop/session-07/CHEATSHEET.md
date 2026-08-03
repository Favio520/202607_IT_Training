# Session 07 cheat sheet

Keep this open in a second tab. One page, everything you need for the lab.

---

## Where to click

**Create the workflow**
Your repo → **Add file** → **Create new file** → filename:
`.github/workflows/ci.yml`
→ paste → **Commit changes** → commit to `main`

**Watch it run**
**Actions** tab → click the run → click the job (left side) → click a step to expand its log

**Edit it again**
Go to `.github/workflows/ci.yml` → pencil icon → edit → **Commit changes**

---

## The skeleton

```yaml
name: CI                    # shows in the Actions tab

on: push                    # what starts it

jobs:
  test:                     # job id — you pick the name
    runs-on: ubuntu-latest  # which machine
    steps:
      - uses: actions/checkout@v4    # someone else's code
      - run: npm test                # your shell command
```

## The six words

| Word | Means |
|---|---|
| `name` | Label in the Actions tab |
| `on` | The event that triggers the run |
| `jobs` | One or more jobs; **each gets its own fresh machine** |
| `runs-on` | Which machine image |
| `steps` | Commands, run top to bottom |
| `needs` | (later) make one job wait for another |

## `run` vs `uses`

- **`run:`** — a shell command you'd type in a terminal yourself
- **`uses:`** — a pre-built action published by someone else, always with a version:
  - `actions/checkout@v4` — copies your repo onto the machine
  - `actions/setup-node@v4` — installs Node
  - options go in a `with:` block underneath

## Triggers

```yaml
on:
  push:
    branches: [main]        # pushes to main
  pull_request:
    branches: [main]        # PRs targeting main -> check appears on the PR
  workflow_dispatch:        # adds a "Run workflow" button
```

There are more than 30 events. You'll use four:

| Event | Fires when |
|---|---|
| `push` | Commits land on a branch or tag |
| `pull_request` | A PR is opened or updated |
| `workflow_dispatch` | You click the Run workflow button |
| `schedule` | A cron time comes round |

Others exist for reacting to almost anything in a repo — `release`, `issues`,
`issue_comment`, `workflow_run`, and so on. Full list:
[docs.github.com → events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)

**Narrowing an event**

```yaml
on:
  push:
    branches: [main]          # only this branch
    paths: ['src/**']         # only when these files change
    tags: ['v*']              # only these tags
  pull_request:
    types: [opened, closed]   # only these activities
```

`paths:` is the easy money — a README edit shouldn't burn build minutes.

**Cron is in UTC.** 9am in Cochabamba is `0 13 * * *`. Or state it plainly:

```yaml
on:
  schedule:
    - cron: '0 9 * * 1-5'
      timezone: "America/La_Paz"
```

Scheduled runs only happen on the default branch, no faster than every 5 minutes,
and can be delayed when GitHub is busy. Use [crontab.guru](https://crontab.guru)
rather than memorising the field order.

---

## When nothing happens

Work down this list — it's almost always one of these four.

1. **Folder name typo.** It must be exactly `.github/workflows/`.
   `.github/worflows/` fails silently with no error anywhere.
2. **Tabs instead of spaces.** YAML forbids tabs. Two spaces per level.
3. **Wrong indentation depth.** `steps:` sits under `runs-on:`'s parent job,
   and each step starts with `- `.
4. **Pasted from a slide.** Slides mangle whitespace. Copy from the README.

## When it goes red

That's the pipeline doing its job. Open the failed step and read from the **bottom
up** — the last few lines hold the actual error. For a failed test, look for the
two values: what it **expected** and what it **actually** got.

---

## Vocabulary

- **workflow** — one YAML file in `.github/workflows/`
- **job** — a unit that gets its own fresh virtual machine
- **step** — a single command or action inside a job
- **runner** — the machine. Created for your run, destroyed after. Starts **empty** —
  which is why `actions/checkout` exists.
- **action** — reusable packaged code you pull in with `uses:`
