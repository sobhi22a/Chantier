import { zodResolver } from "@hookform/resolvers/zod";
import { Alert, Button, Center, Group, Paper, PasswordInput, Stack, Title } from "@mantine/core";
import { IconAlertOctagon, IconInfoCircle } from "@tabler/icons-react";
import { useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";

import { useApiErrorMessage, useAuthChangePasswordMutation, useAuthMeQuery } from "@chantier-frontend/api-core";
import { LanguageSwitcher } from "@chantier-frontend/i18n";
import { applyServerErrors, useFieldError, useNotifications } from "@chantier-frontend/user-interface";

import { changePasswordSchema, type ChangePasswordFormValues } from "../../types/changePassword.zod";
import { AUTHENTICATION_ROUTES } from "../../utilities/resources";
import { useSignOut } from "../../hooks/useSignOut";

/**
 * Changement de mot de passe. Imposé à la première connexion (mot de passe provisoire, CA-001.7, code
 * `MOT_DE_PASSE_A_CHANGER`) : tant qu'il n'est pas changé, le serveur refuse tout le reste.
 */
const ChangePasswordPageComponent = () => {
  const { t } = useTranslation("auth");
  const fieldError = useFieldError();
  const navigate = useNavigate();
  const { showNotification } = useNotifications();
  const { getMessage } = useApiErrorMessage();
  const { signOut, isSigningOut } = useSignOut();
  const { data: me, refetch: refetchMe } = useAuthMeQuery();
  const [changePassword, { isLoading, error }] = useAuthChangePasswordMutation();

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<ChangePasswordFormValues>({
    resolver: zodResolver(changePasswordSchema),
    defaultValues: { currentPassword: "", newPassword: "", confirmPassword: "" },
  });

  const onSubmit = async ({ currentPassword, newPassword }: ChangePasswordFormValues) => {
    try {
      await changePassword({ changePasswordRequest: { currentPassword, newPassword } }).unwrap();
      // Le profil doit être relu avant de partir : sinon la garde verrait encore le mot de passe provisoire.
      await refetchMe();
      showNotification({ type: "success", message: t("changePassword.success") });
      void navigate(AUTHENTICATION_ROUTES.BASE, { replace: true });
    } catch (caught) {
      applyServerErrors(caught, setError, { MOT_DE_PASSE_FAIBLE: "newPassword" });
    }
  };

  // Les erreurs rattachées à un champ (mot de passe faible) s'affichent sous le champ, les autres en alerte.
  const showAlert = error && !errors.newPassword;

  return (
    <Center mih="100dvh" p="md">
      <title>{t("changePassword.title")}</title>
      <Paper withBorder shadow="sm" p="xl" maw={480} w="100%">
        <Stack gap="md">
          <Group justify="space-between" wrap="nowrap" align="flex-start">
            <Title order={1} size="h2">
              {t("changePassword.title")}
            </Title>
            <LanguageSwitcher />
          </Group>

          {me?.mustChangePassword ? (
            <Alert color="blue" variant="light" icon={<IconInfoCircle aria-hidden />}>
              {t("changePassword.intro")}
            </Alert>
          ) : null}

          {showAlert ? (
            <Alert color="red" variant="light" icon={<IconAlertOctagon aria-hidden />} role="alert">
              {getMessage(error)}
            </Alert>
          ) : null}

          <form onSubmit={(event) => void handleSubmit(onSubmit)(event)} noValidate>
            <Stack gap="md">
              <PasswordInput
                label={t("changePassword.current")}
                autoComplete="current-password"
                error={fieldError(errors.currentPassword)}
                {...register("currentPassword")}
              />
              <PasswordInput
                label={t("changePassword.new")}
                autoComplete="new-password"
                description={t("changePassword.minLength")}
                error={fieldError(errors.newPassword)}
                {...register("newPassword")}
              />
              <PasswordInput
                label={t("changePassword.confirm")}
                autoComplete="new-password"
                error={fieldError(errors.confirmPassword)}
                {...register("confirmPassword")}
              />
              <Button type="submit" size="md" fullWidth loading={isLoading}>
                {t("changePassword.submit")}
              </Button>
              {me?.mustChangePassword ? (
                <Button variant="subtle" onClick={() => void signOut()} loading={isSigningOut}>
                  {t("signOut.action")}
                </Button>
              ) : null}
            </Stack>
          </form>
        </Stack>
      </Paper>
    </Center>
  );
};

export default ChangePasswordPageComponent;
