import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";

import { apiUrl, makeMe, makeSite, problem, setupMockServer, server } from "@chantier-frontend/testing";

import { mockSession, renderApp } from "../testing/renderApp";

setupMockServer();

const emptySites = { items: [], page: 1, pageSize: 20, totalCount: 0 };

const mockEmptySites = () => server.use(http.get(apiUrl("/sites"), () => HttpResponse.json(emptySites)));

describe("session et connexion (CT-1, CT-2, CT-11)", () => {
  afterEach(() => {
    document.documentElement.removeAttribute("lang");
    document.documentElement.removeAttribute("dir");
  });

  it("renvoie un visiteur non connecté vers la connexion, en français", async () => {
    mockSession(null);
    const { router } = renderApp("/sites");

    expect(await screen.findByRole("heading", { level: 1, name: "Connexion" })).toBeTruthy();
    expect(router.state.location.pathname).toBe("/sign-in");
    expect(document.documentElement.lang).toBe("fr");
    expect(document.documentElement.dir).toBe("ltr");
  });

  it("affiche la connexion en arabe, de droite à gauche, avec la langue choisissable avant de se connecter (CA-001.8)", async () => {
    mockSession(null);
    renderApp("/sign-in", "ar");

    expect(await screen.findByRole("heading", { level: 1, name: "تسجيل الدخول" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    expect(screen.getByLabelText("اسم المستخدم")).toBeTruthy();
    expect(screen.getByLabelText("كلمة المرور")).toBeTruthy();
    expect(screen.getByRole("radiogroup", { name: "اللغة" })).toBeTruthy();
  });

  it("bascule la connexion du français à l'arabe immédiatement", async () => {
    mockSession(null);
    const user = userEvent.setup();
    renderApp("/sign-in");
    await screen.findByRole("heading", { level: 1, name: "Connexion" });

    await user.click(screen.getByText("العربية"));

    await screen.findByRole("heading", { level: 1, name: "تسجيل الدخول" });
    expect(document.documentElement.dir).toBe("rtl");
  });

  it("connecte l'utilisateur puis ouvre « Mes chantiers » (cookie, isAppMobile=false)", async () => {
    const user = userEvent.setup();
    let session = false;
    let loginBody: unknown;
    server.use(
      http.get(apiUrl("/auth/me"), () => (session ? HttpResponse.json(makeMe("ChefChantier")) : problem(401, "NON_AUTHENTIFIE"))),
      http.post(apiUrl("/auth/login"), async ({ request }) => {
        loginBody = await request.json();
        session = true;
        return HttpResponse.json({ user: { id: "x", userName: "chef.dev", fullName: "Mourad B.", role: "ChefChantier", language: "fr", mustChangePassword: false } });
      }),
    );
    mockEmptySites();
    const { router } = renderApp("/sites");
    await screen.findByRole("heading", { level: 1, name: "Connexion" });

    await user.type(screen.getByLabelText("Identifiant"), "chef.dev");
    await user.type(screen.getByLabelText("Mot de passe"), "motdepasse-de-test");
    await user.click(screen.getByRole("button", { name: "Se connecter" }));

    expect(await screen.findByRole("heading", { level: 1, name: "Mes chantiers" })).toBeTruthy();
    expect(router.state.location.pathname).toBe("/sites");
    expect(loginBody).toEqual({ userName: "chef.dev", password: "motdepasse-de-test", isAppMobile: false });
  });

  it("refuse d'envoyer un formulaire vide, avec des erreurs sous les champs", async () => {
    mockSession(null);
    const user = userEvent.setup();
    renderApp("/sign-in");
    await screen.findByRole("heading", { level: 1, name: "Connexion" });

    await user.click(screen.getByRole("button", { name: "Se connecter" }));

    expect(await screen.findByText("L'identifiant est obligatoire.")).toBeTruthy();
    expect(screen.getByText("Le mot de passe est obligatoire.")).toBeTruthy();
  });

  it.each([
    ["fr", "Identifiant", "Mot de passe", "Se connecter", "Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur."],
    ["ar", "اسم المستخدم", "كلمة المرور", "تسجيل الدخول", "اسم المستخدم أو كلمة المرور غير صحيحة، أو الحساب غير نشط. اتصل بالمسؤول."],
  ] as const)("affiche un seul message d'échec identique pour tout refus (%s, CA-001.3)", async (language, userLabel, passwordLabel, submitLabel, message) => {
    mockSession(null);
    server.use(http.post(apiUrl("/auth/login"), () => problem(401, "IDENTIFIANTS_INVALIDES", { detail: "Compte inconnu : jean" })));
    const user = userEvent.setup();
    renderApp("/sign-in", language);
    await screen.findByLabelText(userLabel);

    await user.type(screen.getByLabelText(userLabel), "inconnu");
    await user.type(screen.getByLabelText(passwordLabel), "mauvais");
    await user.click(screen.getByRole("button", { name: submitLabel }));

    const alert = await screen.findByRole("alert");
    expect(alert.textContent).toContain(message);
    expect(alert.textContent).not.toContain("jean");
    expect(alert.textContent).toContain("00-test-trace");
  });

  it("affiche « Trop d'essais » après 5 échecs (429 TROP_D_ESSAIS)", async () => {
    mockSession(null);
    server.use(http.post(apiUrl("/auth/login"), () => problem(429, "TROP_D_ESSAIS")));
    const user = userEvent.setup();
    renderApp("/sign-in");
    await screen.findByLabelText("Identifiant");

    await user.type(screen.getByLabelText("Identifiant"), "chef.dev");
    await user.type(screen.getByLabelText("Mot de passe"), "x");
    await user.click(screen.getByRole("button", { name: "Se connecter" }));

    expect((await screen.findByRole("alert")).textContent).toContain("Trop d'essais, réessayez plus tard.");
  });

  it("n'envoie qu'une seule demande en cas de double appui (CA-001.6)", async () => {
    mockSession(null);
    let calls = 0;
    server.use(
      http.post(apiUrl("/auth/login"), async () => {
        calls += 1;
        await new Promise((resolve) => setTimeout(resolve, 100));
        return problem(401, "IDENTIFIANTS_INVALIDES");
      }),
    );
    const user = userEvent.setup();
    renderApp("/sign-in");
    await screen.findByLabelText("Identifiant");
    await user.type(screen.getByLabelText("Identifiant"), "chef.dev");
    await user.type(screen.getByLabelText("Mot de passe"), "x");

    const submit = screen.getByRole("button", { name: "Se connecter" });
    await user.dblClick(submit);

    await screen.findByRole("alert");
    expect(calls).toBe(1);
  });

  it("permet d'afficher et de masquer le mot de passe (CA-001.9)", async () => {
    mockSession(null);
    const user = userEvent.setup();
    renderApp("/sign-in");
    const password = await screen.findByLabelText("Mot de passe");
    expect(password.getAttribute("type")).toBe("password");

    await user.click(screen.getByRole("button", { name: "Afficher le mot de passe" }));
    expect(screen.getByLabelText("Mot de passe").getAttribute("type")).toBe("text");

    await user.click(screen.getByRole("button", { name: "Masquer le mot de passe" }));
    expect(screen.getByLabelText("Mot de passe").getAttribute("type")).toBe("password");
  });

  it("renvoie un utilisateur déjà connecté de la page de connexion vers ses chantiers", async () => {
    mockSession("Admin");
    mockEmptySites();
    const { router } = renderApp("/sign-in");

    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });
    expect(router.state.location.pathname).toBe("/sites");
  });

  it("ouvre sur la première route autorisée depuis « / »", async () => {
    mockSession("ChefEquipe");
    mockEmptySites();
    const { router } = renderApp("/");

    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });
    expect(router.state.location.pathname).toBe("/sites");
  });

  it("affiche une panne du serveur avec « Réessayer » (pas la connexion)", async () => {
    server.use(http.get(apiUrl("/auth/me"), () => problem(500, "ERREUR_INTERNE")));
    renderApp("/sites");

    const alert = await screen.findByRole("alert");
    expect(alert.textContent).toContain("Erreur du serveur");
    expect(screen.getByRole("button", { name: "Réessayer" })).toBeTruthy();
  });
});

