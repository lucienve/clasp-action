# Google Apps Script Clasp Action

> [!NOTE]
> **Actively Maintained Fork**: This repository is an actively maintained fork of [`daikikatsuragawa/clasp-action`](https://github.com/daikikatsuragawa/clasp-action). It includes essential security fixes, performance enhancements, modernized dependencies, and updated documentation.

This GitHub Action uses Google's [`clasp`](https://github.com/google/clasp) (Command Line Apps Script Projects) to push, pull, or deploy code to [Google Apps Script](https://developers.google.com/apps-script/).

## Improvements in this Fork

* **Enhanced Secret Security**: Inputs and tokens are read directly from environment variables rather than command-line flags, preventing credential exposure in runner process tables (`ps aux`).
* **Non-Destructive Config Merging**: Uses `jq` to non-destructively merge configuration into `.clasp.json`, preserving custom properties like `rootDir` and `projectId`.
* **Fail-Fast Error Handling**: Employs `set -e` in execution scripts so runtime errors immediately propagate and fail the GitHub Action job accurately.
* **Modernized Dependencies**: Updated to `@google/clasp@3.4.0` running on `node:26-alpine`, backed by automated Dependabot security updates.
* **Credential Setup Guide**: Includes a step-by-step [Google Authentication Setup Guide](docs/setup-credentials.md).

## Authentication Setup

To authenticate this action with Google, you need to generate tokens and client secrets. For a step-by-step walkthrough on how to obtain these values, see:

* [Setting Up Google Authentication Credentials](docs/setup-credentials.md)

## Inputs

### `accessToken`

**Required** `access_token` written in `.clasprc.json`.

### `idToken`

**Required** `id_token` written in `.clasprc.json`.

### `refreshToken`

**Required** `refresh_token` written in `.clasprc.json`.

### `clientId`

**Required** `clientId` written in `.clasprc.json`.

### `clientSecret`

**Required** `clientSecret` written in `.clasprc.json`.

### `scriptId`

**Required** `scriptId` written in `.clasp.json`.

### `rootDir`

Directory where scripts are stored.

### `command`

**Required** Command to execute(`push` or `deploy`).

If `deploy` is selected, this action is running `clasp push -f` just before.

Deploy works for max. 20 deployments due to Gas limit on active deployments and complexity to determine which deployment should be deleted.
Workaround : Set deployId.

### `description`

Description of the deployment.

### `deployId`

Deploy ID that will be updated with this push.

## Example usage

### Case to push

```yaml
- uses: lucienve/clasp-action@v1
  with:
    accessToken: ${{ secrets.ACCESS_TOKEN }}
    idToken: ${{ secrets.ID_TOKEN }}
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: 'push'
```

### Case to pull

```yaml
- uses: lucienve/clasp-action@v1
  with:
    accessToken: ${{ secrets.ACCESS_TOKEN }}
    idToken: ${{ secrets.ID_TOKEN }}
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: 'pull'
```

### Case to deploy

```yaml
- uses: lucienve/clasp-action@v1
  with:
    accessToken: ${{ secrets.ACCESS_TOKEN }}
    idToken: ${{ secrets.ID_TOKEN }}
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: 'deploy'
```

### Case to deploy with description

```yaml
- uses: lucienve/clasp-action@v1
  with:
    accessToken: ${{ secrets.ACCESS_TOKEN }}
    idToken: ${{ secrets.ID_TOKEN }}
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: 'deploy'
    description: 'Sample description'
```

### Case to specify the directory where scripts are stored

```yaml
- uses: lucienve/clasp-action@v1
  with:
    accessToken: ${{ secrets.ACCESS_TOKEN }}
    idToken: ${{ secrets.ID_TOKEN }}
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}     
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    rootDir: 'src'
    command: 'push'
```

### Case to update a specific deploy

```yaml
- uses: lucienve/clasp-action@v1
  with:
    accessToken: ${{ secrets.ACCESS_TOKEN }}
    idToken: ${{ secrets.ID_TOKEN }}
    refreshToken: ${{ secrets.REFRESH_TOKEN }}
    clientId: ${{ secrets.CLIENT_ID }}
    clientSecret: ${{ secrets.CLIENT_SECRET }}
    scriptId: ${{ secrets.SCRIPT_ID }}
    command: 'deploy'
    deployId: ${{ secrets.DEPLOY_ID }}
```

## License summary

This code is made available under the MIT license.
