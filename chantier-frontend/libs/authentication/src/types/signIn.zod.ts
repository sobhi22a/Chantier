import { z } from "zod";

// Les messages sont des clés de traduction (traduites à l'affichage) : ADR 0007.
export const signInSchema = z.object({
  userName: z.string().trim().min(1, "auth:signIn.usernameRequired"),
  password: z.string().min(1, "auth:signIn.passwordRequired"),
});

export type SignInFormValues = z.infer<typeof signInSchema>;
