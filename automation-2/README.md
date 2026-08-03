# GitHub Actions Workshop

A deliberately tiny project: a one-page website plus one small function with three
tests. Small enough that nothing distracts from the pipeline we build around it.

You will use this same repo for Sessions 07 through 10.

---

## Before Session 07 (5 minutes — please do this ahead of time)

1. Sign in to GitHub.
2. Go to this repository and click **Use this template → Create a new repository**.
3. Name it `actions-workshop-<yourname>` and keep it **public** (public repos get
   unlimited Actions minutes).
4. Open your new repo and confirm you can see `index.html` and `src/`.

That's it — no cloning, no installs. Everything in Session 07 happens in the browser.

---

## What's in here

| Path | What it is |
|---|---|
| `index.html` | The website. Type a title, see its URL slug. |
| `src/format.js` | The `slugify()` function — the thing we test. |
| `src/format.test.js` | Three tests, using Node's built-in test runner. |
| `package.json` | `npm test` and `npm run lint`. |
| `workshop/session-07/CHEATSHEET.md` | **Keep this open during the lab.** One page. |
| `workshop/session-07/` | Reference workflows. Try writing your own first. |

There is intentionally **no `.github/workflows/` folder**. You are going to create it.

---

## Session 07 lab

### Step 1 — Your first workflow

1. In your repo, click **Add file → Create new file**.
2. For the filename, type exactly: `.github/workflows/ci.yml`
   (typing the `/` creates the folders for you)
3. Paste this in:

   ```yaml
   name: CI

   on: push

   jobs:
     hello:
       runs-on: ubuntu-latest
       steps:
         - name: Say hello
           run: echo "Hello from GitHub Actions"
   ```

4. **Commit changes** → commit directly to `main`.
5. Click the **Actions** tab. Your workflow is already running.
6. Click into the run, then into the `hello` job, and expand the step to see
   your `echo` output.

You just built a CI pipeline. Congratulations.

> **Question to sit with:** the workflow ran on a computer you have never seen,
> that was created for this run and destroyed afterwards. Where did it get the code?

### Step 2 — Make it test the code

The answer to that question: it didn't. The machine was empty. Let's fix that.

Edit `.github/workflows/ci.yml` (pencil icon) and replace the whole file:

```yaml
name: CI

on: push

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Get the code
        uses: actions/checkout@v4

      - name: Install Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Run tests
        run: npm test
```

Commit, then watch the Actions tab. You should see three passing tests.

**New concepts:**

- `uses:` runs an action — reusable code someone else published.
- `actions/checkout@v4` copies your repository onto the runner. Almost every
  workflow starts with this.
- `actions/setup-node@v4` installs Node. The `with:` block passes it options.
- `@v4` is the version. Always pin it.

### Step 3 — Break it on purpose

Open `src/format.test.js` and change the first test's expected value from
`'hello-world'` to `'hello_world'`. Commit.

1. Watch the run go red.
2. Open the failed step and read the error. Find the two numbers: what the test
   expected and what it actually got.
3. Fix it and watch it go green again.

This is the whole point of CI. The check found a wrong assumption in seconds,
with no human reviewing anything.

### Step 4 — More triggers

Right now the workflow only runs on push. Replace the `on:` block:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

Commit, then:

- Go to **Actions → CI** and use the **Run workflow** button (`workflow_dispatch`).
- Create a branch, change something small, and open a pull request. The check now
  appears **on the PR itself** — this is how teams block broken code from merging.

---

## Optional — if you want to go further

Nothing here is assigned. Ignore it entirely if you'd rather stop at a green check.

Add a fourth test to `src/format.test.js` describing behaviour you think `slugify()`
*should* have. If it fails, decide which was wrong: the function, or your expectation.
There are real gaps to find — try a title that starts with a number, or one that's
nothing but emoji.

Two more things worth trying:

- `.github/workflows/` can hold more than one file. Add `lint.yml` that runs
  `npm run lint` and watch both checks appear — there's a starting point in
  `workshop/session-07/stretch-lint.yml`. Notice it needs an install step, and the
  test workflow doesn't. Why?
- Look at the `on: schedule` documentation. What would you run on a timer?

---

## Running it locally (optional)

```bash
npm test                 # run the tests
npm install && npm run lint
python3 -m http.server    # then open http://localhost:8000
```

The site must be served over HTTP, not opened as a `file://` path — browsers
block ES module imports from the filesystem.
