# Setting Up Google Authentication Credentials

This guide explains how to generate the custom Google Cloud Platform (GCP) credentials and tokens required to authenticate this action. 

Using custom OAuth credentials is the recommended method because default clasp login tokens expire frequently (often within 7 days), which will cause your GitHub Action workflows to fail randomly.

---

## Prerequisites

Before starting, make sure you have:
1. A **Google Cloud Project** where you have permission to create credentials.
2. The Google Apps Script you want to deploy to (and its **Script ID**).
3. `clasp` installed locally on your computer. If you don't have it, install it using:
   ```bash
   npm install -g @google/clasp
   ```

---

## Step 1: Configure the OAuth Consent Screen in GCP

To generate OAuth tokens, your Google Cloud project must have a configured OAuth Consent Screen.

1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Select your project from the dropdown at the top.
3. In the left-hand menu, navigate to **APIs & Services > OAuth consent screen**.
4. Select the **User Type** based on your account type:
   - **Internal**: Choose this if you are using a Google Workspace organization account (recommended, as it restricts access to users within your organization).
   - **External**: Choose this if you are using a personal `@gmail.com` account.
5. Click **Create**.
6. Fill in the required fields:
   - **App name**: (e.g., `GitHub Actions Clasp Deployer`)
   - **User support email**: Select your email address.
   - **Developer contact information**: Enter your email address.
7. Click **Save and Continue** through the remaining screens. If you chose **External** User Type, make sure to add your own Google email address as a **Test User** in the "Test users" step so you can log in.

---

## Step 2: Create a Desktop OAuth Client ID

Next, you need to create the client ID and client secret that `clasp` will use to authenticate.

1. In the GCP Console, navigate to **APIs & Services > Credentials** in the left menu.
2. Click **+ Create Credentials** at the top of the page and select **OAuth client ID**.
3. Under **Application type**, select **Desktop app** (do not select Web application, as clasp is a command-line tool).
4. **Name**: Give it a descriptive name (e.g., `Clasp CLI`).
5. Click **Create**.
6. A dialog box will appear. Click the **Download JSON** button to download the credentials file to your computer.
7. Rename the downloaded file to `creds.json` and move it to a convenient temporary directory on your machine.

---

## Step 3: Enable the Google Apps Script API

You must explicitly enable the Apps Script API in your GCP project to allow programmatic access.

1. In the GCP Console, navigate to **APIs & Services > Enabled APIs & services**.
2. Click **+ Enable APIs and Services** at the top.
3. Search for **Google Apps Script API**.
4. Click on the result and click **Enable**.

---

## Step 4: Login Locally with Your Credentials

Now, run the authentication flow locally on your computer using the credentials you just created.

1. Open your terminal or command prompt.
2. Navigate to the directory where you saved `creds.json`.
3. Run the following command:
   ```bash
   clasp login --creds creds.json
   ```
4. This command will output a URL and attempt to open your default web browser.
5. In the browser, log in using the Google Account that owns or has access to your Google Apps Script project.
6. If you see a "Google hasn't verified this app" screen, click **Advanced** and then click **Go to [App Name] (unsafe)** to proceed.
7. Click **Allow** to grant the requested permissions.
8. Once authentication is complete, you can safely delete the `creds.json` file from your machine.

---

## Step 5: Extract Tokens and Save as GitHub Secrets

clasp has saved your authentication tokens to a file on your computer.

1. Locate and open the `.clasprc.json` file in a text editor:
   - **macOS / Linux**: Open the file at `~/.clasprc.json`
   - **Windows**: Open the file at `%USERPROFILE%\.clasprc.json` (typically `C:\Users\<YourUsername>\.clasprc.json`)
2. Inside `.clasprc.json`, you will see a JSON structure with various credentials.
3. In your GitHub repository, navigate to **Settings > Secrets and variables > Actions** and click **New repository secret**.
4. Create the following secrets by copying the corresponding values from `.clasprc.json`:

| GitHub Secret Name | Source in `.clasprc.json` | Description |
| :--- | :--- | :--- |
| `ACCESS_TOKEN` | `token.access_token` | The current OAuth access token. |
| `ID_TOKEN` | `token.id_token` | The ID token used for authentication. |
| `REFRESH_TOKEN` | `token.refresh_token` | The refresh token used to request new access tokens. |
| `CLIENT_ID` | `oauth2ClientSettings.clientId` | The Client ID created in Step 2. |
| `CLIENT_SECRET` | `oauth2ClientSettings.clientSecret` | The Client Secret created in Step 2. |

---

## Step 6: Find Your Script ID

The GitHub Action also requires a `scriptId` to know which Apps Script project to deploy to.

1. Open your Google Apps Script project in the browser.
2. Click on **Project Settings** (the gear icon on the left panel).
3. Under **IDs**, copy the **Script ID**.
4. In your GitHub repository secrets, add a new secret named `SCRIPT_ID` and paste this value.

---

## Google Sheet & Project Sharing Permissions

If your Google Apps Script is **container-bound** (e.g., created from within a Google Sheet via *Extensions > Apps Script*), or if it interacts with Google Sheets and Google Drive, you must ensure the following permissions are configured:

1. **Google Account Access**: The Google account used to log in via `clasp login` (in Step 4) must be an **Editor** or **Owner** of the container Google Sheet. Without this, clasp will fail to push or deploy the script code.
2. **Dedicated CI/CD Deployer Account (If Applicable)**:
   - If you are using a separate Google account specifically for CI/CD deployments rather than your personal Google account, you must share both the **Google Sheet** and the **Apps Script Project** with that account.
   - For a Google Sheet, click the **Share** button in the top-right corner of the sheet and add the CI/CD Google account as an **Editor**.
   - For a standalone Apps Script project, open the project in the browser, click the **Share** button in the top-right corner, and add the CI/CD Google account as an **Editor**.

