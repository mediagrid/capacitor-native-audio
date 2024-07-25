# @mediagrid/capacitor-native-audio

# 🚧🚧 THIS PACKAGE IS UNRELEASED 🚧🚧

We are currently working on testing this package and it will be released soon.

## Description

Play audio in a Capacitor app natively (Android/iOS) from a URL/web source simultaneously with background audio. Also supports background/foreground playing.

## Install

```bash
# npm install @mediagrid/capacitor-native-audio
npm install https://github.com/mediagrid/capacitor-native-audio#main # Until released on NPM
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
        android:foregroundServiceType="mediaPlayback" />

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

### Add a notification icon

This icon is used in the notification bar while audio is playing.

1. Open the Android project in Android Studio
1. Right-click on the `app/res` folder in the Project files
1. Go to New -> Image Asset
1. Choose "Notification Icons" under "Icon type"
1. Make the Name `ic_stat_icon_default`
1. Choose your icon
1. Click Next

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

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerprepareparams">AudioPlayerPrepareParams</a></code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

--------------------


### initialize(...)

```typescript
initialize(params: AudioPlayerDefaultParams) => Promise<{ success: boolean; }>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

--------------------


### changeAudioSource(...)

```typescript
changeAudioSource(params: AudioPlayerDefaultParams & { source: string; }) => Promise<void>
```

| Param        | Type                                                                                                |
| ------------ | --------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { source: string; }</code> |

--------------------


### getDuration(...)

```typescript
getDuration(params: AudioPlayerDefaultParams) => Promise<{ duration: number; }>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ duration: number; }&gt;</code>

--------------------


### getCurrentTime(...)

```typescript
getCurrentTime(params: AudioPlayerDefaultParams) => Promise<{ currentTime: number; }>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ currentTime: number; }&gt;</code>

--------------------


### play(...)

```typescript
play(params: AudioPlayerDefaultParams) => Promise<void>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

--------------------


### pause(...)

```typescript
pause(params: AudioPlayerDefaultParams) => Promise<void>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

--------------------


### seek(...)

```typescript
seek(params: AudioPlayerDefaultParams & { timeInSeconds: number; }) => Promise<void>
```

| Param        | Type                                                                                                       |
| ------------ | ---------------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { timeInSeconds: number; }</code> |

--------------------


### stop(...)

```typescript
stop(params: AudioPlayerDefaultParams) => Promise<void>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

--------------------


### setVolume(...)

```typescript
setVolume(params: AudioPlayerDefaultParams & { volume: number; }) => Promise<void>
```

| Param        | Type                                                                                                |
| ------------ | --------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { volume: number; }</code> |

--------------------


### setRate(...)

```typescript
setRate(params: AudioPlayerDefaultParams & { rate: number; }) => Promise<void>
```

| Param        | Type                                                                                              |
| ------------ | ------------------------------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a> & { rate: number; }</code> |

--------------------


### isPlaying(...)

```typescript
isPlaying(params: AudioPlayerDefaultParams) => Promise<{ isPlaying: boolean; }>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

**Returns:** <code>Promise&lt;{ isPlaying: boolean; }&gt;</code>

--------------------


### destroy(...)

```typescript
destroy(params: AudioPlayerDefaultParams) => Promise<void>
```

| Param        | Type                                                                          |
| ------------ | ----------------------------------------------------------------------------- |
| **`params`** | <code><a href="#audioplayerdefaultparams">AudioPlayerDefaultParams</a></code> |

--------------------


### onAppGainsFocus(...)

```typescript
onAppGainsFocus(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

--------------------


### onAppLosesFocus(...)

```typescript
onAppLosesFocus(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

--------------------


### onAudioReady(...)

```typescript
onAudioReady(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

--------------------


### onAudioEnd(...)

```typescript
onAudioEnd(params: AudioPlayerListenerParams, callback: () => void) => Promise<AudioPlayerListenerResult>
```

| Param          | Type                                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code> |
| **`callback`** | <code>() =&gt; void</code>                                                      |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

--------------------


### onPlaybackStatusChange(...)

```typescript
onPlaybackStatusChange(params: AudioPlayerListenerParams, callback: (result: { status: 'playing' | 'paused' | 'stopped'; }) => void) => Promise<AudioPlayerListenerResult>
```

| Param          | Type                                                                              |
| -------------- | --------------------------------------------------------------------------------- |
| **`params`**   | <code><a href="#audioplayerlistenerparams">AudioPlayerListenerParams</a></code>   |
| **`callback`** | <code>(result: { status: 'playing' \| 'paused' \| 'stopped'; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#audioplayerlistenerresult">AudioPlayerListenerResult</a>&gt;</code>

--------------------


### Interfaces


#### AudioPlayerPrepareParams

| Prop                     | Type                 |
| ------------------------ | -------------------- |
| **`audioSource`**        | <code>string</code>  |
| **`friendlyTitle`**      | <code>string</code>  |
| **`useForNotification`** | <code>boolean</code> |
| **`isBackgroundMusic`**  | <code>boolean</code> |
| **`loop`**               | <code>boolean</code> |


#### AudioPlayerDefaultParams

| Prop          | Type                |
| ------------- | ------------------- |
| **`audioId`** | <code>string</code> |


#### AudioPlayerListenerResult

| Prop             | Type                |
| ---------------- | ------------------- |
| **`callbackId`** | <code>string</code> |


#### AudioPlayerListenerParams

| Prop          | Type                |
| ------------- | ------------------- |
| **`audioId`** | <code>string</code> |

</docgen-api>