describe("mot de passe provisoire (CA-001.7, MOT_DE_PASSE_A_CHANGER)", () => {
  it("impose le changement avant tout autre écran", async () => {
    mockSession("ChefChantier", { mustChangePassword: true });
    const { router } = renderApp("/sites");

    expect(await screen.findByRole("heading", { level: 1, name: "Choisir un nouveau mot de passe" })).toBeTruthy();
    expect(router.state.location.pathname).toBe("/change-password");
    expect(screen.getByText("Votre mot de passe est provisoire. Choisissez-en un nouveau avant de continuer.")).toBeTruthy();
  });

  it("affiche l'invitation en arabe", async () => {
    mockSession("ChefChantier", { mustChangePassword: true, language: "ar" });
    renderApp("/sites");

    expect(await screen.findByRole("heading", { level: 1, name: "اختيار كلمة مرور جديدة" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
  });

  it("change le mot de passe puis ouvre « Mes chantiers »", async () => {
    const user = userEvent.setup();
    let mustChange = true;
    let body: unknown;
    server.use(
      http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("ChefChantier", { mustChangePassword: mustChange }))),
      http.post(apiUrl("/auth/change-password"), async ({ request }) => {
        body = await request.json();
        mustChange = false;
        return new HttpResponse(null, { status: 204 });
      }),
    );
    mockEmptySites();
    const { router } = renderApp("/sites");
    await screen.findByRole("heading", { level: 1, name: "Choisir un nouveau mot de passe" });

    await user.type(screen.getByLabelText("Mot de passe actuel"), "Provisoire-1");
    await user.type(screen.getByLabelText("Nouveau mot de passe"), "Definitif-2026");
    await user.type(screen.getByLabelText("Confirmer le nouveau mot de passe"), "Definitif-2026");
    await user.click(screen.getByRole("button", { name: "Changer le mot de passe" }));

    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });
    expect(router.state.location.pathname).toBe("/sites");
    expect(body).toEqual({ currentPassword: "Provisoire-1", newPassword: "Definitif-2026" });
  });

  it("refuse deux mots de passe différents ou trop courts avant l'envoi", async () => {
    mockSession("ChefChantier", { mustChangePassword: true });
    const user = userEvent.setup();
    renderApp("/change-password");
    await screen.findByLabelText("Nouveau mot de passe");

    await user.type(screen.getByLabelText("Mot de passe actuel"), "Provisoire-1");
    await user.type(screen.getByLabelText("Nouveau mot de passe"), "court");
    await user.type(screen.getByLabelText("Confirmer le nouveau mot de passe"), "autre");
    await user.click(screen.getByRole("button", { name: "Changer le mot de passe" }));

    expect((await screen.findAllByText("Au moins 8 caractères, dont un chiffre.")).length).toBeGreaterThan(1);
    expect(screen.getByText("Les deux mots de passe sont différents.")).toBeTruthy();
  });

  it("affiche le refus MOT_DE_PASSE_FAIBLE du serveur sous le champ, traduit", async () => {
    mockSession("ChefChantier", { mustChangePassword: true, language: "ar" });
    server.use(http.post(apiUrl("/auth/change-password"), () => problem(422, "MOT_DE_PASSE_FAIBLE")));
    const user = userEvent.setup();
    renderApp("/change-password", "ar");
    await screen.findByLabelText("كلمة المرور الجديدة");

    await user.type(screen.getByLabelText("كلمة المرور الحالية"), "Provisoire-1");
    await user.type(screen.getByLabelText("كلمة المرور الجديدة"), "Aaaaaaa1");
    await user.type(screen.getByLabelText("تأكيد كلمة المرور الجديدة"), "Aaaaaaa1");
    await user.click(screen.getByRole("button", { name: "تغيير كلمة المرور" }));

    expect(await screen.findByText("كلمة المرور ضعيفة. اختر كلمة أطول وأكثر تنوعًا.")).toBeTruthy();
  });

  it("bloque l'accès aux chantiers tant que le mot de passe est provisoire, même par lien direct", async () => {
    mockSession("Admin", { mustChangePassword: true });
    const { router } = renderApp("/sites/00000000-0000-7000-8000-0000000000a1");

    await screen.findByRole("heading", { level: 1, name: "Choisir un nouveau mot de passe" });
    expect(router.state.location.pathname).toBe("/change-password");
  });
});

