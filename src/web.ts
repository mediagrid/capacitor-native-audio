import { WebPlugin } from '@capacitor/core';

import type {
    AudioPlayerDefaultParams,
    AudioPlayerListenerParams,
    AudioPlayerListenerResult,
    AudioPlayerMetadataUpdateListenerEvent,
    AudioPlayerPlugin,
    AudioPlayerPrepareParams,
} from './definitions';

export class AudioPlayerWeb extends WebPlugin implements AudioPlayerPlugin {
    create(params: AudioPlayerPrepareParams): Promise<{ success: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    initialize(params: AudioPlayerDefaultParams): Promise<{ success: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    changeAudioSource(params: AudioPlayerDefaultParams & { source: string }): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    changeMetadata(
        params: AudioPlayerDefaultParams & {
            friendlyTitle?: string;
            artworkSource?: string;
        },
    ): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    updateMetadata(params: AudioPlayerDefaultParams): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    getDuration(params: AudioPlayerDefaultParams): Promise<{ duration: number }> {
        throw this.unimplemented('Not implemented on web.');
    }

    getCurrentTime(params: AudioPlayerDefaultParams): Promise<{ currentTime: number }> {
        throw this.unimplemented('Not implemented on web.');
    }

    play(params: AudioPlayerDefaultParams): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    pause(params: AudioPlayerDefaultParams): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    seek(params: AudioPlayerDefaultParams & { timeInSeconds: number }): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    stop(params: AudioPlayerDefaultParams): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    setVolume(params: AudioPlayerDefaultParams & { volume: number }): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    setRate(params: AudioPlayerDefaultParams & { rate: number }): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    isPlaying(params: AudioPlayerDefaultParams): Promise<{ isPlaying: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    destroy(params: AudioPlayerDefaultParams): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    onAppGainsFocus(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    onAppLosesFocus(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    onAudioReady(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    onAudioEnd(
        params: AudioPlayerListenerParams,
        callback: () => void,
    ): Promise<AudioPlayerListenerResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    onPlaybackStatusChange(
        params: AudioPlayerListenerParams,
        callback: (result: { status: 'playing' | 'paused' | 'stopped' }) => void,
    ): Promise<AudioPlayerListenerResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    onMetadataUpdate(
        params: AudioPlayerListenerParams,
        callback: (result: AudioPlayerMetadataUpdateListenerEvent) => void,
    ): Promise<AudioPlayerListenerResult> {
        throw this.unimplemented('Not implemented on web.');
    }
}
