#!/bin/sh
set -e

# Fail-fast validation of required inputs
if [ -z "$INPUT_REFRESHTOKEN" ] || [ -z "$INPUT_CLIENTID" ] || [ -z "$INPUT_CLIENTSECRET" ]; then
  echo "Error: Missing required authentication inputs (refreshToken, clientId, or clientSecret)." >&2
  exit 1
fi

if [ -z "$INPUT_SCRIPTID" ]; then
  echo "Error: Missing required scriptId input." >&2
  exit 1
fi

if [ -z "$INPUT_COMMAND" ]; then
  echo "Error: Missing required command input." >&2
  exit 1
fi

case "$INPUT_COMMAND" in
  push|pull|deploy) ;;
  *)
    echo "Error: command '$INPUT_COMMAND' is invalid. Must be push, pull, or deploy." >&2
    exit 1
    ;;
esac

if [ -n "$INPUT_ROOTDIR" ] && [ ! -d "$INPUT_ROOTDIR" ]; then
  echo "Error: rootDir '$INPUT_ROOTDIR' is invalid or does not exist." >&2
  exit 1
fi

# Track credential and configuration paths for guaranteed cleanup on exit
CLASPRC_PATH="$HOME/.clasprc.json"
CLASP_JSON_PATH=""
CLASP_BACKUP=""
CLASP_TMP="/tmp/clasp.json.tmp.$$"
CLASP_JSON_CREATED=0

cleanup() {
  rc=$?
  set +e
  trap - EXIT INT TERM
  rm -f "$CLASPRC_PATH" "$CLASP_TMP"
  if [ "$CLASP_JSON_CREATED" = "1" ] && [ -n "$CLASP_JSON_PATH" ]; then
    rm -f "$CLASP_JSON_PATH"
  elif [ -n "$CLASP_BACKUP" ] && [ -f "$CLASP_BACKUP" ] && [ -n "$CLASP_JSON_PATH" ]; then
    cat "$CLASP_BACKUP" > "$CLASP_JSON_PATH"
    rm -f "$CLASP_BACKUP"
  fi
  exit "$rc"
}
trap cleanup EXIT INT TERM

# Write ~/.clasprc.json using Clasp v3 tokens.default schema
# Read credentials directly from environment memory to avoid exposure in process argv
(
  umask 077
  jq -n '{
    tokens: {
      default: {
        client_id: env.INPUT_CLIENTID,
        client_secret: env.INPUT_CLIENTSECRET,
        type: "authorized_user",
        refresh_token: env.INPUT_REFRESHTOKEN
      }
    }
  }' > "$CLASPRC_PATH"
)

# Navigate to rootDir if specified
ORIG_DIR=$(pwd)
if [ -n "$INPUT_ROOTDIR" ]; then
  cd "$INPUT_ROOTDIR"
fi

CLASP_JSON_PATH="$(pwd)/.clasp.json"

# Manage .clasp.json non-destructively
if [ -f "$CLASP_JSON_PATH" ]; then
  echo "Existing .clasp.json found. Merging scriptId..."
  CLASP_BACKUP="/tmp/clasp.json.bak.$$"
  cp "$CLASP_JSON_PATH" "$CLASP_BACKUP"
  jq '.scriptId = env.INPUT_SCRIPTID' "$CLASP_JSON_PATH" > "$CLASP_TMP"
  cat "$CLASP_TMP" > "$CLASP_JSON_PATH"
  rm -f "$CLASP_TMP"
elif [ -n "$INPUT_ROOTDIR" ] && [ -f "$ORIG_DIR/.clasp.json" ]; then
  echo "Found root .clasp.json. Inheriting configuration into $INPUT_ROOTDIR..."
  CLASP_JSON_CREATED=1
  jq '.scriptId = env.INPUT_SCRIPTID | del(.rootDir, .srcDir)' "$ORIG_DIR/.clasp.json" > "$CLASP_TMP"
  cat "$CLASP_TMP" > "$CLASP_JSON_PATH"
  rm -f "$CLASP_TMP"
else
  echo "Creating new .clasp.json..."
  CLASP_JSON_CREATED=1
  jq -n '{scriptId: env.INPUT_SCRIPTID}' > "$CLASP_TMP"
  cat "$CLASP_TMP" > "$CLASP_JSON_PATH"
  rm -f "$CLASP_TMP"
fi

# Execute clasp command
if [ "$INPUT_COMMAND" = "push" ]; then
  clasp push -f
elif [ "$INPUT_COMMAND" = "pull" ]; then
  clasp pull
elif [ "$INPUT_COMMAND" = "deploy" ]; then
  clasp push -f

  set -- clasp deploy
  if [ -n "$INPUT_DESCRIPTION" ]; then
    set -- "$@" --description="$INPUT_DESCRIPTION"
  fi
  if [ -n "$INPUT_DEPLOYID" ]; then
    set -- "$@" --deploymentId="$INPUT_DEPLOYID"
  fi
  "$@"
fi
