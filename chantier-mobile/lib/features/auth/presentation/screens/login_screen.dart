import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/settings/presentation/language_selector.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Connexion : langue choisissable avant de se connecter (CA-001.8), dernier identifiant
/// prerempli (3 gestes : toucher le mot de passe, le saisir, « Se connecter », CA-001.2), message
/// unique en cas d'echec (CA-001.3), bouton inactif pendant l'envoi (CA-001.6), mot de passe
/// masque avec bouton « afficher » (CA-001.9).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userName;
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _userName = TextEditingController(
      text: context.read<AuthBloc>().lastUserName ?? '',
    );
  }

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.selectionClick();
    bloc.add(
      AuthLoginSubmitted(userName: _userName.text, password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AuthBloc>().state;
    final failure = state.failure;
    final offline =
        failure is NetworkApiException || failure is TimeoutApiException;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LanguageSelector(),
                      const SizedBox(height: 24),
                      if (state.notice != null) ...[
                        _Message(
                          text: switch (state.notice!) {
                            AuthNotice.sessionExpired =>
                              l10n.noticeSessionExpired,
                            AuthNotice.accessRevoked => l10n.errorAccesRetire,
                          },
                          icon: Icons.info_outline,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _userName,
                        enabled: !state.isSubmitting,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: l10n.loginUserName,
                        ),
                        style: theme.textTheme.bodyLarge,
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? l10n.loginFieldRequired
                            : null,
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        focusNode: _passwordFocus,
                        enabled: !state.isSubmitting,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: l10n.loginPassword,
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? l10n.loginShowPassword
                                : l10n.loginHidePassword,
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (value) => (value ?? '').isEmpty
                            ? l10n.loginFieldRequired
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      if (offline)
                        _FirstConnectionNeedsNetwork(onRetry: _submit)
                      else if (failure != null)
                        _Message(
                          text: apiErrorMessage(l10n, failure),
                          icon: Icons.error_outline,
                          isError: true,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Bouton principal en bas de l'ecran : accessible au pouce.
            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: state.isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.loginSubmitting),
                          ],
                        )
                      : Text(l10n.loginSubmit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// « Premiere connexion : reseau necessaire » avec « Reessayer » (CA-001.5) : jamais d'ecran
/// blanc ni de chargement sans fin.
class _FirstConnectionNeedsNetwork extends StatelessWidget {
  const _FirstConnectionNeedsNetwork({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi_off, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.loginFirstConnectionTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.loginFirstConnectionBody),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.icon,
    this.isError = false,
  });

  final String text;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.onSurface;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorContainer : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isError
                    ? AppColors.onErrorContainer
                    : AppColors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
