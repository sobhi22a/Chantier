import { expect, test, type Browser, type Page } from '@playwright/test';

/**
 * Parcours réel de la tranche B « Commander, recevoir, suivre » (plan Q2, ADR 0010) contre l'API de développement avec les données
 * de démonstration : le chef de chantier demande 300 sacs de ciment, le conducteur valide, les Achats commandent à 780,00 DZD le sac
 * (montant 234 000,00 calculé par le serveur), le chef reçoit 100 sacs avec la photo du bon, puis le suivi du chantier se lit.
 * Mêmes variables que `requests.spec.ts` (`QA_DEMO_PASSWORD`, `QA_CAPTURES`). Données fictives, parcours répétable.
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

test.describe.configure({ mode: 'serial' });

let requestNumber = '';
const note = `e2e-b ${Date.now().toString(36)}`;

test('chef.dev demande 300 sacs de ciment (tranche A, point de départ)', async ({ browser }) => {
  const page = await newPage(browser, 'chef.dev');
  await page.goto('/materials/requests');
  await page.getByRole('button', { name: 'Nouvelle demande' }).click();
  const dialog = page.getByRole('dialog', { name: 'Nouvelle demande' });
  await dialog.getByRole('textbox', { name: /^Produit/ }).fill('Ciment');
  await page.getByRole('option', { name: /Ciment/ }).first().click();
  await dialog.getByRole('textbox', { name: /^Quantité/ }).fill('300');
  await dialog.getByRole('textbox', { name: /^Usage ou remarque/ }).fill(note);
  await dialog.getByRole('button', { name: 'Créer' }).click();

  const created = page.getByText(/Demande DEM-\d+ créée\./);
  await expect(created).toBeVisible();
  requestNumber = (await created.innerText()).replace(/^[\s\S]*(DEM-\d+)[\s\S]*$/, '$1');
  expect(requestNumber).toMatch(/^DEM-\d+$/);
});

test('conducteur.dev valide la demande depuis « À valider »', async ({ browser }) => {
  expect(requestNumber).not.toBe('');
  const page = await newPage(browser, 'conducteur.dev');
  await page.goto('/materials/to-approve');
  await page.getByRole('textbox', { name: 'Rechercher' }).fill(requestNumber);
  await page.getByRole('row', { name: new RegExp(requestNumber) }).getByRole('button', { name: `Valider ${requestNumber}` }).click();
  await expect(page.getByText(`Demande ${requestNumber} validée.`)).toBeVisible();
});

test('achats.dev commande avec le prix par sac : montant 234 000,00 DZD calculé par le serveur (CA-MAT-005.3)', async ({ browser }) => {
  const page = await newPage(browser, 'achats.dev');
  await page.goto('/materials/to-order');
  await expect(page.getByRole('heading', { level: 1, name: 'Demandes à commander' })).toBeVisible();
  await page.getByRole('textbox', { name: 'Rechercher' }).fill(requestNumber);
  await capture(page, 'web-a-commander-fr.png');
  await page.getByRole('button', { name: `Commander ${requestNumber}` }).click();

  const dialog = page.getByRole('dialog', { name: `Commander ${requestNumber}` });
  await expect(dialog.getByText(/Quantité commandée : 300\s+sacs/)).toBeVisible();
  // Plusieurs fournisseurs du catalogue : le choix est explicite (aucun « dernier fournisseur » n'est connu du web).
  await dialog.getByRole('textbox', { name: /^Fournisseur/ }).click();
  await page.getByRole('option').first().click();
  await dialog.getByRole('textbox', { name: /^Prix unitaire HT/ }).fill('780');
  await capture(page, 'web-commande-fr.png');
  await dialog.getByRole('button', { name: 'Commander' }).click();

  await expect(page.getByText(/montant 234\s000,00\sDZD/)).toBeVisible();
  await page.goto(`/materials/requests?q=${requestNumber}`);
  await page.getByRole('link', { name: `Ouvrir la demande ${requestNumber}` }).click();
  const drawer = page.getByRole('dialog', { name: `Demande ${requestNumber}` });
  await expect(drawer).toContainText('Commandée');
  await expect(drawer.getByRole('group', { name: 'Commande' })).toContainText(/234\s000,00\sDZD/);
});

test('chef.dev reçoit 100 sacs : annonce partielle, photo du bon réduite et lue avec la session, aucun prix (CA-MAT-006, 007, 009.3)', async ({ browser }) => {
  const page = await newPage(browser, 'chef.dev');
  await page.goto(`/materials/requests?q=${requestNumber}`);
  await page.getByRole('link', { name: `Ouvrir la demande ${requestNumber}` }).click();
  const drawer = page.getByRole('dialog', { name: `Demande ${requestNumber}` });
  await expect(drawer.getByRole('group', { name: 'Commande' })).toContainText('Fournisseur');
  // Le chef de chantier n'a pas Prices.View : ni prix ni montant dans la fiche (CA-MAT-009.3).
  await expect(drawer).not.toContainText('DZD');
  await drawer.getByRole('button', { name: 'Enregistrer une livraison' }).click();

  const form = page.getByRole('dialog', { name: `Livraison pour ${requestNumber}` });
  await expect(form.getByRole('textbox', { name: /^Quantité reçue/ })).toHaveValue('300');
  await form.getByRole('textbox', { name: /^Quantité reçue/ }).fill('100');
  await expect(form.getByText(/Livraison partielle : il restera 200\s+sacs\./)).toBeVisible();
  await form.getByRole('textbox', { name: /N° du bon de livraison/ }).fill(`bl-${Date.now().toString(36)}`);
  await capture(page, 'web-livraison-fr.png');
  await form.getByRole('button', { name: 'Nouvelle livraison' }).click();

  await expect(page.getByText(/Livraison LIV-\d+ enregistrée\./)).toBeVisible();
  const delivery = page.getByRole('dialog', { name: /^Livraison LIV-/ });
  await expect(delivery).toContainText('Enregistrée');

  // Une vraie image JPEG, produite par le navigateur : elle est réduite, envoyée (POST puis PUT) et relue par la session.
  const jpeg = await page.evaluate(async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 2400;
    canvas.height = 1600;
    const context = canvas.getContext('2d');
    if (context) {
      context.fillStyle = '#fff';
      context.fillRect(0, 0, 2400, 1600);
      context.fillStyle = '#222';
      context.font = '120px sans-serif';
      context.fillText('BL fictif', 200, 600);
    }
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.9));
    const buffer = new Uint8Array(await (blob as Blob).arrayBuffer());
    return Array.from(buffer);
  });
  await delivery.locator('input[type="file"]').setInputFiles({ name: 'bl.jpg', mimeType: 'image/jpeg', buffer: Buffer.from(jpeg) });
  await expect(page.getByText(/Photo ajoutée à la livraison LIV-\d+\./)).toBeVisible();
  const image = delivery.getByRole('img', { name: 'Bon de livraison, photo 1' });
  await expect(image).toBeVisible();
  expect(await image.getAttribute('src')).toMatch(/^blob:/);
  // 2400 px réduits à 1 600 px au plus avant l'envoi.
  expect(await image.evaluate((element) => (element as HTMLImageElement).naturalWidth)).toBeLessThanOrEqual(1600);
  await capture(page, 'web-detail-livraison-fr.png');
  await expect(delivery).not.toContainText('DZD');

  // Le statut de la demande est recalculé par le serveur.
  await page.goto(`/materials/requests?q=${requestNumber}`);
  await expect(page.getByRole('row', { name: new RegExp(requestNumber) })).toContainText('Livrée partiellement');
});

test('le suivi du chantier montre les compteurs, le total à commander et les montants (CA-MAT-013)', async ({ browser }) => {
  const page = await newPage(browser, 'achats.dev');
  await page.goto('/materials/follow-up');
  await expect(page.getByRole('heading', { level: 1, name: 'Suivi des approvisionnements' })).toBeVisible();
  // Plusieurs chantiers affectés : le suivi se lit pour un chantier choisi.
  await page.getByRole('textbox', { name: 'Chantier' }).click();
  await page.getByRole('option', { name: /CH-ECO-UV18/ }).click();
  const views = page.getByRole('group', { name: 'Vue' });
  await expect(views.getByRole('button', { name: /^Attendues : \d+$/ })).toBeVisible();
  await expect(page.getByRole('group', { name: 'Montants du chantier' })).toContainText('DZD');
  await views.getByRole('button', { name: /^À commander : \d+$/ }).click();
  await expect(page.getByRole('region', { name: 'Totaux à commander' })).toBeVisible();
  await capture(page, 'web-suivi-fr.png');
});

test('equipe.dev ne voit ni « À commander » ni « Suivi » et aucun montant (CA-MAT-009.1)', async ({ browser }) => {
  const page = await newPage(browser, 'equipe.dev');
  await expect(page.getByRole('link', { name: 'À commander' })).toHaveCount(0);
  await expect(page.getByRole('link', { name: 'Suivi' })).toHaveCount(0);
  await page.goto('/materials/to-order');
  await expect(page.getByText('Accès non autorisé')).toBeVisible();
});

test('arabe : le suivi est en RTL, compteurs traduits, chiffres de gauche à droite (CA-MAT-020)', async ({ browser }) => {
  const page = await newPage(browser, 'direction.dev');
  await page.getByText('العربية').click();
  await page.goto('/materials/follow-up');

  await expect(page.getByRole('heading', { level: 1, name: 'متابعة التموين' })).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('dir', 'rtl');
  await page.getByRole('textbox', { name: 'الورشة' }).click();
  await page.getByRole('option').first().click();
  await expect(page.getByRole('group', { name: 'العرض' }).getByRole('button', { name: /^بانتظار المصادقة: \d+$/ })).toBeVisible();
  await capture(page, 'web-suivi-ar.png');
  await page.goto('/materials/deliveries');
  await expect(page.getByRole('heading', { level: 1, name: 'التسليمات' })).toBeVisible();
  await capture(page, 'web-livraisons-ar.png');

  // Remet le compte de démonstration en français.
  await page.getByText('Français').click();
  await expect(page.locator('html')).toHaveAttribute('lang', 'fr');
});
