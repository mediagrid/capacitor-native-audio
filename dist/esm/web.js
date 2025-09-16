import { WebPlugin } from '@capacitor/core';
export class AudioPlayerWeb extends WebPlugin {
    create(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    initialize(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    changeAudioSource(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    changeMetadata(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    updateMetadata(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    getDuration(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    getCurrentTime(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    play(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    pause(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    seek(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    stop(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    setVolume(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    setRate(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    isPlaying(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    destroy(params) {
        throw this.unimplemented('Not implemented on web.');
    }
    onAppGainsFocus(params, callback) {
        throw this.unimplemented('Not implemented on web.');
    }
    onAppLosesFocus(params, callback) {
        throw this.unimplemented('Not implemented on web.');
    }
    onAudioReady(params, callback) {
        throw this.unimplemented('Not implemented on web.');
    }
    onAudioEnd(params, callback) {
        throw this.unimplemented('Not implemented on web.');
    }
    onPlaybackStatusChange(params, callback) {
        throw this.unimplemented('Not implemented on web.');
    }
    onMetadataUpdate(params, callback) {
        throw this.unimplemented('Not implemented on web.');
    }
    startBackgroundTracking(params) {
        // On web, background tracking is not needed since JS timers work fine
        // Return resolved promise to avoid breaking the flow
        return Promise.resolve();
    }
    stopBackgroundTracking(params) {
        // On web, background tracking is not needed since JS timers work fine
        // Return resolved promise to avoid breaking the flow
        return Promise.resolve();
    }
    fetchBackgroundPlayedSeconds(params) {
        // On web, background tracking is not needed since JS timers work fine
        // Return empty array to indicate no background data
        return Promise.resolve({ seconds: [] });
    }
}
//# sourceMappingURL=web.js.map