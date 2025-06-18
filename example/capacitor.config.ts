import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
    appId: 'com.example.plugin',
    appName: 'example',
    webDir: 'dist',
    server: {
        url: 'http://localhost:5173',
        cleartext: true,
    },
};

export default config;
