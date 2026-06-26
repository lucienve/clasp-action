#!/bin/sh
set -e

# Construct ~/.clasprc.json using automatically populated input environment variables
CLASPRC=$(cat <<-EOF
{
    "token": {
        "access_token": "$INPUT_ACCESSTOKEN",
        "refresh_token": "$INPUT_REFRESHTOKEN",
        "scope": "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/service.management https://www.googleapis.com/auth/script.deployments https://www.googleapis.com/auth/logging.read https://www.googleapis.com/auth/script.webapp.deploy https://www.googleapis.com/auth/userinfo.profile openid https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/script.projects https://www.googleapis.com/auth/drive.metadata.readonly",
        "token_type": "Bearer",
        "id_token": "$INPUT_IDTOKEN"
    },
    "oauth2ClientSettings": {
        "clientId": "$INPUT_CLIENTID",
        "clientSecret": "$INPUT_CLIENTSECRET",
        "redirectUri": "http://localhost"
    },
    "isLocalCreds": false
}
EOF
)

# Safely write the clasprc config with quotes
echo "$CLASPRC" > ~/.clasprc.json

# If rootDir is specified, validate and cd into it
if [ -n "$INPUT_ROOTDIR" ]; then
  if [ -d "$INPUT_ROOTDIR" ]; then
    cd "$INPUT_ROOTDIR"
  else
    echo "rootDir '$INPUT_ROOTDIR' is invalid or does not exist."
    exit 1
  fi
fi

# Merge scriptId into .clasp.json instead of overwriting destructively
if [ -f ".clasp.json" ]; then
  echo "Existing .clasp.json found. Merging scriptId..."
  # Use jq to update or insert scriptId, preserving other settings
  jq --arg scriptId "$INPUT_SCRIPTID" '.scriptId = $scriptId' .clasp.json > temp.json && mv temp.json .clasp.json
else
  echo "Creating new .clasp.json..."
  cat <<-EOF > .clasp.json
  {
      "scriptId": "$INPUT_SCRIPTID"
  }
EOF
fi

# Execute command
if [ "$INPUT_COMMAND" = "push" ]; then
  clasp push -f
elif [ "$INPUT_COMMAND" = "pull" ]; then
  clasp pull
elif [ "$INPUT_COMMAND" = "deploy" ]; then
  clasp push -f

  if [ -n "$INPUT_DESCRIPTION" ] && [ -n "$INPUT_DEPLOYID" ]; then
    clasp deploy --description "$INPUT_DESCRIPTION" -i "$INPUT_DEPLOYID"
  elif [ -n "$INPUT_DESCRIPTION" ]; then
    clasp deploy --description "$INPUT_DESCRIPTION"
  elif [ -n "$INPUT_DEPLOYID" ]; then
    clasp deploy -i "$INPUT_DEPLOYID"
  else
    clasp deploy
  fi
else
  echo "command '$INPUT_COMMAND' is invalid."
  exit 1
fi
