import { createBrowserRouter, Navigate, Outlet, type RouteObject } from "react-router-dom";

import {
  AuthGuardComponent,
  AuthProviderComponent,
  ChangePasswordPageComponent,
  DefaultRedirectComponent,
  PermissionsGuardComponent,
  PERMISSIONS_RESOURCES,
  SignInComponent,
} from "@chantier-frontend/authentication";
import {
  GenericErrorFallbackComponent,
  GenericLoaderComponent,
  GenericUnauthorizedComponent,
} from "@chantier-frontend/user-interface";

import DashboardLayout from "../../layouts/structure/dashboard/DashboardLayout.component";
import { BACK_OFFICE_ROUTES } from "./navigationRoutes";
import { DEFAULT_ROUTES } from "./routesMapping";

// =============== ROUTES =============== //
// Exportées séparément pour que les tests puissent les monter dans un routeur en mémoire.
// Les pages des chantiers sont chargées à la demande (une copie de code par route).
export const backOfficeRoutes: RouteObject[] = [
  {
    // La session (`GET /auth/me`) est chargée une fois pour toutes les routes.
    element: (
      <AuthProviderComponent>
        <Outlet />
      </AuthProviderComponent>
    ),
    errorElement: <GenericErrorFallbackComponent />,
    HydrateFallback: () => <GenericLoaderComponent height="100dvh" />,
    children: [
      {
        path: BACK_OFFICE_ROUTES.SIGN_IN,
        element: (
          <AuthGuardComponent access="anonymous">
            <SignInComponent />
          </AuthGuardComponent>
        ),
      },
      {
        path: BACK_OFFICE_ROUTES.CHANGE_PASSWORD,
        element: (
          <AuthGuardComponent access="authenticated-any">
            <ChangePasswordPageComponent />
          </AuthGuardComponent>
        ),
      },
      {
        element: (
          <AuthGuardComponent access="authenticated">
            <DashboardLayout />
          </AuthGuardComponent>
        ),
        children: [
          { index: true, element: <DefaultRedirectComponent routes={DEFAULT_ROUTES} /> },
          {
            path: BACK_OFFICE_ROUTES.SITES,
            element: (
              <PermissionsGuardComponent resourceKey={PERMISSIONS_RESOURCES.SITES}>
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [
              {
                index: true,
                lazy: async () => ({
                  Component: (await import("../../../features/sites/sections/SitesBrowser.section")).default,
                }),
              },
              {
                path: ":siteId",
                lazy: async () => ({
                  Component: (await import("../../../features/sites/sections/SiteDetail.section")).default,
                }),
              },
            ],
          },
          { path: BACK_OFFICE_ROUTES.UNAUTHORIZED, element: <GenericUnauthorizedComponent /> },
        ],
      },
      { path: "*", element: <Navigate to={BACK_OFFICE_ROUTES.BASE} replace /> },
    ],
  },
];

export const backOfficeRouter = createBrowserRouter(backOfficeRoutes);
