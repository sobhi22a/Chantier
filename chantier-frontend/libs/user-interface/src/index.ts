// Generic Component Exports ==============================>
export { default as GenericLoaderComponent } from "./genericComponents/genericLoaderComponent/GenericLoader.component";
export type { GenericLoaderComponentProps } from "./genericComponents/genericLoaderComponent/GenericLoader.component";
export { default as GenericEmptyComponent } from "./genericComponents/genericEmptyComponent/GenericEmpty.component";
export type { GenericEmptyComponentProps } from "./genericComponents/genericEmptyComponent/GenericEmpty.component";
export { default as GenericErrorComponent } from "./genericComponents/genericErrorComponent/GenericError.component";
export type { GenericErrorComponentProps } from "./genericComponents/genericErrorComponent/GenericError.component";
export { default as GenericUnauthorizedComponent } from "./genericComponents/genericUnauthorizedComponent/GenericUnauthorized.component";
export { default as GenericConfirmDialogComponent } from "./genericComponents/genericConfirmDialogComponent/GenericConfirmDialog.component";
export type { GenericConfirmDialogComponentProps } from "./genericComponents/genericConfirmDialogComponent/GenericConfirmDialog.component";

// Generic Error Boundary Exports =========================>
export {
  GenericErrorBoundaryComponent,
  GenericErrorFallbackComponent,
} from "./genericComponents/genericErrorBoundaryComponent/GenericErrorBoundary.component";

// Generic Utilities Exports =============================>
export { logRenderError } from "./genericUtilities/logRenderError";
export { applyServerErrors } from "./genericUtilities/formErrors";
export type { CodeToField } from "./genericUtilities/formErrors";

// Generic Hooks Exports ==================================>
export { useFieldError } from "./genericHooks/useFieldError";
export { useNotifications } from "./genericHooks/useNotifications";
export type { NotificationType, ShowNotificationOptions } from "./genericHooks/useNotifications";
