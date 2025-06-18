# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased](https://github.com/mediagrid/capacitor-native-audio/compare/v2.2.0...HEAD)

## [v2.2.0](https://github.com/mediagrid/capacitor-native-audio/compare/v2.1.1...v2.2.0) - 2025-06-18

### What's Changed

* feat: Add metadata update via URL on an interval by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/25
* example: Improve play status and change Vite default port

**Full Changelog**: https://github.com/mediagrid/capacitor-native-audio/compare/v2.1.1...v2.2.0

## [v2.1.1](https://github.com/mediagrid/capacitor-native-audio/compare/v2.1.0...v2.1.1) - 2025-05-30

### What's Changed

- fix: Android - duration and currentTime returning long instead of float by @mevatron in https://github.com/mediagrid/capacitor-native-audio/pull/30

**Full Changelog**: https://github.com/mediagrid/capacitor-native-audio/compare/v2.1.0...v2.1.1

## [v2.1.0](https://github.com/mediagrid/capacitor-native-audio/compare/v2.0.0...v2.1.0) - 2025-05-06

### What's Changed

- feat: Add album title and artist name by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/24
- Bump Android Media3 library to v1.6.1 in [e62d224b](https://github.com/mediagrid/capacitor-native-audio/commit/e62d224b858e0807bd6f778ca69eb3f9cdd46664)

**Possible breaking change**

When calling `changeMetadata()`, any params not sent will now explicitly be set to an empty value. Before we didn't touch them.

**Full Changelog**: https://github.com/mediagrid/capacitor-native-audio/compare/v2.0.0...v2.1.0

## [v2.0.0](https://github.com/mediagrid/capacitor-native-audio/compare/v1.2.0...v2.0.0) - 2025-02-11

### What's Changed

- Support Capacitor 7 by @wsamoht in https://github.com/mediagrid/capacitor-native-audio/pull/22
- Bump Android Media3 library to [v1.5.1](https://github.com/androidx/media/releases/tag/1.5.1) @wsamoht in [b626813](https://github.com/mediagrid/capacitor-native-audio/commit/b6268139283fb62f463c78d69bcce484fede8e9f)

**Full Changelog**: https://github.com/mediagrid/capacitor-native-audio/compare/v1.2.0...v2.0.0

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
