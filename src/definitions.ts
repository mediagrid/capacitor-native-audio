export interface AudioPlayerDefaultParams {
    /**
     * Any string to differentiate different audio files.
     *
     * @since 1.0.0
     */
    audioId: string;
}

export interface AudioPlayerPrepareParams extends AudioPlayerDefaultParams {
    /**
     * A URI for the audio file to play
     *
     * @example A public web source: https://example.com/example.mp3
     * @since 1.0.0
     */
    audioSource: string;

    /**
     * The album title/name of the audio file to be used on the notification
     *
     * @since 2.1.0
     */
    albumTitle?: string;

    /**
     * The artist name of the audio file to be used on the notification
     *
     * @since 2.1.0
     */
    artistName?: string;

    /**
     * The title/name of the audio file to be used on the notification
     *
     * @since 1.0.0
     */
    friendlyTitle: string;

    /**
     * Whether to use this audio file for the notification.
     * This is considered the primary audio to play.
     *
     * It must be created first and you may only have one at a time.
     *
     * @default false
     * @since 1.0.0
     */
    useForNotification: boolean;

    /**
     * A URI for the album art image to display on the Android/iOS notification.
     *
     * Can also be an in-app source. Pulls from `android/app/src/assets/public` and `ios/App/App/public`.
     * If using [Vite](https://vitejs.dev/guide/assets.html#the-public-directory),
     * you would put the image in your `public` folder and the build process will copy to `dist`
     * which in turn will be copied to the Android/iOS assets by Capacitor.
     *
     * A PNG is the best option with square dimensions. 1200 x 1200px is a good option.
     *
     * @example A public web source: https://example.com/artwork.png
     * @example An in-app source: images/artwork.png
     * @since 1.0.0
     */
    artworkSource?: string;

    /**
     * Is this audio for background music/audio.
     *
     * Should not be `true` when `useForNotification = true`.
     *
     * @default false
     * @since 1.0.0
     */
    isBackgroundMusic?: boolean;

    /**
     * Whether or not to loop other audio like background music
     * while the primary audio (`useForNotification = true`) is playing.
     *
     * @default false
     * @since 1.0.0
     */
    loop?: boolean;

    /**
     * Whether or not to show the seek backward button on the OS's notification.
     * Only has affect when `useForNotification = true`.
     *
     * @default true
     * @since 1.2.0
     */
    showSeekBackward?: boolean;

    /**
     * Whether or not to show the seek forward button on the OS's notification.
     * Only has affect when `useForNotification = true`.
     *
     * @default true
     * @since 1.2.0
     */
    showSeekForward?: boolean;

    /**
     * The URL to fetch metadata updates at the specified interval. Typically used for a radio stream.
     * See the section on [Metadata Updates](#metadata-updates) for more info.
     * Only has affect when `useForNotification = true`.
     *
     * @since 2.2.0
     */
    metadataUpdateUrl?: string;

    /**
     * The interval to fetch metadata updates in seconds.
     *
     * @default 15
     * @since 2.2.0
     */
    metadataUpdateInterval?: number;
}

export interface AudioPlayerListenerParams {
    /**
     * The `audioId` set when `create` was called.
     *
     * @since 1.0.0
     */
    audioId: string;
}

export interface AudioPlayerListenerResult {
    callbackId: string;
}

export interface AudioPlayerMetadataUpdateListenerEvent {
    /**
     * The album title
     *
     * @since 2.2.0
     */
    album_title: string;

    /**
     * The artist name
     *
     * @since 2.2.0
     */
    artist_name: string;

    /**
     * The song title
     *
     * @since 2.2.0
     */
    song_title: string;

    /**
     * A URI for the album art image to display on the Android/iOS notification.
     *
     * @since 2.2.0
     */
    artwork_source: string;
}

export interface AudioPlayerPlugin {
    /**
     * Create an audio source to be played.
     *
     * @since 1.0.0
     */
    create(params: AudioPlayerPrepareParams): Promise<{ success: boolean }>;

    /**
     * Initialize the audio source. Prepares the audio to be played, buffers and such.
     *
     * Should be called after callbacks are registered (e.g. `onAudioReady`).
     *
     * @since 1.0.0
     */
    initialize(params: AudioPlayerDefaultParams): Promise<{ success: boolean }>;

    /**
     * Change the audio source on an existing audio source (`audioId`).
     *
     * This is useful for changing background music while the primary audio is playing
     * or changing the primary audio before it is playing to accommodate different durations
     * that a user can choose from.
     *
     * @since 1.0.0
     */
    changeAudioSource(params: AudioPlayerDefaultParams & { source: string }): Promise<void>;

