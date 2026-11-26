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
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/data/photo_capture.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/materials/domain/order_info.dart';
import 'package:chantier_mobile/features/materials/domain/product_search.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/photo_widgets.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_labels.dart';
import 'package:chantier_mobile/features/zones/presentation/widgets/option_chips.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Parametres de navigation (`extra` de la route) : correction d'une livraison, saisie
/// preremplie (« Corriger ma saisie » depuis « A verifier »), saisie remplacee.
class DeliveryFormArgs {
  const DeliveryFormArgs({this.existing, this.initial, this.replacing});

  final DeliveryView? existing;
  final DeliveryDraft? initial;
  final OutboxRow? replacing;
}

/// « Recevoir » (US-MAT-006, 007, 011) et « Corriger la livraison » (US-MAT-012), **hors ligne**.
///
/// Cas nominal en **3 gestes** depuis l'accueil du chantier : la tuile « A recevoir », la commande,
/// « Enregistrer la livraison » (6 avec la photo du bon : prise, « Garder »). Tout est prerempli :
/// quantite = reste a livrer, unite de la commande, date du jour, produit et fournisseur de la
/// commande, « Conforme ». Le `clientId` est cree a l'ouverture, le bouton est inactif des l'appui.
///
/// * [request] : la demande recue (produit et unite imposes) ; sans elle, « Livraison sans demande »
///   (fait de chantier, enregistree « Non rattachee », CA-MAT-011) ;
/// * [existing] : correction d'une livraison (quantite, unite, date, n° de BL, conformite) ;
/// * aucun prix, aucun montant n'est saisi ni affiche (ADR 0012).
class DeliveryFormScreen extends StatefulWidget {
  const DeliveryFormScreen({
    required this.siteId,
    required this.user,
    required this.deliveries,
    required this.materials,
    required this.capture,
    required this.files,
    this.request,
    this.existing,
    this.initial,
    this.replacing,
    this.onSeeDuplicate,
    DateTime Function()? now,
    super.key,
  }) : _now = now;

  final String siteId;
  final AuthUser user;
  final DeliveriesRepository deliveries;
  final MaterialsRepository materials;
  final PhotoCapture capture;
  final PhotoFiles files;
  final RequestView? request;
  final DeliveryView? existing;
  final DeliveryDraft? initial;
  final OutboxRow? replacing;

  /// « Voir la livraison » d'un doublon de bon.
  final void Function(String deliveryId)? onSeeDuplicate;

  final DateTime Function()? _now;

  @override
  State<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  /// Cree a l'ouverture du formulaire, jamais a l'envoi (anti-doublon).
  final String _clientId = generateClientId();

  bool _loaded = false;
  bool _saving = false;
  bool _saved = false;

  MaterialSettings _settings = const MaterialSettings();
  List<ProductRow> _products = const [];
  ProductSearchIndex _index = ProductSearchIndex(const []);
  List<SupplierRow> _suppliers = const [];
  List<DeliveryRow> _siteDeliveries = const [];

  /// Demande de la livraison (saisie ou corrigee), avec ses saisies en attente.
  RequestView? _request;
  ProductRow? _product;
  MeasureUnit? _orderUnit;
  Quantity? _alreadyReceived;

  // Sans demande.
  bool _freeProduct = false;
  final _search = TextEditingController();
  final _freeName = TextEditingController();
  SupplierRow? _supplier;
  bool _freeSupplier = false;
  final _freeSupplierName = TextEditingController();

  final _quantity = TextEditingController();
  final _note = TextEditingController();
  final _reserveNote = TextEditingController();
  MeasureUnit? _unit;
  late DateTime _date;
  Conformity _conformity = Conformity.conform;
  String? _reserveCode;
  List<CapturedPhoto> _photos = const [];

  DateTime get _today =>
      AlgeriaDate.today((widget._now ?? DateTime.now)().toUtc());

