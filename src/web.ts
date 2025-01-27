import { WebPlugin, registerPlugin, PluginListenerHandle } from '@capacitor/core';
import type { AudioPlayerPlugin, AudioSource } from './definitions';

export class AudioPlayerWeb extends WebPlugin implements AudioPlayerPlugin {

  create(): Promise<{ success: boolean }> {
    throw this.unimplemented('create is not implemented on web.');
  }

  createMultiple(): Promise<{ success: boolean }> {
    throw this.unimplemented('createMultiple is not implemented on web.');
  }

  changeAudioSource(): Promise<void> {
    throw this.unimplemented('changeAudioSource is not implemented on web.');
  }

  changeMetadata(): Promise<void> {
    throw this.unimplemented('changeMetadata is not implemented on web.');
  }

  getDuration(): Promise<{ duration: number }> {
    throw this.unimplemented('getDuration is not implemented on web.');
  }

  getCurrentTime(): Promise<{ currentTime: number }> {
    throw this.unimplemented('getCurrentTime is not implemented on web.');
  }

  play(): Promise<void> {
    throw this.unimplemented('play is not implemented on web.');
  }

  pause(): Promise<void> {
    throw this.unimplemented('pause is not implemented on web.');
  }

  seek(): Promise<void> {
    throw this.unimplemented('seek is not implemented on web.');
  }

  stop(): Promise<void> {
    throw this.unimplemented('stop is not implemented on web.');
  }

  setVolume(): Promise<void> {
    throw this.unimplemented('setVolume is not implemented on web.');
  }

  setRate(): Promise<void> {
    throw this.unimplemented('setRate is not implemented on web.');
  }

  isPlaying(): Promise<{ isPlaying: boolean }> {
    throw this.unimplemented('isPlaying is not implemented on web.');
  }

  destroy(): Promise<void> {
    throw this.unimplemented('destroy is not implemented on web.');
  }

  onAppGainsFocus(): Promise<void> {
    throw this.unimplemented('onAppGainsFocus is not implemented on web.');
  }

  onAppLosesFocus(): Promise<void> {
    throw this.unimplemented('onAppLosesFocus is not implemented on web.');
  }

  onAudioReady(
    params: { audioId: string },
    callback: () => void,
  ): Promise<{ callbackId: string }> {
    console.warn('onAudioReady is not implemented on web.');
    return Promise.resolve({ callbackId: 'web-fallback-callback-id' });
  }

  onAudioEnd(
    params: { audioId: string },
    callback: () => void,
  ): Promise<{ callbackId: string }> {
    console.warn('onAudioEnd is not implemented on web.');
    return Promise.resolve({ callbackId: 'web-fallback-callback-id' });
  }

  playNext(): Promise<void> {
    throw this.unimplemented('playNext is not implemented on web.');
  }

  playPrevious(): Promise<void> {
    throw this.unimplemented('playPrevious is not implemented on web.');
  }

  onPlayNext(callback: () => void): Promise<{ callbackId: string }> {
    console.warn("onPlayNext is not implemented on the web.");
    return Promise.resolve({ callbackId: 'web-fallback-callback-id' });
  }

  onPlayPrevious(callback: () => void): Promise<{ callbackId: string }> {
    console.warn("onPlayPrevious is not implemented on the web.");
    return Promise.resolve({ callbackId: 'web-fallback-callback-id' });
  }

  onSeek(callback: (result: { time: number }) => void): Promise<{ callbackId: string }> {
    console.warn("onSeek is not implemented on the web.");
    callback({ time: 0 }); // Example fallback behavior
    return Promise.resolve({ callbackId: 'web-fallback-callback-id' });
  }

  onPlaybackStatusChange(
    callback: (result: { status: "stopped" | "paused" | "playing" }) => void
  ): Promise<{ callbackId: string }> {
    console.warn("onPlaybackStatusChange is not implemented on the web.");
    return Promise.resolve({ callbackId: 'web-fallback-callback-id' });
  }

  getCurrentAudio(): Promise<{
    audioId: string;
    title: string;
    artist: string;
    albumTitle: string;
    artworkSource: string;
    duration: number;
    currentTime: number;
    isPlaying: boolean;
  }> {
    console.warn('getCurrentAudio is not implemented on web.');

    return Promise.resolve({
      audioId: 'web-fallback-audioId',
      title: 'Fallback Title',
      artist: 'Fallback Artist',
      albumTitle: 'Fallback Album',
      artworkSource: '',
      duration: 0,
      currentTime: 0,
      isPlaying: false,
    });
  }
  setAudioSources(_options: { audioSources: AudioSource[] }): Promise<void> {
    console.warn("setAudioSources is not implemented on web.");
    return Promise.resolve();
  }

  showAirPlayMenu(): Promise<void> {
    console.warn("showAirPlayMenu is not supported on the web platform.");
    return Promise.resolve();
  }
}
