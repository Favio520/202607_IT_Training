#!/usr/bin/env bash
#
# 01-azure-setup.sh — run this ONCE before the workshop.
#
# Creates a resource group + storage account, turns on static website hosting
# (so attendees get a real public URL for what they deploy), and prints the two
# values you hand out to attendees:
#
#   1. AZURE_STORAGE_CONNECTION_STRING  -> GitHub Actions *secret*
#   2. AZURE_WEB_ENDPOINT               -> GitHub Actions *variable*
#
# Requires: Azure CLI (az), logged in via `az login`.
#
# Usage:
#   ./01-azure-setup.sh
#   LOCATION=westus2 RG=rg-my-workshop ./01-azure-setup.sh
#
set -euo pipefail

# ---- Config (override with env vars) ----------------------------------------
LOCATION="${LOCATION:-eastus}"
RG="${RG:-rg-gh-azure-workshop}"
# Storage account names: 3-24 chars, lowercase letters + digits only, globally unique.
ACCOUNT="${ACCOUNT:-stghwks$(date +%y%m%d)$(printf '%04d' $((RANDOM % 10000)))}"
# Extra plain container, in case you want to demo a non-website upload target.
EXTRA_CONTAINER="${EXTRA_CONTAINER:-workshop}"
OUT_FILE="${OUT_FILE:-workshop-credentials.txt}"
# -----------------------------------------------------------------------------

command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI (az) not found. Install it first." >&2; exit 1; }
az account show >/dev/null 2>&1 || { echo "ERROR: not logged in. Run: az login" >&2; exit 1; }

SUB_NAME="$(az account show --query name -o tsv)"
echo "=============================================================="
echo " Subscription : $SUB_NAME"
echo " Location     : $LOCATION"
echo " Resource grp : $RG"
echo " Storage acct : $ACCOUNT"
echo "=============================================================="
read -r -p "Proceed? [y/N] " reply
[[ "$reply" == [yY] ]] || { echo "Aborted."; exit 0; }

echo
echo "==> Creating resource group..."
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --tags purpose=workshop owner="${USER:-facilitator}" \
  --output none

echo "==> Creating storage account (this takes ~30s)..."
az storage account create \
  --name "$ACCOUNT" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none
# NOTE: allow-blob-public-access stays FALSE on purpose. Static website hosting
# ($web) serves anonymously regardless of that flag, so attendees still get a
# working public URL without opening up every container in the account.

echo "==> Fetching connection string..."
CONN="$(az storage account show-connection-string \
  --name "$ACCOUNT" \
  --resource-group "$RG" \
  --query connectionString -o tsv)"

echo "==> Enabling static website hosting..."
# The error document is deliberately a DISTINCT page, not index.html.
# Static website hosting only guarantees the index document at the site root, so
# a request to a subfolder (/site-alice/) can miss and fall through to the error
# document. If that document were index.html, every attendee visiting their own
# folder URL would be served the root landing page instead — looking as though
# everyone shares one identical site. A separate 404 page makes the miss obvious.
az storage blob service-properties update \
  --connection-string "$CONN" \
  --static-website true \
  --index-document index.html \
  --404-document 404.html \
  --output none

echo "==> Creating extra container '$EXTRA_CONTAINER'..."
az storage container create \
  --name "$EXTRA_CONTAINER" \
  --connection-string "$CONN" \
  --output none

echo "==> Uploading the root landing page and the 404 page..."
TMPD="$(mktemp -d)"
cat > "$TMPD/index.html" <<'HTML'
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Workshop storage is live</title>
<style>
  body{font-family:system-ui,-apple-system,Segoe UI,sans-serif;max-width:34rem;
       margin:15vh auto;padding:0 1.5rem;line-height:1.6;color:#1b1b1f}
  code{background:#f1f1f4;padding:.15em .4em;border-radius:4px}
</style></head>
<body>
  <h1>Workshop storage is live</h1>
  <p>This is the root of the static website endpoint. Your deployed page will be
     at <code>/&lt;your-folder-name&gt;/index.html</code> &mdash; include the
     filename, not just the folder.</p>
</body></html>
HTML
cat > "$TMPD/404.html" <<'HTML'
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Nothing at this address</title>
<style>
  body{font-family:system-ui,-apple-system,Segoe UI,sans-serif;max-width:34rem;
       margin:15vh auto;padding:0 1.5rem;line-height:1.6;color:#1b1b1f}
  code{background:#f1f1f4;padding:.15em .4em;border-radius:4px}
  .hint{border-left:3px solid #0f6cbd;background:#f6f9fd;padding:.9rem 1.1rem;
        border-radius:0 8px 8px 0}
</style></head>
<body>
  <h1>Nothing at this address</h1>
  <p>This page means the URL you asked for does not exist in storage.</p>
  <div class="hint">
    <p><strong>Asking for a folder?</strong> Add the filename. Use
       <code>/your-folder/index.html</code> rather than <code>/your-folder/</code>
       &mdash; a bare folder path is not guaranteed to find its index page.</p>
  </div>
  <p>Otherwise: check the spelling of your folder, and check that your workflow
     run finished green.</p>
</body></html>
HTML
for f in index.html 404.html; do
  az storage blob upload \
    --connection-string "$CONN" \
    --container-name '$web' \
    --name "$f" \
    --file "$TMPD/$f" \
    --content-type "text/html" \
    --overwrite \
    --output none
done
rm -rf "$TMPD"

WEB_ENDPOINT="$(az storage account show \
  --name "$ACCOUNT" \
  --resource-group "$RG" \
  --query "primaryEndpoints.web" -o tsv)"
WEB_ENDPOINT="${WEB_ENDPOINT%/}"   # strip trailing slash

# ---- Write the handout ------------------------------------------------------
umask 077
cat > "$OUT_FILE" <<EOF
GitHub Actions -> Azure Storage workshop
Generated: $(date -u '+%Y-%m-%d %H:%M UTC')

Resource group : $RG
Storage account: $ACCOUNT
Web endpoint   : $WEB_ENDPOINT

--- GitHub Actions SECRET -----------------------------------------------------
Name : AZURE_STORAGE_CONNECTION_STRING
Value: $CONN

--- GitHub Actions VARIABLE ---------------------------------------------------
Name : AZURE_WEB_ENDPOINT
Value: $WEB_ENDPOINT

Teardown when the workshop is over:
  az group delete --name $RG --yes --no-wait
EOF

echo
echo "=============================================================="
echo " DONE"
echo "=============================================================="
echo " Web endpoint : $WEB_ENDPOINT"
echo " Credentials  : ./$OUT_FILE  (mode 600 — do not commit this)"
echo
echo " Next: run ./02-seed-attendee-repos.sh to push the secret and"
echo "       variable into each attendee repo."
echo
echo " Teardown: az group delete --name $RG --yes --no-wait"
echo "=============================================================="
