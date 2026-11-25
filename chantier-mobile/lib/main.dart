import 'package:chantier_mobile/app.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/di/injection.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/logging/app_logging.dart';
import 'package:chantier_mobile/core/router/app_router.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureLogging();

  await initializeDependencies();
  sl<AppConfig>().assertSecureFor(isRelease: kReleaseMode);

  // La session est restauree depuis le telephone : aucun reseau n'est necessaire (CA-012.1).
  final authBloc = sl<AuthBloc>()..add(const AuthStarted());

  runApp(
    ChantierApp(
      router: AppRouter.create(authBloc),
      localeCubit: sl<LocaleCubit>(),
      authBloc: authBloc,
    ),
  );
}
