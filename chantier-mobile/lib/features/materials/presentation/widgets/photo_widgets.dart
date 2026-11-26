import 'dart:async';
import 'dart:io';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/data/photo_capture.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Prise de photos du bon (CA-MAT-007.1, 007.3, 007.5) : « Photographier le bon » ouvre l'appareil
/// photo en **un geste** ; la vignette propose **Reprendre** ou **Garder** ; au plus [maxPhotos]
/// photos (la suivante est refusee avec « N photos au maximum »).
///
/// Les photos gardees sont rangees dans le dossier prive de l'application (`PhotoFiles`) ; le
/// parent les enregistre avec la livraison ou, s'il est abandonne, les supprime ([photos] lui
/// appartient). Aucune permission n'est demandee : la prise passe par l'application photo du
/// telephone.
class PhotoCaptureSection extends StatefulWidget {
  const PhotoCaptureSection({
    required this.ownerUserId,
    required this.capture,
    required this.files,
    required this.photos,
    required this.onChanged,
    required this.maxPhotos,
    required this.maxBytes,
    this.alreadyTaken = 0,
    this.now,
    super.key,
  });

  final String ownerUserId;
  final PhotoCapture capture;
  final PhotoFiles files;

  /// Photos prises dans ce formulaire et pas encore enregistrees.
  final List<CapturedPhoto> photos;
  final ValueChanged<List<CapturedPhoto>> onChanged;
  final int maxPhotos;
  final int maxBytes;

  /// Photos deja enregistrees pour la livraison (comptent dans la limite).
  final int alreadyTaken;
  final DateTime Function()? now;

  @override
  State<PhotoCaptureSection> createState() => _PhotoCaptureSectionState();
}

class _PhotoCaptureSectionState extends State<PhotoCaptureSection> {
  bool _busy = false;

  int get _total => widget.alreadyTaken + widget.photos.length;

  Future<void> _take() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_total >= widget.maxPhotos) {
      unawaited(HapticFeedback.heavyImpact());
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.photoMax(widget.maxPhotos.toString()))),
      );
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    try {
      while (mounted) {
        final File? taken;
        try {
          taken = await widget.capture.takePhoto();
        } on Object {
          // Aucun appareil photo, ou refus du systeme : la saisie continue sans photo.
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.photoErrorNoCamera)),
            );
          }
          return;
        }
        if (taken == null || !mounted) return;
        final CapturedPhoto photo;
        try {
          photo = await widget.files.importCaptured(
            source: taken,
            ownerUserId: widget.ownerUserId,
            clientId: generateClientId(),
            takenAt: (widget.now ?? DateTime.now)().toUtc(),
            maxBytes: widget.maxBytes,
          );
        } on PhotoFileException catch (error) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(switch (error.problem) {
                  PhotoFileProblem.notAnImage => l10n.photoErrorNotImage,
                  PhotoFileProblem.tooLarge => l10n.photoErrorTooLarge,
                  PhotoFileProblem.unreadable => l10n.photoErrorUnreadable,
                }),
              ),
            );
          }
          return;
        }
        if (!mounted) {
          await widget.files.delete(widget.ownerUserId, photo.relativePath);
          return;
        }
        final keep = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _PreviewDialog(photo: photo),
        );
        if (keep ?? false) {
          unawaited(HapticFeedback.mediumImpact());
          widget.onChanged([...widget.photos, photo]);
          return;
        }
        // « Reprendre » : la vignette est jetee et l'appareil photo se rouvre.
        await widget.files.delete(widget.ownerUserId, photo.relativePath);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(CapturedPhoto photo) async {
    await widget.files.delete(widget.ownerUserId, photo.relativePath);
    widget.onChanged([
      for (final other in widget.photos)
        if (other.clientId != photo.clientId) other,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final photo in widget.photos)
                  Stack(
                    key: ValueKey(photo.clientId),
                    children: [
                      PhotoThumbnail(file: photo.file),
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: IconButton.filled(
                          tooltip: l10n.actionCancel,
                          constraints: const BoxConstraints(
                            minWidth: AppSizes.minTapTarget,
                            minHeight: AppSizes.minTapTarget,
                          ),
                          onPressed: () => _remove(photo),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: _busy ? null : _take,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
          ),
          icon: const Icon(Icons.photo_camera),
          label: Text(l10n.photoAdd),
        ),
        if (_total > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.photoCountLabel(_total.toString())),
          ),
      ],
    );
  }
}

