#!/usr/bin/env bash
set -euo pipefail

cd /home/azureuser/profile_list_on_x

source .venv/bin/activate

python -m src.main
COLLECTOR_EXIT=$?

deactivate 2>/dev/null || true

echo "=== git status ==="
git status --porcelain

if [ -n "$(git status --porcelain)" ]; then
  echo "=== changes detected, committing ==="
  git add -A
  git -c user.name="Hermes Agent" -c user.email="hermes@local" commit -m "chore: hourly IP data update $(date -u +'%Y-%m-%d %H:%M:%S') UTC"
  echo "=== pushing to GitHub ==="
  git push origin main
else
  echo "=== no changes, exiting silently ==="
fi
