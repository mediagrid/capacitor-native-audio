import { AudioPlayer } from '@mediagrid/capacitor-native-audio';

window.testEcho = () => {
  const inputValue = document.getElementById('echoInput').value;
  AudioPlayer.echo({ value: inputValue });
};
