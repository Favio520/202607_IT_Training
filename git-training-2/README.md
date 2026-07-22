# Git Undoing Changes & Conflicts — Hands-On Practice

Companion exercises for **Git Essentials 02: Undoing Changes & Conflicts**.
Work through the parts in order. Each part matches a section of the workshop PDF.

**Requirements:** Git installed (`git --version`), a terminal, and a GitHub account (Part 5 only).

---

## Part 1 — The "Oops" Button (`git restore`)

**Goal:** Discard local uncommitted changes safely.

1. Make a messy, throwaway edit:
   ```bash
   change hello-world/hello-world.py to something broken
   ```
2. Check what Git sees:
   ```bash
   git status
   ```
3. Throw it away:
   ```bash
   git restore hello-world/hello-world.py
   ```
   **Checkpoint ✅** — `git status` is clean again; the file matches the last commit.

> ❗ **Note:** Changes discarded this way are unrecoverable — there is no undo for `git restore`.

---

## Part 2 — Fixing the Last Commit (`git commit --amend`)

**Goal:** Correct a commit message or bundle a forgotten file without a new "fix" commit.

1. Fix a typo in your last commit message:
   ```bash
   git commit --amend
   ```
2. Or, if you forgot a file:
   ```bash
   git add forgotten_file.py
   git commit --amend --no-edit
   ```

> ❓ **Think:** Why is `--amend` only safe on commits you haven't pushed/shared yet?

---

## Part 3 — Parking Work-in-Progress (`git stash`)

**Goal:** Shelve incomplete work so you can switch branches without committing broken code.

1. Make an uncommitted edit on your current branch.
2. Park it:
   ```bash
   git stash
   ```
3. Switch branches, do whatever you needed to do, then come back.
4. Bring your work back:
   ```bash
   git stash pop
   ```

**Checkpoint ✅** — Your uncommitted edit is back exactly where you left it.

### 🔥 Drill — trigger the "switch branch needs stash" error

Normally Git will happily carry an uncommitted edit across a branch switch. It only **blocks** the switch when the target branch has a *different committed version* of the same lines. Force that:

```bash
git switch -c feature-branch-2
echo 'print("Hello, ABC!")' > hello-world/hello-world.py   # uncommitted edit, do NOT commit

git stash                # set this aside for a moment
git switch main
echo 'print("Hello, from Main!")' > hello-world/hello-world.py
git add hello-world/hello-world.py
git commit -m "Update greeting on main"

git switch feature-branch-2
git stash pop             # brings back the uncommitted "Hello, ABC!" edit

git switch main            # <-- try this now
```

#### Expected result: switch blocked ❌

```text
error: Your local changes to the following files would be overwritten by checkout:
        hello-world/hello-world.py
Please commit your changes or stash them before you switch branches.
Aborting
```

Fix it the way the error tells you to:
```bash
git stash
git switch main
```

> ❓ **Think:** Why did Git allow the *first* switch (before `main` had a divergent commit) but block the second one?

---

## Part 4 — Simple Merge Conflicts

**Goal:** Recognize and resolve a real conflict.

1. Edit the **same line** of `hello-world/hello-world.py` differently on two branches (or one branch vs. the committed version on `main`), then attempt a merge:
   ```bash
   git merge <branch-name>
   ```
2. Open the file and find the conflict markers:
   ```
   <<<<<<< HEAD (Current Change)
   const timeout = 5000;
   =======
   const timeout = 3000;
   >>>>>>> feature-branch (Incoming Change)
   ```
3. **The Golden Rule:** Read both sides. Never blind-accept. Delete all three markers and leave only the final code you want.
4. Stage and commit the resolution:
   ```bash
   git add hello-world/hello-world.py
   git commit
   ```

### 🔥 Drill — trigger a real merge conflict

Continuing from the drill above, `main` and `feature-branch-2` now have **different committed content** on the same line of `hello-world.py` — that's exactly what's needed for `git merge` to conflict instead of just fast-forwarding:

```bash
git switch feature-branch-2
git add hello-world/hello-world.py
git commit -m "Update greeting on feature-branch-2"   # commit the "Hello, ABC!" line

git switch main
git merge feature-branch-2
```

#### Expected result: merge conflict ❌

```text
Auto-merging hello-world/hello-world.py
CONFLICT (content): Merge conflict in hello-world/hello-world.py
Automatic merge failed; fix conflicts and then commit the result.
```

Open the file, you'll see:

```text
<<<<<<< HEAD
print("Hello, from Main!")
=======
print("Hello, ABC!")
>>>>>>> feature-branch-2
```
Resolve it (delete the markers, keep the line you want), then:
```bash
git add hello-world/hello-world.py
git commit
```

---

## Part 5 — Interactive Exercise: Pull Request

**Task:** Create a branch, change a line in `hello-world` or `bye-world`, and send a Pull Request to `main`.

> **Why a Pull Request instead of pushing directly to `main`?**
> Pushing directly to a shared `main` branch is dangerous and causes chaos. PRs enforce code review, trigger automated testing, and provide a safe UI to spot and resolve conflicts before they break production.

Steps:
```bash
git switch -c my-fix
change a line in hello-world/hello-world.py
git add hello-world/hello-world.py
git commit -m "Update greeting"
git push -u origin my-fix
```
Then open a Pull Request on GitHub targeting `main`.

---

## Part 6 — Fixing History (`git revert`)

**Goal:** Safely undo a commit that's already been pushed and shared.

```bash
# Revert a specific commit (creates a new commit that undoes it)
git revert <commit-hash>

# Revert without auto-committing, so you can review first
git revert -n <commit-hash>
```

> ❓ **Think:** Why does `revert` create a *new* commit instead of deleting the bad one?

---

## Part 7 — The Dangerous Command (`git reset --hard`)

**Goal:** Understand when a destructive rewind is (and isn't) okay.

```bash
# DANGER: Discard all local modifications
git reset --hard HEAD

# Force local branch to match origin
git reset --hard origin/main
```

> ⚠️ **NEVER use on shared branches.** Rewinding a public branch diverges your history from teammates and causes a web of merge conflicts. Only use `reset --hard` on private, local, disposable branches.

---

## Quick Reference Card

| Command | What it does |
|---|---|
| `git restore <file>` | Discard uncommitted changes to a file (unrecoverable) |
| `git restore .` | Discard uncommitted changes to the whole directory |
| `git commit --amend` | Rewrite the last commit's message |
| `git commit --amend --no-edit` | Add staged changes to the last commit, keep its message |
| `git stash` | Shelve uncommitted changes |
| `git stash pop` | Restore and remove the latest stashed changes |
| `git merge <branch>` | Bring another branch's commits into the current branch |
| `git revert <commit-hash>` | Create a new commit that undoes an existing one |
| `git reset --hard <ref>` | Permanently rewind the branch and discard changes |
