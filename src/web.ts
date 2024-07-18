import { WebPlugin } from '@capacitor/core';

import type { AudioPlayerPlugin } from './definitions';

export class AudioPlayerWeb extends WebPlugin implements AudioPlayerPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
