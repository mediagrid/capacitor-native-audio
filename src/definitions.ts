import type { PluginListenerHandle } from '@capacitor/core';

export interface AudioSource {
  /**
   * Unique identifier for the audio source.
   */
  audioId: string;

  /**
   * A URI for the audio file to play.
   */
  source: string;

  /**
   * Title of the audio track.
   */
  title: string;

  /**
   * Artist of the audio track.
   */
  artist: string;

  /**
   * Album title of the audio track.
   */
  albumTitle: string;

  /**
   * URI for the artwork image of the audio track.
   */
  artworkSource: string;
}

export interface CurrentAudio {
  /**
   * Unique identifier for the current audio source.
   */
  audioId: string;

  /**
   * Title of the current audio track.
   */
  title: string;

  /**
   * Artist of the current audio track.
   */
  artist: string;

  /**
   * Album title of the current audio track.
   */
  albumTitle: string;

  /**
   * URI for the artwork image of the current audio track.
   */
  artworkSource: string;

  /**
   * Duration of the current audio track in seconds.
   */
  duration: number;

  /**
   * Current playback time of the audio track in seconds.
   */
  currentTime: number;

  /**
   * Whether the current audio is playing.
   */
  isPlaying: boolean;
}

export interface AudioPlayerPlugin {
  /**
   * Create a single audio source for playback.
   */
  create(params: AudioSource): Promise<{ success: boolean }>;

  /**
   * Create multiple audio sources for playlist management.
   */
  createMultiple(params: { audioSources: AudioSource[] }): Promise<{ success: boolean }>;

  /**
   * Change the audio source for an existing player.
   */
  changeAudioSource(params: { audioId: string; source: string }): Promise<void>;

  /**
   * Change the metadata of an existing audio source.
   */
  changeMetadata(
    params: {
      audioId: string;
      title?: string;
      artist?: string;
      albumTitle?: string;
      artworkSource?: string;
    },
  ): Promise<void>;

  /**
   * Play an audio source by its ID.
   */
    play(params?: { audioId?: string | null }): Promise<void>;

  /**
   * Pause playback of an audio source.
   */
  pause(): Promise<void>;

  /**
   * Stop playback and reset the audio source.
   */
  stop(): Promise<void>;

  /**
   * Seek to a specific time in the audio source.
   */
  seek(params: { timeInSeconds: number }): Promise<void>;

  /**
   * Get the current playback time of an audio source.
   */
  getCurrentTime(): Promise<{ currentTime: number }>;

  /**
   * Get the duration of an audio source.
   */
  getDuration(): Promise<{ duration: number }>;

  /**
   * Skip to the next audio source in the playlist.
   */
  playNext(): Promise<void>;

  /**
   * Skip to the previous audio source in the playlist.
   */
  playPrevious(): Promise<void>;

  /**
   * Set the volume for the audio source.
   */
  setVolume(params: { volume: number }): Promise<void>;

  /**
   * Set the playback rate for the audio source.
   */
  setRate(params: { rate: number }): Promise<void>;

  /**
   * Determine if the audio source is currently playing.
   */
  isPlaying(params: { audioId: string }): Promise<{ isPlaying: boolean }>;

  /**
   * Destroy all resources associated with the audio source.
   */
  destroy(params: { audioId: string }): Promise<void>;

  /**
   * Get details about the currently active audio source.
   */
  getCurrentAudio(): Promise<CurrentAudio>;

  /**
   * Register a callback for when the audio source is ready for playback.
   */
  onAudioReady(
    params: { audioId: string },
    callback: () => void,
  ): Promise<{ callbackId: string }>;

  /**
   * Register a callback for when playback of the audio source ends.
   */
  onAudioEnd(
    params: { audioId: string },
    callback: () => void,
  ): Promise<{ callbackId: string }>;

  /**
   * Register a callback for playback status changes.
   */
    onPlaybackStatusChange(
      callback: (result: { status: "stopped" | "paused" | "playing" }) => void
    ): Promise<{ callbackId: string }>;

  /**
   * Register a callback for when the next track is played.
   */
  onPlayNext(
    callback: () => void,
  ): Promise<{ callbackId: string }>;

  /**
   * Register a callback for when the previous track is played.
   */
  onPlayPrevious(
    callback: () => void,
  ): Promise<{ callbackId: string }>;

  /**
   * Register a callback for seek events.
   */
  onSeek(
    callback: (result: { time: number }) => void,
  ): Promise<{ callbackId: string }>;
    
    /**
     * Add listeners for events
     */
    addListener(
        eventName: 'onPlayNext' | 'onPlayPrevious' | 'onSeek' | 'onPlaybackStatusChange' | 'onAudioEnd',
        listenerFunc: (data: any) => void
      ): Promise<PluginListenerHandle>;
    
    /**
     * Set all audio sources (useful for setting a new playlist without creating a new AudioPlayer)
     */
    setAudioSources(options: { audioSources: AudioSource[] }): Promise<void>;
}
