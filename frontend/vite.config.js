import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],

  resolve: {
    alias: {
      // Alias '@' to the 'src' directory for cleaner imports
      '@': path.resolve(__dirname, './src'),
    },
  },

  server: {
    host: '0.0.0.0',
    port: 8080,
    open: true,
    proxy: {
      // Proxy API requests to Flask backend (on port 5005)
      '/api': {
        target: 'http://localhost:5005',
        changeOrigin: true,
      },
      '/retrieve': {
        target: 'http://localhost:5005',
        changeOrigin: true,
      },
    },
    // historyApiFallback is enabled by default for SPAs
  },

  // Use relative base URL for flexibility in deployment
  base: './',

  build: {
    // Output directory for production build
    outDir: 'dist',
  },
});