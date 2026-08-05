# Workshop: deploy a folder to Azure Storage with GitHub Actions

A 60–75 minute hands-on workshop. Attendees create a folder, change two lines in a GitHub Actions workflow, push, and watch their folder appear on a live URL served from Azure Storage.

No Azure account, no CLI, and no local tooling needed on the attendee side — everything can be done in the GitHub web UI.

## Start here

| You are… | Read |
|---|---|
| Running the workshop | [`FACILITATOR-GUIDE.md`](FACILITATOR-GUIDE.md) |
| Setting up Azure by clicking, not scripting | [`facilitator/PORTAL-SETUP.md`](facilitator/PORTAL-SETUP.md) |
| Attending it | [`ATTENDEE-HANDOUT.md`](ATTENDEE-HANDOUT.md) |

## The 30-second version

1. Facilitator creates a storage account with static website hosting on — via `facilitator/01-azure-setup.sh`, or by hand using `facilitator/PORTAL-SETUP.md`.
2. Facilitator pushes this kit to a **public** training repo and hands out the connection string during the session.
3. Each attendee **forks** the repo, enables Actions on their fork, adds the credential as a secret, and copies `site-sample/` to `site-<their-name>/`.
4. Each attendee changes **two** values in `.github/workflows/deploy-to-azure.yml` — the `paths:` filter and `SITE_FOLDER`.
5. They push. The workflow triggers, uploads their folder, and prints a clickable live URL in the run summary.

## What it teaches

- **Triggers vs. steps** — `on:` decides whether a workflow runs; the steps decide what it does.
- **Path filters** — how a repo can hold much more than the thing it deploys without every push shipping. There is a deliberate experiment where the workflow correctly does *nothing*.
- **`workflow_dispatch`** — a manual run button with optional inputs, as an escape hatch.
- **Secrets** — the credential lives in repository settings, never in the YAML.
- **Content types** — why a successful deploy can still produce a broken page.

## Contents

```
.github/workflows/deploy-to-azure.yml   the workflow attendees copy and edit
site-sample/                            sample folder to copy
ATTENDEE-HANDOUT.md                     step-by-step walkthrough + experiments
FACILITATOR-GUIDE.md                    prep, run of show, failure modes, teardown
facilitator/PORTAL-SETUP.md             click-by-click setup, no CLI needed
facilitator/01-azure-setup.sh           create Azure resources
facilitator/02-seed-attendee-repos.sh   seed GitHub secret/variable, invite people
facilitator/03-teardown.sh              delete everything
```

## Requirements

**Facilitator:** an Azure subscription and admin on a GitHub repo. Azure CLI (`az login`) and GitHub CLI (`gh auth login`) if you use the scripts — not needed if you follow the portal guide instead.

**Attendee:** a GitHub account and a browser. They fork the training repo, so Actions minutes come from their own account — free and unlimited on a public fork.
