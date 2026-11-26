import 'dart:async';

import 'package:chantier_mobile/core/l10n/error_messages.dart';
import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/core/theme/app_colors.dart';
import 'package:chantier_mobile/core/theme/app_sizes.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/materials/domain/product_search.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/features/zones/presentation/zone_picker.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Parametres de navigation du formulaire (`extra` de la route) : correction d'une demande,
/// valeurs preremplies, saisie remplacee.
class RequestFormArgs {
  const RequestFormArgs({this.existing, this.initial, this.replacing});

  final RequestView? existing;
  final RequestDraft? initial;
  final OutboxRow? replacing;
}

/// « Nouvelle demande » (US-MAT-001) et « Corriger la demande » (US-MAT-004), **hors ligne**.
///
/// Cas nominal en 4 gestes : toucher le materiau, taper la quantite, (unite, zone, date et
/// urgence sont preselectionnees), « Envoyer ». Tout se lit dans la base locale : catalogue,
/// reglages, derniere zone. Le `clientId` est cree a l'ouverture du formulaire ; le bouton est
/// inactif des l'appui (anti-doublon).
///
/// * [existing] : correction d'une demande (le materiau ne se corrige pas) ;
/// * [initial] : valeurs preremplies (« Creer une nouvelle demande avec mes valeurs ») ;
/// * [replacing] : la saisie refusee ou en conflit que cette saisie remplace.
class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({
    required this.siteId,
    required this.user,
    required this.repository,
    required this.zonesRepository,
    this.existing,
    this.initial,
    this.replacing,
    this.onSeeDuplicate,
    DateTime Function()? now,
    super.key,
  }) : _now = now;

  final String siteId;
  final AuthUser user;
  final MaterialsRepository repository;
  final ZonesRepository zonesRepository;
  final RequestView? existing;
  final RequestDraft? initial;
  final OutboxRow? replacing;

  /// « Voir la demande » d'un doublon possible : ouvre son detail.
  final void Function(String requestId)? onSeeDuplicate;
  final DateTime Function()? _now;

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  /// Cree a l'ouverture du formulaire, jamais a l'envoi ; renouvele apres « ajouter un autre ».
  String _clientId = generateClientId();

  bool _loaded = false;
  bool _saving = false;
  bool _pastConfirmed = false;

  List<ProductRow> _products = const [];
  ProductSearchIndex _index = ProductSearchIndex(const []);
  List<ProductRow> _top = const [];
  List<ZoneRow> _zones = const [];
  List<ZoneRow> _recentZones = const [];
  List<MaterialRequestRow> _siteRequests = const [];
  MaterialSettings _settings = const MaterialSettings();

  ProductRow? _product;
  bool _free = false;
  final _search = TextEditingController();
  final _freeName = TextEditingController();
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  final _quantityFocus = FocusNode();

  MeasureUnit? _unit;
  String? _zoneId;
  bool _zoneIsPending = false;
  late DateTime _neededBy;
  RequestPriority _priority = RequestPriority.normal;

  DateTime get _today =>
      AlgeriaDate.today((widget._now ?? DateTime.now)().toUtc());

  bool get _isEdit => widget.existing != null;

  /// Produit, quantite, unite et zone figes apres la validation (`DEMANDE_VERROUILLEE`).
  bool get _lockedFields =>
      _isEdit && !widget.user.canEditLockedFields(widget.existing!.row);

  @override
  void initState() {
    super.initState();
    _neededBy = _today;
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    _freeName.dispose();
    _quantity.dispose();
    _note.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repository = widget.repository;
    final products = await repository.watchProducts().first;
    final settings = await repository.settings();
    final top = await repository.topProducts(widget.siteId);
    final requests = await repository.requestsOf(widget.siteId);
    final zones = await widget.zonesRepository.watchZones(widget.siteId).first;
    final last = await widget.zonesRepository.lastUsedZone(widget.user.id);
    if (!mounted) return;

    final recentIds = <String>[];
    final byCreation = [...requests]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final request in byCreation) {
      final zoneId = request.zoneId;
      if (zoneId != null && !recentIds.contains(zoneId)) recentIds.add(zoneId);
    }
    final lastInSite = last != null && last.siteId == widget.siteId
        ? last
        : null;
    final recent = <ZoneRow>[
      ?lastInSite,
      for (final id in recentIds)
        for (final zone in zones)
          if (zone.id == id && zone.id != lastInSite?.id) zone,
    ].take(3).toList();

    setState(() {
      _products = products;
      _index = ProductSearchIndex([
        for (final product in products)
          SearchableProduct(
            id: product.id,
            nameFr: product.nameFr,
            nameAr: product.nameAr,
          ),
      ]);
      _top = top;
      _zones = zones;
      _recentZones = recent;
      _siteRequests = requests;
      _settings = settings;
      _neededBy = AlgeriaDate.defaultNeededBy(
        _today,
        settings.defaultNeededByDays,
      );
      _zoneId = lastInSite?.id;
      _zoneIsPending = lastInSite?.isPending ?? false;
      _applyPrefill(products);
      _loaded = true;
    });
  }

  /// Valeurs de depart : la demande corrigee, ou la saisie preremplie.
  void _applyPrefill(List<ProductRow> products) {
    final existing = widget.existing?.row;
    final initial = widget.initial;
    if (existing != null) {
      _product = _productById(products, existing.productId);
      _free = existing.productId == null || _product == null;
      _freeName.text = existing.freeProductName ?? existing.productName ?? '';
      _quantity.text = _plain(existing.quantityValue.toString());
      _unit = MeasureUnit.tryParse(existing.quantityUnit);
      _zoneId = existing.zoneId;
      _zoneIsPending = _zones.any((z) => z.id == _zoneId && z.isPending);
      _neededBy = existing.neededBy;
      _priority = existing.priorityValue ?? RequestPriority.normal;
      _note.text = existing.note ?? '';
    }
    if (initial != null) {
      _product = _productById(products, initial.productId);
      _free = initial.freeProductName != null;
      _freeName.text = initial.freeProductName ?? '';
      _quantity.text = _plain(initial.quantity.value.toString());
      _unit = initial.quantity.unit;
      _zoneId = initial.zoneId;
      _zoneIsPending = initial.zoneIsPending;
      _neededBy = initial.neededBy;
      _priority = initial.priority;
      _note.text = initial.note ?? '';
    }
  }

  static ProductRow? _productById(List<ProductRow> products, String? id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  static String _plain(String decimal) => decimal.replaceAll('.', ',');

  // --- Choix du materiau -------------------------------------------------------------------------

  void _chooseProduct(ProductRow product) {
    setState(() {
      _product = product;
      _free = false;
      _search.clear();
      _unit = product.defaultMeasureUnit;
    });
    // Le clavier numerique s'ouvre tout de suite : un geste de moins.
    _quantityFocus.requestFocus();
  }

  void _chooseFree() {
    setState(() {
      _product = null;
      _free = true;
      _unit = null;
    });
  }

  void _clearProduct() => setState(() {
    _product = null;
    _free = false;
    _unit = null;
  });

  // --- Calculs de la saisie ---------------------------------------------------------------------------

  ({Quantity? quantity, String? error}) get _checked =>
      RequestFormRules.checkQuantity(_quantity.text, _unit);

  bool get _hasProduct => _free
      ? RequestFormRules.isFreeNameValid(_freeName.text)
      : _product != null;

  bool get _canSubmit =>
      !_saving && _hasProduct && _unit != null && _checked.quantity != null;

  RequestDraft? _draft() {
    final quantity = _checked.quantity;
    if (quantity == null || !_hasProduct) return null;
    return RequestDraft(
      productId: _free ? null : _product?.id,
      freeProductName: _free ? _freeName.text.trim() : null,
      quantity: quantity,
      zoneId: _zoneId,
      zoneIsPending: _zoneIsPending,
      neededBy: _neededBy,
      priority: _priority,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
  }

  // --- Envoi --------------------------------------------------------------------------------------------

  Future<void> _submit({bool another = false}) async {
    if (!_canSubmit) return;
    final l10n = AppLocalizations.of(context);
    final draft = _draft();
    if (draft == null) return;

    // Date passee : avertissement, jamais un blocage.
    if (!_pastConfirmed && RequestFormRules.isPast(_neededBy, _today)) {
      final send = await _confirm(
        message: l10n.requestFormPastDate,
        confirm: l10n.requestFormSendAnyway,
        cancel: l10n.requestFormOtherDate,
      );
      if (!send || !mounted) return;
      _pastConfirmed = true;
    }

    // Doublon possible (meme materiau, meme zone, demande ouverte) : jamais bloquant.
    if (!_isEdit && draft.productId != null) {
      final duplicate = findPossibleDuplicate(
        _siteRequests,
        productId: draft.productId,
        zoneId: draft.zoneId,
        // La saisie que celle-ci remplace n'est pas un doublon d'elle-meme.
        ignoringId: widget.replacing?.clientId,
      );
      if (duplicate != null) {
        final number = duplicate.number;
        final goOn = await _confirm(
          message: l10n.requestFormDuplicate(
            Formatters.isolateLtr(number ?? l10n.materialNumberPending),
          ),
          confirm: l10n.requestFormOtherRequest,
          cancel: l10n.requestFormSeeDuplicate,
        );
        if (!mounted) return;
        if (!goOn) {
          widget.onSeeDuplicate?.call(duplicate.id);
          return;
        }
      }
    }

    // Bouton inactif des l'appui : un second appui ne part pas.
    setState(() => _saving = true);
    final result = _isEdit
        ? await widget.repository.editRequest(
            view: widget.existing!,
            draft: draft,
            userId: widget.user.id,
            clientId: _clientId,
            label: _label(l10n, draft),
            replacing: widget.replacing,
          )
        : await widget.repository.createRequest(
            clientId: _clientId,
            siteId: widget.siteId,
            userId: widget.user.id,
            requesterName: widget.user.fullName,
            draft: draft,
            label: _label(l10n, draft),
            product: _product,
            replacing: widget.replacing,
          );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case RequestSaved():
        unawaited(HapticFeedback.mediumImpact());
        messenger.showSnackBar(SnackBar(content: Text(l10n.requestSaved)));
        if (another && !_isEdit) {
          unawaited(_resetForAnother());
        } else {
          Navigator.of(context).pop(true);
        }
      case RequestAlreadySaved():
        Navigator.of(context).pop(true);
      case RequestUnchanged():
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.requestEditNothing)),
        );
        Navigator.of(context).pop(false);
      case RequestBusy():
        unawaited(HapticFeedback.heavyImpact());
        messenger.showSnackBar(SnackBar(content: Text(l10n.requestEditBusy)));
        setState(() => _saving = false);
    }
  }

  String _label(AppLocalizations l10n, RequestDraft draft) {
    final name =
        draft.freeProductName ??
        _product?.nameFr ??
        widget.existing?.row.productName ??
        '';
    return [name, formatQuantity(l10n, draft.quantity)].join(' · ');
  }

  /// « Ajouter un autre materiau » : nouveau `clientId`, zone et date gardees (CA-MAT-001.12).
  Future<void> _resetForAnother() async {
    final all = await widget.repository.requestsOf(widget.siteId);
    if (!mounted) return;
    setState(() {
      _clientId = generateClientId();
      _saving = false;
      _product = null;
      _free = false;
      _unit = null;
      _quantity.clear();
      _freeName.clear();
      _search.clear();
      _note.clear();
      _priority = RequestPriority.normal;
      // La demande qui vient d'etre saisie compte pour le controle de doublon suivant.
      _siteRequests = all;
    });
  }

  Future<bool> _confirm({
    required String message,
    required String confirm,
    required String cancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // --- Dates et zones -----------------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _neededBy.isBefore(today) ? today : _neededBy,
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: DateTime.utc(today.year + 2, today.month, today.day),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _neededBy = DateTime.utc(picked.year, picked.month, picked.day);
      _pastConfirmed = false;
    });
  }

  Future<void> _pickZone() async {
    final l10n = AppLocalizations.of(context);
    ZoneRow? chosen;
    var none = false;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          0,
          AppSizes.screenPadding,
          AppSizes.screenPadding +
              MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.zonePickerTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              ZonePicker(
                zones: [
                  for (final zone in _zones)
                    if (zone.archivedAt == null) zone,
                ],
                initial: _zoneId == null
                    ? null
                    : _zones.where((z) => z.id == _zoneId).firstOrNull,
                allowNone: true,
                onChanged: (zone) {
                  chosen = zone;
                  none = zone == null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.zonePickerConfirm),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    if (chosen == null && !none) return;
    setState(() {
      _zoneId = chosen?.id;
      _zoneIsPending = chosen?.isPending ?? false;
    });
  }

  // --- Affichage --------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.requestEditTitle : l10n.requestNew),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _section(
                            l10n.requestFormProduct,
                            _productSection(l10n),
                          ),
                          if (_hasProduct || _free) ...[
                            _section(
                              l10n.requestFormQuantity,
                              _quantitySection(l10n),
                            ),
                            _section(l10n.requestFormZone, _zoneSection(l10n)),
                            _section(
                              l10n.requestFormNeededBy,
                              _dateSection(l10n),
                            ),
                            _section(
                              l10n.requestFormPriority,
                              _prioritySection(l10n),
                            ),
                            _section(
                              l10n.requestFormNote,
                              TextField(
                                controller: _note,
                                maxLength: _settings.noteMaxLength,
                                decoration: const InputDecoration(),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: _canSubmit ? _submit : null,
                          child: Text(
                            _isEdit
                                ? l10n.requestEditSave
                                : l10n.requestFormSend,
                          ),
                        ),
                        if (!_isEdit) ...[
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _canSubmit
                                ? () => _submit(another: true)
                                : null,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(
                                AppSizes.minTapTarget,
                              ),
                            ),
                            child: Text(l10n.requestFormSendAnother),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );

  String _productName(ProductRow product) {
    final arabic = product.nameAr;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic && arabic != null && arabic.isNotEmpty
        ? arabic
        : product.nameFr;
  }

  Widget _productSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    // Correction : le materiau est affiche, il ne se change pas.
    if (_isEdit) {
      final row = widget.existing!.row;
      final name = _product == null
          ? (row.productName ?? row.freeProductName ?? '—')
          : _productName(_product!);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Formatters.isolateName(name),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.requestEditProductLocked,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    if (_product != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              Formatters.isolateName(_productName(_product!)),
              style: theme.textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: _clearProduct,
            child: Text(l10n.pendingCorrect),
          ),
        ],
      );
    }
    if (_free) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _freeName,
            maxLength: RequestFormRules.freeNameMaxLength,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.requestFormFreeName,
              errorText:
                  _freeName.text.isNotEmpty &&
                      !RequestFormRules.isFreeNameValid(_freeName.text)
                  ? l10n.requestFormFreeNameInvalid
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextButton(
            onPressed: _clearProduct,
            child: Text(l10n.pendingCorrect),
          ),
        ],
      );
    }

    final results = _search.text.trim().isEmpty
        ? const <SearchableProduct>[]
        : _index.search(_search.text, limit: 8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_top.isNotEmpty && _search.text.trim().isEmpty) ...[
          Text(
            l10n.requestFormTopProducts,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final product in _top)
                OptionChip(
                  selected: false,
                  onSelected: () => _chooseProduct(product),
                  child: (style) => Text(_productName(product), style: style),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.requestFormSearchHint,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        if (_search.text.trim().isNotEmpty && results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.requestFormNoProduct),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final found in results)
              OptionChip(
                selected: false,
                onSelected: () => _chooseProduct(
                  _products.firstWhere((p) => p.id == found.id),
                ),
                child: (style) => Text(
                  _productName(_products.firstWhere((p) => p.id == found.id)),
                  style: style,
                ),
              ),
            OptionChip(
              selected: false,
              onSelected: _chooseFree,
              child: (style) =>
                  Text(l10n.requestFormOtherProduct, style: style),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quantitySection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final checked = _checked;
    final equivalence = RequestFormRules.equivalence(
      checked.quantity,
      _product,
    );
    final error = checked.error == null
        ? null
        : errorMessageForCode(l10n, checked.error);
    final units = RequestFormRules.unitsFor(_free ? null : _product);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _quantity,
          focusNode: _quantityFocus,
          enabled: !_lockedFields,
          // Clavier numerique decimal ; des lettres sont impossibles a saisir.
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.headlineSmall,
          decoration: InputDecoration(
            labelText: l10n.requestFormQuantity,
            errorText: error,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.requestFormUnit,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // Unite en pastilles, jamais en texte libre ; obligatoire.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final unit in units)
              OptionChip(
                selected: _unit == unit,
                onSelected: () {
                  if (!_lockedFields) setState(() => _unit = unit);
                },
                child: (style) =>
                    Text(unitLabel(l10n, unit.code), style: style),
              ),
          ],
        ),
        if (_unit == null &&
            _quantity.text.trim().isNotEmpty &&
            checked.error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessageForCode(l10n, 'UNITE_OBLIGATOIRE') ?? '',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (equivalence != null && checked.quantity != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              Formatters.isolateLtr(
                '${formatQuantity(l10n, checked.quantity!)} = '
                '${formatQuantity(l10n, equivalence)}',
              ),
              style: theme.textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  Widget _zoneSection(AppLocalizations l10n) {
    final selected = _zoneId == null
        ? null
        : _zones.where((zone) => zone.id == _zoneId).firstOrNull;
    final shown = <ZoneRow>[
      ..._recentZones,
      if (selected != null && !_recentZones.any((z) => z.id == selected.id))
        selected,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final zone in shown)
          OptionChip(
            selected: _zoneId == zone.id,
            onSelected: () {
              if (_lockedFields) return;
              setState(() {
                _zoneId = zone.id;
                _zoneIsPending = zone.isPending;
              });
            },
            child: (style) =>
                Text(zoneLabelForDisplay(l10n, zone), style: style),
          ),
        OptionChip(
          selected: false,
          onSelected: _lockedFields ? () {} : _pickZone,
          child: (style) => Text(l10n.requestFormZoneOther, style: style),
        ),
        OptionChip(
          selected: _zoneId == null,
          onSelected: () {
            if (!_lockedFields) setState(() => _zoneId = null);
          },
          child: (style) => Text(l10n.zonePickerNone, style: style),
        ),
      ],
    );
  }

  Widget _dateSection(AppLocalizations l10n) {
    final today = _today;
    final days = _settings.defaultNeededByDays;
    final tomorrow = DateTime.utc(today.year, today.month, today.day + 1);
    final inDays = DateTime.utc(today.year, today.month, today.day + days);
    final choices = RequestFormRules.neededByChoices(today, days);
    String label(DateTime date) => date == tomorrow
        ? l10n.requestFormTomorrow
        : date == inDays
        ? l10n.requestFormInDays(days.toString())
        : l10n.requestFormNextWeek;
    final custom = !choices.contains(_neededBy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final date in choices)
              OptionChip(
                selected: _neededBy == date,
                onSelected: () => setState(() {
                  _neededBy = date;
                  _pastConfirmed = false;
                }),
                child: (style) => Text(label(date), style: style),
              ),
            OptionChip(
              selected: custom,
              onSelected: _pickDate,
              child: (style) => Text(l10n.requestFormOtherDate, style: style),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Date complete affichee : jamais de texte libre pour une date.
        LtrText(
          Formatters.date(_neededBy),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (RequestFormRules.isPast(_neededBy, today))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.requestFormPastDate,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
      ],
    );
  }

  Widget _prioritySection(AppLocalizations l10n) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final priority in [
        RequestPriority.normal,
        RequestPriority.urgent,
        RequestPriority.blocking,
      ])
        OptionChip(
          selected: _priority == priority,
          onSelected: () => setState(() => _priority = priority),
          child: (style) =>
              Text(priorityLabel(l10n, priority.code), style: style),
        ),
    ],
  );
}
