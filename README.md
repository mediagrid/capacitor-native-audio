# @mediagrid/capacitor-native-audio

Play audio in a Capacitor app natively from a URL/web source simultaneously with background audio.

## Install

```bash
npm install @mediagrid/capacitor-native-audio
npx cap sync
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
