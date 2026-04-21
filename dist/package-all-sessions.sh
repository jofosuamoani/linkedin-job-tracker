#!/bin/bash

# Package Claude, Codex, Cursor, and Cline sessions into a shared folder at repo root.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
OUTPUT_DIR="${1:-$REPO_ROOT/session-packages}"

CLAUDE_SCRIPT="${CLAUDE_SCRIPT:-$REPO_ROOT/dist/package-claude-sessions.sh}"
CODEX_SCRIPT="${CODEX_SCRIPT:-$REPO_ROOT/dist/package-codex-sessions.sh}"
CURSOR_SCRIPT="${CURSOR_SCRIPT:-$REPO_ROOT/dist/package-cursor-sessions.sh}"
CLINE_SCRIPT="${CLINE_SCRIPT:-$REPO_ROOT/dist/package-cline-sessions.sh}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

case "$(uname -s)" in
    Darwin)
        CURSOR_BASE="${CURSOR_BASE:-$HOME/Library/Application Support/Cursor/User}"
        EDITOR_BASE_TEMPLATE="$HOME/Library/Application Support/%s/User"
        ;;
    Linux)
        CURSOR_BASE="${CURSOR_BASE:-$HOME/.config/Cursor/User}"
        EDITOR_BASE_TEMPLATE="$HOME/.config/%s/User"
        ;;
    *)
        CURSOR_BASE=""
        EDITOR_BASE_TEMPLATE=""
        ;;
esac

mkdir -p "$OUTPUT_DIR"

echo "Using output directory: $OUTPUT_DIR"

claude_status=0
codex_status=0
cursor_status=0
cline_status=0
ran_any=0

sanitize_path() { printf '%s' "$1" | sed 's|/|-|g; s|_|-|g; s| |-|g'; }
SANITIZED_REPO="$(sanitize_path "$REPO_ROOT")"
CLAUDE_ROOT="$HOME/.claude/projects"

# Claude: look for any project dir whose sanitized name matches REPO_ROOT or a
# subpath under it (candidate may run Claude from <repo>/subfolder).
claude_found=0
if [ -d "$CLAUDE_ROOT" ]; then
    shopt -s nullglob
    for dir in "$CLAUDE_ROOT/$SANITIZED_REPO" "$CLAUDE_ROOT/$SANITIZED_REPO"-*; do
        [ -d "$dir" ] || continue
        # Use grep rather than rg here — rg isn't reliably on candidate PATH
        # when submit.sh shells out, and when rg was missing every cwd check
        # silently failed and we reported no sessions found.
        if grep -r -E -q "\"cwd\":\"$REPO_ROOT(/[^\"]*)?\"" "$dir" 2>/dev/null; then
            claude_found=1
            break
        fi
    done
    shopt -u nullglob
fi

if [ "$claude_found" -eq 1 ]; then
    ran_any=1
    if [ -x "$CLAUDE_SCRIPT" ]; then
        echo "Running Claude session packager..."
        "$CLAUDE_SCRIPT" "$OUTPUT_DIR" || claude_status=$?
    else
        echo "Claude sessions exist but packager is missing or not executable: $CLAUDE_SCRIPT"
        claude_status=127
    fi
else
    echo "Skipping Claude packaging (no sessions found for this repo)."
fi

# Codex: sessions are JSONL with "cwd" — match REPO_ROOT or subpaths.
# grep -E doesn't support \s; substitute [[:space:]]* for portability.
if grep -r -E -q "\"cwd\":[[:space:]]*\"$REPO_ROOT(/[^\"]*)?\"" "$CODEX_HOME/sessions" 2>/dev/null; then
    ran_any=1
    if [ -x "$CODEX_SCRIPT" ]; then
        echo "Running Codex session packager..."
        "$CODEX_SCRIPT" "$OUTPUT_DIR" || codex_status=$?
    else
        echo "Codex sessions exist but packager is missing or not executable: $CODEX_SCRIPT"
        codex_status=127
    fi
else
    echo "Skipping Codex packaging (no sessions found for this repo)."
fi

# Cursor: workspace.json folder must be REPO_ROOT or a subpath under it.
cursor_found=0
if [ -n "$CURSOR_BASE" ] && [ -d "$CURSOR_BASE/workspaceStorage" ]; then
    for ws in "$CURSOR_BASE/workspaceStorage"/*/workspace.json; do
        [ -f "$ws" ] || continue
        folder="$(grep -o '"folder":"[^"]*"' "$ws" 2>/dev/null | head -1 | sed 's/"folder":"//; s/"$//; s|^file://||')" || true
        if [ "$folder" = "$REPO_ROOT" ] || [[ "$folder" == "$REPO_ROOT"/* ]]; then
            cursor_found=1
            break
        fi
    done
fi
# Also count global state as a reason to run
if [ -n "$CURSOR_BASE" ] && [ -f "$CURSOR_BASE/globalStorage/state.vscdb" ]; then
    cursor_found=1
fi

if [ "$cursor_found" -eq 1 ]; then
    ran_any=1
    if [ -x "$CURSOR_SCRIPT" ]; then
        echo "Running Cursor session packager..."
        "$CURSOR_SCRIPT" "$OUTPUT_DIR" || cursor_status=$?
    else
        echo "Cursor sessions exist but packager is missing or not executable: $CURSOR_SCRIPT"
        cursor_status=127
    fi
else
    echo "Skipping Cursor packaging (no sessions found for this repo)."
fi

# Cline: per-task folders under <editor>/User/globalStorage/saoudrizwan.claude-dev/tasks/
cline_found=0
if [ -n "$EDITOR_BASE_TEMPLATE" ]; then
    for editor in Code "Code - Insiders" Cursor Windsurf VSCodium; do
        base="$(printf "$EDITOR_BASE_TEMPLATE" "$editor")"
        tasks_dir="$base/globalStorage/saoudrizwan.claude-dev/tasks"
        [ -d "$tasks_dir" ] || continue
        for task_dir in "$tasks_dir"/*/; do
            hist="$task_dir/api_conversation_history.json"
            [ -f "$hist" ] || continue
            if grep -qF "Current Working Directory ($REPO_ROOT)" "$hist" 2>/dev/null \
               || grep -qF "Current Working Directory ($REPO_ROOT/" "$hist" 2>/dev/null; then
                cline_found=1
                break 2
            fi
        done
    done
fi

if [ "$cline_found" -eq 1 ]; then
    ran_any=1
    if [ -x "$CLINE_SCRIPT" ]; then
        echo "Running Cline session packager..."
        "$CLINE_SCRIPT" "$OUTPUT_DIR" || cline_status=$?
    else
        echo "Cline sessions exist but packager is missing or not executable: $CLINE_SCRIPT"
        cline_status=127
    fi
else
    echo "Skipping Cline packaging (no sessions found for this repo)."
fi

if [ "$ran_any" -eq 0 ]; then
    echo "No sessions found for this repo. Nothing to package."
    exit 0
fi

if [ "$claude_status" -ne 0 ] || [ "$codex_status" -ne 0 ] || [ "$cursor_status" -ne 0 ] || [ "$cline_status" -ne 0 ]; then
    echo "One or more packagers failed."
    [ "$claude_status" -ne 0 ] && echo "Claude packager failed with status $claude_status."
    [ "$codex_status" -ne 0 ] && echo "Codex packager failed with status $codex_status."
    [ "$cursor_status" -ne 0 ] && echo "Cursor packager failed with status $cursor_status."
    [ "$cline_status" -ne 0 ] && echo "Cline packager failed with status $cline_status."
    exit 1
fi

echo "Done. Archives are in: $OUTPUT_DIR"
