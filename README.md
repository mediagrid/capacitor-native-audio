# @mediagrid/capacitor-native-audio

# 🚧🚧 THIS PACKAGE IS UNRELEASED 🚧🚧

We are currently working on testing this package and it will be released soon.

## Description

Play audio in a Capacitor app natively (Android/iOS) from a URL/web source simultaneously with background audio. Also supports background/foreground playing.

## Install

```bash
npm install @mediagrid/capacitor-native-audio
npx cap sync
```

## Android

### `AndroidManifest.xml` required changes

Located at `android/app/src/main/AndroidManifest.xml`

```xml
<application>
    <!-- OTHER STUFF -->

    <!-- Add service to be used for background play -->
    <service
        android:name="us.mediagrid.capacitorjs.plugins.nativeaudio.AudioPlayerService"
        android:description="@string/audio_player_service_description"
        android:foregroundServiceType="mediaPlayback"
        android:exported="true">
        <intent-filter>
            <action android:name="androidx.media3.session.MediaSessionService"/>
        </intent-filter>
    </service>

    <!-- OTHER STUFF -->
</application>

<!-- Add required permissions -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### `strings.xml` required changes

Located at `android/app/src/main/res/values/strings.xml`

```xml
<resources>
    <!-- OTHER STUFF -->

    <!-- Describes the service in your app settings once installed -->
    <string name="audio_player_service_description">Allows for audio to play in the background.</string>
</resources>
```

# iOS

## Enable Audio Background Mode

This can be done in XCode or by editing `Info.plist` directly.

```xml
<!-- ios/App/App/Info.plist -->

<dict>
    <!-- OTHER STUFF -->

    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>

    <!-- OTHER STUFF -->
