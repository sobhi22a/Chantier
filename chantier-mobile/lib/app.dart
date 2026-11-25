import 'dart:async';

import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/theme/app_theme.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Racine de l'application : theme terrain, francais/arabe, sens de lecture selon la langue,
/// navigation pilotee par l'etat d'authentification.
class ChantierApp extends StatelessWidget {
  const ChantierApp({
    required this.router,
    required this.localeCubit,
    required this.authBloc,
    super.key,
  });

  final GoRouter router;
  final LocaleCubit localeCubit;
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: authBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        // A la connexion, la langue du compte s'applique (CA-014.1). Pas a la restauration de
        // session : un choix fait hors ligne n'est pas ecrase.
        listenWhen: (previous, current) =>
            previous.status == AuthStatus.unauthenticated &&
            current.user != null,
        listener: (context, state) =>
            unawaited(localeCubit.setLanguage(state.user!.language)),
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) => MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: locale,
            supportedLocales: LocaleCubit.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        ),
      ),
    );
  }
}
