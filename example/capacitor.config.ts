import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.plugin',
  appName: 'example',
  webDir: 'dist',
  server: {
    url: 'http://localhost:3000',
    cleartext: true,
  },
};

export default config;
