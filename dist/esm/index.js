import { registerPlugin } from '@capacitor/core';
const AudioPlayer = registerPlugin('AudioPlayer', {
    web: () => import('./web').then(m => new m.AudioPlayerWeb()),
});
export * from './definitions';
export { AudioPlayer };
//# sourceMappingURL=index.js.map