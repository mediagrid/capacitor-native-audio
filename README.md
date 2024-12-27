# @mediagrid/capacitor-native-audio

## Description

Play audio in a Capacitor app natively (Android/iOS) from a URL/web source simultaneously with background audio. Also supports background playing with an OS notification.

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

## Add Now Playing Icon (optional) - DEPRECATED

⚠️⚠️ This is DEPRECATED. Use `artworkSource` now. ⚠️⚠️

If you would like a now playing icon to show in the iOS notification, add an image with the name `NowPlayingIcon` to your Asset catalog. See [Managing assets with asset catalogs](https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs) on how to add a new asset.

A PNG is recommended with the size of 1024 x 1024px. The same image can be used for the three different Asset wells (1x, 2x, 3x).

# API

<docgen-index>

* [`create(...)`](#create)
* [`createMultiple(...)`](#createmultiple)
* [`changeAudioSource(...)`](#changeaudiosource)
* [`changeMetadata(...)`](#changemetadata)
* [`play(...)`](#play)
* [`pause()`](#pause)
* [`stop()`](#stop)
* [`seek(...)`](#seek)
* [`getCurrentTime()`](#getcurrenttime)
* [`getDuration()`](#getduration)
* [`playNext()`](#playnext)
* [`playPrevious()`](#playprevious)
* [`setVolume(...)`](#setvolume)
* [`setRate(...)`](#setrate)
* [`isPlaying(...)`](#isplaying)
* [`destroy(...)`](#destroy)
* [`getCurrentAudio()`](#getcurrentaudio)
* [`onAudioReady(...)`](#onaudioready)
* [`onAudioEnd(...)`](#onaudioend)
* [`onPlaybackStatusChange(...)`](#onplaybackstatuschange)
* [`onPlayNext(...)`](#onplaynext)
* [`onPlayPrevious(...)`](#onplayprevious)
* [`onSeek(...)`](#onseek)
* [`addListener('onPlayNext' | 'onPlayPrevious' | 'onSeek' | 'onPlaybackStatusChange' | 'onAudioEnd', ...)`](#addlisteneronplaynext--onplayprevious--onseek--onplaybackstatuschange--onaudioend-)
* [`setAudioSources(...)`](#setaudiosources)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### create(...)

```typescript
create(params: AudioSource) => Promise<{ success: boolean; }>
```

Create a single audio source for playback.

| Param        | Type                                                |
| ------------ | --------------------------------------------------- |
| **`params`** | <code><a href="#audiosource">AudioSource</a></code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

--------------------


### createMultiple(...)

```typescript
createMultiple(params: { audioSources: AudioSource[]; }) => Promise<{ success: boolean; }>
```

Create multiple audio sources for playlist management.

| Param        | Type                                          |
| ------------ | --------------------------------------------- |
| **`params`** | <code>{ audioSources: AudioSource[]; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

--------------------


### changeAudioSource(...)

```typescript
changeAudioSource(params: { audioId: string; source: string; }) => Promise<void>
```

Change the audio source for an existing player.

| Param        | Type                                              |
| ------------ | ------------------------------------------------- |
| **`params`** | <code>{ audioId: string; source: string; }</code> |

--------------------


### changeMetadata(...)

```typescript
changeMetadata(params: { audioId: string; title?: string; artist?: string; albumTitle?: string; artworkSource?: string; }) => Promise<void>
```

Change the metadata of an existing audio source.

| Param        | Type                                                                                                            |
| ------------ | --------------------------------------------------------------------------------------------------------------- |
| **`params`** | <code>{ audioId: string; title?: string; artist?: string; albumTitle?: string; artworkSource?: string; }</code> |

--------------------


### play(...)

```typescript
play(params?: { audioId?: string | null | undefined; } | undefined) => Promise<void>
```

Play an audio source by its ID.

| Param        | Type                                       |
| ------------ | ------------------------------------------ |
| **`params`** | <code>{ audioId?: string \| null; }</code> |

--------------------


### pause()

```typescript
pause() => Promise<void>
```

Pause playback of an audio source.

--------------------


### stop()

```typescript
stop() => Promise<void>
```

Stop playback and reset the audio source.

--------------------


### seek(...)

```typescript
seek(params: { timeInSeconds: number; }) => Promise<void>
```

Seek to a specific time in the audio source.

| Param        | Type                                    |
| ------------ | --------------------------------------- |
| **`params`** | <code>{ timeInSeconds: number; }</code> |

--------------------


### getCurrentTime()

```typescript
getCurrentTime() => Promise<{ currentTime: number; }>
```

Get the current playback time of an audio source.

**Returns:** <code>Promise&lt;{ currentTime: number; }&gt;</code>

--------------------


### getDuration()

```typescript
getDuration() => Promise<{ duration: number; }>
```

Get the duration of an audio source.

**Returns:** <code>Promise&lt;{ duration: number; }&gt;</code>

--------------------


### playNext()

```typescript
playNext() => Promise<void>
```

Skip to the next audio source in the playlist.

--------------------


### playPrevious()

```typescript
playPrevious() => Promise<void>
```

Skip to the previous audio source in the playlist.

--------------------


### setVolume(...)

```typescript
setVolume(params: { volume: number; }) => Promise<void>
```

Set the volume for the audio source.

| Param        | Type                             |
| ------------ | -------------------------------- |
| **`params`** | <code>{ volume: number; }</code> |

--------------------


### setRate(...)

```typescript
setRate(params: { rate: number; }) => Promise<void>
```

Set the playback rate for the audio source.

| Param        | Type                           |
| ------------ | ------------------------------ |
| **`params`** | <code>{ rate: number; }</code> |

--------------------


### isPlaying(...)

```typescript
isPlaying(params: { audioId: string; }) => Promise<{ isPlaying: boolean; }>
```

Determine if the audio source is currently playing.

| Param        | Type                              |
| ------------ | --------------------------------- |
| **`params`** | <code>{ audioId: string; }</code> |

**Returns:** <code>Promise&lt;{ isPlaying: boolean; }&gt;</code>

--------------------


### destroy(...)

```typescript
destroy(params: { audioId: string; }) => Promise<void>
```

Destroy all resources associated with the audio source.

| Param        | Type                              |
| ------------ | --------------------------------- |
| **`params`** | <code>{ audioId: string; }</code> |

--------------------


### getCurrentAudio()

```typescript
getCurrentAudio() => Promise<CurrentAudio>
```

Get details about the currently active audio source.

**Returns:** <code>Promise&lt;<a href="#currentaudio">CurrentAudio</a>&gt;</code>

--------------------


### onAudioReady(...)

```typescript
onAudioReady(params: { audioId: string; }, callback: () => void) => Promise<{ callbackId: string; }>
```

Register a callback for when the audio source is ready for playback.

| Param          | Type                              |
| -------------- | --------------------------------- |
| **`params`**   | <code>{ audioId: string; }</code> |
| **`callback`** | <code>() =&gt; void</code>        |

**Returns:** <code>Promise&lt;{ callbackId: string; }&gt;</code>

--------------------


### onAudioEnd(...)

```typescript
onAudioEnd(params: { audioId: string; }, callback: () => void) => Promise<{ callbackId: string; }>
```

Register a callback for when playback of the audio source ends.

| Param          | Type                              |
| -------------- | --------------------------------- |
| **`params`**   | <code>{ audioId: string; }</code> |
| **`callback`** | <code>() =&gt; void</code>        |

**Returns:** <code>Promise&lt;{ callbackId: string; }&gt;</code>

--------------------


### onPlaybackStatusChange(...)

```typescript
onPlaybackStatusChange(callback: (result: { status: "stopped" | "paused" | "playing"; }) => void) => Promise<{ callbackId: string; }>
```

Register a callback for playback status changes.

| Param          | Type                                                                              |
| -------------- | --------------------------------------------------------------------------------- |
| **`callback`** | <code>(result: { status: 'stopped' \| 'paused' \| 'playing'; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;{ callbackId: string; }&gt;</code>

--------------------


### onPlayNext(...)

```typescript
onPlayNext(callback: () => void) => Promise<{ callbackId: string; }>
```

Register a callback for when the next track is played.

| Param          | Type                       |
| -------------- | -------------------------- |
| **`callback`** | <code>() =&gt; void</code> |

**Returns:** <code>Promise&lt;{ callbackId: string; }&gt;</code>

--------------------


### onPlayPrevious(...)

```typescript
onPlayPrevious(callback: () => void) => Promise<{ callbackId: string; }>
```

Register a callback for when the previous track is played.

| Param          | Type                       |
| -------------- | -------------------------- |
| **`callback`** | <code>() =&gt; void</code> |

**Returns:** <code>Promise&lt;{ callbackId: string; }&gt;</code>

--------------------


### onSeek(...)

```typescript
onSeek(callback: (result: { time: number; }) => void) => Promise<{ callbackId: string; }>
```

Register a callback for seek events.

| Param          | Type                                                |
| -------------- | --------------------------------------------------- |
| **`callback`** | <code>(result: { time: number; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;{ callbackId: string; }&gt;</code>

--------------------


### addListener('onPlayNext' | 'onPlayPrevious' | 'onSeek' | 'onPlaybackStatusChange' | 'onAudioEnd', ...)

```typescript
addListener(eventName: 'onPlayNext' | 'onPlayPrevious' | 'onSeek' | 'onPlaybackStatusChange' | 'onAudioEnd', listenerFunc: (data: any) => void) => Promise<PluginListenerHandle>
```

Add listeners for events

| Param              | Type                                                                                                  |
| ------------------ | ----------------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'onPlayNext' \| 'onPlayPrevious' \| 'onSeek' \| 'onPlaybackStatusChange' \| 'onAudioEnd'</code> |
| **`listenerFunc`** | <code>(data: any) =&gt; void</code>                                                                   |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### setAudioSources(...)

```typescript
setAudioSources(options: { audioSources: AudioSource[]; }) => Promise<void>
```

Set all audio sources (useful for setting a new playlist without creating a new AudioPlayer)

| Param         | Type                                          |
| ------------- | --------------------------------------------- |
| **`options`** | <code>{ audioSources: AudioSource[]; }</code> |

--------------------


### Interfaces


#### AudioSource

| Prop                | Type                | Description                                   |
| ------------------- | ------------------- | --------------------------------------------- |
| **`audioId`**       | <code>string</code> | Unique identifier for the audio source.       |
| **`source`**        | <code>string</code> | A URI for the audio file to play.             |
| **`title`**         | <code>string</code> | Title of the audio track.                     |
| **`artist`**        | <code>string</code> | Artist of the audio track.                    |
| **`albumTitle`**    | <code>string</code> | Album title of the audio track.               |
| **`artworkSource`** | <code>string</code> | URI for the artwork image of the audio track. |


#### CurrentAudio

| Prop                | Type                 | Description                                           |
| ------------------- | -------------------- | ----------------------------------------------------- |
| **`audioId`**       | <code>string</code>  | Unique identifier for the current audio source.       |
| **`title`**         | <code>string</code>  | Title of the current audio track.                     |
| **`artist`**        | <code>string</code>  | Artist of the current audio track.                    |
| **`albumTitle`**    | <code>string</code>  | Album title of the current audio track.               |
| **`artworkSource`** | <code>string</code>  | URI for the artwork image of the current audio track. |
| **`duration`**      | <code>number</code>  | Duration of the current audio track in seconds.       |
| **`currentTime`**   | <code>number</code>  | Current playback time of the audio track in seconds.  |
| **`isPlaying`**     | <code>boolean</code> | Whether the current audio is playing.                 |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
