import { AudioPlayer } from '@mediagrid&#x2F;capacitor-native-audio';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    AudioPlayer.echo({ value: inputValue })
}