  bool get _isEdit => widget.existing != null;

  bool get _hasRequest => _request != null;

  @override
  void initState() {
    super.initState();
    _date = _today;
    unawaited(_load());
  }

  @override
  void dispose() {
    // Formulaire abandonne : les photos prises mais pas enregistrees sont supprimees du disque.
    if (!_saved) {
      for (final photo in _photos) {
        unawaited(widget.files.delete(widget.user.id, photo.relativePath));
      }
    }
    _search.dispose();
    _freeName.dispose();
    _freeSupplierName.dispose();
    _quantity.dispose();
    _note.dispose();
    _reserveNote.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final materials = widget.materials;
    final settings = await materials.settings();
    final products = await materials.watchProducts().first;
    final suppliers = await materials.watchSuppliers().first;
    final siteDeliveries = await widget.deliveries.deliveriesOf(widget.siteId);

    var request = widget.request;
    final existing = widget.existing;
    if (request == null && existing?.row.requestId != null) {
      request = await materials
          .watchRequest(existing!.row.requestId!, widget.user.id)
          .first;
    }
    if (request == null && widget.initial?.request != null) {
      final ref = widget.initial!.request!;
      var id = ref.requestId;
      final clientId = ref.requestClientId;
      if (id == null && clientId != null) {
        id = (await materials.findRequestByClientId(
          widget.siteId,
          clientId,
        ))?.id;
      }
      if (id != null) {
        request = await materials.watchRequest(id, widget.user.id).first;
      }
    }
    final productId = request?.row.productId ?? existing?.row.productId;
    final product = productId == null
        ? null
        : await materials.getProduct(productId);
    if (!mounted) return;

    final row = request?.row;
    final ordered = row?.quantity;
    Quantity? received;
    if (row != null && ordered != null) {
      var value = row.receivedValue ?? Decimal.zero;
      // Correction : la livraison corrigee ne compte pas deux fois dans « deja recu ».
      final own = existing?.row.quantityInRequest;
      if (own != null && !(existing?.row.isCancelled ?? false)) {
        value = value - own.value;
        if (value < Decimal.zero) value = Decimal.zero;
      }
      received = Quantity(value, ordered.unit);
    }

    setState(() {
      _settings = settings;
      _products = products;
      _index = ProductSearchIndex([
        for (final p in products)
          SearchableProduct(id: p.id, nameFr: p.nameFr, nameAr: p.nameAr),
      ]);
      _suppliers = suppliers;
      _siteDeliveries = siteDeliveries;
      _request = request;
      _product = product;
      _orderUnit = ordered?.unit;
      _alreadyReceived = received;
      _prefill(existing, row);
      _loaded = true;
    });
  }

