#!/bin/bash
# One-line status: model/dir/worktree/branch, then ctx bar, duration, activity sparkline.
# Backup of the previous version: statusline-command.sh.bak

IN=$(cat)
eval "$(printf '%s' "$IN" | jq -r '@sh "model=\(.model.display_name // "?") cwd=\(.workspace.current_dir // .cwd // "") pct=\(.context_window.used_percentage // 0 | floor) ms=\(.cost.total_duration_ms // 0 | floor)"')"
[ -z "$cwd" ] && cwd="$PWD"

# Git: branch + worktree name (git-dir differs from common dir inside a linked worktree)
branch=""; wt=""
if git -C "$cwd" rev-parse --git-dir &>/dev/null; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  gd=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)
  cd_=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  [ "$gd" != "$cd_" ] && wt=$(basename "$(git -C "$cwd" rev-parse --show-toplevel)")
fi

# Activity sparkline: one awk pass over the log (line 1 = "start last", rest = call timestamps)
LOG="$HOME/.claude/toolcall-session.log"
NOW=$(date +%s)
[ -f "$LOG" ] || echo "$NOW $NOW" > "$LOG"
read -r START LAST < "$LOG"
[ $((NOW - LAST)) -ge 7200 ] && START=$NOW
{ echo "$START $NOW"; awk -v h=$((NOW-3600)) 'NR>1 && $1>=h' "$LOG"; echo "$NOW"; } > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
spark=$(awk -v now="$NOW" '
  BEGIN { split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", B, " ") }
  NR>1 { b=int(($1-(now-3600))/300); if (b>=0 && b<12) c[b]++; m[int($1/60)]=1 }
  END {
    for (i=0;i<12;i++) if (c[i]>mx) mx=c[i]
    split("36 36 32 32 33 33 31 31", K, " ")   # cyan, green, yellow, red by height
    for (i=0;i<12;i++) { j=int(c[i]*7/mx)+1; s = s (c[i]==0 ? "\033[2m░\033[0m" : "\033[" K[j] "m" B[j] "\033[0m") }
    n=0; for (k in m) n++
    print s " \033[2m" n "/hr\033[0m"
  }' "$LOG")

# Context bar, colored at 70% / 90%
(( pct > 100 )) && pct=100
filled=$((pct / 10)); bar=""
for i in $(seq 1 10); do (( i <= filled )) && bar+="█" || bar+="░"; done
if   (( pct >= 90 )); then c="\033[31m"; note=" ✖ compact soon"
elif (( pct >= 70 )); then c="\033[33m"; note=" ⚠"
else c="\033[32m"; note=""; fi

# Duration
mins=$((ms / 60000)); dur="${mins}m"; (( mins >= 60 )) && dur="$((mins/60))h$((mins%60))m"

# Output
R="\033[0m"; D="\033[2m"
l1="\033[36m[${model}]${R} 📁 \033[34m$(basename "$cwd")${R}"
[ -n "$wt" ] && l1+=" ${D}(wt: ${wt})${R}"
[ -n "$branch" ] && l1+=" │ 🌿 \033[33m${branch}${R}"
echo -e "$l1 │ ${c}${bar} ${pct}%${note}${R} │ ${dur} │ ${spark}"
