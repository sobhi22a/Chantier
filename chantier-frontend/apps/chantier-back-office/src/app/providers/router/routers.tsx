import { createBrowserRouter, Navigate, Outlet, type RouteObject } from "react-router-dom";

import {
  AuthGuardComponent,
  AuthProviderComponent,
  ChangePasswordPageComponent,
  DefaultRedirectComponent,
  FOLLOW_UP_PERMISSIONS,
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

// Pages des matériaux chargées à la demande (une copie de code par route).
const loadRequestsSection = async () => ({
  Component: (await import("../../../features/materials/sections/Requests.section")).default,
});
const loadToApproveSection = async () => ({
  Component: (await import("../../../features/materials/sections/ToApprove.section")).default,
});
const loadToOrderSection = async () => ({
  Component: (await import("../../../features/materials/sections/ToOrder.section")).default,
});
const loadDeliveriesSection = async () => ({
  Component: (await import("../../../features/materials/sections/Deliveries.section")).default,
});
const loadFollowUpSection = async () => ({
  Component: (await import("../../../features/materials/sections/FollowUp.section")).default,
});

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
          {
            path: BACK_OFFICE_ROUTES.MATERIAL_REQUESTS,
            element: (
              <PermissionsGuardComponent resourceKey={PERMISSIONS_RESOURCES.REQUESTS}>
                <Outlet />
              </PermissionsGuardComponent>
            ),
            // La fiche s'ouvre dans un tiroir au-dessus de la même liste : même page, adresse partageable.
            children: [
              { index: true, lazy: loadRequestsSection },
              { path: ":siteId/:requestId", lazy: loadRequestsSection },
            ],
          },
          {
            path: BACK_OFFICE_ROUTES.MATERIAL_TO_APPROVE,
            element: (
              <PermissionsGuardComponent permission="Requests.Approve">
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [
              { index: true, lazy: loadToApproveSection },
              { path: ":siteId/:requestId", lazy: loadToApproveSection },
            ],
          },
          {
            path: BACK_OFFICE_ROUTES.MATERIAL_TO_ORDER,
            element: (
              <PermissionsGuardComponent permission="Orders.Create">
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [
              { index: true, lazy: loadToOrderSection },
              { path: ":siteId/:requestId", lazy: loadToOrderSection },
            ],
          },
          {
            path: BACK_OFFICE_ROUTES.MATERIAL_DELIVERIES,
            element: (
              <PermissionsGuardComponent permission="Deliveries.View">
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [
              { index: true, lazy: loadDeliveriesSection },
              { path: ":siteId/:deliveryId", lazy: loadDeliveriesSection },
            ],
          },
          {
            path: BACK_OFFICE_ROUTES.MATERIAL_FOLLOW_UP,
            element: (
              <PermissionsGuardComponent anyOf={FOLLOW_UP_PERMISSIONS}>
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [
              { index: true, lazy: loadFollowUpSection },
              { path: ":siteId/:requestId", lazy: loadFollowUpSection },
            ],
          },
          {
            path: BACK_OFFICE_ROUTES.CATALOG_PRODUCTS,
            element: (
              <PermissionsGuardComponent resourceKey={PERMISSIONS_RESOURCES.PRODUCTS}>
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [{ index: true, lazy: async () => ({ Component: (await import("../../../features/catalog/sections/Products.section")).default }) }],
          },
          {
            path: BACK_OFFICE_ROUTES.CATALOG_SUPPLIERS,
            element: (
              <PermissionsGuardComponent resourceKey={PERMISSIONS_RESOURCES.SUPPLIERS}>
                <Outlet />
              </PermissionsGuardComponent>
            ),
            children: [{ index: true, lazy: async () => ({ Component: (await import("../../../features/catalog/sections/Suppliers.section")).default }) }],
          },
          { path: BACK_OFFICE_ROUTES.UNAUTHORIZED, element: <GenericUnauthorizedComponent /> },
        ],
      },
      { path: "*", element: <Navigate to={BACK_OFFICE_ROUTES.BASE} replace /> },
    ],
  },
];

export const backOfficeRouter = createBrowserRouter(backOfficeRoutes);
