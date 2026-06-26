# Project Context

This GitHub Action wraps the Google App Script CLI (`clasp`) to deploy, push, or pull Apps Script projects.

## Architectural Decisions

### Package Management & Dependabot Setup (June 2026)
- **Dependency Migration**: Shifted the `@google/clasp` CLI installation from a global npm installation (`npm install -g` inside the `Dockerfile`) to local package management via `package.json` and `package-lock.json`. This ensures that clasp and its transitive dependencies can be tracked by standard dependency scanners and dependency managers.
- **Path Resolution**: Configured the `Dockerfile` to add the local node modules executable directory (`/app/node_modules/.bin`) to the `PATH` environment variable. This avoids the need to change command invocations inside `entrypoint.sh`.
- **Dependabot Integration**: Added `.github/dependabot.yml` to automatically track and update:
  - The Docker base image (`node:20-alpine`)
  - The npm dependencies (`@google/clasp` in `package.json`)

## File Structure

- [Dockerfile](../Dockerfile): Defines the runtime container image using Node 20 Alpine, installs dependencies, and copies the entrypoint script.
- [package.json](../package.json): Declares `@google/clasp` as a pinned dependency.
- [package-lock.json](../package-lock.json): Pins the exact dependency graph.
- [entrypoint.sh](../entrypoint.sh): Executed by the action to merge configuration and call `clasp` commands.
- [action.yml](../action.yml): GitHub Action metadata declaring inputs and the Docker execution environment.
- [.github/dependabot.yml](../.github/dependabot.yml): Dependabot automated updates configuration.
