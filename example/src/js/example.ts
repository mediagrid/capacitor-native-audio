import { CapacitorException } from '@capacitor/core';
import { AudioPlayer } from '@mediagrid/capacitor-native-audio';
import mainAudio from '../assets/karen_the_news_update.mp3';
import backgroundAudio from '../assets/komiku_bicycle.mp3';

const mainAudioHref = new URL(mainAudio, import.meta.url).href;
const bgAudioHref = new URL(backgroundAudio, import.meta.url).href;

const audioId = generateAudioId();
const bgAudioId = generateAudioId();

console.log(`audioId: ${audioId}, bgAudioId: ${bgAudioId}`);

let isInitialized = false;

async function initialize(): Promise<void> {
  isInitialized = true;

  await AudioPlayer.create({
    audioId: audioId,
    audioSource: mainAudioHref,
    friendlyTitle: 'My Test Audio',
    useForNotification: true,
    isBackgroundMusic: false,
    loop: false,
  }).catch(ex => setError(ex));

  await AudioPlayer.create({
    audioId: bgAudioId,
    audioSource: bgAudioHref,
    friendlyTitle: '',
    useForNotification: false,
    isBackgroundMusic: true,
    loop: true,
  }).catch(ex => setError(ex));

  AudioPlayer.onAudioReady({ audioId: audioId }, async () => {
    setText(
      'duration',
      Math.ceil(
        (await AudioPlayer.getDuration({ audioId: audioId })).duration,
      ).toString(),
    );
  });

  AudioPlayer.onPlaybackStatusChange({ audioId: audioId }, result => {
    setText('status', result.status);

    switch (result.status) {
      case 'playing':
        AudioPlayer.setVolume({ audioId: bgAudioId, volume: 0.5 });
        AudioPlayer.play({ audioId: bgAudioId });
        break;
      case 'paused':
        AudioPlayer.pause({ audioId: bgAudioId });
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

  await AudioPlayer.initialize({ audioId: audioId }).catch(ex => setError(ex));
  await AudioPlayer.initialize({ audioId: bgAudioId }).catch(ex =>
    setError(ex),
  );
}

addClickEvent('playButton', async () => {
  if (!isInitialized) {
    await initialize();
  }

  await AudioPlayer.play({ audioId });
  startCurrentPositionUpdate();
});

addClickEvent('pauseButton', () => {
  stopCurrentPositionUpdate();
  AudioPlayer.pause({ audioId });
});

addClickEvent('stopButton', () => {
  stopCurrentPositionUpdate(true);
  AudioPlayer.stop({ audioId });
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