  /// Valeurs de depart : la livraison corrigee, la saisie preremplie, ou la commande
  /// (quantite = reste a livrer, unite de la commande).
  void _prefill(DeliveryView? existing, MaterialRequestRow? request) {
    final initial = widget.initial;
    if (existing != null) {
      final row = existing.row;
      _quantity.text = row.quantityValue.toString();
      _unit = MeasureUnit.tryParse(row.quantityUnit);
      _date = row.deliveryDate;
      _note.text = row.deliveryNoteNumber ?? '';
      _conformity = row.conformityValue ?? Conformity.conform;
      _reserveCode = row.reserveReasonCode;
      _reserveNote.text = row.reserveNote ?? '';
      // « Refaire ma modification » : mes valeurs passent avant celles du serveur.
      if (initial != null) {
        _quantity.text = initial.quantity.value.toString();
        _unit = initial.quantity.unit;
        _date = initial.deliveryDate;
        _note.text = initial.deliveryNoteNumber ?? '';
        _conformity = initial.conformity;
        _reserveCode = initial.reserveReasonCode;
        _reserveNote.text = initial.reserveNote ?? '';
      }
      return;
    }
    if (initial != null) {
      _quantity.text = initial.quantity.value.toString();
      _unit = initial.quantity.unit;
      _date = initial.deliveryDate;
      _note.text = initial.deliveryNoteNumber ?? '';
      _conformity = initial.conformity;
      _reserveCode = initial.reserveReasonCode;
      _reserveNote.text = initial.reserveNote ?? '';
      _supplier = initial.supplierId == null
          ? null
          : _suppliers.where((s) => s.id == initial.supplierId).firstOrNull;
      if (initial.freeSupplierName != null) {
        _freeSupplier = true;
        _freeSupplierName.text = initial.freeSupplierName!;
      }
      if (initial.request == null) {
        _product = initial.productId == null
            ? null
            : _products.where((p) => p.id == initial.productId).firstOrNull;
        if (initial.freeProductName != null) {
          _freeProduct = true;
          _freeName.text = initial.freeProductName!;
        }
      }
      return;
    }
    if (request != null) {
      final ordered = request.quantity;
      final remaining = request.remainingQuantity;
      _unit = ordered?.unit;
      if (remaining != null && remaining.value > Decimal.zero) {
        _quantity.text = remaining.value.toString();
      } else if (ordered != null && request.receivedValue == null) {
        _quantity.text = ordered.value.toString();
      }
    }
  }

  // --- Calculs de la saisie ----------------------------------------------------------------------

  ({Quantity? quantity, String? error}) get _checked =>
      RequestFormRules.checkQuantity(_quantity.text, _unit);

  List<MeasureUnit> get _units {
    final orderUnit = _orderUnit;
    if (orderUnit != null) {
      return DeliveryFormRules.unitsFor(orderUnit, _product);
    }
    return RequestFormRules.unitsFor(_product);
  }

  bool get _hasProduct =>
      _hasRequest ||
      _isEdit ||
      (_freeProduct
          ? RequestFormRules.isFreeNameValid(_freeName.text)
          : _product != null);

  bool get _hasSupplier =>
      _hasRequest ||
      _isEdit ||
      (_freeSupplier
          ? RequestFormRules.isFreeNameValid(_freeSupplierName.text)
          : _supplier != null);

  bool get _reserveOk =>
      _conformity == Conformity.conform ||
      (_reserveCode != null &&
          (_reserveCode != 'Other' || _reserveNote.text.trim().isNotEmpty));

  bool get _canSubmit =>
      !_saving &&
      _hasProduct &&
      _hasSupplier &&
      _unit != null &&
      _checked.quantity != null &&
      _reserveOk;

  DeliveryAnnouncement? get _announcement {
    final request = _request;
    final quantity = _checked.quantity;
    final ordered = request?.row.quantity;
    if (request == null || quantity == null || ordered == null) return null;
    return DeliveryFormRules.announce(
      ordered: ordered,
      alreadyReceived: [?_alreadyReceived],
      receiving: quantity,
      bagMassKg: _product?.bagMassKg,
      tolerancePercent: _settings.toleranceOrZero,
      isSettled: request.row.isSettled,
    );
  }

  Quantity? _quantityInRequest(Quantity quantity) {
    final ordered = _orderUnit;
    if (ordered == null) return null;
    return DeliveryFormRules.equivalenceInOrderUnit(
          quantity,
          ordered,
          _product,
        ) ??
        (quantity.unit == ordered ? quantity : null);
  }

