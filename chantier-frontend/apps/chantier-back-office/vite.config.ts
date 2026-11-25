/// <reference types='vitest' />
import { nxViteTsPaths } from '@nx/vite/plugins/nx-tsconfig-paths.plugin';
import react from '@vitejs/plugin-react';
import { defineConfig, loadEnv } from 'vite';

// URL de l'API en développement local (port 8195, README racine) quand aucune variable n'est définie.
const DEV_API_BASE_URL = 'http://localhost:8195';
const ENV_DIR = '../../';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, ENV_DIR, 'VITE_');
  const apiBaseUrl = env['VITE_BACKEND_API_BASE_URL'] ?? (mode === 'development' ? DEV_API_BASE_URL : undefined);

  return {
    root: __dirname,
    // Variables VITE_* lues à la racine de chantier-frontend (.env.local, voir .env.example).
    envDir: ENV_DIR,
    define: apiBaseUrl ? { 'import.meta.env.VITE_BACKEND_API_BASE_URL': JSON.stringify(apiBaseUrl) } : {},
    cacheDir: '../../node_modules/.vite/apps/chantier-back-office',
    server: {
      // Port fixe : le CORS du serveur n'autorise que cette origine (ADR 0007, Cors:Origins).
      port: 3600,
      strictPort: true,
      host: 'localhost',
    },
    preview: {
      port: 3600,
      strictPort: true,
      host: 'localhost',
    },
    // Les alias @chantier-frontend/* viennent de tsconfig.base.json : toujours les sources des bibliothèques,
    // jamais une copie obsolète sous node_modules (piège constaté sous Windows dans Kardinal).
    plugins: [react(), nxViteTsPaths()],
    build: {
      outDir: './build',
      emptyOutDir: true,
      reportCompressedSize: true,
      rollupOptions: {
        output: {
          // Dépendances rarement modifiées dans des fichiers à part (cache navigateur) ; le code applicatif reste léger.
          manualChunks: (id: string) => {
            if (!id.includes('node_modules')) return undefined;
            if (/node_modules\/(@mantine|@floating-ui|@tabler|dayjs|react-textarea-autosize|react-remove-scroll)/.test(id)) return 'vendor-ui';
            if (/node_modules\/(react|react-dom|react-router|react-router-dom|scheduler|@remix-run)\//.test(id)) return 'vendor-react';
            return 'vendor';
          },
        },
      },
      commonjsOptions: {
        transformMixedEsModules: true,
      },
    },
    test: {
      name: 'chantier-back-office',
      watch: false,
      globals: true,
      environment: 'jsdom',
      include: ['{src,tests}/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
      setupFiles: ['../../tools/vitest/setup-dom.ts'],
      env: { VITE_BACKEND_API_BASE_URL: 'http://api.test' },
      reporters: ['default'],
      coverage: {
        reportsDirectory: './test-output/vitest/coverage',
        provider: 'v8' as const,
      },
    },
  };
});
