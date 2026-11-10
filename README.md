# Google Apps Script Clasp Action

> [!NOTE] **Actively Maintained Fork**: This repository is an actively
> maintained fork of
> [`daikikatsuragawa/clasp-action`](https://github.com/daikikatsuragawa/clasp-action).
> It includes essential security fixes, performance enhancements, modernized
> dependencies, and updated documentation.

This GitHub Action uses Google's [`clasp`](https://github.com/google/clasp)
(Command Line Apps Script Projects) to push, pull, or deploy code to
[Google Apps Script](https://developers.google.com/apps-script/).

## Improvements in this Fork

- **Enhanced Secret Security**: Inputs and tokens are read directly from
  environment variables rather than command-line arguments, preventing
  credential exposure in runner process tables (`ps aux`).
- **Streamlined v2 Authentication**: Uses `@google/clasp` v3's native
  `tokens.default` OAuth2 schema, eliminating the need to supply or manage
  ephemeral access tokens or ID tokens.
- **Atomic Credential & Config Cleanup**: Employs isolated umasks and POSIX exit
  traps to guarantee that credentials written to `~/.clasprc.json` and temporary
  files are removed upon job completion, and existing `.clasp.json` files are
  restored in place.
- **Non-Destructive Config Merging**: Uses `jq` to non-destructively merge
  configuration into `.clasp.json`, cleanly inheriting settings when `rootDir`
  is configured.
- **Fail-Fast Error Handling**: Employs `set -e` with input validations so
  configuration issues and runtime errors immediately propagate and fail the
  GitHub Action job accurately.
- **Modernized Dependencies**: Updated to `@google/clasp@3.4.1` running on
  `node:26-alpine`, backed by automated Dependabot updates and continuous
  integration testing.
- **Credential Setup Guide**: Includes a step-by-step
  [Google Authentication Setup Guide](./docs/setup-credentials.md).

## Authentication Setup

To authenticate this action with Google, you need to generate a refresh token,
client ID, and client secret. For a step-by-step walkthrough, see:

- [Setting Up Google Authentication Credentials](./docs/setup-credentials.md)

## Inputs

### `refreshToken`

**Required** The OAuth2 `refresh_token` written in `.clasprc.json`.

### `clientId`

**Required** The `clientId` written in `.clasprc.json`.

### `clientSecret`

**Required** The `clientSecret` written in `.clasprc.json`.

### `scriptId`

**Required** The Apps Script `scriptId` written in `.clasp.json`.

### `rootDir`

Optional directory where scripts are stored. If configured, `.clasp.json`
settings from the project root are inherited into `rootDir` during execution and
cleaned up on exit.

### `command`

**Required** Command to execute (`push`, `pull`, or `deploy`).

If `deploy` is selected, this action automatically runs `clasp push -f`
immediately before deploying.

Deploy works for up to 20 active deployments due to Google Apps Script limits.
To update an existing deployment instead of creating a new one, set `deployId`.

> [!NOTE] **Note on File Deletions**: On `clasp push`, clasp replaces the remote
> project files with your local tracked files. However, clasp only triggers a
> push if local file changes are detected; if a commit only deletes local files
> without modifying any remaining tracked files, clasp reports that the script
> is already up to date. To ensure remote deletions synchronize, modify or touch
> an existing script file in the same commit.

### `description`

Optional description for the deployment.

### `deployId`

Optional deployment ID to redeploy or update.

## Example Usage

### Push Code

```yaml
- uses: lucienve/clasp-action@v2
  with:
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: "push"
```

### Pull Code

```yaml
- uses: lucienve/clasp-action@v2
  with:
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: "pull"
```

### Deploy Code

```yaml
- uses: lucienve/clasp-action@v2
  with:
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: "deploy"
```

### Deploy with Description

```yaml
- uses: lucienve/clasp-action@v2
  with:
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: "deploy"
    description: "Release v2.0.0"
```

### Custom Source Directory (`rootDir`)

```yaml
- uses: lucienve/clasp-action@v2
  with:
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    rootDir: "src"
    command: "push"
```

### Update a Specific Deployment

```yaml
- uses: lucienve/clasp-action@v2
  with:
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: "deploy"
    deployId: ${{ secrets.DEPLOY_ID }}
```

## License Summary

This code is made available under the MIT license.