    /**
     * Change the associated metadata of an existing audio source
     *
     * @since 1.1.0
     */
    changeMetadata(
        params: AudioPlayerDefaultParams & {
            albumTitle?: string;
            artistName?: string;
            friendlyTitle?: string;
            artworkSource?: string;
        },
    ): Promise<void>;

    /**
     * Update metadata from Update URL
     *
     * This runs async on the native side. Use the `onMetadataUpdate` listener to get the updated metadata.
     *
     * @since 2.2.0
     */
    updateMetadata(params: AudioPlayerDefaultParams): Promise<void>;

    /**
     * Get the duration of the audio source.
     *
     * Should be called once the audio is ready (`onAudioReady`).
     *
     * @since 1.0.0
     */
    getDuration(params: AudioPlayerDefaultParams): Promise<{ duration: number }>;

    /**
     * Get the current time of the audio source being played.
     *
     * @since 1.0.0
     */
    getCurrentTime(params: AudioPlayerDefaultParams): Promise<{ currentTime: number }>;

    /**
     * Play the audio source.
     *
     * @since 1.0.0
     */
    play(params: AudioPlayerDefaultParams): Promise<void>;

    /**
     * Pause the audio source.
     *
     * @since 1.0.0
     */
    pause(params: AudioPlayerDefaultParams): Promise<void>;

    /**
     * Seek the audio source to a specific time.
     *
     * @since 1.0.0
     */
    seek(params: AudioPlayerDefaultParams & { timeInSeconds: number }): Promise<void>;

    /**
     * Stop playing the audio source and reset the current time to zero.
     *
     * @since 1.0.0
     */
    stop(params: AudioPlayerDefaultParams): Promise<void>;

    /**
     * Set the volume of the audio source. Should be a decimal less than or equal to `1.00`.
     *
     * This is useful for background music.
     *
     * @since 1.0.0
     */
    setVolume(params: AudioPlayerDefaultParams & { volume: number }): Promise<void>;

    /**
     * Set the rate for the audio source to be played at.
     * Should be a decimal. An example being `1` is normal speed, `0.5` being half the speed and `1.5` being 1.5 times faster.
     *
     * @since 1.0.0
     */
    setRate(params: AudioPlayerDefaultParams & { rate: number }): Promise<void>;

    /**
     * Wether or not the audio source is currently playing.
     *
     * @since 1.0.0
     */
    isPlaying(params: AudioPlayerDefaultParams): Promise<{ isPlaying: boolean }>;

    /**
     * Destroy all resources for the audio source.
     * The audio source with `useForNotification = true` must be destroyed last.
     *
     * @since 1.0.0
     */
    destroy(params: AudioPlayerDefaultParams): Promise<void>;

    /**
     * Register a callback for when the app comes to the foreground.
     *
     * @since 1.0.0
     */
    onAppGainsFocus(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult>;

    /**
     * Registers a callback from when the app goes to the background.
     *
     * @since 1.0.0
     */
    onAppLosesFocus(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult>;

    /**
     * Registers a callback for when the audio source is ready to be played.
     *
     * @since 1.0.0
     */
    onAudioReady(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult>;

    /**
     * Registers a callback for when the audio source has ended (reached the end of the audio).
     *
     * @since 1.0.0
     */
    onAudioEnd(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult>;

    /**
     * Registers a callback for when state of playback for the audio source has changed by external controls.
     * This should be used to update your UI when the notification/external controls are used to control the playback.
     *
     * On Android, this also gets fired when your app changes the state (e.g. by calling `play`, `pause` or `stop`)
     * due to a limitation of not knowing where the state change came from, either the app or the `MediaSession` (external controls).
     *
     * It may be fixed in the future for Android if a solution is found so don't rely on it when your app itself changes the state.
     *
     * @since 1.0.0
     */
    onPlaybackStatusChange(
        params: AudioPlayerListenerParams,
        callback: (result: { status: 'playing' | 'paused' | 'stopped' }) => void,
    ): Promise<AudioPlayerListenerResult>;

    /**
     * Registers a callback for when metadata updates from a URL.
     *
     * It will return all data from the URL response, not just the required data. So you could have the metadata endpoint return other data that you may need.
     *
     * @since 2.2.0
     */
    onMetadataUpdate(
        params: AudioPlayerListenerParams,
        callback: (result: AudioPlayerMetadataUpdateListenerEvent) => void,
    ): Promise<AudioPlayerListenerResult>;
}
