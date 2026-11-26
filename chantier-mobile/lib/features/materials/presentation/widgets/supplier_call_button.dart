import 'dart:async';

import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/features/materials/data/supplier_contact.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// « Appeler le fournisseur » (US-MAT-009, ADR 0012) : le numero est lu **en ligne** a l'appui
/// (`GET /suppliers/{id}`), affiche le temps de la boite de dialogue puis compose par le telephone
/// (`tel:`). Il n'est **jamais** garde : ni base, ni cache, ni journal. Sans reseau : « Reseau
/// necessaire pour afficher le numero ». A n'afficher que si l'utilisateur a `SupplierPhone.View`.
class SupplierCallButton extends StatefulWidget {
  const SupplierCallButton({
    required this.supplierId,
    required this.supplierName,
    required this.contact,
    required this.dialer,
    super.key,
  });

  final String supplierId;
  final String? supplierName;
  final SupplierContactSource contact;
  final PhoneDialer dialer;

  @override
  State<SupplierCallButton> createState() => _SupplierCallButtonState();
}

class _SupplierCallButtonState extends State<SupplierCallButton> {
  bool _loading = false;

  Future<void> _call() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    String? phone;
    String? problem;
    try {
      phone = await widget.contact.phoneOf(widget.supplierId);
      if (phone == null) problem = l10n.supplierCallNoNumber;
    } on ApiException catch (error) {
      problem = switch (error) {
        NetworkApiException() ||
        TimeoutApiException() => l10n.supplierCallNeedsNetwork,
        // Sans le droit, le serveur n'envoie pas le numero : meme message qu'un numero absent.
        _ => l10n.supplierCallNoNumber,
      };
    }
    if (!mounted) return;
    setState(() => _loading = false);
    final number = phone;
    if (number == null) {
      messenger.showSnackBar(SnackBar(content: Text(problem ?? '')));
      return;
    }
    // Le numero ne vit que dans cette boite de dialogue.
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.supplierCallTitle(
            Formatters.isolateName(widget.supplierName ?? ''),
          ),
        ),
        content: LtrText(
          number,
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.supplierCallClose),
          ),
          FilledButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final opened = await widget.dialer.dial(number);
              if (!opened) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.supplierCallNoApp)),
                );
              }
              navigator.pop();
            },
            icon: const Icon(Icons.call),
            label: Text(l10n.supplierCallDial),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: _loading ? null : () => unawaited(_call()),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
      ),
      icon: _loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : const Icon(Icons.call),
      label: Text(l10n.supplierCall),
    );
  }
}