describe("langue du compte (PUT /auth/me/language) et menu", () => {
  it("applique la langue enregistrée sur le compte à la connexion", async () => {
    mockSession("ChefChantier", { language: "ar" });
    mockEmptySites();
    renderApp("/sites", "fr");

    expect(await screen.findByRole("heading", { level: 1, name: "ورشاتي" })).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
    expect(document.documentElement.lang).toBe("ar");
  });

  it("mémorise le changement de langue sur le compte, une seule fois, sans bloquer l'écran", async () => {
    mockSession("ChefChantier");
    mockEmptySites();
    const calls: unknown[] = [];
    server.use(
      http.put(apiUrl("/auth/me/language"), async ({ request }) => {
        calls.push(await request.json());
        return new HttpResponse(null, { status: 204 });
      }),
    );
    const user = userEvent.setup();
    renderApp("/sites");
    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });

    await user.click(screen.getByText("العربية"));

    await screen.findByRole("heading", { level: 1, name: "ورشاتي" });
    await waitFor(() => expect(calls).toEqual([{ language: "ar" }]));
    expect(document.documentElement.dir).toBe("rtl");
  });

  it("garde la langue choisie quand la mémorisation échoue, avec un avertissement traduit", async () => {
    mockSession("ChefChantier");
    mockEmptySites();
    server.use(http.put(apiUrl("/auth/me/language"), () => problem(429, "TROP_DE_REQUETES")));
    const user = userEvent.setup();
    renderApp("/sites");
    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });

    await user.click(screen.getByText("العربية"));

    expect(await screen.findByText("طلبات كثيرة. انتظر قليلًا ثم أعد المحاولة.")).toBeTruthy();
    expect(document.documentElement.dir).toBe("rtl");
  });

  it("affiche le nom, le rôle et la déconnexion ; la déconnexion vide la session et ramène à la connexion", async () => {
    let session = true;
    server.use(
      http.get(apiUrl("/auth/me"), () => (session ? HttpResponse.json(makeMe("ConducteurTravaux")) : problem(401, "NON_AUTHENTIFIE"))),
      http.post(apiUrl("/auth/logout"), () => {
        session = false;
        return new HttpResponse(null, { status: 204 });
      }),
    );
    mockEmptySites();
    const user = userEvent.setup();
    const { router } = renderApp("/sites");
    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });

    await user.click(screen.getByRole("button", { name: "Menu de l'utilisateur" }));
    expect(await screen.findByText("Rôle : Conducteur de travaux")).toBeTruthy();
    await user.click(screen.getByRole("menuitem", { name: "Se déconnecter" }));

    await screen.findByRole("heading", { level: 1, name: "Connexion" });
    expect(router.state.location.pathname).toBe("/sign-in");
  });
});

