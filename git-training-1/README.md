# Git Basics — Hands-On Practice

Companion exercises for **Git Basics: Modern Version Control**.
Work through the parts in order. Each part matches a section of the workshop.

**Requirements:** Git installed (`git --version`), a terminal, and a GitHub account (Part 4 only).

**One-time setup** (skip if you've used Git on this machine before):

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

---

## Part 1 — Initializing a Repository (`git init`)

**Goal:** Turn an ordinary folder into a Git workspace.

1. Check the folder is *not* a repository yet:
   ```bash
   git status
   ```
   > ❓ What error do you get? Why?
2. Initialize the repository:
   ```bash
   git init
   ```
3. Prove the hidden `.git` directory exists:
   ```bash
   ls -a        # Windows PowerShell: ls -Force
   ```

**Checkpoint ✅** — `git status` now says `On branch main` (or `master`) with `No commits yet`.

> ❓ **Think:** What happens if you delete the `.git` folder? What would you lose?

---

## Part 2 — Core Commands & Atomic Commits

**Goal:** Practice `status`, `add`, `commit`, `log` — and keep each commit to *one logical unit of work*.

1. Edit two files:
   ```bash
   change to 'print("Hello, edgar!")'
   change to 'print("Bye, edgar!")'
   ```
2. **Do NOT run `git add .`** — these are two different logical changes.
   Stage and commit them **separately**:
   ```bash
   git add hello-world/hello-world.py
   git commit -m "Add hello-world script"

   git add bye-world/bye-world.py
   git commit -m "Add bye-world script"
   ```
3. View your history:
   ```bash
   git log --oneline
   ```
   **Checkpoint ✅** — You see 4 commits, newest first, each with a short hash.

4. **Bad commit message drill.** Which of these is the best message, and why?
   - `update`
   - `fix stuff`
   - `Fix login form validation for empty email`
   - `changed project.py, README.md, styles.css and other files`

5. **Rollback preview (just look, don't run):**
   ```bash
   git log --oneline
   ```
   > ❓ If `hello-world/hello-world.py` had a bug, which single commit would you need to inspect? How does committing atomically make that answer easy?

---

## Part 3 — Branching & Merging

**Goal:** Build a feature in an isolated branch, then merge it back into a clean `main`.

1. Confirm where you are:
   ```bash
   git branch
   ```
2. Create and switch to a feature branch:
   ```bash
   git switch -c feature-greeting
   ```
   > ❓ What does the `-c` flag do? What happens if you omit it?
3. Make a change **on the branch**:
   ```bash
   change to 'print("Hello, Dennis!")'
   ```
4. Stage and commit the change:
   ```bash
   git add hello-world/hello-world.py bye-world/bye-world.py
   git commit -m "Update greeting to Dennis"
   ```
5. Prove `main` is untouched:
   ```bash
   git switch main
   cat hello-world/hello-world.py
   ```
   **Checkpoint ✅** — The greeting line is *gone* on `main`. (It's safe on the branch!)
6. Merge the approved feature:
   ```bash
   git merge feature-greeting
   cat hello-world/hello-world.py
   ```
   **Checkpoint ✅** — The greeting is now on `main`, and `git log --oneline` shows the branch commit.
7. Clean up:
   ```bash
   git branch -d feature-greeting
   ```

> ❓ **Think:** Why should `main` always stay deployable? What kind of code is allowed to live there?

### 🔥 Bonus challenge — your first merge conflict
1. Create branch `feature-a`, change line 1 of `README.md`, commit.
2. Switch back to `main`, change the **same line** differently, commit.
3. Run `git merge feature-a` and read the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
4. Edit the file to keep the version you want, then `git add README.md` and `git commit`.

---

## Part 4 — Remotes: Push, Pull & Clone

**Goal:** Connect your local repository to GitHub and complete the full sync cycle.

1. On GitHub: click **New**, name the repository `git-practice`, keep it **empty** (no README, no .gitignore), and create it.
2. Link your local repo and push:
   ```bash
   git remote add origin https://github.com/YOUR-USERNAME/git-practice.git
   git push -u origin main
   ```
   **Checkpoint ✅** — Refresh GitHub; all your files and commits are visible.
3. Simulate a teammate's change: on GitHub, edit `README.md` directly in the browser and commit it there.
4. Pull the remote change down:
   ```bash
   git pull origin main
   cat README.md
   ```
   **Checkpoint ✅** — The browser edit now exists locally.
5. Practice `clone` — download the whole project fresh, as a new teammate would:
   ```bash
   cd ..
   git clone https://github.com/YOUR-USERNAME/git-practice.git git-practice-clone
   cd git-practice-clone
   git log --oneline
   ```
   **Checkpoint ✅** — The clone contains the *entire* history, not just the latest files.

> ❓ **Think:** When do you use `clone` vs `pull`? Which direction does `push` move data?
> 
---

## Quick Reference Card

| Command | What it does |
|---|---|
| `git init` | Turn a folder into a repository |
| `git status` | Show the state of every file — run it constantly |
| `git add <file>` | Stage a change (use `git add .` with caution) |
| `git commit -m "msg"` | Snapshot the staged changes permanently |
| `git log --oneline` | Compact history view |
| `git switch -c <name>` | Create and switch to a new branch |
| `git merge <name>` | Bring a branch's commits into the current branch |
| `git remote add origin <url>` | Link a local repo to GitHub |
| `git push origin main` | Upload local commits to the remote |
| `git pull origin main` | Download and merge remote commits |
| `git clone <url>` | Copy an entire remote repository locally |