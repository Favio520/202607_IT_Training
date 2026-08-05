#!/usr/bin/env bash
#
# 03-teardown.sh — delete everything the workshop created in Azure.
#
# Usage:
#   ./03-teardown.sh                    # reads RG from workshop-credentials.txt
#   RG=rg-gh-azure-workshop ./03-teardown.sh
#
set -euo pipefail

CRED_FILE="${CRED_FILE:-workshop-credentials.txt}"

if [[ -z "${RG:-}" ]]; then
  if [[ -f "$CRED_FILE" ]]; then
    RG="$(sed -n 's/^Resource group *: *\(.*\)$/\1/p' "$CRED_FILE" | head -n1)"
  fi
fi
[[ -n "${RG:-}" ]] || { echo "ERROR: set RG=<resource-group> (or keep $CRED_FILE around)." >&2; exit 1; }

echo "This will DELETE the resource group '$RG' and everything in it."
az resource list --resource-group "$RG" --query "[].{name:name,type:type}" -o table 2>/dev/null || true
echo
read -r -p "Type the resource group name to confirm: " confirm
[[ "$confirm" == "$RG" ]] || { echo "Name did not match. Aborted."; exit 1; }

az group delete --name "$RG" --yes --no-wait
echo "Delete started (running in the background). Check with:"
echo "  az group show --name $RG"
