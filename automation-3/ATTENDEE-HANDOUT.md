# Deploy a folder to Azure with GitHub Actions

**Time:** about 35 minutes · **You need:** a GitHub account and a browser. No Azure account, no CLI, no local setup.

By the end you will have pushed a folder to GitHub and watched an automated workflow copy it to Azure Storage, then opened it as a live web page.

---

## What you have been given

| Thing | Value |
|---|---|
| Repository to fork | `_______________________________________` |
| Your folder name | `site-<your-github-username>` |
| Live site base URL | `_______________________________________` |
| Connection string | handed out during the session |

You will be working in **your own fork** of the training repository, so nothing you do can affect anyone else's work.

One thing *is* shared: everyone uploads into the same Azure storage account. Your folder name is what keeps your page separate from everyone else's, which is why it has to be your username and not something generic.

---

## Part 0 — Fork it and set it up

Three quick pieces of housekeeping that only apply because you are working in your own copy.

**1. Fork the repository.**

Open the training repo and click **Fork** (top right) → **Create fork**. You now have your own copy at `github.com/<your-username>/<repo-name>`.

**2. Turn on Actions in your fork.**

Click the **Actions** tab. You will see a banner saying workflows are disabled. Click **"I understand my workflows, go ahead and enable them."**

Forks arrive with Actions switched off — that is deliberate on GitHub's part, so a fork cannot start running things unexpectedly. Nothing will deploy until you do this.

**3. Add the credential to your fork.**

Forking does **not** copy secrets. Your fork starts with an empty secret store, so you have to add the credential yourself:

- **Settings** → **Secrets and variables** → **Actions**
- **Secrets** tab → **New repository secret**
  - Name: `AZURE_STORAGE_CONNECTION_STRING`
  - Secret: paste the connection string your facilitator gave you
- **Variables** tab → **New repository variable**
  - Name: `AZURE_WEB_ENDPOINT`
  - Value: the live site base URL from the table above

> ### Paste the connection string into that box and nowhere else
>
> **Your fork is public.** Anything you commit to a file in it is visible to the entire internet, permanently, even if you delete it afterwards.
>
> The connection string is a password for the storage account. It belongs in the **Secrets** box, which is write-only and masked out of logs. It does **not** belong in the workflow file, in a comment, in a README, or in `data.json`.
>
> If you paste it into a file by accident, GitHub will most likely block the push and warn you. Do not try to work around that warning — tell your facilitator instead, so the credential can be replaced.

---

## Part 1 — Make your own folder

You can do all of this in the GitHub web UI. No `git` required. You are in your own fork now, so work directly on `main` — no branches needed.

**1. Copy the sample folder under your own name.**

The repo has a folder called `site-sample`. Make your own copy of it:

- Click **Add file → Create new file**
- In the filename box type: `site-<your-username>/index.html`
  (typing the `/` creates the folder — this is how you make folders in the web UI)
- Open `site-sample/index.html` in another tab, copy all of it, paste it in
- **Commit changes**

Repeat for `styles.css` and `data.json`.

> Working locally instead? `cp -r site-sample site-<your-username>` and you are done.

**2. Put your name on it.**

In your `index.html`, find this line and replace `your name here`:

```html
<h1>Hello from <span class="name">your name here</span></h1>
```

Commit it.

---

## Part 2 — Point the workflow at your folder

Open `.github/workflows/deploy-to-azure.yml` and click the pencil icon to edit.

There are exactly **two** things to change. Both are marked `# <<< EDIT ME`.

**Edit 1** — near the top, under `on: push: paths:`

```yaml
on:
  push:
    paths:
      - 'site-sample/**'          # <<< EDIT ME (1 of 2)
```

becomes

```yaml
on:
  push:
    paths:
      - 'site-YOURNAME/**'        # <<< EDIT ME (1 of 2)
```

**Edit 2** — a few lines below, under `env:`

```yaml
env:
  SITE_FOLDER: site-sample        # <<< EDIT ME (2 of 2)
```

becomes

```yaml
env:
  SITE_FOLDER: site-YOURNAME      # <<< EDIT ME (2 of 2)
```

The two values **must match each other exactly** — same spelling, same case. Keep the `/**` on the first one and do not add it to the second.

Commit it.

> The workflow refuses to deploy while `SITE_FOLDER` is still `site-sample`, and tells you so. That is on purpose — everyone shares one storage account, so two people deploying `site-sample` would overwrite each other's page.

### What did you just change?

- **`paths:`** is a filter on the trigger. It decides *whether the workflow runs at all*. Without it, every push anywhere in the repo would kick off a deploy.
- **`SITE_FOLDER`** is a variable the steps read. It decides *what gets uploaded* once the workflow has started.

