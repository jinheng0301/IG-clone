# Instagramzzz

A Flutter Instagram clone with Firebase backend support and real-time social features.

## Overview

This application recreates core Instagram-style interactions in a responsive Flutter app. It supports authentication, posting, profile management, social engagement, and real-time updates through Firebase services.

The project is intended as a serious engineering exercise, not a template-level demo. It should be read, extended, and maintained with production discipline.

## Core Features

- Responsive Instagram-style UI for different screen sizes
- Email and password authentication
- User account creation with profile data
- Share posts with captions
- Display posts in the feed
- Delete posts
- Like posts
- Comment on posts
- Like comments
- Delete comments
- Automatically update like counts and comment counts
- Search users
- Follow and unfollow users
- Profile screen with user posts, followers, and following counts
- Sign out
- Real-time data behavior using Firebase

## Real-Time Behavior

The app is designed around real-time social interaction.

Examples:

- Newly added posts appear from Firestore updates
- Likes are reflected after user interaction
- Comments and comment counts stay synchronized
- Follow and unfollow changes update profile relationships
- Profile data remains connected to live backend data

This is one of the main goals of the project: social features should feel live, not manually refreshed or locally faked.

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Provider

Additional UI and media packages are also used for images, video, grids, loading states, zooming, and SVG rendering.

## Current Feature Scope

### Authentication

- Sign up with email and password
- Log in with email and password
- Load authenticated user state
- Sign out

### Social Content

- Create a post with caption
- Upload post media
- Display post feed
- Delete own posts
- Like and unlike posts

### Comments

- Add comments to posts
- Like comments
- Delete comments
- Maintain comment counters

### User Discovery and Relationships

- Search users
- Follow users
- Unfollow users
- Show followers and following

### Profile

- Display profile information
- Display user posts
- Show follower count
- Show following count

## Project Structure

Key folders inside `lib/`:

- `models/` for app data models such as user, post, comment, and story
- `providers/` for state management
- `resources/` for Firebase auth, storage, and Firestore logic
- `responsive/` for mobile and web layout handling
- `screens/` for feature screens
- `utils/` for shared constants and helpers
- `widgets/` for reusable UI components

## Firebase Usage

The project depends on Firebase for core product behavior:

- Authentication manages sign up, login, and session state
- Firestore stores users, posts, comments, likes, followers, and following relationships
- Storage stores uploaded images and other media assets

Because the app uses Firebase heavily, project setup must keep configuration files, Gradle setup, and SDK versions aligned.

## How To Run

1. Install Flutter SDK
2. Install Android Studio or another supported Flutter toolchain
3. Configure Firebase for the target platform
4. Run `flutter pub get`
5. Run `flutter run`

## Professional AI Usage

This project should not be developed through "vibe coding".

AI is useful here only when used with engineering intent. That means:

- Start from a concrete problem statement
- Read the existing code before changing it
- Ask AI for bounded tasks
- Inspect every generated change
- Confirm architecture and naming still make sense
- Validate behavior after each meaningful modification

### Good Prompts

- "Explain the auth flow in this project."
- "Fix the comment count update bug without changing UI behavior."
- "Refactor Firestore methods to improve readability."
- "Update the Android Gradle files to current Flutter compatibility."
- "Document the profile feature and list its dependencies."

### Bad Prompts

- "Build the whole app for me."
- "Make it more professional."
- "Rewrite everything."
- "Add random features."
- "Fix bugs" without naming the bug, screen, or behavior.

### Professional Rule

If a developer cannot explain:

- what changed
- why it changed
- which files changed
- how it was verified

then the change is not ready, even if it appears to work.

## Development Notes

- Keep folder and file naming consistent
- Prefer small, verifiable changes
- Avoid mixing refactors with feature work in one step
- Keep Firebase-dependent behavior explicit
- Update documentation when features or setup change

## Status

This project already implements the main Instagram clone workflow:

- authentication
- posting
- likes
- comments
- profile relationships
- search
- real-time backend interaction

The next quality improvements should focus on:

- documentation accuracy
- configuration consistency
- naming cleanup
- test coverage
- platform setup validation