</dict>
```

## API

<docgen-index>

* [`create(...)`](#create)
* [`initialize(...)`](#initialize)
* [`changeAudioSource(...)`](#changeaudiosource)
* [`getDuration(...)`](#getduration)
* [`getCurrentTime(...)`](#getcurrenttime)
* [`play(...)`](#play)
* [`pause(...)`](#pause)
* [`seek(...)`](#seek)
* [`stop(...)`](#stop)
* [`setVolume(...)`](#setvolume)
* [`setRate(...)`](#setrate)
* [`isPlaying(...)`](#isplaying)
* [`destroy(...)`](#destroy)
* [`onAppGainsFocus(...)`](#onappgainsfocus)
* [`onAppLosesFocus(...)`](#onapplosesfocus)
* [`onAudioReady(...)`](#onaudioready)
* [`onAudioEnd(...)`](#onaudioend)
* [`onPlaybackStatusChange(...)`](#onplaybackstatuschange)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### create(...)

```typescript
create(params: AudioPlayerPrepareParams) => Promise<{ success: boolean; }>
```

Create an audio source to be played.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerprepareparams">AudioPlayerPrepareParams</a></code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

**Since:** 1.0.0

--------------------


### initialize(...)

```typescript
initialize(params: AudioPlayerDefaultParams) => Promise<{ success: boolean; }>
```

Initialize the audio source. Prepares the audio to be played, buffers and such.

Should be called after callbacks are registered (e.g. `onAudioReady`).

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

**Since:** 1.0.0

--------------------


### changeAudioSource(...)

```typescript
changeAudioSource(params: AudioPlayerDefaultParams & { source: string; }) => Promise<void>
```

Change the audio source on an existing audio source (`audioId`).

This is useful for changing background music while the primary audio is playing
or changing the primary audio before it is playing to accommodate different durations
that a user can choose from.

| Param        | Type                                                                                                |
| ------------ | --------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { source: string; }</code> |

**Since:** 1.0.0

--------------------


### getDuration(...)

```typescript
getDuration(params: AudioPlayerDefaultParams) => Promise<{ duration: number; }>
```

Get the duration of the audio source.

Should be called once the audio is ready (`onAudioReady`).

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ duration: number; }&gt;</code>

**Since:** 1.0.0

--------------------


### getCurrentTime(...)

```typescript
getCurrentTime(params: AudioPlayerDefaultParams) => Promise<{ currentTime: number; }>
```

Get the current time of the audio source being played.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ currentTime: number; }&gt;</code>

**Since:** 1.0.0

--------------------


### play(...)

```typescript
play(params: AudioPlayerDefaultParams) => Promise<void>
```

Play the audio source.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Since:** 1.0.0

--------------------


### pause(...)

```typescript
pause(params: AudioPlayerDefaultParams) => Promise<void>
```

Pause the audio source.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Since:** 1.0.0

--------------------


### seek(...)

```typescript
seek(params: AudioPlayerDefaultParams & { timeInSeconds: number; }) => Promise<void>
```

Seek the audio source to a specific time.

| Param        | Type                                                                                                       |
| ------------ | ---------------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { timeInSeconds: number; }</code> |

**Since:** 1.0.0

--------------------


### stop(...)

```typescript
stop(params: AudioPlayerDefaultParams) => Promise<void>
```

Stop playing the audio source and reset the current time to zero.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Since:** 1.0.0

--------------------


### setVolume(...)

```typescript
setVolume(params: AudioPlayerDefaultParams & { volume: number; }) => Promise<void>
```

Set the volume of the audio source. Should be a decimal less than or equal to `1.00`.

This is useful for background music.

| Param        | Type                                                                                                |
| ------------ | --------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { volume: number; }</code> |

**Since:** 1.0.0

--------------------


### setRate(...)

```typescript
setRate(params: AudioPlayerDefaultParams & { rate: number; }) => Promise<void>
```

Set the rate for the audio source to be played at.
Should be a decimal. An example being `1` is normal speed, `0.5` being half the speed and `1.5` being 1.5 times faster.

| Param        | Type                                                                                              |
| ------------ | ------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { rate: number; }</code> |

**Since:** 1.0.0

--------------------


### isPlaying(...)

```typescript
isPlaying(params: AudioPlayerDefaultParams) => Promise<{ isPlaying: boolean; }>
```

Wether or not the audio source is currently playing.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ isPlaying: boolean; }&gt;</code>

**Since:** 1.0.0

--------------------


### destroy(...)

```typescript
destroy(params: AudioPlayerDefaultParams) => Promise<void>
```

Destroy all resources for the audio source.
The audio source with `useForNotification = true` must be destroyed last.

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Since:** 1.0.0

--------------------


### onAppGainsFocus(...)

```typescript
onAppGainsFocus(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

Register a callback for when the app comes to the foreground.

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### onAppLosesFocus(...)

```typescript
onAppLosesFocus(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

Registers a callback from when the app goes to the background.

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### onAudioReady(...)

```typescript
onAudioReady(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

Registers a callback for when the audio source is ready to be played.

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### onAudioEnd(...)

```typescript
onAudioEnd(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

Registers a callback for when the audio source has ended (reached the end of the audio).

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### onPlaybackStatusChange(...)

```typescript
onPlaybackStatusChange(params: AudioPlayerListenerParams, callback: (result: { status: 'playing' | 'paused' | 'stopped'; }) => void) => Promise<AudioPlayerListenerResult>
```

Registers a callback for when state of playback for the audio source has changed.
This should be used to update the UI when the notification controls are used to control the playback.

| Param          | Type                                                                              |
| -------------- | --------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code>   |
| **`callback`** | <code>(result: { status: 'playing' \| 'paused' \| 'stopped'; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### Interfaces


#### AudioPlayerPrepareParams

| Prop                     | Type                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Since |
| ------------------------ | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **`audioSource`**        | <code>string</code>  | A URI for the audio file to play                                                                                                                                                                                                                                                                                                                                                                                                                                                                | 1.0.0 |
| **`friendlyTitle`**      | <code>string</code>  | The title/name of the audio file to be used on the notification                                                                                                                                                                                                                                                                                                                                                                                                                                 | 1.0.0 |
| **`useForNotification`** | <code>boolean</code> | Whether to use this audio file for the notification. This is considered the primary audio to play. It must be created first and you may only have one at a time.                                                                                                                                                                                                                                                                                                                                | 1.0.0 |
| **`artworkSource`**      | <code>string</code>  | A URI for the album art image to display on the Android notification. Has no affect on iOS. Can also be an in-app source. Pulls from `android/app/src/assets/public`. If using [Vite](https://vitejs.dev/guide/assets.html#the-public-directory), you would put the image in your `public` folder and the build process will copy to `dist` which in turn will be copied to the Android assets by Capacitor. A PNG is the best option with square dimensions. 1200px x 1200px is a good option. | 1.0.0 |
| **`isBackgroundMusic`**  | <code>boolean</code> | Is this audio for background music/audio. Should not be `true` when `useForNotification = true`.                                                                                                                                                                                                                                                                                                                                                                                                | 1.0.0 |
| **`loop`**               | <code>boolean</code> | Whether or not to loop other audio like background music while the primary audio (`useForNotification = true`) is playing.                                                                                                                                                                                                                                                                                                                                                                      | 1.0.0 |


#### AudioPlayerDefaultParams

| Prop          | Type                | Description                                        | Since |
| ------------- | ------------------- | -------------------------------------------------- | ----- |
| **`audioId`** | <code>string</code> | Any string to differentiate different audio files. | 1.0.0 |


#### AudioPlayerListenerResult

| Prop             | Type                |
| ---------------- | ------------------- |
| **`callbackId`** | <code>string</code> |


#### AudioPlayerListenerParams

| Prop          | Type                | Description                                 | Since |
| ------------- | ------------------- | ------------------------------------------- | ----- |
| **`audioId`** | <code>string</code> | The `audioId` set when `create` was called. | 1.0.0 |

</docgen-api>
