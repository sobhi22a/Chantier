import 'dart:async';

import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_scheduler.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/widgets/current_site_header.dart';
import 'package:chantier_mobile/core/widgets/stale_data_banner.dart';
import 'package:chantier_mobile/core/widgets/sync_status_bar.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Coquille de tous les ecrans connectes : barre d'etat de synchronisation, bandeau de donnees
/// anciennes et chantier courant **en haut de chaque ecran** (CA-013.1, CA-010.1).
///
/// Elle possede aussi la synchronisation du premier plan : demarrage, retour au premier plan,
/// reseau, minuteur (`SyncScheduler`). Au repos en arriere-plan, plus aucun minuteur.
class AuthenticatedShell extends StatefulWidget {
  const AuthenticatedShell({
    required this.userId,
    required this.database,
    required this.engine,
    required this.scheduler,
    required this.onOpenPending,
    required this.child,
    super.key,
  });

  final String userId;
  final AppDatabase database;
  final SyncEngine engine;
  final SyncScheduler scheduler;

  /// Ouvre « Envois en attente » (appui sur la barre d'etat).
  final VoidCallback onOpenPending;
  final Widget child;

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell>
    with WidgetsBindingObserver {
  late final SyncStatusCubit _syncStatus;
  late final CurrentSiteCubit _currentSite;

  @override
  void initState() {
    super.initState();
    _syncStatus = SyncStatusCubit(
      engine: widget.engine,
      database: widget.database,
      userId: widget.userId,
    );
    _currentSite = CurrentSiteCubit(
      database: widget.database,
      userId: widget.userId,
    );
    WidgetsBinding.instance.addObserver(this);
    widget.scheduler.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.scheduler.resume();
      case AppLifecycleState.paused || AppLifecycleState.detached:
        widget.scheduler.pause();
      case AppLifecycleState.inactive || AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.scheduler.pause();
    unawaited(_syncStatus.close());
    unawaited(_currentSite.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _syncStatus),
        BlocProvider.value(value: _currentSite),
      ],
      child: Material(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SyncStatusBar(onTap: widget.onOpenPending),
              const StaleDataBanner(),
              const CurrentSiteHeader(),
              Expanded(
                // Le haut de l'ecran est deja protege par la coquille.
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
