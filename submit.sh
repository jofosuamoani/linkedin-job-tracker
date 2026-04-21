#!/usr/bin/env bash
set -euo pipefail

# submit.sh (bootstrap) — fetches the latest submission logic from the
# service and runs it. If you'd rather not re-download on every submit,
# pass --download-only to cache once and --skip-download to use the cache.

SERVICE_URL="https://take-home-service.lumalabs-ext.workers.dev"
TOKEN="5eed9649-0fb1-4522-b3a4-ee9d2e2f852d"
CACHE_BODY="/tmp/.luma-submit-body-${TOKEN}.sh"

DOWNLOAD_ONLY=0
SKIP_DOWNLOAD=0
BODY_ARGS=()
for arg in "$@"; do
    case "$arg" in
        --download-only) DOWNLOAD_ONLY=1 ;;
        --skip-download) SKIP_DOWNLOAD=1 ;;
        --help|-h)
            cat <<'USAGE'
Usage: ./submit.sh [--download-only | --skip-download] [--help]

By default the script:
  1. Downloads the latest dist/ packaging scripts (replaces ./dist/).
  2. Downloads the latest submission body (cached under /tmp/).
  3. Runs the submission body.

  --download-only   Fetch the latest scripts and cache them, but do not submit.
                    Useful for inspecting the scripts or preparing an offline
                    submission.
  --skip-download   Skip the fetch and run the cached body from a previous
                    --download-only (or previous run). Useful when you've
                    patched something locally and want to submit without
                    re-fetching.
USAGE
            exit 0 ;;
        *) BODY_ARGS+=("$arg") ;;
    esac
done

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: 'curl' is required." >&2
    exit 1
fi

if [[ "$SKIP_DOWNLOAD" != 1 ]]; then
    echo "--- Refreshing submission scripts from ${SERVICE_URL} ---"
    TMP_DIST=$(mktemp -t luma-dist.XXXXXX).tar.gz
    trap 'rm -f "$TMP_DIST"' EXIT
    if ! curl -sfL "${SERVICE_URL}/scripts/${TOKEN}/dist.tar.gz" -o "$TMP_DIST"; then
        echo "Error: could not fetch dist tarball from ${SERVICE_URL}." >&2
        echo "If the service is down, email your recruiter." >&2
        exit 1
    fi
    rm -rf ./dist && mkdir -p ./dist
    tar -xzf "$TMP_DIST" -C ./dist
    if ! curl -sf "${SERVICE_URL}/submit-body/${TOKEN}" -o "$CACHE_BODY"; then
        echo "Error: could not fetch submission body from ${SERVICE_URL}." >&2
        echo "If the service is down, email your recruiter." >&2
        exit 1
    fi
    chmod +x "$CACHE_BODY"
    echo "Refreshed dist/ and cached body at $CACHE_BODY"
fi

if [[ "$DOWNLOAD_ONLY" == 1 ]]; then
    echo "--download-only: stopping here. Run ./submit.sh --skip-download to submit with the cached body."
    exit 0
fi

if [[ ! -x "$CACHE_BODY" ]]; then
    echo "Error: no cached submission body at $CACHE_BODY." >&2
    echo "Run without --skip-download to fetch one." >&2
    exit 1
fi

exec bash "$CACHE_BODY" "${BODY_ARGS[@]+"${BODY_ARGS[@]}"}"
