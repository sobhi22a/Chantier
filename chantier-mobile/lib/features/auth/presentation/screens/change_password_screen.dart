import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Changement obligatoire du mot de passe provisoire (CA-001.7, 403 `MOT_DE_PASSE_A_CHANGER`).
/// Tant qu'il n'est pas fait, le serveur refuse tout le reste : l'application n'ouvre rien d'autre.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    bloc.add(
      AuthPasswordChangeSubmitted(
        currentPassword: _current.text,
        newPassword: _new.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AuthBloc>().state;
    final failure = state.failure;

    String? required(String? value) =>
        (value ?? '').isEmpty ? l10n.loginFieldRequired : null;

    Widget field(
      TextEditingController controller,
      String label, {
      String? Function(String?)? validator,
      bool last = false,
    }) => TextFormField(
      controller: controller,
      enabled: !state.isSubmitting,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: validator ?? required,
      onFieldSubmitted: last ? (_) => _submit() : null,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.passwordChangeTitle)),
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
                      Text(
                        l10n.passwordChangeIntro,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      field(_current, l10n.passwordCurrent),
                      const SizedBox(height: 16),
                      field(_new, l10n.passwordNew),
                      const SizedBox(height: 16),
                      field(
                        _confirm,
                        l10n.passwordConfirm,
                        last: true,
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return l10n.loginFieldRequired;
                          }
                          return value == _new.text
                              ? null
                              : l10n.passwordMismatch;
                        },
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          label: Text(
                            _obscure
                                ? l10n.loginShowPassword
                                : l10n.loginHidePassword,
                          ),
                        ),
                      ),
                      if (failure != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            apiErrorMessage(l10n, failure),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                              fontSize: AppSizes.minBodyText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: Text(l10n.passwordChangeSubmit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
