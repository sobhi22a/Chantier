import { expect, test, type APIRequestContext, type Page } from '@playwright/test';

/**
 * Parcours réel « connexion puis Mes chantiers » (ADR 0010, plan Q1) contre l'API de développement avec les données
 * de démonstration (`Seed:Demo = true`). Variables d'environnement (jamais écrites dans le dépôt) :
 *   - `QA_DEMO_PASSWORD` : mot de passe de développement des comptes `*.dev` (`Seed:DemoPassword`) ;
 *   - `QA_API_URL` : racine de l'API (défaut `http://localhost:8195`) ;
 *   - `QA_CAPTURES` : dossier où écrire les captures FR/AR (facultatif).
 * Sans `QA_DEMO_PASSWORD`, les tests sont ignorés (ils ne peuvent pas se connecter).
 */
const PASSWORD = process.env['QA_DEMO_PASSWORD'] ?? '';
const API = process.env['QA_API_URL'] ?? 'http://localhost:8195';
const CAPTURES = process.env['QA_CAPTURES'];

// eslint-disable-next-line playwright/no-skipped-test -- sans mot de passe de démonstration, le parcours réel ne peut pas se connecter
test.skip(PASSWORD === '', 'QA_DEMO_PASSWORD absent : parcours réel ignoré');

/** Capture d'écran facultative (contrôle visuel FR/AR) : seulement si QA_CAPTURES est défini. */
const capture = async (page: Page, name: string) => {
  if (CAPTURES) await page.screenshot({ path: `${CAPTURES}/${name}`, fullPage: true });
};

const signIn = async (page: Page, userName: string, language: 'fr' | 'ar' = 'fr') => {
  await page.goto('/sign-in');
  if (language === 'ar') {
    await page.getByText('العربية').click();
  }
  await page.getByLabel(language === 'ar' ? 'اسم المستخدم' : 'Identifiant', { exact: true }).fill(userName);
  await page.getByLabel(language === 'ar' ? 'كلمة المرور' : 'Mot de passe', { exact: true }).fill(PASSWORD);
  await page.getByRole('button', { name: language === 'ar' ? 'تسجيل الدخول' : 'Se connecter' }).click();
};

// Une seule connexion API pour tout le fichier : la politique « auth » limite à 10 connexions / 5 min par couple adresse + identifiant.
let ids: Record<string, string> = {};
test.beforeAll(async ({ request }) => {
  ids = await apiSiteIds(request, 'admin.dev');
});

const apiSiteIds = async (request: APIRequestContext, userName: string): Promise<Record<string, string>> => {
  const login = await request.post(`${API}/api/v1/auth/login`, { data: { userName, password: PASSWORD, isAppMobile: true } });
  expect(login.ok()).toBeTruthy();
  const { accessToken } = (await login.json()) as { accessToken: string };
  const list = await request.get(`${API}/api/v1/sites?pageSize=50`, { headers: { Authorization: `Bearer ${accessToken}` } });
  const { items } = (await list.json()) as { items: { id: string; code: string }[] };
  return Object.fromEntries(items.map((site) => [site.code, site.id]));
};