/// Apercu apres la prise : **Reprendre** ou **Garder** (CA-MAT-007.1).
class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.photo});

  final CapturedPhoto photo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      content: SizedBox(
        width: 320,
        child: Image.file(
          photo.file,
          fit: BoxFit.contain,
          // Aperçu reduit : jamais l'image pleine taille en memoire.
          cacheWidth: 800,
          errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 64),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            minimumSize: const Size(AppSizes.minTapTarget, 56),
          ),
          child: Text(l10n.photoRetake),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.photoKeep),
        ),
      ],
    );
  }
}

/// Vignette d'une photo locale (jamais en pleine taille).
class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({required this.file, super.key});

  final File file;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppSizes.radius),
    child: Image.file(
      file,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      cacheWidth: 192,
      errorBuilder: (_, _, _) => const SizedBox(
        width: 96,
        height: 96,
        child: Icon(Icons.broken_image),
      ),
    ),
  );
}

/// Photos d'une livraison dans son detail : envoyees (chargees **a la demande, avec reseau**, en
/// memoire seulement) ou en attente d'envoi (fichier local). Un role sans `DeliveryPhotos.View`
/// ne voit pas les photos envoyees (le serveur n'envoie aucune ligne `photo`).
class DeliveryPhotoGallery extends StatelessWidget {
  const DeliveryPhotoGallery({
    required this.photos,
    required this.siteId,
    required this.viewer,
    required this.files,
    required this.ownerUserId,
    required this.pendingPaths,
    required this.canView,
    super.key,
  });

  final List<DeliveryPhotoRow> photos;
  final String siteId;
  final PhotoViewer viewer;
  final PhotoFiles files;
  final String ownerUserId;

  /// Fichiers en attente d'envoi : `clientId` de la photo -> chemin relatif.
  final Map<String, String> pendingPaths;
  final bool canView;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final photo in photos)
        _GalleryItem(
          key: ValueKey(photo.id),
          photo: photo,
          siteId: siteId,
          viewer: viewer,
          files: files,
          ownerUserId: ownerUserId,
          pendingPath: pendingPaths[photo.clientId ?? photo.id],
          canView: canView,
        ),
    ],
  );
}

class _GalleryItem extends StatefulWidget {
  const _GalleryItem({
    required this.photo,
    required this.siteId,
    required this.viewer,
    required this.files,
    required this.ownerUserId,
    required this.pendingPath,
    required this.canView,
    super.key,
  });

  final DeliveryPhotoRow photo;
  final String siteId;
  final PhotoViewer viewer;
  final PhotoFiles files;
  final String ownerUserId;
  final String? pendingPath;
  final bool canView;

  @override
  State<_GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<_GalleryItem> {
  Uint8List? _bytes;
  String? _error;
  bool _loading = false;
  File? _local;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveLocal());
  }

  Future<void> _resolveLocal() async {
    final path = widget.pendingPath;
    if (path == null) return;
    final file = await widget.files.fileFor(widget.ownerUserId, path);
    if (mounted && file.existsSync()) setState(() => _local = file);
  }

  Future<void> _show() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await widget.viewer.load(
        siteId: widget.siteId,
        photoId: widget.photo.id,
      );
      if (mounted) setState(() => _bytes = bytes);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error) {
          NetworkApiException() ||
          TimeoutApiException() => l10n.photoNeedsNetwork,
          NotFoundApiException() => l10n.photoNotFound,
          _ => apiErrorMessage(l10n, error),
        },
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final local = _local;
    if (local != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhotoThumbnail(file: local),
          const SizedBox(height: 4),
          _Badge(icon: Icons.cloud_upload, text: l10n.photoPendingSend),
        ],
      );
    }
    final bytes = _bytes;
    if (bytes != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Image.memory(
              bytes,
              width: 240,
              fit: BoxFit.contain,
              cacheWidth: 720,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _bytes = null),
            child: Text(l10n.photoHide),
          ),
        ],
      );
    }
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: !widget.canView || _loading ? null : _show,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
            ),
            icon: _loading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.image),
            label: Text(l10n.photoShow),
          ),
          if (widget.photo.contentStatus == PhotoContentStatus.pending)
            _Badge(icon: Icons.cloud_upload, text: l10n.photoPendingSend),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
        ),
      ),
    ],
  );
}
