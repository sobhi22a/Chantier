import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Button, Center, Group, Paper, PasswordInput, Stack, TextInput, Title } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { IconAlertOctagon } from "@tabler/icons-react";
import { useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { useApiErrorMessage, useAuthLoginMutation } from "@chantier-frontend/api-core";
import { LanguageSwitcher } from "@chantier-frontend/i18n";
import { useFieldError } from "@chantier-frontend/user-interface";

import { signInSchema, type SignInFormValues } from "../../types/signIn.zod";

/**
 * Connexion. Choix de la langue avant de se connecter (CA-001.8), mot de passe masquable (CA-001.9),
 * bouton inactif pendant l'envoi (CA-001.6) et un seul message d'échec, quel que soit le motif (CA-001.3).
 * Une fois la session ouverte, `AuthGuard access="anonymous"` renvoie l'utilisateur là d'où il venait.
 */
const SignInPageComponent = () => {
  const { t } = useTranslation("auth");
  const fieldError = useFieldError();
  const { getMessage, getReference } = useApiErrorMessage();
  const [passwordVisible, { toggle: togglePasswordVisibility }] = useDisclosure(false);
  const [login, { isLoading, error }] = useAuthLoginMutation();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<SignInFormValues>({
    resolver: zodResolver(signInSchema),
    defaultValues: { userName: "", password: "" },
  });

  const onSubmit = async ({ userName, password }: SignInFormValues) => {
    try {
      await login({ loginRequest: { userName, password, isAppMobile: false } }).unwrap();
    } catch {
      // L'erreur est lue depuis l'état de la mutation et affichée ci-dessous.
    }
  };

  return (
    <Center mih="100dvh" p="md">
      <title>{t("signIn.title")}</title>
      <Paper withBorder shadow="sm" p="xl" maw={440} w="100%">
        <Stack gap="md">
          <Group justify="space-between" wrap="nowrap" align="flex-start">
            <Title order={1} size="h2">
              {t("signIn.title")}
            </Title>
            <LanguageSwitcher />
          </Group>

          {error ? (
            <Alert color="red" variant="light" icon={<IconAlertOctagon aria-hidden />} role="alert">
              {getMessage(error)}
              {getReference(error) ? ` ${getReference(error)}` : null}
            </Alert>
          ) : null}

          <form onSubmit={(event) => void handleSubmit(onSubmit)(event)} noValidate>
            <Stack gap="md">
              <TextInput
                label={t("signIn.username")}
                autoComplete="username"
                autoCapitalize="none"
                spellCheck={false}
                error={fieldError(errors.userName)}
                {...register("userName")}
              />
              <PasswordInput
                label={t("signIn.password")}
                autoComplete="current-password"
                visible={passwordVisible}
                onVisibilityChange={togglePasswordVisibility}
                visibilityToggleButtonProps={{
                  "aria-label": passwordVisible ? t("signIn.hidePassword") : t("signIn.showPassword"),
                }}
                error={fieldError(errors.password)}
                {...register("password")}
              />
              <Button type="submit" size="md" fullWidth loading={isLoading}>
                {isLoading ? t("signIn.submitting") : t("signIn.submit")}
              </Button>
            </Stack>
          </form>
        </Stack>
      </Paper>
    </Center>
  );
};

export default SignInPageComponent;
