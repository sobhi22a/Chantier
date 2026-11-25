import { expect, test } from '@playwright/test';

// Parcours de base : la page de connexion s'affiche en français puis bascule en arabe (RTL) sans recharger.
// (Mis à jour par la QA : l'ancien test visait l'accueil du squelette W1, remplacé par la connexion en W4.)
test('affiche la connexion en français puis bascule en arabe sans recharger', async ({ page }) => {
  await page.goto('/');

  await expect(page.getByRole('heading', { level: 1, name: 'Connexion' })).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('lang', 'fr');
  await expect(page.locator('html')).toHaveAttribute('dir', 'ltr');

  await page.getByText('العربية').click();

  await expect(page.getByRole('heading', { level: 1, name: 'تسجيل الدخول' })).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('lang', 'ar');
  await expect(page.locator('html')).toHaveAttribute('dir', 'rtl');

  // Le choix est mémorisé : il survit à un rechargement.
  await page.reload();
  await expect(page.locator('html')).toHaveAttribute('dir', 'rtl');
});
