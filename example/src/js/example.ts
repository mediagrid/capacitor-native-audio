import type { CapacitorException } from '@capacitor/core';
import { AudioPlayer } from '@mediagrid/capacitor-native-audio';

const mainAudioHref = new URL('/assets/karen_the_news_update.mp3', import.meta.url).href;
const bgAudioHref = new URL('/assets/komiku_bicycle.mp3', import.meta.url).href;

const audioId = generateAudioId();
const bgAudioId = generateAudioId();

console.log(`audioId: ${audioId}, bgAudioId: ${bgAudioId}`);

let isInitialized = false;

async function initialize(): Promise<void> {
    isInitialized = true;

    await AudioPlayer.create({
        audioId: audioId,
        audioSource: mainAudioHref,
        // albumTitle: 'My Album Title',
        // artistName: 'My Artist',
        friendlyTitle: 'My Test Audio',
        useForNotification: true,
        artworkSource: 'assets/sample_artwork.png',
        // artworkSource: 'https://placehold.co/1200.jpg',
        isBackgroundMusic: false,
        loop: false,
        showSeekForward: true,
        showSeekBackward: true,
        // metadataUpdateUrl: 'https://pfd4e5xj5qvsvsdcghre2222vm0pvhsj.lambda-url.us-east-2.on.aws?includeOtherData=0',
        // metadataUpdateInterval: 30,
    }).catch(ex => setError(ex));

    await AudioPlayer.create({
        audioId: bgAudioId,
        audioSource: bgAudioHref,
        friendlyTitle: '',
        useForNotification: false,
        isBackgroundMusic: true,
        loop: true,
    }).catch(ex => setError(ex));

    await AudioPlayer.onAudioReady({ audioId: audioId }, async () => {
        setText(
            'duration',
            Math.ceil((await AudioPlayer.getDuration({ audioId: audioId })).duration).toString(),
        );
    });

    AudioPlayer.onAudioEnd({ audioId: audioId }, async () => {
        setText('status', 'stopped');

        stopCurrentPositionUpdate(true);

        AudioPlayer.stop({ audioId: bgAudioId });
    });

    AudioPlayer.onPlaybackStatusChange({ audioId: audioId }, result => {
        setText('status', result.status);

        switch (result.status) {
            case 'playing':
                AudioPlayer.play({ audioId: bgAudioId });
                startCurrentPositionUpdate();
                break;
            case 'paused':
                AudioPlayer.pause({ audioId: bgAudioId });
                stopCurrentPositionUpdate();
                break;
            case 'stopped':
                AudioPlayer.stop({ audioId: bgAudioId });
                stopCurrentPositionUpdate(true);
                break;
            default:
                AudioPlayer.stop({ audioId: bgAudioId });
                break;
        }
    });

    AudioPlayer.onMetadataUpdate({ audioId: audioId }, result => {
        console.log(result);
    });

    await AudioPlayer.initialize({ audioId: audioId }).catch(ex => setError(ex));
    await AudioPlayer.initialize({ audioId: bgAudioId }).catch(ex => setError(ex));
}

addClickEvent('playButton', async () => {
    if (!isInitialized) {
        await initialize();
    }

    setText('status', 'playing');

    await AudioPlayer.play({ audioId });
    AudioPlayer.play({ audioId: bgAudioId });
    startCurrentPositionUpdate();

    AudioPlayer.setVolume({ audioId: bgAudioId, volume: 0.5 });
    AudioPlayer.play({ audioId: bgAudioId });
});

addClickEvent('pauseButton', () => {
    setText('status', 'paused');

    stopCurrentPositionUpdate();
    AudioPlayer.pause({ audioId });

    AudioPlayer.pause({ audioId: bgAudioId });
});

addClickEvent('stopButton', () => {
    setText('status', 'stopped');

    stopCurrentPositionUpdate(true);
    AudioPlayer.stop({ audioId });

    AudioPlayer.stop({ audioId: bgAudioId });
});

addClickEvent('changeMetadataButton', () => {
    AudioPlayer.changeMetadata({
        audioId: audioId,
        // albumTitle: 'A New Album',
        // artistName: 'A New Artist',
        friendlyTitle: 'A New Title',
        artworkSource: 'assets/sample_artwork_new.png',
        // artworkSource: 'https://placehold.co/1200.jpg',
    });
});

addClickEvent('updateMetadataButton', () => {
    AudioPlayer.updateMetadata({
        audioId: audioId,
    });
});

addClickEvent('cleanupButton', async () => {
    setText('status', 'stopped');

    stopCurrentPositionUpdate(true);

    await AudioPlayer.destroy({ audioId: bgAudioId });
    AudioPlayer.destroy({ audioId: audioId });

    isInitialized = false;
});

let currentPositionIntervalId = 0;

function startCurrentPositionUpdate(): void {
    stopCurrentPositionUpdate();

    currentPositionIntervalId = window.setInterval(async () => {
        setText(
            'currentTime',
            Math.round(
                (await AudioPlayer.getCurrentTime({ audioId: audioId })).currentTime,
            ).toString(),
        );
    }, 1000);
}

function stopCurrentPositionUpdate(resetText = false): void {
    clearInterval(currentPositionIntervalId);
    currentPositionIntervalId = 0;

    if (resetText) {
        setText('currentTime', '0');
    }
}

function addClickEvent(elementId: string, callback: () => void): void {
    const el = document.getElementById(elementId);

    if (el) {
        el.onclick = callback;
    }
}

function generateAudioId(): string {
    return Math.ceil(Math.random() * 10000000).toString();
}

function setError(exception: unknown) {
    const ex = exception as CapacitorException;

    setText('error', ex.message);
}

function setText(elementId: string, text: string): void {
    const el = document.getElementById(elementId);

    if (el) {
        el.innerText = text;
    }
}
