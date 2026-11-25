export { default as SignInComponent } from "./pages/signInPage/SignInPage.component";
export { default as ChangePasswordPageComponent } from "./pages/changePasswordPage/ChangePasswordPage.component";

export { default as AuthProviderComponent } from "./components/AuthProvider.component";
export { default as AuthGuardComponent } from "./components/AuthGuard.component";
export type { AuthGuardAccess } from "./components/AuthGuard.component";
export { default as PermissionsGuardComponent } from "./components/PermissionsGuard.component";
export { default as DefaultRedirectComponent } from "./components/DefaultRedirect.component";

export { usePermissions } from "./hooks/usePermissions";
export type { PermissionAction } from "./hooks/usePermissions";
export { useSignOut } from "./hooks/useSignOut";

export { PASSWORD_MIN_LENGTH } from "./types/changePassword.zod";
export { AUTHENTICATION_ROUTES, PERMISSIONS_RESOURCES } from "./utilities/resources";
export type { AuthRouteKeysTypes, PermissionResourceKey } from "./utilities/resources";