They are two separate mechanisms that happen to need the same value. Forgetting one of them is the single most common mistake in this workshop — and the workflow is written to tell you clearly when it happens.

---

## Part 3 — Watch it trigger

You already pushed a commit that touches the workflow file, so a run has probably started. Go to the **Actions** tab.

Click into the run and watch:

1. **Why did this run?** — prints the event, branch, and commit message
2. **Work out which folder to deploy** — resolves and sanity-checks your folder
3. **Upload files to Azure Storage** — one line per file, with its content type
4. **Write the run summary** — go back to the run's main page

The summary at the top of the run page has a **clickable link to your live site**. Open it.

> Use that link rather than typing a URL by hand. It ends in `/index.html` on purpose — a bare folder URL like `.../site-yourname/` is not guaranteed to find your index page and will show the site's error page instead.

You should see your page, with your name on it, served from Azure.

---

## Part 4 — Three experiments

This is the part worth your attention. Do all three.

### Experiment A — a normal deploy

Edit your `styles.css` and change the accent colour:

```css
--accent: #0f6cbd;   /* try #b8336a or #157a5b */
```

Commit. Watch the Actions tab. Reload your live URL.

**Expected:** the workflow runs, the colour changes. Note how long the whole loop took.

### Experiment B — prove the path filter works

Create a file at the **root** of the repo called `notes-<your-username>.md` with any text in it. Commit it.

Now go to the Actions tab.

**Expected: nothing happens.** No new run. Your commit pushed fine, but the path filter says "only run when something under `site-YOURNAME/**` changes," and that file is not in your folder.

This is what `paths:` buys you. In a real project the repository holds far more than the thing you deploy — docs, tests, configuration, other people's code. Without the filter, editing the README would redeploy the website.

### Experiment C — the manual trigger

In the Actions tab, pick **Deploy folder to Azure Storage** in the left sidebar. You get a **Run workflow** button.

Choose `main`, leave the folder box empty, and run it.

**Expected:** it deploys the same folder as before, with no code change at all.

Now try again, but type a neighbour's folder name into the box — it deploys *their* folder from your fork instead of yours. A manual run overrides what the file says.

`workflow_dispatch` is how you re-run a deploy without a code change, and how you pass in one-off parameters. It is also your escape hatch when something has gone wrong and you just want to try again.

---

## When something breaks

| What you see | What it means |
|---|---|
| No run appears at all | Either you never enabled Actions in your fork (Part 0, step 2), or your change was outside the folder in the `paths:` filter — that is Experiment B. |
| `Folder 'site-x' does not exist` | Typo, or you changed `SITE_FOLDER` but not `paths:`. The error lists the folders that do exist — compare them character by character. |
| `Secret AZURE_STORAGE_CONNECTION_STRING is not set` | You have not added it to your fork yet, or the name is misspelled. Forks do not inherit secrets — see Part 0, step 3. |
| `SITE_FOLDER is still set to the default` | You did Edit 1 but not Edit 2. The workflow blocks the default name so attendees cannot overwrite each other. |
| Run is green but the URL 404s | Give it 10 seconds and hard-reload (Cmd/Ctrl + Shift + R). Then check you included the filename: `.../site-yourname/index.html`, not `.../site-yourname/` |
| You see a "Workshop storage is live" page instead of yours | You asked for the folder without the filename. A bare folder URL is not guaranteed to find its index page, so it falls through to the site's error page. Add `/index.html` on the end. |
| Page loads as plain text or downloads | A content type problem. The workflow sets these explicitly, so this usually means an unusual file extension. |
| `AuthenticationFailed` or `AuthorizationFailure` | The connection string has expired or been rotated. Facilitator's problem, not yours. |
| Build number says "could not load data.json" | You created `index.html` but not `data.json` in your folder. |

---

## What to take away

Four ideas, in order of how much they will matter to you later:

1. **A workflow is a trigger plus steps.** Most of the work in real pipelines is being precise about the trigger, not the steps.
2. **Path filters scope the trigger.** A repository holds much more than the thing you deploy, and the filter is what stops unrelated edits from shipping.
3. **Secrets stay out of the file.** The YAML is public; the connection string is not. Rotating a credential means updating one setting, not editing code — and the fact that you had to add the secret yourself is the mechanism working as designed, not an inconvenience.
4. **Always give yourself a manual trigger.** `workflow_dispatch` costs two lines and saves you on the day something is on fire.

### If you want to go further

- Add a branch to your fork that deploys to a preview prefix, so only `main` publishes to the real one.
- Replace the connection-string secret with OIDC federated credentials — no stored secret at all.
- Add a step that purges a CDN cache after upload.
- Use `actions/upload-artifact` to keep a copy of what was deployed.
