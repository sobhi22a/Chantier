import { expect, test, type Page } from '@playwright/test';

/**
 * QA seconde passe (D-2, R3-02, R3-04) contre l'API de développement avec les données de démonstration : le serveur répond 503
 * `ERREUR_TEMPORAIRE` à l'envoi du fichier d'une photo de bon ; le navigateur affiche le message traduit et propose « Réessayer l'envoi »,
 * qui rejoue le `PUT` de la **même** photo (une seule photo côté serveur, une seule place du quota consommée).
 * Variables : `QA_DEMO_PASSWORD` (mot de passe de démonstration), `QA_API_URL` (défaut http://localhost:8195). Données fictives.
 */
const PASSWORD = process.env['QA_DEMO_PASSWORD'] ?? '';
const API = process.env['QA_API_URL'] ?? 'http://localhost:8195';

// eslint-disable-next-line playwright/no-skipped-test -- sans mot de passe de démonstration, le parcours réel ne peut pas se connecter
test.skip(PASSWORD === '', 'QA_DEMO_PASSWORD absent : parcours réel ignoré');

interface PhotoItem {
  id: string;
  contentStatus: string;
}

test('503 sur le fichier d\'une photo : message traduit, « Réessayer l\'envoi » rejoue la même photo (R3-02, R3-04)', async ({ browser, request }) => {
  // Préparation par l'API : une livraison neuve sur la commande DEM-009 de la démonstration.
  const login = await request.post(`${API}/api/v1/auth/login`, { data: { userName: 'chef.dev', password: PASSWORD, isAppMobile: true } });
  expect(login.ok()).toBeTruthy();
  const headers = { Authorization: `Bearer ${((await login.json()) as { accessToken: string }).accessToken}` };
  const sites = (await (await request.get(`${API}/api/v1/sites`, { headers })).json()) as { items: { id: string; code: string }[] };
  const siteId = (sites.items.find((site) => site.code === 'CH-ECO-UV18') as { id: string }).id;
  const list = (await (await request.get(`${API}/api/v1/sites/${siteId}/requests?q=DEM-009&pageSize=5`, { headers })).json()) as { items: { id: string; number: string }[] };
  const requestId = (list.items.find((item) => item.number === 'DEM-009') as { id: string }).id;
  const today = new Date(Date.now() + 3_600_000).toISOString().slice(0, 10);
  const created = await request.post(`${API}/api/v1/sites/${siteId}/deliveries`, {
    headers,
    data: { clientId: crypto.randomUUID(), clientCreatedAt: new Date().toISOString(), requestId, quantity: { value: 1, unit: 't' }, deliveryDate: today, conformity: 'Conform' },
  });
  expect(created.status()).toBe(201);
  const deliveryId = ((await created.json()) as { id: string }).id;
  const photosOnServer = async (): Promise<PhotoItem[]> =>
    ((await (await request.get(`${API}/api/v1/sites/${siteId}/deliveries/${deliveryId}`, { headers })).json()) as { photos: PhotoItem[] }).photos;

  const page: Page = await (await browser.newContext()).newPage();
  await page.goto('/sign-in');
  await page.getByLabel('Identifiant', { exact: true }).fill('chef.dev');
  await page.getByLabel('Mot de passe', { exact: true }).fill(PASSWORD);
  await page.getByRole('button', { name: 'Se connecter' }).click();
  await page.waitForURL((url) => !url.pathname.startsWith('/sign-in'));

  // Le premier envoi du fichier échoue en 503 ERREUR_TEMPORAIRE (le serveur est occupé), les suivants passent.
  let puts = 0;
  await page.route('**/api/v1/sites/*/photos/*/content', async (route) => {
    if (route.request().method() === 'PUT') {
      puts += 1;
      if (puts === 1) {
        await route.fulfill({
          status: 503,
          contentType: 'application/problem+json',
          headers: { 'Retry-After': '1' },
          body: JSON.stringify({ type: 'https://chantier.local/errors/erreur-temporaire', title: 'Erreur temporaire', status: 503, code: 'ERREUR_TEMPORAIRE' }),
        });
        return;
      }
    }
    await route.continue();
  });

  await page.goto(`/materials/deliveries/${siteId}/${deliveryId}`);
  const drawer = page.getByRole('dialog', { name: /^Livraison LIV-/ });
  await expect(drawer).toBeVisible();

  const jpeg = await page.evaluate(async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 1800;
    canvas.height = 1200;
    const context = canvas.getContext('2d');
    if (context) {
      context.fillStyle = '#fff';
      context.fillRect(0, 0, 1800, 1200);
      context.fillStyle = '#222';
      context.font = '90px sans-serif';
      context.fillText('BL fictif R3-04', 100, 500);
    }
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.9));
    return Array.from(new Uint8Array(await (blob as Blob).arrayBuffer()));
  });
  await drawer.locator('input[type="file"]').setInputFiles({ name: 'bl.jpg', mimeType: 'image/jpeg', buffer: Buffer.from(jpeg) });

  // D-2 / R3-02 : le message traduit, pas le texte générique ; R3-04 : le bouton de reprise.
  await expect(drawer.getByText(/Le serveur est momentanément occupé/)).toBeVisible();
  const retry = drawer.getByRole('button', { name: "Réessayer l'envoi" });
  await expect(retry).toBeVisible();
  const pending = await photosOnServer();
  expect(pending).toHaveLength(1);
  expect(pending[0]?.contentStatus).toBe('Pending');

  await retry.click();
  await expect(page.getByText(/Photo ajoutée à la livraison LIV-\d+\./)).toBeVisible();

  // Une seule photo côté serveur (même photo rejouée), maintenant reçue : une seule place du quota de 5 consommée.
  const after = await photosOnServer();
  expect(after).toHaveLength(1);
  expect(after[0]?.id).toBe(pending[0]?.id);
  expect(after[0]?.contentStatus).toBe('Uploaded');
  expect(puts).toBe(2);
});
