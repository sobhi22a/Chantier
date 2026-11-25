/**
 * Journalise une erreur de rendu React. À brancher sur `createRoot(…, { onCaughtError, onUncaughtError })` :
 * sans cela React écrit l'erreur complète (son message peut citer une donnée de l'utilisateur).
 * En production : seulement le type de l'erreur et la pile des composants, jamais le message.
 */
export const logRenderError = (error: unknown, errorInfo?: { componentStack?: string }): void => {
  if (import.meta.env.DEV) {
    console.error(error, errorInfo?.componentStack);
    return;
  }
  const name = error instanceof Error ? error.name : "UnknownError";
  console.error("Erreur de rendu :", name, errorInfo?.componentStack);
};