test('chef.dev : connexion puis Mes chantiers, seulement l’école UV18 (CA-006.1, CA-018.4 a)', async ({ page }) => {
  await signIn(page, 'chef.dev');

  await expect(page.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();
  await expect(page.getByText('CH-ECO-UV18')).toBeVisible();
  await expect(page.getByText('CH-LOG-OL40')).toHaveCount(0);
  await capture(page, 'web-mes-chantiers-fr.png');
});

test('conducteur.dev voit les deux chantiers (CA-018.4 b)', async ({ page }) => {
  await signIn(page, 'conducteur.dev');

  await expect(page.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();
  await expect(page.getByText('CH-ECO-UV18')).toBeVisible();
  await expect(page.getByText('CH-LOG-OL40')).toBeVisible();
});

test('nonaffecte.dev ne voit aucun chantier et peut actualiser (CA-006.3, CA-018.4 c)', async ({ page }) => {
  await signIn(page, 'nonaffecte.dev');

  await expect(page.getByText('Aucun chantier ne vous est affecté. Contactez votre administrateur.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Actualiser' })).toBeVisible();
});

test('chef.dev ouvre CH-LOG-OL40 par lien direct : « introuvable », comme un chantier inexistant (CA-006.2, CA-018.4 d)', async ({ page }) => {
  expect(ids['CH-LOG-OL40']).toBeTruthy();
  await signIn(page, 'chef.dev');
  await expect(page.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();

  await page.goto(`/sites/${ids['CH-LOG-OL40']}`);
  await expect(page.locator('main')).toContainText('introuvable');
  const nonAssigned = await page.locator('main').innerText();
  await page.goto('/sites/00000000-0000-7000-8000-00000000dead');
  await expect(page.locator('main')).toContainText('introuvable');
  const unknown = await page.locator('main').innerText();

  expect(nonAssigned).toContain('introuvable');
  // La référence de support (traceId) est propre à chaque requête : on la retire avant de comparer.
  const withoutTrace = (text: string) => text.replace(/Référence pour le support\s*:\s*\S+/, '');
  expect(withoutTrace(nonAssigned)).toBe(withoutTrace(unknown));
});

test('fiche UV18 : fin contractuelle 24/08/2027, montant visible pour conducteur.dev et absent pour equipe.dev (CA-007.2, CA-018.4 e f)', async ({ browser }) => {

  const conductor = await (await browser.newContext()).newPage();
  await signIn(conductor, 'conducteur.dev');
  await expect(conductor.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();
  await conductor.goto(`/sites/${ids['CH-ECO-UV18']}`);
  await expect(conductor.getByRole('heading', { level: 1, name: 'École UV18' })).toBeVisible();
  await expect(conductor.locator('main')).toContainText('24/08/2027');
  await expect(conductor.locator('main')).toContainText('185');
  await expect(conductor.locator('main')).toContainText('DZD');
  await capture(conductor, 'web-fiche-chantier-fr.png');

  const team = await (await browser.newContext()).newPage();
  await signIn(team, 'equipe.dev');
  await expect(team.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();
  await team.goto(`/sites/${ids['CH-ECO-UV18']}`);
  await expect(team.getByRole('heading', { level: 1, name: 'École UV18' })).toBeVisible();
  await expect(team.locator('main')).toContainText('24/08/2027');
  await expect(team.locator('main')).not.toContainText('DZD');
  await expect(team.locator('main')).not.toContainText('185 000 000');
});

test('arabe : liste et fiche en RTL, codes et dates de gauche à droite, captures (CA-014)', async ({ page }) => {
  // Compte dédié (direction.dev) : le choix de langue est mémorisé sur le compte et ne doit pas gêner les autres parcours.
  await signIn(page, 'direction.dev');
  await expect(page.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();
  // Défaut D-4 : la langue choisie AVANT la connexion est remplacée par celle du compte ; on change donc depuis l'en-tête.
  await page.getByText('العربية').click();

  await expect(page.getByRole('heading', { level: 1, name: 'ورشاتي' })).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('dir', 'rtl');
  await expect(page.getByText('CH-ECO-UV18')).toBeVisible();
  await capture(page, 'web-mes-chantiers-ar.png');

  await page.goto(`/sites/${ids['CH-ECO-UV18']}`);
  await expect(page.locator('main')).toContainText('24/08/2027');
  await capture(page, 'web-fiche-chantier-ar.png');

  // Le code du chantier garde sa direction de lecture même dans une page arabe.
  const direction = await page.getByText('CH-ECO-UV18').first().evaluate((element) => getComputedStyle(element).direction);
  const isolated = await page.getByText('CH-ECO-UV18').first().evaluate((element) => {
    const holder = element.closest('[dir]') as HTMLElement | null;
    return holder?.getAttribute('dir') ?? getComputedStyle(element).direction;
  });
  expect([direction, isolated]).toContain('ltr');

  // Remet le compte de démonstration en français.
  await page.getByText('Français').click();
  await expect(page.locator('html')).toHaveAttribute('lang', 'fr');
});

test('admin.dev : « Nouveau chantier » propose la wilaya et le maître d’ouvrage du dernier chantier (CA-008.6)', async ({ page }) => {
  await signIn(page, 'admin.dev');
  await expect(page.getByRole('heading', { level: 1, name: 'Mes chantiers' })).toBeVisible();

  await page.getByRole('button', { name: 'Nouveau chantier' }).click();

  const dialog = page.getByRole('dialog');
  await expect(dialog.getByRole('textbox', { name: /Wilaya/ })).toHaveValue('Blida');
  await expect(dialog.getByRole('textbox', { name: /Maître d/ })).not.toHaveValue('');
});
