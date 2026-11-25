import { z } from "zod";

/** Longueur minimale côté client : confort de saisie seulement, le serveur refuse un mot de passe faible (`MOT_DE_PASSE_FAIBLE`). */
export const PASSWORD_MIN_LENGTH = 8;

export const changePasswordSchema = z
  .object({
    currentPassword: z.string().min(1, "auth:changePassword.currentRequired"),
    newPassword: z
      .string()
      .min(1, "auth:changePassword.newRequired")
      .min(PASSWORD_MIN_LENGTH, "auth:changePassword.minLength")
      .regex(/\d/, "auth:changePassword.minLength"),
    confirmPassword: z.string(),
  })
  .refine((values) => values.newPassword === values.confirmPassword, {
    path: ["confirmPassword"],
    message: "auth:changePassword.mismatch",
  });

export type ChangePasswordFormValues = z.infer<typeof changePasswordSchema>;
