# Facilitator guide

Workshop: **Deploy a folder to Azure Storage with GitHub Actions**

Attendees end the session with a live URL serving a folder they created, deployed by a workflow they configured. Runs about 80 minutes for up to ~25 people — budget the extra time for Part 0, the fork setup.

---

## The shape of it

**One public training repository that every attendee forks.** Each attendee owns their fork, works on `main` in it, and deploys into a folder named after themselves.

What that buys you:

- **No concurrency ceiling.** Each fork's runs bill to that attendee's own account, and public repositories get unlimited Actions minutes. Twenty-five people can push at the exact same second and nothing queues. (This is the big advantage over a shared repo, where all runs draw on the org's single concurrent-job pool — 20 jobs on Free, 60 on Team.)
- **Total blast-radius isolation on the Git side.** Nobody can touch anyone else's copy, so there is nothing to merge and nothing to break.
- **The secret setup becomes part of the lesson.** Attendees add the credential to their own fork, which teaches secrets properly instead of hiding them.

And the three things it costs you — read these before the day, because each one will stop an attendee dead:

| | |
|---|---|
| **Forks do not inherit secrets** | A fork starts with an empty secret store. Every attendee must add `AZURE_STORAGE_CONNECTION_STRING` themselves, which means **you have to hand out the credential**. See the distribution section below. |
| **Actions is disabled in a fork** | GitHub deliberately switches workflows off in forks. Until each attendee clicks *"I understand my workflows, go ahead and enable them"* on the Actions tab, pushing does nothing at all — with no error to explain why. |
| **One shared storage account is the only shared thing** | Two people deploying the same folder name overwrite each other. The workflow now refuses to deploy while `SITE_FOLDER` is the default `site-sample`, which closes the realistic version of this. |

All three are in Part 0 of the attendee handout. Walk the room through Part 0 together rather than letting people self-serve it — it is pure setup with no learning in it, and stragglers here fall behind everywhere else.

> Script `02-seed-attendee-repos.sh` cannot help with the fork model: attendee forks live in their personal accounts and you have no admin on them. `MODE=perrepo` is only useful when your org creates the repositories.

---

## Before the day

Budget 25 minutes, and **fork the repo yourself and run the whole attendee path end to end.** Not a shortcut version — fork it, enable Actions, add the secret, make a folder, deploy. That fork is also what you demo from at 0:05, so you get the dry run and the demo prep in one pass.

Do not skip this. Every failure mode here — a stale credential, an org policy blocking forks, a typo in the endpoint variable — only appears on a real run.

> Note that the workflow refuses to deploy while `SITE_FOLDER` is the default `site-sample`, so your demo fork needs its own folder name just like everyone else's. That guard is what stops twenty-five people overwriting one another in the shared storage account.

> **Prefer clicking to scripting?** [`facilitator/PORTAL-SETUP.md`](facilitator/PORTAL-SETUP.md) does steps 1 and 3 below entirely in the Azure portal and the GitHub web UI — no `az`, no `gh`. Same end result. Use that instead of the scripts, then come back here for the run of show.

### 1. Create the Azure resources

```bash
cd facilitator
chmod +x *.sh
./01-azure-setup.sh
```

Optionally override the defaults:

```bash
LOCATION=westus2 RG=rg-amaxst-gh-workshop ./01-azure-setup.sh
```

This creates a resource group, a StorageV2 account, turns on static website hosting, and writes `workshop-credentials.txt` (mode 600) with the two values you need. **Do not commit that file.**

Public blob access stays disabled on the account. Static website hosting serves the `$web` container anonymously regardless of that setting, so attendees get a real public URL without you loosening anything else.

### 2. Create the public training repository

```bash
gh repo create amaxst/gh-azure-workshop --public --clone
# copy the contents of this kit in, then:
git add . && git commit -m "Workshop starter" && git push
```

**Public matters.** It makes forking frictionless and gives every attendee unlimited Actions minutes on their own fork. Leave `SITE_FOLDER` as `site-sample` on `main` — the workflow blocks that value on push, so nothing in your own repo self-deploys.

Do not add branch protection, and do not put secrets on this repo — attendees add them to their forks.

One caveat of public: **do not commit `workshop-credentials.txt`.** The kit's `.gitignore` already covers it, but check `git status` before your first push.

### 3. Decide how you hand out the credential

Attendees cannot inherit your secret, so you have to give them the connection string. You picked the full connection string on a public repo, which is the highest-exposure combination available — so treat these three as mandatory rather than advisory.

**Show it, do not broadcast it.** Put it on the projector, or a printed slip per table. Avoid Slack, email-to-all, or a shared doc: those keep a copy long after the session and spread it past the room.

**Say the "secrets box, nowhere else" line out loud, twice** — once in Part 0, once before the experiments. On a public fork, a credential committed to a file is world-readable and stays in the Git history even after deletion. GitHub secret-scanning push protection covers Azure storage keys and will most likely block such a push, but that is a backstop, not a plan; attendees can click through warnings.

**Rotate the key the moment the session ends.** Not that evening. Twenty-five people now hold full read/write/delete on the account, in personal repos you do not control:

```bash
az storage account keys renew --account-name <acct> -g <rg> --key primary
```

That instantly invalidates every copy. Attendee sites keep serving; only further deploys stop, which is exactly what you want.

> If that exposure is more than you want to carry, the smaller-blast-radius option is a container-scoped SAS token expiring the evening of the workshop — swap `--connection-string` for `--account-name` + `--sas-token` in the upload step. Worth doing if you run this more than once.

### 4. Fill in the handout

`ATTENDEE-HANDOUT.md` opens with a table of blanks — the repo to fork, the folder-name pattern, and the site base URL. Fill those in from `workshop-credentials.txt` and send it out the morning of. Leave the connection string out of the handout; hand that over live.

### 5. Sanity-check the room

- Everyone can sign in to GitHub **on the network they will be using.** Corporate SSO on guest wifi is the classic day-of blocker.
- Attendees can fork to their personal accounts. If your org applies a policy that blocks forking, sort that out in advance.
- If your org restricts which actions can run, allowlist `actions/checkout` — though on personal forks the attendee's own settings apply, not the org's.
- You have a screen to project the Actions tab on.

---

## Run of show

| Time | Segment | What you are doing |
|---|---|---|
| 0:00 | **Framing** (5 min) | The problem: "how does a folder on my laptop end up on a server without me dragging it anywhere?" Do not open the YAML yet. |
| 0:05 | **Live demo** (7 min) | Deploy from **your own fork**, set up exactly like theirs will be. Edit a file, commit, switch to Actions, let them watch it go green, open the URL. No explanation yet — just the loop. |
| 0:12 | **Part 0: fork and set up** (8 min) | Do this **together, in lockstep**, projector first: fork → enable Actions → add the secret and variable. Pure setup, no learning — do not let people self-serve it or you will lose stragglers for the rest of the session. Hand out the connection string here. |
| 0:20 | **Tour the workflow** (10 min) | Now open the YAML. Walk `on:` → `env:` → `steps:`. Land the trigger/steps distinction hard, because that is the concept Part 2 depends on. |
| 0:30 | **Part 1 + 2: hands-on** (20 min) | They create their folder and edit the two values. Circulate. This is where the time goes. |
| 0:50 | **Part 3: first deploy** (8 min) | Everyone pushes and watches. Put a couple of live URLs on the projector — the room reaction is the payoff. |
| 0:58 | **Part 4: experiments** (15 min) | A (normal deploy), B (path filter does nothing), C (manual dispatch). Debrief B out loud — it is the least intuitive and the most useful. |
| 1:13 | **Wrap** (10 min) | Secrets, what changes for production, questions. |

### Where it actually goes wrong

**Creating a folder in the GitHub web UI.** Most people do not know that typing `myfolder/index.html` in the filename box creates the folder. Demo it explicitly in the tour segment, on the projector, or you will explain it fifteen times individually.

**Editing one `EDIT ME` and not the other.** Expect this from a third of the room. The workflow fails loudly and lists the folders that do exist, so it is self-service — but say up front that the two values must match, and that the error message will tell them when they do not.

**Forgetting to enable Actions in the fork.** The symptom is indistinguishable from experiment B: they push, and nothing happens. Anyone reporting "no run appeared" before experiment B should be sent straight to their Actions tab to look for the enable banner.

**Confusing `paths:` with `SITE_FOLDER`.** Worth two minutes on the projector. Draw it: `paths:` is a gate before the run starts; `SITE_FOLDER` is a value used during the run.

---

## Things worth saying out loud

**On secrets.** The YAML is public; the connection string is not. Point out that when this credential rotates, you update one setting and every workflow keeps working — nothing gets edited, nothing gets redeployed. That is the actual argument for secrets, more than "hackers."

The fork model gives you a better version of this lesson than a shared repo does: they had to add the secret themselves, and they can see it is unreadable afterwards even to them. Point at that. It also means you can say honestly that *you* cannot see their copy either — the credential is now in twenty-five places, which is exactly why you will rotate it at the end.

**On why the upload step is a loop.** It sets `Content-Type` per file explicitly. Ask what happens if you serve `index.html` as `application/octet-stream` — the browser downloads it instead of rendering it, and you get a "my deploy worked but the site is broken" bug that looks like nothing. There is a commented one-line `upload-batch` alternative in the file for after they understand what it is doing.

**On what production adds.** Be straight that a connection string in a secret is the training-wheels version. Real pipelines use OIDC federated identity: GitHub proves who it is to Azure, no stored credential at all. Mention it, do not teach it — the app registration per attendee would eat the session.

**On idempotency.** Running the workflow twice with no changes is safe. `--overwrite true` means re-uploading the same bytes is a no-op from the attendee's point of view. Ask them why that property matters for a deploy tool.

**On the one thing that is shared.** Worth naming explicitly, because it is the question every sharp attendee asks: their repositories are completely separate, but the storage account is not. The folder name is the only thing keeping their page distinct from their neighbour's. That is why the workflow refuses to deploy the default `site-sample` on a push — and it is a decent illustration of how real multi-tenant systems work, where isolation is a naming convention somebody has to enforce.

---

## Cost

Effectively nothing. A Standard_LRS StorageV2 account holding a few hundred KB of HTML for a day is well under a cent, and GitHub Actions on public repos is free (private repos draw on your org's included minutes — each run here is roughly 30 seconds).

Delete the resource group afterwards anyway.

---

## Teardown

```bash
cd facilitator
./03-teardown.sh
```

It reads the resource group from `workshop-credentials.txt`, shows you what is about to be deleted, and requires you to type the group name. Then:

- Leave the training repo up as reference — attendee forks stay linked to it. You cannot delete their forks, and do not need to.
- Shred `workshop-credentials.txt`.
- If the repo stays alive, rotate the storage keys so the old connection string in Actions history is dead: `az storage account keys renew --account-name <acct> -g <rg> --key primary`

---

## Files in this kit

```
.github/workflows/deploy-to-azure.yml   the workflow attendees copy and edit
site-sample/                            sample folder: index.html, styles.css, data.json
ATTENDEE-HANDOUT.md                     give this to attendees
FACILITATOR-GUIDE.md                    this file
facilitator/PORTAL-SETUP.md             click-by-click setup, no CLI needed
facilitator/01-azure-setup.sh           create Azure resources, emit credentials
facilitator/02-seed-attendee-repos.sh   secret/variable seeding (org-owned repos only)
facilitator/03-teardown.sh              delete everything
```
