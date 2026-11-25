# api-core

Service RTK Query de base (`ApplicationApiService`), compteur d'activité réseau et étiquettes de cache.

- URL de l'API : variable `VITE_BACKEND_API_BASE_URL` (lue au premier appel, pas à l'import).
- Les endpoints seront **générés** depuis `docs/api/openapi.json` (tâche W3, ADR 0006) ; ne jamais les écrire à la main.
- Tests : `npx nx test api-core`.
