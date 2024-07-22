import { WebPlugin } from '@capacitor/core';

import type {
  AudioPlayerDefaultParams,
  AudioPlayerListenerParams,
  AudioPlayerListenerResult,
  AudioPlayerPlugin,
  AudioPlayerPrepareParams,
} from './definitions';

export class AudioPlayerWeb extends WebPlugin implements AudioPlayerPlugin {
  create(params: AudioPlayerPrepareParams): Promise<{ success: boolean }> {
    throw new Error('Method not implemented.');
  }
  initialize(params: AudioPlayerDefaultParams): Promise<{ success: boolean }> {
    throw new Error('Method not implemented.');
  }
  changeAudioSource(
    params: AudioPlayerDefaultParams & { source: string },
  ): Promise<void> {
    throw new Error('Method not implemented.');
  }
  getDuration(params: AudioPlayerDefaultParams): Promise<{ duration: number }> {
    throw new Error('Method not implemented.');
  }
  getCurrentTime(
    params: AudioPlayerDefaultParams,
  ): Promise<{ currentTime: number }> {
    throw new Error('Method not implemented.');
  }
  play(params: AudioPlayerDefaultParams): Promise<void> {
    throw new Error('Method not implemented.');
  }
  pause(params: AudioPlayerDefaultParams): Promise<void> {
    throw new Error('Method not implemented.');
  }
  seek(
    params: AudioPlayerDefaultParams & { timeInSeconds: number },
  ): Promise<void> {
    throw new Error('Method not implemented.');
  }
  stop(params: AudioPlayerDefaultParams): Promise<void> {
    throw new Error('Method not implemented.');
  }
  setVolume(
    params: AudioPlayerDefaultParams & { volume: number },
  ): Promise<void> {
    throw new Error('Method not implemented.');
  }
  setRate(params: AudioPlayerDefaultParams & { rate: number }): Promise<void> {
    throw new Error('Method not implemented.');
  }
  isPlaying(params: AudioPlayerDefaultParams): Promise<{ isPlaying: boolean }> {
    throw new Error('Method not implemented.');
  }
  destroy(params: AudioPlayerDefaultParams): Promise<void> {
    throw new Error('Method not implemented.');
  }
  onAppGainsFocus(
    params: AudioPlayerListenerParams,
    callback: () => void,
  ): Promise<AudioPlayerListenerResult> {
    throw new Error('Method not implemented.');
  }
  onAppLosesFocus(
    params: AudioPlayerListenerParams,
    callback: () => void,
  ): Promise<AudioPlayerListenerResult> {
    throw new Error('Method not implemented.');
  }
  onAudioReady(
    params: AudioPlayerListenerParams,
    callback: () => void,
  ): Promise<AudioPlayerListenerResult> {
    throw new Error('Method not implemented.');
  }
  onAudioEnd(
    params: AudioPlayerListenerParams,
    callback: () => void,
  ): Promise<AudioPlayerListenerResult> {
    throw new Error('Method not implemented.');
  }
  onPlaybackStatusChange(
    params: AudioPlayerListenerParams,
    callback: (result: { status: 'playing' | 'paused' | 'stopped' }) => void,
  ): Promise<AudioPlayerListenerResult> {
    throw new Error('Method not implemented.');
  }
}
