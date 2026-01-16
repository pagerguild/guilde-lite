#!/bin/bash
# Tool status summary for Homebrew, mise, and core runtimes

set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

hr() {
  printf '%s\n' "================================================================"
}

print_row() {
  printf '%-12s %-20s %s\n' "$1" "$2" "$3"
}

get_cmd_version() {
  local cmd=$1
  local args=${2:---version}
  if have "$cmd"; then
    "$cmd" $args 2>/dev/null | head -1 | sed 's/^[[:space:]]*//'
  else
    echo "not installed"
  fi
}

brew_summary() {
  if have brew; then
    local formulas casks
    formulas=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    casks=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    echo "formulae=${formulas}, casks=${casks}"
  else
    echo "not installed"
  fi
}

mise_summary() {
  if have mise; then
    local configured installed
    configured=$(python - <<'PY'
import tomllib
from pathlib import Path
p = Path('mise.toml')
if not p.exists():
    print('0')
else:
    data = tomllib.loads(p.read_text())
    tools = data.get('tools', {})
    print(len(tools))
PY
)
    installed=$(mise ls 2>/dev/null | awk 'NF{count++} END{print count+0}')
    echo "configured=${configured}, installed=${installed}"
  else
    echo "not installed"
  fi
}

hr
echo "Tool Status Summary"
hr
printf '%-12s %-20s %s\n' "Tool" "Version" "Notes"
print_row "homebrew" "$(get_cmd_version brew)" "$(brew_summary)"
print_row "mise" "$(get_cmd_version mise)" "$(mise_summary)"
print_row "task" "$(get_cmd_version task)" ""
print_row "just" "$(get_cmd_version just)" ""
print_row "bun" "$(get_cmd_version bun)" ""
print_row "node" "$(get_cmd_version node)" ""
print_row "npm" "$(get_cmd_version npm)" ""
print_row "uv" "$(get_cmd_version uv)" ""
print_row "python" "$(get_cmd_version python)" ""
print_row "go" "$(get_cmd_version go version)" ""
print_row "rustc" "$(get_cmd_version rustc)" ""

hr
echo "Homebrew Packages"
hr
if have brew; then
  echo "Formulas (brew list --versions):"
  brew list --versions || true
  echo ""
  echo "Casks (brew list --cask --versions):"
  brew list --cask --versions || true
else
  echo "brew not installed"
fi

hr
echo "Mise Tools"
hr
if have mise; then
  echo "Configured/installed (mise ls -c):"
  mise ls -c || true
  echo ""
  echo "Active versions (mise current):"
  mise current || true
else
  echo "mise not installed"
fi