  DeliveryDraft? _draft() {
    final quantity = _checked.quantity;
    if (quantity == null) return null;
    final request = _request;
    final order = request?.row.order;
    final freeSupplier = _freeSupplier
        ? _freeSupplierName.text.trim()
        : (_hasRequest && order?.supplierId == null
              ? order?.supplierName
              : null);
    return DeliveryDraft(
      request: request == null ? null : RequestRef.of(request.stored),
      supplierId: _hasRequest ? order?.supplierId : _supplier?.id,
      freeSupplierName: freeSupplier,
      productId: _hasRequest ? null : (_freeProduct ? null : _product?.id),
      freeProductName: _hasRequest || !_freeProduct
          ? null
          : _freeName.text.trim(),
      quantity: quantity,
      deliveryDate: _date,
      deliveryNoteNumber: DeliveryFormRules.normalizeNoteNumber(_note.text),
      conformity: _conformity,
      reserveReasonCode: _conformity == Conformity.withReserve
          ? _reserveCode
          : null,
      reserveNote: _conformity == Conformity.withReserve
          ? (_reserveNote.text.trim().isEmpty ? null : _reserveNote.text.trim())
          : null,
    );
  }

  // --- Enregistrement ---------------------------------------------------------------------------------

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

  String _label(AppLocalizations l10n, DeliveryDraft draft) {
    final request = _request?.row;
    final name =
        request?.productName ??
        request?.freeProductName ??
        _product?.nameFr ??
        draft.freeProductName ??
        widget.existing?.row.productName ??
        '';
    return [
      if (widget.existing?.row.number != null) widget.existing!.row.number!,
      name,
      formatQuantity(l10n, draft.quantity),
    ].join(' · ');
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final l10n = AppLocalizations.of(context);
    final draft = _draft();
    if (draft == null) return;

    // Meme n° de bon, meme fournisseur, meme produit : avertissement, jamais un blocage.
    if (draft.deliveryNoteNumber != null) {
      final productKey =
          _request?.row.productId ??
          widget.existing?.row.productId ??
          draft.productId ??
          draft.freeProductName?.trim().toLowerCase();
      final supplierKey =
          draft.supplierId ??
          draft.freeSupplierName?.trim().toLowerCase() ??
          widget.existing?.row.supplierId;
      final duplicate = DeliveryFormRules.findDuplicateNote(
        _siteDeliveries,
        noteNumber: draft.deliveryNoteNumber,
        supplierKey: supplierKey,
        productKey: productKey,
        ignoringId: widget.existing?.row.id ?? widget.replacing?.clientId,
      );
      if (duplicate != null) {
        final goOn = await _confirm(
          message: l10n.deliveryDuplicateNote(
            Formatters.isolateLtr(
              duplicate.number ?? l10n.materialNumberPending,
            ),
          ),
          confirm: l10n.deliveryDuplicateOther,
          cancel: l10n.deliveryDuplicateSee,
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
    final quantityInRequest = _quantityInRequest(draft.quantity);
    final DeliverySaveResult result;
    if (_isEdit) {
      result = await widget.deliveries.edit(
        view: widget.existing!,
        draft: DeliveryEditDraft(
          quantity: draft.quantity,
          deliveryDate: draft.deliveryDate,
          deliveryNoteNumber: draft.deliveryNoteNumber,
          conformity: draft.conformity,
          reserveReasonCode: draft.reserveReasonCode,
          reserveNote: draft.reserveNote,
        ),
        userId: widget.user.id,
        clientId: _clientId,
        label: _label(l10n, draft),
        quantityInRequest: quantityInRequest,
        replacing: widget.replacing,
      );
    } else {
      result = await widget.deliveries.record(
        clientId: _clientId,
        siteId: widget.siteId,
        userId: widget.user.id,
        recorderName: widget.user.fullName,
        draft: draft,
        label: _label(l10n, draft),
        photoLabel: l10n.pendingEntityPhoto,
        maxPhotos: _settings.maxPhotosPerDelivery,
        request: _request?.stored,
        product: _product,
        supplier: _supplier,
        quantityInRequest: quantityInRequest,
        photos: _photos,
        replacing: widget.replacing,
      );
    }
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case DeliverySaved():
        _saved = true;
        unawaited(HapticFeedback.mediumImpact());
        messenger.showSnackBar(SnackBar(content: Text(l10n.deliverySaved)));
        final complete =
            _announcement?.outcome == DeliveryOutcome.complete ||
            _announcement?.outcome == DeliveryOutcome.surplus;
        final request = _request;
        // « DEM-014 est livree. Receptionner maintenant ? » (CA-MAT-006.13).
        if (!_isEdit &&
            complete &&
            request != null &&
            widget.user.canReceiveRequests) {
          await _offerReception(request);
          if (!mounted) return;
        }
        Navigator.of(context).pop(true);
      case DeliveryAlreadySaved():
        _saved = true;
        Navigator.of(context).pop(true);
      case DeliveryUnchanged():
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.requestEditNothing)),
        );
        Navigator.of(context).pop(false);
      case DeliveryBusy():
        unawaited(HapticFeedback.heavyImpact());
        messenger.showSnackBar(SnackBar(content: Text(l10n.requestEditBusy)));
        setState(() => _saving = false);
      case DeliveryTooManyPhotos():
        unawaited(HapticFeedback.heavyImpact());
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.photoMax(_settings.maxPhotosPerDelivery.toString()),
            ),
          ),
        );
        setState(() => _saving = false);
    }
  }

  /// Livraison complete : propose de receptionner tout de suite (1 geste). La demande est relue
  /// avec la livraison qui vient d'etre saisie : si elle est « Livree » (a confirmer), l'offre
  /// est faite ; « Plus tard » ne change rien.
  Future<void> _offerReception(RequestView request) async {
    final l10n = AppLocalizations.of(context);
    final fresh = await widget.materials
        .watchRequest(request.id, widget.user.id)
        .first;
    if (!mounted ||
        fresh == null ||
        fresh.row.statusValue != RequestStatus.delivered) {
      return;
    }
    final number = fresh.row.number;
    final yes = await _confirm(
      message: l10n.receiveNowPrompt(
        Formatters.isolateLtr(number ?? l10n.materialNumberPending),
      ),
      confirm: l10n.receiveNowYes,
      cancel: l10n.receiveNowLater,
    );
    if (!yes || !mounted) return;
    await widget.materials.receive(
      view: fresh,
      userId: widget.user.id,
      clientId: generateClientId(),
      label: requestOperationLabel(l10n, fresh.row),
    );
    unawaited(HapticFeedback.mediumImpact());
  }

  // --- Dates ------------------------------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime.utc(today.year - 1, today.month, today.day),
      // Jamais dans le futur (CA-MAT-006.5).
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() => _date = DateTime.utc(picked.year, picked.month, picked.day));
  }

  // --- Affichage ---------------------------------------------------------------------------------------------

  String _productName(ProductRow product) {
    final arabic = product.nameAr;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic && arabic != null && arabic.isNotEmpty
        ? arabic
        : product.nameFr;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isEdit
        ? l10n.deliveryEditTitle
        : _hasRequest
        ? l10n.deliveryNewTitle
        : l10n.deliveryNoRequestTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                          _header(l10n),
                          if (!_hasRequest && !_isEdit)
                            _section(
                              l10n.requestFormProduct,
                              _productSection(l10n),
                            ),
                          if (!_hasRequest && !_isEdit)
                            _section(
                              l10n.deliveryFormSupplier,
                              _supplierSection(l10n),
                            ),
                          if (_hasProduct) ...[
                            _section(
                              l10n.deliveryFormQuantity,
                              _quantitySection(l10n),
                            ),
                            _section(l10n.deliveryFormDate, _dateSection(l10n)),
                            _section(
                              l10n.deliveryFormNote,
                              TextField(
                                controller: _note,
                                maxLength:
                                    DeliveryFormRules.noteNumberMaxLength,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            _section(
                              l10n.deliveryFormConformity,
                              _conformitySection(l10n),
                            ),
                            if (!_isEdit && widget.user.canAddDeliveryPhotos)
                              _section(
                                l10n.deliveryFormPhotos,
                                PhotoCaptureSection(
                                  ownerUserId: widget.user.id,
                                  capture: widget.capture,
                                  files: widget.files,
                                  photos: _photos,
                                  maxPhotos: _settings.maxPhotosPerDelivery,
                                  maxBytes: _settings.maxPhotoBytes,
                                  now: widget._now,
                                  onChanged: (photos) =>
                                      setState(() => _photos = photos),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    child: FilledButton(
                      onPressed: _canSubmit ? _submit : null,
                      child: Text(
                        _isEdit ? l10n.requestEditSave : l10n.deliveryFormSave,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Demande, materiau et fournisseur de la commande (lecture seule : imposes par la demande).
  Widget _header(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final request = _request?.row;
    final existing = widget.existing?.row;
    if (request == null && existing == null) return const SizedBox.shrink();
    final name = request != null
        ? requestProductName(request, languageCode)
        : (existing!.productName ?? existing.freeProductName ?? '—');
    final supplier =
        request?.order?.supplierName ??
        existing?.supplierName ??
        existing?.freeSupplierName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request?.number != null)
            LtrText(request!.number!, style: theme.textTheme.titleMedium),
          Text(Formatters.isolateName(name), style: theme.textTheme.titleLarge),
          if (supplier != null)
            Text(
              Formatters.isolateName(supplier),
              style: theme.textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }

  Widget _productSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
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
            onPressed: () => setState(() {
              _product = null;
              _unit = null;
            }),
            child: Text(l10n.pendingCorrect),
          ),
        ],
      );
    }
    if (_freeProduct) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _freeName,
            maxLength: RequestFormRules.freeNameMaxLength,
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
            onPressed: () => setState(() => _freeProduct = false),
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
                onSelected: () => setState(() {
                  _product = _products.firstWhere((p) => p.id == found.id);
                  _unit = _product!.defaultMeasureUnit;
                }),
                child: (style) => Text(
                  _productName(_products.firstWhere((p) => p.id == found.id)),
                  style: style,
                ),
              ),
            OptionChip(
              selected: false,
              onSelected: () => setState(() => _freeProduct = true),
              child: (style) =>
                  Text(l10n.requestFormOtherProduct, style: style),
            ),
          ],
        ),
      ],
    );
  }

  Widget _supplierSection(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final supplier in _suppliers)
            OptionChip(
              selected: !_freeSupplier && _supplier?.id == supplier.id,
              onSelected: () => setState(() {
                _supplier = supplier;
                _freeSupplier = false;
              }),
              child: (style) =>
                  Text(Formatters.isolateName(supplier.name), style: style),
            ),
          OptionChip(
            selected: _freeSupplier,
            onSelected: () => setState(() {
              _freeSupplier = true;
              _supplier = null;
            }),
            child: (style) =>
                Text(l10n.deliveryFormOtherSupplier, style: style),
          ),
        ],
      ),
      if (_freeSupplier)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(
            controller: _freeSupplierName,
            maxLength: RequestFormRules.freeNameMaxLength,
            decoration: InputDecoration(
              labelText: l10n.deliveryFormSupplierName,
              errorText:
                  _freeSupplierName.text.isNotEmpty &&
                      !RequestFormRules.isFreeNameValid(_freeSupplierName.text)
                  ? l10n.deliveryFormSupplierInvalid
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
    ],
  );

  Widget _quantitySection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final checked = _checked;
    final error = checked.error == null
        ? null
        : errorMessageForCode(l10n, checked.error);
    final equivalence = checked.quantity == null
        ? null
        : (_orderUnit != null
              ? DeliveryFormRules.equivalenceInOrderUnit(
                  checked.quantity!,
                  _orderUnit!,
                  _product,
                )
              : RequestFormRules.equivalence(checked.quantity, _product));
    final announcement = _announcement;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _quantity,
          // Clavier numerique decimal ; des lettres sont impossibles a saisir.
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          textDirection: TextDirection.ltr,
          style: theme.textTheme.headlineSmall,
          decoration: InputDecoration(
            labelText: l10n.deliveryFormQuantity,
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
        // Unite en pastilles, jamais en texte libre ; obligatoire. Avec une commande : l'unite de
        // la commande et ses unites convertibles seulement (jamais m3 <-> T).
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final unit in _units)
              OptionChip(
                selected: _unit == unit,
                onSelected: () => setState(() => _unit = unit),
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
              style: TextStyle(color: theme.colorScheme.error),
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
        if (announcement != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _announcementLine(l10n, announcement),
          ),
      ],
    );
  }

  /// « Livraison partielle : il restera 100 sacs » · « Livraison complete » · « Surplus de +20
  /// sacs (+5,00 %) » : en toutes lettres, icone **et** texte (CA-MAT-006.3).
  Widget _announcementLine(
    AppLocalizations l10n,
    DeliveryAnnouncement announcement,
  ) {
    final (icon, color, text) = switch (announcement.outcome) {
      DeliveryOutcome.partial => (
        Icons.hourglass_bottom,
        AppColors.warning,
        l10n.deliveryAnnouncePartial(
          Formatters.isolateLtr(formatQuantity(l10n, announcement.amount)),
        ),
      ),
      DeliveryOutcome.complete => (
        Icons.check_circle,
        AppColors.success,
        l10n.deliveryAnnounceComplete,
      ),
      DeliveryOutcome.surplus => (
        Icons.add_circle,
        AppColors.warning,
        l10n.deliveryAnnounceSurplus(
          Formatters.isolateLtr(formatQuantity(l10n, announcement.amount)),
          Formatters.isolateLtr(
            Formatters.decimal(announcement.percent?.toString() ?? '0'),
          ),
        ),
      ),
    };
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _dateSection(AppLocalizations l10n) {
    final today = _today;
    final yesterday = DateTime.utc(today.year, today.month, today.day - 1);
    final custom = _date != today && _date != yesterday;
    final requestDay = _request == null
        ? null
        : AlgeriaDate.today(_request!.row.createdAt.toUtc());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OptionChip(
              selected: _date == today,
              onSelected: () => setState(() => _date = today),
              child: (style) => Text(l10n.deliveryFormToday, style: style),
            ),
            OptionChip(
              selected: _date == yesterday,
              onSelected: () => setState(() => _date = yesterday),
              child: (style) => Text(l10n.deliveryFormYesterday, style: style),
            ),
            OptionChip(
              selected: custom,
              onSelected: _pickDate,
              child: (style) => Text(l10n.deliveryFormOtherDate, style: style),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Date complete affichee : jamais de texte libre pour une date.
        LtrText(
          Formatters.date(_date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (requestDay != null &&
            DeliveryFormRules.isBeforeRequest(_date, requestDay))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.deliveryFormBeforeRequest,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
      ],
    );
  }

  Widget _conformitySection(AppLocalizations l10n) {
    final reasons = _settings.reasons['reserve'] ?? const ['Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in Conformity.values)
              OptionChip(
                selected: _conformity == value,
                onSelected: () => setState(() => _conformity = value),
                child: (style) =>
                    Text(conformityLabel(l10n, value.code), style: style),
              ),
          ],
        ),
        if (_conformity == Conformity.withReserve) ...[
          const SizedBox(height: 12),
          Text(
            l10n.deliveryFormReserveReason,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final code in reasons)
                OptionChip(
                  selected: _reserveCode == code,
                  onSelected: () => setState(() => _reserveCode = code),
                  child: (style) => Text(reasonLabel(l10n, code), style: style),
                ),
            ],
          ),
          if (_reserveCode == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _reserveNote,
                maxLength: _settings.noteMaxLength,
                decoration: InputDecoration(
                  labelText: l10n.deliveryFormReserveNote,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          if (_reserveCode == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.deliveryFormReserveRequired,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ],
    );
  }
}
