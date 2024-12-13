# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased](https://github.com/mediagrid/capacitor-native-audio/compare/v1.2.0...HEAD)

## [v1.2.0](https://github.com/mediagrid/capacitor-native-audio/compare/v1.1.0...v1.2.0) - 2024-12-13

- feat: Add ability to disable seek buttons in notification by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/15
- feat: Add iOS URL artwork image support by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/14
- fix: Adjust Android focus and content type settings by @wsamoht in [7cf66e2](https://github.com/mediagrid/capacitor-native-audio/commit/7cf66e20356d98225ba28938dd90b39ffaeb4fe3)

## [v1.1.0](https://github.com/mediagrid/capacitor-native-audio/compare/v1.0.0...v1.1.0) - 2024-10-01

- chore: Bring ios checks to parity with android by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/5
- feat: Add method to change metadata by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/6
- chore: Bump Android Media3 library to v1.4.1

## v1.0.0 - 2024-08-14

Initial release 🤩🚀🎉

If coming from the [local plugin](https://gitlab.com/wsamoht/capacitor-js-audio-player-local-plugin), please note the following items:

- Android: Service declaration and permissions were updated (see the [README](https://github.com/mediagrid/capacitor-native-audio?tab=readme-ov-file#android))
- Android: The notification `icon ic_stat_icon_default` is no longer being used, if you are using the same icon for local/push notifications, you’ll want to keep it around
- Android: A new `artworkSource` option was added in lieu of the notification icon
