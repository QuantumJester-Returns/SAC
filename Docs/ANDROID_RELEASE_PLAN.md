# Android Build and Update Plan

SAC is being developed as a native Unreal Engine game with Android as the first hands-on test target.

## Major-update APK workflow

For each agreed major milestone:
1. Build and test the project in Unreal Editor.
2. Package an Android APK for the target device architecture (initially ARM64).
3. Install and test the APK on the phone.
4. Record the build number and milestone in release notes.
5. Keep the Android application ID and signing identity unchanged.

## Persistent signing identity

Android updates must be signed with the same signing identity as the installed application. We will create one private release keystore and preserve it securely.

Security rules:
- Never commit the keystore file (.jks or .keystore) to Git.
- Never put keystore passwords or key passwords in source files, logs, screenshots, or chat.
- Keep at least one secure backup outside the project repository.
- Use protected GitHub Actions secrets only if automated signing is configured.
- Do not regenerate the release key after distributing the first signed test APK.

The application ID is initially set to com.quantumjester.sac. Changing it later creates a different Android app identity and prevents in-place upgrades.

## Build versioning

- StoreVersion is the Android version code and must increase for every distributed update.
- The user-facing version name should also be updated for each milestone.
- Use ARM64 packaging for current Android phones unless device testing indicates otherwise.

## Build prerequisites

A successful Unreal Android package requires a compatible Unreal Engine installation, Android SDK, NDK, Java toolchain, and the project's required assets. Their versions must match the selected Unreal Engine release.

This repository can hold project source and build configuration, but an APK is only considered delivered after an actual successful Android package build and installation test.
