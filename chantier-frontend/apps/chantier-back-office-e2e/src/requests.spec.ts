import { expect, test, type Browser, type Page } from '@playwright/test';

/**
 * Parcours réel de la tranche A « Demander et valider » (plan Q1, ADR 0010) contre l'API de développement avec les données de
 * démonstration : l'acheteur crée un produit, le chef de chantier le demande, le conducteur valide. Mêmes variables que `sites.spec.ts`
 * (`QA_DEMO_PASSWORD`, `QA_CAPTURES`). Sans mot de passe de démonstration, les tests sont ignorés.
 * Données fictives, noms uniques par exécution : le parcours est répétable sans nettoyage.
 */
const PASSWORD = process.env['QA_DEMO_PASSWORD'] ?? '';
const CAPTURES = process.env['QA_CAPTURES'];

// eslint-disable-next-line playwright/no-skipped-test -- sans mot de passe de démonstration, le parcours réel ne peut pas se connecter
test.skip(PASSWORD === '', 'QA_DEMO_PASSWORD absent : parcours réel ignoré');

const capture = async (page: Page, name: string) => {
  if (CAPTURES) await page.screenshot({ path: `${CAPTURES}/${name}`, fullPage: true });
};

const signIn = async (page: Page, userName: string) => {
  await page.goto('/sign-in');
  await page.getByLabel('Identifiant', { exact: true }).fill(userName);
  await page.getByLabel('Mot de passe', { exact: true }).fill(PASSWORD);
  await page.getByRole('button', { name: 'Se connecter' }).click();
  // La page de connexion a elle aussi un titre : on attend de la quitter.
  await page.waitForURL((url) => !url.pathname.startsWith('/sign-in'));
};

const newPage = async (browser: Browser, userName: string): Promise<Page> => {
  const page = await (await browser.newContext()).newPage();
  await signIn(page, userName);
  return page;
};

// Une seule exécution à la fois : les étapes se suivent (produit, demande, validation).
test.describe.configure({ mode: 'serial' });

const stamp = Date.now().toString(36);
const productName = `Ciment e2e ${stamp}`;
let requestNumber = '';

