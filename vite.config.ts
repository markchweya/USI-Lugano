import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  // GitHub Pages serves the site from /<repo>/; set BASE_PATH there, '/' everywhere else.
  base: process.env.BASE_PATH ?? '/',
  plugins: [vue()],
  build: {
    rollupOptions: {
      output: {
        // A stable, clearly named chunk for third-party code (Vue, Vue Router).
        manualChunks: (id) => (id.includes('node_modules') && !id.includes('@fontsource') ? 'vendor' : undefined),
      },
    },
  },
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
  test: {
    environment: 'jsdom',
  },
})