describe("droits par rôle : routes (CT-3, CA-003.1)", () => {
  it("envoie sur « Accès non autorisé » un rôle sans la permission Sites.View", async () => {
    server.use(
      http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("Achats", { permissions: ["Zones.View"] }))),
    );
    const { router } = renderApp("/sites");

    expect(await screen.findByRole("heading", { level: 1, name: "Accès non autorisé" })).toBeTruthy();
    expect(router.state.location.pathname).toBe("/unauthorized");
    expect(screen.queryByRole("link", { name: "Mes chantiers" })).toBeNull();
  });

  it("affiche l'accès non autorisé en arabe", async () => {
    server.use(http.get(apiUrl("/auth/me"), () => HttpResponse.json(makeMe("Achats", { permissions: [], language: "ar" }))));
    renderApp("/sites");

    expect(await screen.findByRole("heading", { level: 1, name: "الدخول غير مسموح" })).toBeTruthy();
  });

  it("n'affiche que les entrées de menu autorisées", async () => {
    mockSession("Direction");
    server.use(http.get(apiUrl("/sites"), () => HttpResponse.json({ items: [makeSite()], page: 1, pageSize: 20, totalCount: 1 })));
    renderApp("/sites");

    const nav = await screen.findByRole("navigation", { name: "Menu principal" });
    expect(nav.textContent).toContain("Mes chantiers");
  });

  it("renvoie une adresse inconnue vers l'accueil", async () => {
    mockSession("ChefChantier");
    mockEmptySites();
    const { router } = renderApp("/page-inexistante");

    await screen.findByRole("heading", { level: 1, name: "Mes chantiers" });
    expect(router.state.location.pathname).toBe("/sites");
  });
});
