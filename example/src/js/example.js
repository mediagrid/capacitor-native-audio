import { AudioPlayer } from '@mediagrid/capacitor-native-audio';
import mainAudio from '../assets/karen_the_news_update.mp3';
import backgroundAudio from '../assets/komiku_bicycle.mp3';

const mainAudioHref = new URL(mainAudio, import.meta.url).href;
const bgAudioHref = new URL(backgroundAudio, import.meta.url).href;

window.testEcho = () => {
  console.log(mainAudioHref);
  console.log(bgAudioHref);
};
