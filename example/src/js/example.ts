import { CapacitorException } from '@capacitor/core';
import { AudioPlayer } from '@mediagrid/capacitor-native-audio';
import mainAudio from '../assets/karen_the_news_update.mp3';
import backgroundAudio from '../assets/komiku_bicycle.mp3';

const mainAudioHref = new URL(mainAudio, import.meta.url).href;
const bgAudioHref = new URL(backgroundAudio, import.meta.url).href;

const audioId = generateAudioId();
const bgAudioId = generateAudioId();

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

await AudioPlayer.initialize({ audioId: audioId }).catch(ex => setError(ex));

addClickEvent('playButton', () => {
  AudioPlayer.play({ audioId });
});

function addClickEvent(htmlId: string, callback: () => void): void {
  const el = document.getElementById(htmlId);

  if (el) {
    el.onclick = callback;
  }
}

function generateAudioId(): string {
  return Math.ceil(Math.random() * 10000000).toString();
}

function setError(exception: unknown) {
  const ex = exception as CapacitorException;

  const el = document.getElementById('error');

  if (el) {
    el.innerText = ex.message;
  }
}
