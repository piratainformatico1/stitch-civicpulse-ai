import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: '0.0.0.0', // Listen on all network addresses (accessible by any PC on LAN/Wi-Fi)
    port: 5173,
    strictPort: false,
    cors: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  },
  preview: {
    host: '0.0.0.0',
    port: 4173,
    cors: true
  }
});
