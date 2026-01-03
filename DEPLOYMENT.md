# Deployment Guide

## GitHub Secrets Configuration

Go to your repository Settings > Secrets and variables > Actions, and add the following secrets:

### Vercel Deployment (Web)

1. **VERCEL_TOKEN**: Get from https://vercel.com/account/tokens
2. **VERCEL_ORG_ID**: Found in `.vercel/project.json` after linking project
3. **VERCEL_PROJECT_ID**: Found in `.vercel/project.json` after linking project

To get VERCEL_ORG_ID and VERCEL_PROJECT_ID:
```bash
cd web
npx vercel link
# Follow the prompts to link to your Vercel account
# Then check .vercel/project.json for the IDs
```

### Play Store Deployment (Android)

1. **KEYSTORE_BASE64**: Your upload keystore encoded in base64
   ```bash
   base64 -i keys/upload-keystore.jks
   ```

2. **KEYSTORE_PASSWORD**: Password for the keystore

3. **KEY_PASSWORD**: Password for the key

4. **KEY_ALIAS**: Alias of the key (e.g., "upload")

5. **GOOGLE_SERVICES_JSON**: Contents of google-services.json file

6. **PLAY_STORE_CREDENTIALS**: Google Play service account JSON
   - Go to Google Play Console > Settings > API access
   - Create a service account with "Release to production" permission
   - Download the JSON key file and paste its contents

## Manual Deployment

### Web (Vercel)

```bash
cd web
npm install
npm run build
npx vercel --prod
```

### Android (Play Store)

```bash
cd mobile
flutter build appbundle --release
```

Then upload the AAB file from `build/app/outputs/bundle/release/app-release.aab` to Play Console.

## CI/CD Workflows

### Web Deploy (`web-deploy.yml`)
- Triggers on push to master/main when web/ files change
- Builds Next.js app and deploys to Vercel

### Android Release (`android-release.yml`)
- Triggers on push to master/main when mobile/ files change
- Can be manually triggered with release track selection
- Builds Flutter app and uploads to Play Store

## First Time Setup

1. Create the GitHub repository (done)
2. Set up Vercel project:
   ```bash
   cd web
   npx vercel link
   ```
3. Add all GitHub secrets
4. Create Play Store app listing
5. Upload first AAB manually to Play Store
6. Enable automated publishing in Play Store Console

## Release Tracks

- **internal**: Internal testing (fastest)
- **alpha**: Closed testing
- **beta**: Open testing
- **production**: Public release
