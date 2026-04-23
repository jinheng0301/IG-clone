# Cloudinary Migration Summary

## What Was Changed

The app was changed to use Cloudinary for image uploads instead of Firebase Storage.

What stayed the same:

- Firebase Authentication is still used
- Cloud Firestore is still used
- The Go backend was not changed
- The rest of the Flutter app flow stays the same

## Files Changed

### 1. `pubspec.yaml`

Changed dependencies:

- added `http`
- removed `firebase_storage`

This lets the app upload images directly to Cloudinary over HTTP.

### 2. `lib/config/cloudinary_config.dart`

Added a new config file that reads Cloudinary values from `--dart-define`:

- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_UPLOAD_PRESET`

### 3. `lib/resources/storage_methods.dart`

Replaced the previous Firebase Storage upload logic with direct Cloudinary upload logic.

Current behavior:

- profile images upload to Cloudinary folder: `profilePics/<uid>`
- post images upload to Cloudinary folder: `posts/<uid>`
- profile uploads use a timestamp-based `public_id`
- post uploads use a UUID-based `public_id`
- the method returns the Cloudinary `secure_url`

This keeps the rest of the app unchanged because existing Firestore code still stores the returned image URL in:

- `users.photoUrl`
- `posts.postUrl`

## Current Architecture

After this change, the app works like this:

- login/signup: Firebase Auth
- user/post/comment data: Firestore
- image hosting: Cloudinary

## What I Verified

- `flutter pub get` completed successfully
- `firebase_storage` is no longer present in the lockfile
- the new Cloudinary config and upload code were added successfully

## What I Could Not Fully Verify Yet

I could not run a true end-to-end upload test because Cloudinary credentials are not available in the project yet.

That means:

- signup profile image upload is coded, but not tested with your real Cloudinary account
- post image upload is coded, but not tested with your real Cloudinary account

## What You Need From Cloudinary

Create a free Cloudinary account and prepare:

1. your `cloud name`
2. an `unsigned upload preset`

You need both values for the app to upload images.

## How To Run The App

Run Flutter with these defines:

```powershell
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name --dart-define=CLOUDINARY_UPLOAD_PRESET=your_unsigned_preset
```

## How To Test

### Test 1: Signup Profile Image

1. Start the app with the Cloudinary defines
2. Sign up with a selected profile image
3. Confirm signup succeeds
4. Check Firestore `users` collection
5. Confirm `photoUrl` is a Cloudinary URL

Expected shape:

```text
https://res.cloudinary.com/<cloud_name>/...
```

### Test 2: Post Image Upload

1. Log in
2. Open add post
3. Pick an image
4. Submit the post
5. Check Firestore `posts` collection
6. Confirm `postUrl` is a Cloudinary URL

Expected shape:

```text
https://res.cloudinary.com/<cloud_name>/...
```

## Important Notes

- If `CLOUDINARY_CLOUD_NAME` or `CLOUDINARY_UPLOAD_PRESET` is missing, uploads will fail
- profile upload falls back to the default placeholder URL if upload fails
- post upload throws an error if upload fails, so the user sees the failure instead of silently saving a broken post

## Next Recommended Step

Once you create the Cloudinary account, the next step is to run the app with the two `--dart-define` values and test:

1. signup with profile image
2. create post with image

If needed, the next follow-up change should be adding a small `.env` or launch configuration workflow for local development so you do not have to type the Cloudinary values manually each time.
