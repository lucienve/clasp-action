# Project Context

This GitHub Action wraps the Google Apps Script CLI (`clasp`) to deploy, push,
or pull Apps Script projects.

## Architectural Decisions

### Upstream Pull Request Branches (November 2026)

This repository maintains two active pull request branches targeting the
upstream repository
([`daikikatsuragawa/clasp-action`](https://github.com/daikikatsuragawa/clasp-action)
at commit `861a874` / `v1.2.0`):

1. **`patch-1` (Upstream PR #13)**:
   - **Purpose**: Documentation fix for upstream `v1.2.0`. Updates all 6
     workflow examples in `README.md` to reference
     `daikikatsuragawa/clasp-action@v1.2.0` instead of `@v1.1.0` (which threw
     errors for users attempting to use `pull`), adds `pull` to the action's
     overview description and `command` input documentation, and standardizes
     prose formatting to 80 characters.
   - **Ancestry**: Based directly on `861a874` (`v1.2.0`).
2. **`modernize-action` (Upstream PR #14)**:
   - **Purpose**: Comprehensive v2 modernization for upstream clasp-action.
     Upgrades the runtime to `@google/clasp@3.4.1` on `node:26-alpine`,
     transitions authentication to Clasp v3's native `tokens.default` OAuth2
     schema via `refreshToken`, `clientId`, and `clientSecret` (eliminating
     legacy `accessToken` and `idToken`), hardens `entrypoint.sh` with fail-fast
     validation, zero-argv credential ingestion via `jq -n`, scoped `umask 077`,
     POSIX trap cleanups, non-destructive `.clasp.json` preservation, and adds
     `.github/workflows/ci.yml`, `.github/dependabot.yml`, Prettier,
     markdownlint, and `docs/setup-credentials.md`.
   - **Marketplace & Scope Continuity**: Retains `name: 'Clasp Action'` in
     `action.yml` for upstream marketplace compatibility, omits fork-only
     sections and machine-local rules, and references
     `daikikatsuragawa/clasp-action@v2.0.0` in workflow examples.
   - **Mergeability**: Merges cleanly (3-way merge exit code 0) against both
     upstream `861a874` and `patch-1`.

### Release v2.0.0 Architecture & Security Hardening (November 2026)

- **Native Clasp v3 Credential Schema**: Removed legacy `accessToken` and
  `idToken` inputs. Configured `entrypoint.sh` to generate the native
  `tokens.default` schema (`type: "authorized_user"`, `client_id`,
  `client_secret`, and `refresh_token`), enabling `google-auth-library` to
  manage token lifecycles automatically without premature 401 retry loops.
- **Zero-Argv Secret Handling**: Injected inputs directly via environment
  variables (`env.INPUT_*`) in `jq` expressions to prevent credential leakage in
  runner process tables (`ps aux`).
- **Scoped Umask & Lifecycle Cleanup**: Scoped `umask 077` to `~/.clasprc.json`
  creation to ensure `0600` file permissions without degrading
  `/github/workspace` file permissions during `clasp pull`. Configured a POSIX
  `EXIT INT TERM` trap to guarantee the removal of `~/.clasprc.json` and
  temporary files upon job exit.
- **In-Place `.clasp.json` Restoration**: Configured `entrypoint.sh` to back up
  and restore existing `.clasp.json` files in place via content streaming,
  preserving inode identities and permissions. When `rootDir` is configured,
  settings are cleanly inherited from the repository root with stripped nested
  directory keys.
- **CI & Code Health Automation**: Added `.github/workflows/ci.yml` running
  ShellCheck, Prettier, markdownlint, Docker container builds, and entrypoint
  smoke tests on every push and pull request. Added `.markdownlint.json` and
  `.prettierrc` enforcing 80-character prose wrapping.

### Package Management & Dependabot Setup (June 2026)

- **Dependency Migration**: Shifted `@google/clasp` CLI installation from a
  global npm installation (`npm install -g`) to local package management via
  `package.json` and `package-lock.json`. This ensures that clasp and its
  transitive dependencies are pinned and tracked by Dependabot.
- **Path Resolution**: Configured `Dockerfile` to add `/app/node_modules/.bin`
  to the `PATH` environment variable.
- **Dependabot Integration**: Added `.github/dependabot.yml` to automatically
  track updates for the Docker base image and npm dependencies.

## File Structure

- [Dockerfile](../Dockerfile): Defines the runtime container image using Node 26
  Alpine, installs dependencies, and copies the entrypoint script.
- [package.json](../package.json): Declares `@google/clasp` as a pinned
  dependency.
- [package-lock.json](../package-lock.json): Pins the exact dependency graph.
- [entrypoint.sh](../entrypoint.sh): Executed by the action to merge
  configuration and call `clasp` commands.
- [action.yml](../action.yml): GitHub Action metadata declaring inputs and the
  Docker execution environment.
- [.github/dependabot.yml](../.github/dependabot.yml): Dependabot automated
  updates configuration.
- [.github/workflows/ci.yml](../.github/workflows/ci.yml): Automated CI workflow
  running linters, image builds, and smoke tests.
- [.prettierrc](../.prettierrc): Prettier formatting configuration enforcing
  80-character prose wrapping.
- [.markdownlint.json](../.markdownlint.json): Markdown linting rules enforcing
  MD013 line length on prose.
- [docs/setup-credentials.md](./setup-credentials.md): Guide for configuring
  Google Cloud OAuth2 credentials for the action.
