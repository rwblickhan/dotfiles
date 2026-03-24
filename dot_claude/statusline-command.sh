#!/bin/bash
input=$(cat)

DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
# "// empty" produces no output when rate_limits is absent
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

COST_FMT=$(printf '$%.2f' "$COST")

CYAN='\033[36m'; WHITE='\033[97m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'

# Helper: build a 10-block bar with color for a given integer percentage
make_bar() {
  local pct=$1
  local color
  if [ "$pct" -ge 90 ]; then color="$RED"
  elif [ "$pct" -ge 70 ]; then color="$YELLOW"
  else color="$GREEN"; fi
  local filled=$((pct / 10)); local empty=$((10 - filled))
  printf -v _fill "%${filled}s"; printf -v _pad "%${empty}s"
  echo -e "${color}${_fill// /█}${_pad// /░}${RESET}"
}

# Line 1: jj workspace name, or git branch as fallback
REPO_LINE=""
if [ -n "$DIR" ] && [ -d "$DIR" ]; then
  JJ_WS_ROOT=$(cd "$DIR" && jj workspace root --no-pager 2>/dev/null)
  if [ -n "$JJ_WS_ROOT" ]; then
    # The workspace name is the final component of the workspace root path
    JJ_WS_NAME=$(basename "$JJ_WS_ROOT")
    if [ -n "$JJ_WS_NAME" ]; then
      JJ_DESC=$(cd "$DIR" && jj log --no-graph -r @ --template 'description' --no-pager 2>/dev/null | head -1)
      if [ -n "$JJ_DESC" ]; then
        DESC_PART=" ${GREEN}${JJ_DESC}${RESET}"
      else
        DESC_PART=" ${DIM}(no description)${RESET}"
      fi
      REPO_LINE="🛠️ ${WHITE}${JJ_WS_NAME}${DESC_PART}"
    fi
  else
    # Fall back to git branch if not in a jj workspace
    GIT_BRANCH=$(cd "$DIR" && git branch --show-current 2>/dev/null)
    if [ -n "$GIT_BRANCH" ]; then
      REPO_LINE="🌿 ${WHITE}${GIT_BRANCH}${RESET}"
    fi
  fi
fi

[ -n "$REPO_LINE" ] && echo -e "$REPO_LINE"

# Line 2: Context bar, rate limits, cost
CTX_BAR=$(make_bar "$PCT")

# Rate limit bars (only when data is present)
LIMITS=""
if [ -n "$FIVE_H" ]; then
  FIVE_H_INT=$(printf '%.0f' "$FIVE_H")
  FIVE_BAR=$(make_bar "$FIVE_H_INT")
  LIMITS="5h: ${FIVE_BAR} ${FIVE_H_INT}%"
fi
if [ -n "$WEEK" ]; then
  WEEK_INT=$(printf '%.0f' "$WEEK")
  WEEK_BAR=$(make_bar "$WEEK_INT")
  LIMITS="${LIMITS:+$LIMITS | }7d: ${WEEK_BAR} ${WEEK_INT}%"
fi

[ -n "$LIMITS" ] && echo -e "ctx: ${CTX_BAR} ${PCT}% | $LIMITS | ${YELLOW}${COST_FMT}${RESET}" || echo -e "ctx: ${CTX_BAR} ${PCT}% | ${YELLOW}${COST_FMT}${RESET}"
