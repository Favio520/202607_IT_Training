# Portal setup (no CLI)

Do this once, before the workshop. About 15 minutes.

This is the click-by-click alternative to `01-azure-setup.sh` and `02-seed-attendee-repos.sh`. You end up with exactly the same thing: a storage account serving a public website, and two values sitting in your GitHub repo.

**What you are collecting.** Two values. Write them down as you go — everything else is scaffolding.

| # | Value | Goes into GitHub as |
|---|---|---|
| A | Connection string | a **secret** named `AZURE_STORAGE_CONNECTION_STRING` |
| B | Primary endpoint URL | a **variable** named `AZURE_WEB_ENDPOINT` |

---

## Part 1 — Create the storage account

**1.** Go to [portal.azure.com](https://portal.azure.com) and sign in.

**2.** In the top search bar, type `storage accounts` and pick **Storage accounts** from the results.

**3.** Click **+ Create**.

**4.** Fill in the **Basics** tab:

| Field | What to put |
|---|---|
| Subscription | whichever you are using |
| Resource group | **Create new** → `rg-gh-azure-workshop` |
| Storage account name | something globally unique, lowercase letters and digits only, 3–24 chars — e.g. `stghwks` + today's date, like `stghwks260804` |
| Region | pick the one closest to your attendees |
| Primary service | **Azure Blob Storage or Azure Data Lake Storage Gen2** |
| Performance | **Standard** |
| Redundancy | **Locally-redundant storage (LRS)** — cheapest, fine for a workshop |

If the name is taken the portal tells you immediately with a red mark. Add digits until it goes green.

> **Why LRS and Standard?** This is throwaway infrastructure holding a few hundred KB of HTML for a day. Anything more redundant is money for nothing.

**5.** Click through to the **Advanced** tab and check these:

| Setting | Value | Why |
|---|---|---|
| Require secure transfer for REST API operations | **checked** (default) | HTTPS only |
| Allow enabling anonymous access on individual containers | **UNCHECKED** | See the note below |
| Minimum TLS version | **Version 1.2** (default) | |
| Enable hierarchical namespace | **unchecked** | HNS changes how blobs behave; leave it off |

> **The anonymous-access checkbox is the one people get wrong.** Leave it unchecked. You do *not* need it. Static website hosting serves the `$web` container publicly no matter what that setting says — it is a separate mechanism. So attendees still get a working public URL, and you have not opened up every other container in the account. If you check the box "to be safe," you have made the account more exposed for no benefit.

**6.** Skip the remaining tabs. Click **Review + create**, then **Create**.

Deployment takes 30–60 seconds. When it finishes, click **Go to resource**.

---

## Part 2 — Turn on static website hosting

This is what gives attendees a real URL they can open in a browser.

**7.** On your storage account's **Overview** page, select the **Capabilities** tab, then click **Static website**.

> Can't find it? There is also a **Static website** entry in the left-hand menu, under **Data management**. Both go to the same page. If neither appears, your account is not GPv2 or BlockBlobStorage — go back and recreate it with the settings in step 4.

**8.** On that page:

- **Static website**: flip it to **Enabled**
- **Index document name**: `index.html`
- **Error document path**: `404.html`   ← *not* `index.html`

**9.** Click **Save**.

> **Why the error document must be different from the index document.** Static website hosting only guarantees the index document at the **root** of the site. A request to a subfolder — `/site-alice/` with no filename — is not guaranteed to resolve to that folder's `index.html`, and falls through to the error document instead. If the error document were `index.html`, every attendee visiting their own folder URL would be served the *root landing page*, and the whole room would appear to be sharing one identical site. Pointing it at a separate `404.html` makes a miss look like a miss.
>
> The practical rule, which the workflow's run summary already follows: hand out `/site-alice/index.html`, never `/site-alice/`.

**10.** The page now shows a **Primary endpoint**. It looks like:

```
https://stghwks260804.z13.web.core.windows.net/
```

**Copy it — this is value B.** Note the `z13` bit varies by region, so you cannot guess this URL; you have to read it here.

Saving also creates a container called `$web` for you. That is where the workflow uploads to.

---

## Part 3 — Upload the landing page and the 404 page (5 minutes)

Not optional any more, given the error-document note above: you need a `404.html` in place, or a mistyped URL shows a blank Azure error that tells attendees nothing.

**11.** Left menu → **Data storage** → **Containers**. You should see `$web` in the list. Click it.

**12.** Create two small files on your machine:

`index.html` — anything, e.g. *"Workshop storage is live. Your page is at /your-folder/index.html"*

`404.html` — something that names the likely cause, e.g. *"Nothing at this address. Asking for a folder? Add the filename: /your-folder/index.html"*

**13.** Click **Upload** and upload both. Before confirming, expand **Advanced** and set **Blob type** to **Block blob**. Leave everything else alone.

Now visit your primary endpoint — you should see your landing page. Then visit your endpoint with `/nonsense/` on the end; you should see your 404 page, not the landing page. If you see the landing page, the error document is still set to `index.html` — go back to step 8.

> If it downloads the file instead of displaying it, the content type is wrong. Click the blob → **Edit** tab is not it — go to the blob's **Overview**, click **Edit properties** (or the properties pencil), and set **Content-Type** to `text/html`. This is the exact bug the workshop's upload step is written to prevent, so it's a useful thing to have seen yourself.

---

## Part 4 — Get the connection string

**14.** Left menu → **Security + networking** → **Access keys**.

**15.** Click **Show keys** at the top.

**16.** Under **key1**, find the **Connection string** row and click its **Copy** button.

**Paste it somewhere safe — this is value A.** It looks like:

```
DefaultEndpointsProtocol=https;AccountName=stghwks260804;AccountKey=very+long+base64+string==;EndpointSuffix=core.windows.net
```

> **Treat this like a password.** It contains a key granting full read/write to the whole account. Do not put it in Slack, do not paste it into a shared doc, do not commit it. It goes into one place: a GitHub secret. You will rotate it after the workshop (Part 6).

---

## Part 5 — Set up your own fork, then hand the values out

Attendees fork the training repo, and **forking does not copy secrets** — every fork starts with an empty secret store. So there is nothing to configure on the training repo itself. Instead you do two things.

### 5a. Set up your own fork, for the dry run and the live demo

Fork the training repo to your own account and give it the same treatment attendees will:

**17.** Click **Fork** → **Create fork**.

**18.** On your fork: **Actions** tab → click **"I understand my workflows, go ahead and enable them."** Forks arrive with Actions disabled.

**19.** On your fork: **Settings** → **Secrets and variables** → **Actions**.

You will see two tabs, **Secrets** and **Variables**. You need one of each.

- **Secrets** tab → **New repository secret**
  - Name: `AZURE_STORAGE_CONNECTION_STRING`
  - Secret: paste value A
- **Variables** tab → **New repository variable**
  - Name: `AZURE_WEB_ENDPOINT`
  - Value: paste value B

Names must match exactly — all caps, underscores, no spaces. The workflow looks them up by those literal strings.

> **Why is one a secret and one a variable?** A secret is write-only — once saved, even you cannot read it back, and Actions masks it out of logs. A variable is plain text, readable by anyone with repo access. The connection string needs the first; a public endpoint URL does not need protecting and is more useful visible.

**20.** Now deploy from your fork end to end: make a folder named after yourself, change both `EDIT ME` values, commit, and confirm the run goes green and the live link works. This is both your dry run and your demo material.

### 5b. Plan how you hand value A to the room

Attendees each paste the connection string into their own fork, so you must give it to them live. Put it on the projector or a printed slip — not Slack, not email-to-all, not a shared doc, all of which keep a copy long after the session.

Then say this out loud when you hand it over, because their forks are public: **the connection string goes in the Secrets box and nowhere else.** A credential committed to a file in a public repo is world-readable and stays in the Git history even after deletion.

And put a calendar reminder on yourself to rotate the key the moment the session ends — see Part 6.

---

## Part 6 — Afterwards

**Delete everything.** Portal → **Resource groups** → `rg-gh-azure-workshop` → **Delete resource group**. It makes you type the group name to confirm.

**Rotate the key the moment the session ends — this is not optional here.** Every attendee holds a copy of a connection string granting full read/write/delete on the account, inside a personal public repo you do not control. Storage account → **Access keys** → **Rotate key** next to key1. That instantly invalidates every copy. Attendee sites keep serving; only further deploys stop, which is what you want.

---

## Quick checklist

Before you close the portal, confirm:

- [ ] Storage account exists, kind is **StorageV2**
- [ ] "Allow anonymous access on individual containers" is **unchecked**
- [ ] Static website is **Enabled**, index document is `index.html`, error document is `404.html`
- [ ] Both `index.html` and `404.html` are uploaded to `$web`, and `<endpoint>/nonsense/` shows the 404 page rather than the landing page
- [ ] You have copied the **Primary endpoint** (value B)
- [ ] You have copied the **key1 Connection string** (value A)
- [ ] Your **fork** has Actions enabled, the secret `AZURE_STORAGE_CONNECTION_STRING`, and the variable `AZURE_WEB_ENDPOINT`
- [ ] The training repo is **public**, so attendees can fork it and get free unlimited Actions minutes
- [ ] You have a plan for showing value A to the room live, and a reminder set to rotate it afterwards
- [ ] **You have run one deploy yourself, end to end**

That last one is not optional. Push a change to `site-sample/` on a test branch and watch the Actions run go green and produce a working URL. Every failure mode in this setup — wrong secret name, typo'd endpoint, static website not actually saved — shows up on the first real run. Better it shows up now than in front of the room.

---

## When the portal fights you

| Symptom | Cause |
|---|---|
| No **Static website** option anywhere | Account isn't GPv2 / BlockBlobStorage. Recreate it. |
| Static website page saves but no `$web` container | Reload the Containers page — the portal caches the list. |
| Primary endpoint returns `404 The requested content does not exist` | Nothing uploaded to `$web` yet, or your index document name doesn't match the uploaded filename. |
| Every attendee's folder URL shows the same landing page | The error document is set to `index.html`. A bare folder URL misses and falls through to it. Set it to `404.html` and tell people to use `/folder/index.html`. |
| Browser downloads `index.html` instead of showing it | Content-Type is `application/octet-stream`. Fix it on the blob's properties. |
| Workflow fails `AuthenticationFailed` | Connection string copied incompletely — it must end with `EndpointSuffix=core.windows.net`. Re-copy with the Copy button rather than selecting text by hand. |
| Workflow fails `Secret ... is not set` | Name mismatch, added as a *variable* instead of a *secret*, or added to the training repo instead of the fork that is running. Forks do not inherit secrets. |
| Attendee pushes and no run appears at all | Actions is still disabled on their fork. Actions tab → click the enable banner. |
| Run summary has no clickable link | `AZURE_WEB_ENDPOINT` variable missing. The deploy still worked — only the links are absent. |