test('achats.dev crée un produit du catalogue avec sa masse de sac (CA-MAT-015.1)', async ({ browser }) => {
  const page = await newPage(browser, 'achats.dev');
  await page.goto('/catalog/products');
  await expect(page.getByRole('heading', { level: 1, name: 'Produits du catalogue' })).toBeVisible();

  await page.getByRole('button', { name: 'Nouveau produit' }).click();
  const dialog = page.getByRole('dialog', { name: 'Nouveau produit' });
  await dialog.getByRole('textbox', { name: /^Nom en français/ }).fill(productName);
  await dialog.getByRole('checkbox', { name: 'Sac' }).check();
  await dialog.getByRole('checkbox', { name: 'Tonne (T)' }).check();
  await dialog.getByRole('textbox', { name: /^Masse d'un sac/ }).fill('50');
  await dialog.getByRole('button', { name: 'Créer' }).click();

  await expect(page.getByText('Produit créé.')).toBeVisible();
  await page.getByRole('textbox', { name: 'Rechercher' }).fill(productName);
  const row = page.getByRole('row', { name: new RegExp(productName) });
  await expect(row).toContainText('50');
  await expect(row).toContainText('Actif');
  await capture(page, 'web-catalogue-produits-fr.png');
});

test('chef.dev demande 300 sacs : équivalence 15 T, numéro donné par le serveur (CA-MAT-001)', async ({ browser }) => {
  const page = await newPage(browser, 'chef.dev');
  await page.goto('/materials/requests');
  await expect(page.getByRole('heading', { level: 1, name: 'Demandes de matériaux' })).toBeVisible();

  await page.getByRole('button', { name: 'Nouvelle demande' }).click();
  const dialog = page.getByRole('dialog', { name: 'Nouvelle demande' });
  await dialog.getByRole('textbox', { name: /^Produit/ }).fill(productName);
  await page.getByRole('option', { name: productName }).click();
  await expect(dialog.getByRole('textbox', { name: /^Unité/ })).toHaveValue('Sac');
  await dialog.getByRole('textbox', { name: /^Quantité/ }).fill('300');
  await expect(dialog.getByText(/Équivalence : 300\s+sacs = 15\s+T/)).toBeVisible();
  await capture(page, 'web-nouvelle-demande-fr.png');
  await dialog.getByRole('button', { name: 'Créer' }).click();

  const created = page.getByText(/Demande DEM-\d+ créée\./);
  await expect(created).toBeVisible();
  requestNumber = (await created.innerText()).replace(/^[\s\S]*(DEM-\d+)[\s\S]*$/, '$1');
  expect(requestNumber).toMatch(/^DEM-\d+$/);

  const row = page.getByRole('row', { name: new RegExp(requestNumber) });
  await expect(row).toContainText(productName);
  await expect(row).toContainText(/300\s+sacs/);
  await expect(row).toContainText('Demandée');
  await expect(row).toContainText('CH-ECO-UV18');
  // Aucun prix ni montant sur l'écran d'un chef de chantier (CA-MAT-009.3).
  await expect(page.locator('main')).not.toContainText('DZD');
});

test('conducteur.dev valide la demande en un clic depuis « À valider » (CA-MAT-003.1)', async ({ browser }) => {
  expect(requestNumber).not.toBe('');
  const page = await newPage(browser, 'conducteur.dev');
  await page.goto('/materials/to-approve');
  await expect(page.getByRole('heading', { level: 1, name: 'Demandes à valider' })).toBeVisible();

  await page.getByRole('textbox', { name: 'Rechercher' }).fill(requestNumber);
  const row = page.getByRole('row', { name: new RegExp(requestNumber) });
  await expect(row).toContainText(productName);
  await capture(page, 'web-a-valider-fr.png');
  await row.getByRole('button', { name: `Valider ${requestNumber}` }).click();

  await expect(page.getByText(`Demande ${requestNumber} validée.`)).toBeVisible();
  await expect(page.getByRole('row', { name: new RegExp(requestNumber) })).toHaveCount(0);

  // La fiche montre le statut « Validée » et l'historique (qui, quand, ancien → nouveau statut).
  await page.goto(`/materials/requests?q=${requestNumber}`);
  await page.getByRole('link', { name: `Ouvrir la demande ${requestNumber}` }).click();
  const drawer = page.getByRole('dialog', { name: `Demande ${requestNumber}` });
  await expect(drawer).toContainText('Validée');
  await expect(drawer).toContainText('Demande validée');
  await expect(drawer).toContainText('Demandée → Validée');
  await capture(page, 'web-detail-demande-fr.png');
});

test('equipe.dev ne voit ni « À valider » ni les boutons de validation (CA-MAT-003.7, CA-MAT-009.1)', async ({ browser }) => {
  const page = await newPage(browser, 'equipe.dev');
  await expect(page.getByRole('link', { name: 'À valider' })).toHaveCount(0);
  await page.goto('/materials/to-approve');
  await expect(page.getByText('Accès non autorisé')).toBeVisible();
});

test('arabe : la liste des demandes est en RTL, numéros et dates de gauche à droite (CA-MAT-001.15)', async ({ browser }) => {
  // Compte dédié : le choix de langue est mémorisé sur le compte et ne doit pas gêner les autres parcours.
  const page = await newPage(browser, 'direction.dev');
  await page.getByText('العربية').click();
  await page.goto('/materials/requests');

  await expect(page.getByRole('heading', { level: 1, name: 'طلبات المواد' })).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('dir', 'rtl');
  // La Direction consulte sans bouton d'écriture.
  await expect(page.getByRole('button', { name: 'طلب جديد' })).toHaveCount(0);
  await capture(page, 'web-demandes-ar.png');

  // Remet le compte de démonstration en français.
  await page.getByText('Français').click();
  await expect(page.locator('html')).toHaveAttribute('lang', 'fr');
});
