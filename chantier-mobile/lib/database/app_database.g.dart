// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SitesTable extends Sites with TableInfo<$SitesTable, SiteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wilayaMeta = const VerificationMeta('wilaya');
  @override
  late final GeneratedColumn<String> wilaya = GeneratedColumn<String>(
    'wilaya',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _communeMeta = const VerificationMeta(
    'commune',
  );
  @override
  late final GeneratedColumn<String> commune = GeneratedColumn<String>(
    'commune',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> latitude =
      GeneratedColumn<String>(
        'latitude',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($SitesTable.$converterlatituden);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> longitude =
      GeneratedColumn<String>(
        'longitude',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($SitesTable.$converterlongituden);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractNumberMeta = const VerificationMeta(
    'contractNumber',
  );
  @override
  late final GeneratedColumn<String> contractNumber = GeneratedColumn<String>(
    'contract_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> contractAmount =
      GeneratedColumn<String>(
        'contract_amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($SitesTable.$convertercontractAmountn);
  static const VerificationMeta _delayDaysMeta = const VerificationMeta(
    'delayDays',
  );
  @override
  late final GeneratedColumn<int> delayDays = GeneratedColumn<int>(
    'delay_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> odsDate =
      GeneratedColumn<String>(
        'ods_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SitesTable.$converterodsDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
  contractualEndDate = GeneratedColumn<String>(
    'contractual_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<DateTime?>($SitesTable.$convertercontractualEndDaten);
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByNameMeta = const VerificationMeta(
    'createdByName',
  );
  @override
  late final GeneratedColumn<String> createdByName = GeneratedColumn<String>(
    'created_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByNameMeta = const VerificationMeta(
    'updatedByName',
  );
  @override
  late final GeneratedColumn<String> updatedByName = GeneratedColumn<String>(
    'updated_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    nameAr,
    type,
    wilaya,
    commune,
    latitude,
    longitude,
    owner,
    contractNumber,
    contractAmount,
    delayDays,
    odsDate,
    contractualEndDate,
    archivedAt,
    version,
    createdAt,
    createdByName,
    updatedAt,
    updatedByName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<SiteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('wilaya')) {
      context.handle(
        _wilayaMeta,
        wilaya.isAcceptableOrUnknown(data['wilaya']!, _wilayaMeta),
      );
    } else if (isInserting) {
      context.missing(_wilayaMeta);
    }
    if (data.containsKey('commune')) {
      context.handle(
        _communeMeta,
        commune.isAcceptableOrUnknown(data['commune']!, _communeMeta),
      );
    } else if (isInserting) {
      context.missing(_communeMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('contract_number')) {
      context.handle(
        _contractNumberMeta,
        contractNumber.isAcceptableOrUnknown(
          data['contract_number']!,
          _contractNumberMeta,
        ),
      );
    }
    if (data.containsKey('delay_days')) {
      context.handle(
        _delayDaysMeta,
        delayDays.isAcceptableOrUnknown(data['delay_days']!, _delayDaysMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by_name')) {
      context.handle(
        _createdByNameMeta,
        createdByName.isAcceptableOrUnknown(
          data['created_by_name']!,
          _createdByNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByNameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by_name')) {
      context.handle(
        _updatedByNameMeta,
        updatedByName.isAcceptableOrUnknown(
          data['updated_by_name']!,
          _updatedByNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SiteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      wilaya: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wilaya'],
      )!,
      commune: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune'],
      )!,
      latitude: $SitesTable.$converterlatituden.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}latitude'],
        ),
      ),
      longitude: $SitesTable.$converterlongituden.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}longitude'],
        ),
      ),
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      contractNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_number'],
      ),
      contractAmount: $SitesTable.$convertercontractAmountn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}contract_amount'],
        ),
      ),
      delayDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delay_days'],
      ),
      odsDate: $SitesTable.$converterodsDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ods_date'],
        ),
      ),
      contractualEndDate: $SitesTable.$convertercontractualEndDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}contractual_end_date'],
        ),
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      updatedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_name'],
      ),
    );
  }

  @override
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterlatitude =
      const DecimalTextConverter(scale: 6);
  static TypeConverter<Decimal?, String?> $converterlatituden =
      NullAwareTypeConverter.wrap($converterlatitude);
  static TypeConverter<Decimal, String> $converterlongitude =
      const DecimalTextConverter(scale: 6);
  static TypeConverter<Decimal?, String?> $converterlongituden =
      NullAwareTypeConverter.wrap($converterlongitude);
  static TypeConverter<Decimal, String> $convertercontractAmount =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $convertercontractAmountn =
      NullAwareTypeConverter.wrap($convertercontractAmount);
  static TypeConverter<DateTime, String> $converterodsDate =
      const DateOnlyTextConverter();
  static TypeConverter<DateTime?, String?> $converterodsDaten =
      NullAwareTypeConverter.wrap($converterodsDate);
  static TypeConverter<DateTime, String> $convertercontractualEndDate =
      const DateOnlyTextConverter();
  static TypeConverter<DateTime?, String?> $convertercontractualEndDaten =
      NullAwareTypeConverter.wrap($convertercontractualEndDate);
}

class SiteRow extends DataClass implements Insertable<SiteRow> {
  final String id;
  final String code;
  final String name;
  final String? nameAr;

  /// `School`, `Housing`, `PublicFacility`, `Other` (chaines stables du contrat).
  final String type;
  final String wilaya;
  final String commune;
  final Decimal? latitude;
  final Decimal? longitude;
  final String owner;
  final String? contractNumber;
  final Decimal? contractAmount;
  final int? delayDays;
  final DateTime? odsDate;

  /// Calculee par le serveur (ODS + delai) ; `null` = « A definir ».
  final DateTime? contractualEndDate;
  final DateTime? archivedAt;

  /// Version serveur (`rowversion`) : comparee **numeriquement** (ADR 0009).
  final int version;
  final DateTime createdAt;
  final String createdByName;
  final DateTime? updatedAt;
  final String? updatedByName;
  const SiteRow({
    required this.id,
    required this.code,
    required this.name,
    this.nameAr,
    required this.type,
    required this.wilaya,
    required this.commune,
    this.latitude,
    this.longitude,
    required this.owner,
    this.contractNumber,
    this.contractAmount,
    this.delayDays,
    this.odsDate,
    this.contractualEndDate,
    this.archivedAt,
    required this.version,
    required this.createdAt,
    required this.createdByName,
    this.updatedAt,
    this.updatedByName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameAr != null) {
      map['name_ar'] = Variable<String>(nameAr);
    }
    map['type'] = Variable<String>(type);
    map['wilaya'] = Variable<String>(wilaya);
    map['commune'] = Variable<String>(commune);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<String>(
        $SitesTable.$converterlatituden.toSql(latitude),
      );
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<String>(
        $SitesTable.$converterlongituden.toSql(longitude),
      );
    }
    map['owner'] = Variable<String>(owner);
    if (!nullToAbsent || contractNumber != null) {
      map['contract_number'] = Variable<String>(contractNumber);
    }
    if (!nullToAbsent || contractAmount != null) {
      map['contract_amount'] = Variable<String>(
        $SitesTable.$convertercontractAmountn.toSql(contractAmount),
      );
    }
    if (!nullToAbsent || delayDays != null) {
      map['delay_days'] = Variable<int>(delayDays);
    }
    if (!nullToAbsent || odsDate != null) {
      map['ods_date'] = Variable<String>(
        $SitesTable.$converterodsDaten.toSql(odsDate),
      );
    }
    if (!nullToAbsent || contractualEndDate != null) {
      map['contractual_end_date'] = Variable<String>(
        $SitesTable.$convertercontractualEndDaten.toSql(contractualEndDate),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['created_by_name'] = Variable<String>(createdByName);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedByName != null) {
      map['updated_by_name'] = Variable<String>(updatedByName);
    }
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      nameAr: nameAr == null && nullToAbsent
          ? const Value.absent()
          : Value(nameAr),
      type: Value(type),
      wilaya: Value(wilaya),
      commune: Value(commune),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      owner: Value(owner),
      contractNumber: contractNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(contractNumber),
      contractAmount: contractAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(contractAmount),
      delayDays: delayDays == null && nullToAbsent
          ? const Value.absent()
          : Value(delayDays),
      odsDate: odsDate == null && nullToAbsent
          ? const Value.absent()
          : Value(odsDate),
      contractualEndDate: contractualEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(contractualEndDate),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      version: Value(version),
      createdAt: Value(createdAt),
      createdByName: Value(createdByName),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedByName: updatedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByName),
    );
  }

  factory SiteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      nameAr: serializer.fromJson<String?>(json['nameAr']),
      type: serializer.fromJson<String>(json['type']),
      wilaya: serializer.fromJson<String>(json['wilaya']),
      commune: serializer.fromJson<String>(json['commune']),
      latitude: serializer.fromJson<Decimal?>(json['latitude']),
      longitude: serializer.fromJson<Decimal?>(json['longitude']),
      owner: serializer.fromJson<String>(json['owner']),
      contractNumber: serializer.fromJson<String?>(json['contractNumber']),
      contractAmount: serializer.fromJson<Decimal?>(json['contractAmount']),
      delayDays: serializer.fromJson<int?>(json['delayDays']),
      odsDate: serializer.fromJson<DateTime?>(json['odsDate']),
      contractualEndDate: serializer.fromJson<DateTime?>(
        json['contractualEndDate'],
      ),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdByName: serializer.fromJson<String>(json['createdByName']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      updatedByName: serializer.fromJson<String?>(json['updatedByName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'nameAr': serializer.toJson<String?>(nameAr),
      'type': serializer.toJson<String>(type),
      'wilaya': serializer.toJson<String>(wilaya),
      'commune': serializer.toJson<String>(commune),
      'latitude': serializer.toJson<Decimal?>(latitude),
      'longitude': serializer.toJson<Decimal?>(longitude),
      'owner': serializer.toJson<String>(owner),
      'contractNumber': serializer.toJson<String?>(contractNumber),
      'contractAmount': serializer.toJson<Decimal?>(contractAmount),
      'delayDays': serializer.toJson<int?>(delayDays),
      'odsDate': serializer.toJson<DateTime?>(odsDate),
      'contractualEndDate': serializer.toJson<DateTime?>(contractualEndDate),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdByName': serializer.toJson<String>(createdByName),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'updatedByName': serializer.toJson<String?>(updatedByName),
    };
  }

  SiteRow copyWith({
    String? id,
    String? code,
    String? name,
    Value<String?> nameAr = const Value.absent(),
    String? type,
    String? wilaya,
    String? commune,
    Value<Decimal?> latitude = const Value.absent(),
    Value<Decimal?> longitude = const Value.absent(),
    String? owner,
    Value<String?> contractNumber = const Value.absent(),
    Value<Decimal?> contractAmount = const Value.absent(),
    Value<int?> delayDays = const Value.absent(),
    Value<DateTime?> odsDate = const Value.absent(),
    Value<DateTime?> contractualEndDate = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    int? version,
    DateTime? createdAt,
    String? createdByName,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> updatedByName = const Value.absent(),
  }) => SiteRow(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    nameAr: nameAr.present ? nameAr.value : this.nameAr,
    type: type ?? this.type,
    wilaya: wilaya ?? this.wilaya,
    commune: commune ?? this.commune,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    owner: owner ?? this.owner,
    contractNumber: contractNumber.present
        ? contractNumber.value
        : this.contractNumber,
    contractAmount: contractAmount.present
        ? contractAmount.value
        : this.contractAmount,
    delayDays: delayDays.present ? delayDays.value : this.delayDays,
    odsDate: odsDate.present ? odsDate.value : this.odsDate,
    contractualEndDate: contractualEndDate.present
        ? contractualEndDate.value
        : this.contractualEndDate,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    createdByName: createdByName ?? this.createdByName,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedByName: updatedByName.present
        ? updatedByName.value
        : this.updatedByName,
  );
  SiteRow copyWithCompanion(SitesCompanion data) {
    return SiteRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      type: data.type.present ? data.type.value : this.type,
      wilaya: data.wilaya.present ? data.wilaya.value : this.wilaya,
      commune: data.commune.present ? data.commune.value : this.commune,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      owner: data.owner.present ? data.owner.value : this.owner,
      contractNumber: data.contractNumber.present
          ? data.contractNumber.value
          : this.contractNumber,
      contractAmount: data.contractAmount.present
          ? data.contractAmount.value
          : this.contractAmount,
      delayDays: data.delayDays.present ? data.delayDays.value : this.delayDays,
      odsDate: data.odsDate.present ? data.odsDate.value : this.odsDate,
      contractualEndDate: data.contractualEndDate.present
          ? data.contractualEndDate.value
          : this.contractualEndDate,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdByName: data.createdByName.present
          ? data.createdByName.value
          : this.createdByName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedByName: data.updatedByName.present
          ? data.updatedByName.value
          : this.updatedByName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameAr: $nameAr, ')
          ..write('type: $type, ')
          ..write('wilaya: $wilaya, ')
          ..write('commune: $commune, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('owner: $owner, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('contractAmount: $contractAmount, ')
          ..write('delayDays: $delayDays, ')
          ..write('odsDate: $odsDate, ')
          ..write('contractualEndDate: $contractualEndDate, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdByName: $createdByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByName: $updatedByName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    code,
    name,
    nameAr,
    type,
    wilaya,
    commune,
    latitude,
    longitude,
    owner,
    contractNumber,
    contractAmount,
    delayDays,
    odsDate,
    contractualEndDate,
    archivedAt,
    version,
    createdAt,
    createdByName,
    updatedAt,
    updatedByName,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.nameAr == this.nameAr &&
          other.type == this.type &&
          other.wilaya == this.wilaya &&
          other.commune == this.commune &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.owner == this.owner &&
          other.contractNumber == this.contractNumber &&
          other.contractAmount == this.contractAmount &&
          other.delayDays == this.delayDays &&
          other.odsDate == this.odsDate &&
          other.contractualEndDate == this.contractualEndDate &&
          other.archivedAt == this.archivedAt &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.createdByName == this.createdByName &&
          other.updatedAt == this.updatedAt &&
          other.updatedByName == this.updatedByName);
}

class SitesCompanion extends UpdateCompanion<SiteRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> nameAr;
  final Value<String> type;
  final Value<String> wilaya;
  final Value<String> commune;
  final Value<Decimal?> latitude;
  final Value<Decimal?> longitude;
  final Value<String> owner;
  final Value<String?> contractNumber;
  final Value<Decimal?> contractAmount;
  final Value<int?> delayDays;
  final Value<DateTime?> odsDate;
  final Value<DateTime?> contractualEndDate;
  final Value<DateTime?> archivedAt;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<String> createdByName;
  final Value<DateTime?> updatedAt;
  final Value<String?> updatedByName;
  final Value<int> rowid;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.type = const Value.absent(),
    this.wilaya = const Value.absent(),
    this.commune = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.owner = const Value.absent(),
    this.contractNumber = const Value.absent(),
    this.contractAmount = const Value.absent(),
    this.delayDays = const Value.absent(),
    this.odsDate = const Value.absent(),
    this.contractualEndDate = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SitesCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.nameAr = const Value.absent(),
    required String type,
    required String wilaya,
    required String commune,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required String owner,
    this.contractNumber = const Value.absent(),
    this.contractAmount = const Value.absent(),
    this.delayDays = const Value.absent(),
    this.odsDate = const Value.absent(),
    this.contractualEndDate = const Value.absent(),
    this.archivedAt = const Value.absent(),
    required int version,
    required DateTime createdAt,
    required String createdByName,
    this.updatedAt = const Value.absent(),
    this.updatedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       type = Value(type),
       wilaya = Value(wilaya),
       commune = Value(commune),
       owner = Value(owner),
       version = Value(version),
       createdAt = Value(createdAt),
       createdByName = Value(createdByName);
  static Insertable<SiteRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? nameAr,
    Expression<String>? type,
    Expression<String>? wilaya,
    Expression<String>? commune,
    Expression<String>? latitude,
    Expression<String>? longitude,
    Expression<String>? owner,
    Expression<String>? contractNumber,
    Expression<String>? contractAmount,
    Expression<int>? delayDays,
    Expression<String>? odsDate,
    Expression<String>? contractualEndDate,
    Expression<DateTime>? archivedAt,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<String>? createdByName,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedByName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (nameAr != null) 'name_ar': nameAr,
      if (type != null) 'type': type,
      if (wilaya != null) 'wilaya': wilaya,
      if (commune != null) 'commune': commune,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (owner != null) 'owner': owner,
      if (contractNumber != null) 'contract_number': contractNumber,
      if (contractAmount != null) 'contract_amount': contractAmount,
      if (delayDays != null) 'delay_days': delayDays,
      if (odsDate != null) 'ods_date': odsDate,
      if (contractualEndDate != null)
        'contractual_end_date': contractualEndDate,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (createdByName != null) 'created_by_name': createdByName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedByName != null) 'updated_by_name': updatedByName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SitesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? nameAr,
    Value<String>? type,
    Value<String>? wilaya,
    Value<String>? commune,
    Value<Decimal?>? latitude,
    Value<Decimal?>? longitude,
    Value<String>? owner,
    Value<String?>? contractNumber,
    Value<Decimal?>? contractAmount,
    Value<int?>? delayDays,
    Value<DateTime?>? odsDate,
    Value<DateTime?>? contractualEndDate,
    Value<DateTime?>? archivedAt,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<String>? createdByName,
    Value<DateTime?>? updatedAt,
    Value<String?>? updatedByName,
    Value<int>? rowid,
  }) {
    return SitesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      type: type ?? this.type,
      wilaya: wilaya ?? this.wilaya,
      commune: commune ?? this.commune,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      owner: owner ?? this.owner,
      contractNumber: contractNumber ?? this.contractNumber,
      contractAmount: contractAmount ?? this.contractAmount,
      delayDays: delayDays ?? this.delayDays,
      odsDate: odsDate ?? this.odsDate,
      contractualEndDate: contractualEndDate ?? this.contractualEndDate,
      archivedAt: archivedAt ?? this.archivedAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      createdByName: createdByName ?? this.createdByName,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByName: updatedByName ?? this.updatedByName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (wilaya.present) {
      map['wilaya'] = Variable<String>(wilaya.value);
    }
    if (commune.present) {
      map['commune'] = Variable<String>(commune.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<String>(
        $SitesTable.$converterlatituden.toSql(latitude.value),
      );
    }
    if (longitude.present) {
      map['longitude'] = Variable<String>(
        $SitesTable.$converterlongituden.toSql(longitude.value),
      );
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (contractNumber.present) {
      map['contract_number'] = Variable<String>(contractNumber.value);
    }
    if (contractAmount.present) {
      map['contract_amount'] = Variable<String>(
        $SitesTable.$convertercontractAmountn.toSql(contractAmount.value),
      );
    }
    if (delayDays.present) {
      map['delay_days'] = Variable<int>(delayDays.value);
    }
    if (odsDate.present) {
      map['ods_date'] = Variable<String>(
        $SitesTable.$converterodsDaten.toSql(odsDate.value),
      );
    }
    if (contractualEndDate.present) {
      map['contractual_end_date'] = Variable<String>(
        $SitesTable.$convertercontractualEndDaten.toSql(
          contractualEndDate.value,
        ),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdByName.present) {
      map['created_by_name'] = Variable<String>(createdByName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedByName.present) {
      map['updated_by_name'] = Variable<String>(updatedByName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameAr: $nameAr, ')
          ..write('type: $type, ')
          ..write('wilaya: $wilaya, ')
          ..write('commune: $commune, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('owner: $owner, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('contractAmount: $contractAmount, ')
          ..write('delayDays: $delayDays, ')
          ..write('odsDate: $odsDate, ')
          ..write('contractualEndDate: $contractualEndDate, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdByName: $createdByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByName: $updatedByName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZonesTable extends Zones with TableInfo<$ZonesTable, ZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sites (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockMeta = const VerificationMeta('block');
  @override
  late final GeneratedColumn<String> block = GeneratedColumn<String>(
    'block',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> elevation =
      GeneratedColumn<String>(
        'elevation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($ZonesTable.$converterelevationn);
  static const VerificationMeta _roomTypeMeta = const VerificationMeta(
    'roomType',
  );
  @override
  late final GeneratedColumn<String> roomType = GeneratedColumn<String>(
    'room_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta(
    'roomNumber',
  );
  @override
  late final GeneratedColumn<int> roomNumber = GeneratedColumn<int>(
    'room_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomLabelMeta = const VerificationMeta(
    'roomLabel',
  );
  @override
  late final GeneratedColumn<String> roomLabel = GeneratedColumn<String>(
    'room_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPendingMeta = const VerificationMeta(
    'isPending',
  );
  @override
  late final GeneratedColumn<bool> isPending = GeneratedColumn<bool>(
    'is_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByNameMeta = const VerificationMeta(
    'createdByName',
  );
  @override
  late final GeneratedColumn<String> createdByName = GeneratedColumn<String>(
    'created_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    clientId,
    block,
    elevation,
    roomType,
    roomNumber,
    roomLabel,
    archivedAt,
    version,
    isPending,
    createdAt,
    createdByName,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('block')) {
      context.handle(
        _blockMeta,
        block.isAcceptableOrUnknown(data['block']!, _blockMeta),
      );
    } else if (isInserting) {
      context.missing(_blockMeta);
    }
    if (data.containsKey('room_type')) {
      context.handle(
        _roomTypeMeta,
        roomType.isAcceptableOrUnknown(data['room_type']!, _roomTypeMeta),
      );
    }
    if (data.containsKey('room_number')) {
      context.handle(
        _roomNumberMeta,
        roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta),
      );
    }
    if (data.containsKey('room_label')) {
      context.handle(
        _roomLabelMeta,
        roomLabel.isAcceptableOrUnknown(data['room_label']!, _roomLabelMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_pending')) {
      context.handle(
        _isPendingMeta,
        isPending.isAcceptableOrUnknown(data['is_pending']!, _isPendingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by_name')) {
      context.handle(
        _createdByNameMeta,
        createdByName.isAcceptableOrUnknown(
          data['created_by_name']!,
          _createdByNameMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {siteId, clientId},
  ];
  @override
  ZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      block: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}block'],
      )!,
      elevation: $ZonesTable.$converterelevationn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}elevation'],
        ),
      ),
      roomType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_type'],
      ),
      roomNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}room_number'],
      ),
      roomLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_label'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pending'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_name'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ZonesTable createAlias(String alias) {
    return $ZonesTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterelevation =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterelevationn =
      NullAwareTypeConverter.wrap($converterelevation);
}

class ZoneRow extends DataClass implements Insertable<ZoneRow> {
  final String id;
  final String siteId;

  /// `clientId` de creation (zones creees sur un telephone), unique par chantier.
  final String? clientId;
  final String block;

  /// Cote en metres, 2 decimales (−1.90, 0.00, 3.40).
  final Decimal? elevation;
  final String? roomType;
  final int? roomNumber;
  final String? roomLabel;
  final DateTime? archivedAt;
  final int version;

  /// Vrai tant que le serveur n'a pas confirme la creation.
  final bool isPending;
  final DateTime createdAt;
  final String? createdByName;
  final DateTime? updatedAt;
  const ZoneRow({
    required this.id,
    required this.siteId,
    this.clientId,
    required this.block,
    this.elevation,
    this.roomType,
    this.roomNumber,
    this.roomLabel,
    this.archivedAt,
    required this.version,
    required this.isPending,
    required this.createdAt,
    this.createdByName,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['block'] = Variable<String>(block);
    if (!nullToAbsent || elevation != null) {
      map['elevation'] = Variable<String>(
        $ZonesTable.$converterelevationn.toSql(elevation),
      );
    }
    if (!nullToAbsent || roomType != null) {
      map['room_type'] = Variable<String>(roomType);
    }
    if (!nullToAbsent || roomNumber != null) {
      map['room_number'] = Variable<int>(roomNumber);
    }
    if (!nullToAbsent || roomLabel != null) {
      map['room_label'] = Variable<String>(roomLabel);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['version'] = Variable<int>(version);
    map['is_pending'] = Variable<bool>(isPending);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || createdByName != null) {
      map['created_by_name'] = Variable<String>(createdByName);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ZonesCompanion toCompanion(bool nullToAbsent) {
    return ZonesCompanion(
      id: Value(id),
      siteId: Value(siteId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      block: Value(block),
      elevation: elevation == null && nullToAbsent
          ? const Value.absent()
          : Value(elevation),
      roomType: roomType == null && nullToAbsent
          ? const Value.absent()
          : Value(roomType),
      roomNumber: roomNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(roomNumber),
      roomLabel: roomLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(roomLabel),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      version: Value(version),
      isPending: Value(isPending),
      createdAt: Value(createdAt),
      createdByName: createdByName == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByName),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ZoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZoneRow(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      block: serializer.fromJson<String>(json['block']),
      elevation: serializer.fromJson<Decimal?>(json['elevation']),
      roomType: serializer.fromJson<String?>(json['roomType']),
      roomNumber: serializer.fromJson<int?>(json['roomNumber']),
      roomLabel: serializer.fromJson<String?>(json['roomLabel']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      version: serializer.fromJson<int>(json['version']),
      isPending: serializer.fromJson<bool>(json['isPending']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdByName: serializer.fromJson<String?>(json['createdByName']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'clientId': serializer.toJson<String?>(clientId),
      'block': serializer.toJson<String>(block),
      'elevation': serializer.toJson<Decimal?>(elevation),
      'roomType': serializer.toJson<String?>(roomType),
      'roomNumber': serializer.toJson<int?>(roomNumber),
      'roomLabel': serializer.toJson<String?>(roomLabel),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'version': serializer.toJson<int>(version),
      'isPending': serializer.toJson<bool>(isPending),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdByName': serializer.toJson<String?>(createdByName),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ZoneRow copyWith({
    String? id,
    String? siteId,
    Value<String?> clientId = const Value.absent(),
    String? block,
    Value<Decimal?> elevation = const Value.absent(),
    Value<String?> roomType = const Value.absent(),
    Value<int?> roomNumber = const Value.absent(),
    Value<String?> roomLabel = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    int? version,
    bool? isPending,
    DateTime? createdAt,
    Value<String?> createdByName = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ZoneRow(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    clientId: clientId.present ? clientId.value : this.clientId,
    block: block ?? this.block,
    elevation: elevation.present ? elevation.value : this.elevation,
    roomType: roomType.present ? roomType.value : this.roomType,
    roomNumber: roomNumber.present ? roomNumber.value : this.roomNumber,
    roomLabel: roomLabel.present ? roomLabel.value : this.roomLabel,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    version: version ?? this.version,
    isPending: isPending ?? this.isPending,
    createdAt: createdAt ?? this.createdAt,
    createdByName: createdByName.present
        ? createdByName.value
        : this.createdByName,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ZoneRow copyWithCompanion(ZonesCompanion data) {
    return ZoneRow(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      block: data.block.present ? data.block.value : this.block,
      elevation: data.elevation.present ? data.elevation.value : this.elevation,
      roomType: data.roomType.present ? data.roomType.value : this.roomType,
      roomNumber: data.roomNumber.present
          ? data.roomNumber.value
          : this.roomNumber,
      roomLabel: data.roomLabel.present ? data.roomLabel.value : this.roomLabel,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      version: data.version.present ? data.version.value : this.version,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdByName: data.createdByName.present
          ? data.createdByName.value
          : this.createdByName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZoneRow(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('clientId: $clientId, ')
          ..write('block: $block, ')
          ..write('elevation: $elevation, ')
          ..write('roomType: $roomType, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('roomLabel: $roomLabel, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('version: $version, ')
          ..write('isPending: $isPending, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdByName: $createdByName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    clientId,
    block,
    elevation,
    roomType,
    roomNumber,
    roomLabel,
    archivedAt,
    version,
    isPending,
    createdAt,
    createdByName,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZoneRow &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.clientId == this.clientId &&
          other.block == this.block &&
          other.elevation == this.elevation &&
          other.roomType == this.roomType &&
          other.roomNumber == this.roomNumber &&
          other.roomLabel == this.roomLabel &&
          other.archivedAt == this.archivedAt &&
          other.version == this.version &&
          other.isPending == this.isPending &&
          other.createdAt == this.createdAt &&
          other.createdByName == this.createdByName &&
          other.updatedAt == this.updatedAt);
}

class ZonesCompanion extends UpdateCompanion<ZoneRow> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String?> clientId;
  final Value<String> block;
  final Value<Decimal?> elevation;
  final Value<String?> roomType;
  final Value<int?> roomNumber;
  final Value<String?> roomLabel;
  final Value<DateTime?> archivedAt;
  final Value<int> version;
  final Value<bool> isPending;
  final Value<DateTime> createdAt;
  final Value<String?> createdByName;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ZonesCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.block = const Value.absent(),
    this.elevation = const Value.absent(),
    this.roomType = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.roomLabel = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isPending = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZonesCompanion.insert({
    required String id,
    required String siteId,
    this.clientId = const Value.absent(),
    required String block,
    this.elevation = const Value.absent(),
    this.roomType = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.roomLabel = const Value.absent(),
    this.archivedAt = const Value.absent(),
    required int version,
    this.isPending = const Value.absent(),
    required DateTime createdAt,
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       block = Value(block),
       version = Value(version),
       createdAt = Value(createdAt);
  static Insertable<ZoneRow> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? clientId,
    Expression<String>? block,
    Expression<String>? elevation,
    Expression<String>? roomType,
    Expression<int>? roomNumber,
    Expression<String>? roomLabel,
    Expression<DateTime>? archivedAt,
    Expression<int>? version,
    Expression<bool>? isPending,
    Expression<DateTime>? createdAt,
    Expression<String>? createdByName,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (clientId != null) 'client_id': clientId,
      if (block != null) 'block': block,
      if (elevation != null) 'elevation': elevation,
      if (roomType != null) 'room_type': roomType,
      if (roomNumber != null) 'room_number': roomNumber,
      if (roomLabel != null) 'room_label': roomLabel,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (version != null) 'version': version,
      if (isPending != null) 'is_pending': isPending,
      if (createdAt != null) 'created_at': createdAt,
      if (createdByName != null) 'created_by_name': createdByName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZonesCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String?>? clientId,
    Value<String>? block,
    Value<Decimal?>? elevation,
    Value<String?>? roomType,
    Value<int?>? roomNumber,
    Value<String?>? roomLabel,
    Value<DateTime?>? archivedAt,
    Value<int>? version,
    Value<bool>? isPending,
    Value<DateTime>? createdAt,
    Value<String?>? createdByName,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ZonesCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      clientId: clientId ?? this.clientId,
      block: block ?? this.block,
      elevation: elevation ?? this.elevation,
      roomType: roomType ?? this.roomType,
      roomNumber: roomNumber ?? this.roomNumber,
      roomLabel: roomLabel ?? this.roomLabel,
      archivedAt: archivedAt ?? this.archivedAt,
      version: version ?? this.version,
      isPending: isPending ?? this.isPending,
      createdAt: createdAt ?? this.createdAt,
      createdByName: createdByName ?? this.createdByName,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (block.present) {
      map['block'] = Variable<String>(block.value);
    }
    if (elevation.present) {
      map['elevation'] = Variable<String>(
        $ZonesTable.$converterelevationn.toSql(elevation.value),
      );
    }
    if (roomType.present) {
      map['room_type'] = Variable<String>(roomType.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<int>(roomNumber.value);
    }
    if (roomLabel.present) {
      map['room_label'] = Variable<String>(roomLabel.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isPending.present) {
      map['is_pending'] = Variable<bool>(isPending.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdByName.present) {
      map['created_by_name'] = Variable<String>(createdByName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonesCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('clientId: $clientId, ')
          ..write('block: $block, ')
          ..write('elevation: $elevation, ')
          ..write('roomType: $roomType, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('roomLabel: $roomLabel, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('version: $version, ')
          ..write('isPending: $isPending, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdByName: $createdByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SiteMembersTable extends SiteMembers
    with TableInfo<$SiteMembersTable, SiteMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SiteMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sites (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedAtMeta = const VerificationMeta(
    'assignedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
    'assigned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    userId,
    fullName,
    role,
    assignedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<SiteMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
        _assignedAtMeta,
        assignedAt.isAcceptableOrUnknown(data['assigned_at']!, _assignedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SiteMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteMemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      assignedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $SiteMembersTable createAlias(String alias) {
    return $SiteMembersTable(attachedDatabase, alias);
  }
}

class SiteMemberRow extends DataClass implements Insertable<SiteMemberRow> {
  final String id;
  final String siteId;
  final String userId;
  final String fullName;
  final String role;
  final DateTime assignedAt;
  final int version;
  const SiteMemberRow({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.fullName,
    required this.role,
    required this.assignedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    map['user_id'] = Variable<String>(userId);
    map['full_name'] = Variable<String>(fullName);
    map['role'] = Variable<String>(role);
    map['assigned_at'] = Variable<DateTime>(assignedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  SiteMembersCompanion toCompanion(bool nullToAbsent) {
    return SiteMembersCompanion(
      id: Value(id),
      siteId: Value(siteId),
      userId: Value(userId),
      fullName: Value(fullName),
      role: Value(role),
      assignedAt: Value(assignedAt),
      version: Value(version),
    );
  }

  factory SiteMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteMemberRow(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      userId: serializer.fromJson<String>(json['userId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'userId': serializer.toJson<String>(userId),
      'fullName': serializer.toJson<String>(fullName),
      'role': serializer.toJson<String>(role),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  SiteMemberRow copyWith({
    String? id,
    String? siteId,
    String? userId,
    String? fullName,
    String? role,
    DateTime? assignedAt,
    int? version,
  }) => SiteMemberRow(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    userId: userId ?? this.userId,
    fullName: fullName ?? this.fullName,
    role: role ?? this.role,
    assignedAt: assignedAt ?? this.assignedAt,
    version: version ?? this.version,
  );
  SiteMemberRow copyWithCompanion(SiteMembersCompanion data) {
    return SiteMemberRow(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      assignedAt: data.assignedAt.present
          ? data.assignedAt.value
          : this.assignedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteMemberRow(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('userId: $userId, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, siteId, userId, fullName, role, assignedAt, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteMemberRow &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.userId == this.userId &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.assignedAt == this.assignedAt &&
          other.version == this.version);
}

class SiteMembersCompanion extends UpdateCompanion<SiteMemberRow> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String> userId;
  final Value<String> fullName;
  final Value<String> role;
  final Value<DateTime> assignedAt;
  final Value<int> version;
  final Value<int> rowid;
  const SiteMembersCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SiteMembersCompanion.insert({
    required String id,
    required String siteId,
    required String userId,
    required String fullName,
    required String role,
    required DateTime assignedAt,
    required int version,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       userId = Value(userId),
       fullName = Value(fullName),
       role = Value(role),
       assignedAt = Value(assignedAt),
       version = Value(version);
  static Insertable<SiteMemberRow> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? userId,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<DateTime>? assignedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (userId != null) 'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SiteMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String>? userId,
    Value<String>? fullName,
    Value<String>? role,
    Value<DateTime>? assignedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return SiteMembersCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      assignedAt: assignedAt ?? this.assignedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiteMembersCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('userId: $userId, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOperationsTable extends OutboxOperations
    with TableInfo<$OutboxOperationsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(OutboxStatus.pending.name),
      ).withConverter<OutboxStatus>($OutboxOperationsTable.$converterstatus);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    ownerUserId,
    entity,
    operation,
    siteId,
    label,
    payloadJson,
    baseVersion,
    status,
    attempts,
    lastErrorCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      ),
      status: $OutboxOperationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxOperationsTable createAlias(String alias) {
    return $OutboxOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxStatus, String, String> $converterstatus =
      const EnumNameConverter<OutboxStatus>(OutboxStatus.values);
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  /// Ordre d'insertion = ordre de creation = ordre d'envoi.
  final int id;

  /// GUID cree a l'ouverture du formulaire (anti-doublon), pas a l'envoi.
  final String clientId;
  final String ownerUserId;
  final String entity;

  /// `create`, `update`, `transition`.
  final String operation;
  final String? siteId;

  /// Libelle lisible pour l'ecran « Envois en attente » (ex. `Zone Bloc 01 · +3,40 m`).
  final String label;
  final String payloadJson;
  final int? baseVersion;
  final OutboxStatus status;
  final int attempts;
  final String? lastErrorCode;

  /// Heure du telephone a la saisie : affichee (« saisi le »), jamais utilisee pour decider.
  final DateTime createdAt;
  const OutboxRow({
    required this.id,
    required this.clientId,
    required this.ownerUserId,
    required this.entity,
    required this.operation,
    this.siteId,
    required this.label,
    required this.payloadJson,
    this.baseVersion,
    required this.status,
    required this.attempts,
    this.lastErrorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<String>(clientId);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['entity'] = Variable<String>(entity);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    map['label'] = Variable<String>(label);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    {
      map['status'] = Variable<String>(
        $OutboxOperationsTable.$converterstatus.toSql(status),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxOperationsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOperationsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      ownerUserId: Value(ownerUserId),
      entity: Value(entity),
      operation: Value(operation),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      label: Value(label),
      payloadJson: Value(payloadJson),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      status: Value(status),
      attempts: Value(attempts),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      entity: serializer.fromJson<String>(json['entity']),
      operation: serializer.fromJson<String>(json['operation']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      label: serializer.fromJson<String>(json['label']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      status: $OutboxOperationsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<String>(clientId),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'entity': serializer.toJson<String>(entity),
      'operation': serializer.toJson<String>(operation),
      'siteId': serializer.toJson<String?>(siteId),
      'label': serializer.toJson<String>(label),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'status': serializer.toJson<String>(
        $OutboxOperationsTable.$converterstatus.toJson(status),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxRow copyWith({
    int? id,
    String? clientId,
    String? ownerUserId,
    String? entity,
    String? operation,
    Value<String?> siteId = const Value.absent(),
    String? label,
    String? payloadJson,
    Value<int?> baseVersion = const Value.absent(),
    OutboxStatus? status,
    int? attempts,
    Value<String?> lastErrorCode = const Value.absent(),
    DateTime? createdAt,
  }) => OutboxRow(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    entity: entity ?? this.entity,
    operation: operation ?? this.operation,
    siteId: siteId.present ? siteId.value : this.siteId,
    label: label ?? this.label,
    payloadJson: payloadJson ?? this.payloadJson,
    baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRow copyWithCompanion(OutboxOperationsCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      entity: data.entity.present ? data.entity.value : this.entity,
      operation: data.operation.present ? data.operation.value : this.operation,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      label: data.label.present ? data.label.value : this.label,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('entity: $entity, ')
          ..write('operation: $operation, ')
          ..write('siteId: $siteId, ')
          ..write('label: $label, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    ownerUserId,
    entity,
    operation,
    siteId,
    label,
    payloadJson,
    baseVersion,
    status,
    attempts,
    lastErrorCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.ownerUserId == this.ownerUserId &&
          other.entity == this.entity &&
          other.operation == this.operation &&
          other.siteId == this.siteId &&
          other.label == this.label &&
          other.payloadJson == this.payloadJson &&
          other.baseVersion == this.baseVersion &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastErrorCode == this.lastErrorCode &&
          other.createdAt == this.createdAt);
}

class OutboxOperationsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> id;
  final Value<String> clientId;
  final Value<String> ownerUserId;
  final Value<String> entity;
  final Value<String> operation;
  final Value<String?> siteId;
  final Value<String> label;
  final Value<String> payloadJson;
  final Value<int?> baseVersion;
  final Value<OutboxStatus> status;
  final Value<int> attempts;
  final Value<String?> lastErrorCode;
  final Value<DateTime> createdAt;
  const OutboxOperationsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.entity = const Value.absent(),
    this.operation = const Value.absent(),
    this.siteId = const Value.absent(),
    this.label = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxOperationsCompanion.insert({
    this.id = const Value.absent(),
    required String clientId,
    required String ownerUserId,
    required String entity,
    required String operation,
    this.siteId = const Value.absent(),
    required String label,
    required String payloadJson,
    this.baseVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    required DateTime createdAt,
  }) : clientId = Value(clientId),
       ownerUserId = Value(ownerUserId),
       entity = Value(entity),
       operation = Value(operation),
       label = Value(label),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? id,
    Expression<String>? clientId,
    Expression<String>? ownerUserId,
    Expression<String>? entity,
    Expression<String>? operation,
    Expression<String>? siteId,
    Expression<String>? label,
    Expression<String>? payloadJson,
    Expression<int>? baseVersion,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? lastErrorCode,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (entity != null) 'entity': entity,
      if (operation != null) 'operation': operation,
      if (siteId != null) 'site_id': siteId,
      if (label != null) 'label': label,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (baseVersion != null) 'base_version': baseVersion,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxOperationsCompanion copyWith({
    Value<int>? id,
    Value<String>? clientId,
    Value<String>? ownerUserId,
    Value<String>? entity,
    Value<String>? operation,
    Value<String?>? siteId,
    Value<String>? label,
    Value<String>? payloadJson,
    Value<int?>? baseVersion,
    Value<OutboxStatus>? status,
    Value<int>? attempts,
    Value<String?>? lastErrorCode,
    Value<DateTime>? createdAt,
  }) {
    return OutboxOperationsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      entity: entity ?? this.entity,
      operation: operation ?? this.operation,
      siteId: siteId ?? this.siteId,
      label: label ?? this.label,
      payloadJson: payloadJson ?? this.payloadJson,
      baseVersion: baseVersion ?? this.baseVersion,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OutboxOperationsTable.$converterstatus.toSql(status.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOperationsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('entity: $entity, ')
          ..write('operation: $operation, ')
          ..write('siteId: $siteId, ')
          ..write('label: $label, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String key;
  final String value;
  const SyncStateRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(key: Value(key), value: Value(value));
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncStateRow copyWith({String? key, String? value}) =>
      SyncStateRow(key: key ?? this.key, value: value ?? this.value);
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncStateRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPrefsTable extends UserPrefs
    with TableInfo<$UserPrefsTable, UserPrefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPrefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, key};
  @override
  UserPrefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPrefRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $UserPrefsTable createAlias(String alias) {
    return $UserPrefsTable(attachedDatabase, alias);
  }
}

class UserPrefRow extends DataClass implements Insertable<UserPrefRow> {
  final String userId;
  final String key;
  final String value;
  const UserPrefRow({
    required this.userId,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserPrefsCompanion toCompanion(bool nullToAbsent) {
    return UserPrefsCompanion(
      userId: Value(userId),
      key: Value(key),
      value: Value(value),
    );
  }

  factory UserPrefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPrefRow(
      userId: serializer.fromJson<String>(json['userId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserPrefRow copyWith({String? userId, String? key, String? value}) =>
      UserPrefRow(
        userId: userId ?? this.userId,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  UserPrefRow copyWithCompanion(UserPrefsCompanion data) {
    return UserPrefRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPrefRow(')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPrefRow &&
          other.userId == this.userId &&
          other.key == this.key &&
          other.value == this.value);
}

class UserPrefsCompanion extends UpdateCompanion<UserPrefRow> {
  final Value<String> userId;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserPrefsCompanion({
    this.userId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPrefsCompanion.insert({
    required String userId,
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       key = Value(key),
       value = Value(value);
  static Insertable<UserPrefRow> custom({
    Expression<String>? userId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPrefsCompanion copyWith({
    Value<String>? userId,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserPrefsCompanion(
      userId: userId ?? this.userId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPrefsCompanion(')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $ZonesTable zones = $ZonesTable(this);
  late final $SiteMembersTable siteMembers = $SiteMembersTable(this);
  late final $OutboxOperationsTable outboxOperations = $OutboxOperationsTable(
    this,
  );
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $UserPrefsTable userPrefs = $UserPrefsTable(this);
  late final Index idxZonesSiteId = Index(
    'idx_zones_site_id',
    'CREATE INDEX idx_zones_site_id ON zones (site_id)',
  );
  late final Index idxSiteMembersSiteId = Index(
    'idx_site_members_site_id',
    'CREATE INDEX idx_site_members_site_id ON site_members (site_id)',
  );
  late final Index idxOutboxOwnerStatus = Index(
    'idx_outbox_owner_status',
    'CREATE INDEX idx_outbox_owner_status ON outbox_operations (owner_user_id, status)',
  );
  late final SitesDao sitesDao = SitesDao(this as AppDatabase);
  late final ZonesDao zonesDao = ZonesDao(this as AppDatabase);
  late final SiteMembersDao siteMembersDao = SiteMembersDao(
    this as AppDatabase,
  );
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  late final UserPrefsDao userPrefsDao = UserPrefsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sites,
    zones,
    siteMembers,
    outboxOperations,
    syncState,
    userPrefs,
    idxZonesSiteId,
    idxSiteMembersSiteId,
    idxOutboxOwnerStatus,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sites',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('zones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sites',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('site_members', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SitesTableCreateCompanionBuilder =
    SitesCompanion Function({
      required String id,
      required String code,
      required String name,
      Value<String?> nameAr,
      required String type,
      required String wilaya,
      required String commune,
      Value<Decimal?> latitude,
      Value<Decimal?> longitude,
      required String owner,
      Value<String?> contractNumber,
      Value<Decimal?> contractAmount,
      Value<int?> delayDays,
      Value<DateTime?> odsDate,
      Value<DateTime?> contractualEndDate,
      Value<DateTime?> archivedAt,
      required int version,
      required DateTime createdAt,
      required String createdByName,
      Value<DateTime?> updatedAt,
      Value<String?> updatedByName,
      Value<int> rowid,
    });
typedef $$SitesTableUpdateCompanionBuilder =
    SitesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String?> nameAr,
      Value<String> type,
      Value<String> wilaya,
      Value<String> commune,
      Value<Decimal?> latitude,
      Value<Decimal?> longitude,
      Value<String> owner,
      Value<String?> contractNumber,
      Value<Decimal?> contractAmount,
      Value<int?> delayDays,
      Value<DateTime?> odsDate,
      Value<DateTime?> contractualEndDate,
      Value<DateTime?> archivedAt,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<String> createdByName,
      Value<DateTime?> updatedAt,
      Value<String?> updatedByName,
      Value<int> rowid,
    });

final class $$SitesTableReferences
    extends BaseReferences<_$AppDatabase, $SitesTable, SiteRow> {
  $$SitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ZonesTable, List<ZoneRow>> _zonesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.zones,
    aliasName: $_aliasNameGenerator(db.sites.id, db.zones.siteId),
  );

  $$ZonesTableProcessedTableManager get zonesRefs {
    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.siteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_zonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SiteMembersTable, List<SiteMemberRow>>
  _siteMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.siteMembers,
    aliasName: $_aliasNameGenerator(db.sites.id, db.siteMembers.siteId),
  );

  $$SiteMembersTableProcessedTableManager get siteMembersRefs {
    final manager = $$SiteMembersTableTableManager(
      $_db,
      $_db.siteMembers,
    ).filter((f) => f.siteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_siteMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SitesTableFilterComposer extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wilaya => $composableBuilder(
    column: $table.wilaya,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get latitude =>
      $composableBuilder(
        column: $table.latitude,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get longitude =>
      $composableBuilder(
        column: $table.longitude,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractNumber => $composableBuilder(
    column: $table.contractNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String>
  get contractAmount => $composableBuilder(
    column: $table.contractAmount,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get delayDays => $composableBuilder(
    column: $table.delayDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get odsDate =>
      $composableBuilder(
        column: $table.odsDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get contractualEndDate => $composableBuilder(
    column: $table.contractualEndDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByName => $composableBuilder(
    column: $table.createdByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> zonesRefs(
    Expression<bool> Function($$ZonesTableFilterComposer f) f,
  ) {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> siteMembersRefs(
    Expression<bool> Function($$SiteMembersTableFilterComposer f) f,
  ) {
    final $$SiteMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.siteMembers,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiteMembersTableFilterComposer(
            $db: $db,
            $table: $db.siteMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wilaya => $composableBuilder(
    column: $table.wilaya,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractNumber => $composableBuilder(
    column: $table.contractNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractAmount => $composableBuilder(
    column: $table.contractAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delayDays => $composableBuilder(
    column: $table.delayDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get odsDate => $composableBuilder(
    column: $table.odsDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractualEndDate => $composableBuilder(
    column: $table.contractualEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByName => $composableBuilder(
    column: $table.createdByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get wilaya =>
      $composableBuilder(column: $table.wilaya, builder: (column) => column);

  GeneratedColumn<String> get commune =>
      $composableBuilder(column: $table.commune, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get contractNumber => $composableBuilder(
    column: $table.contractNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String> get contractAmount =>
      $composableBuilder(
        column: $table.contractAmount,
        builder: (column) => column,
      );

  GeneratedColumn<int> get delayDays =>
      $composableBuilder(column: $table.delayDays, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get odsDate =>
      $composableBuilder(column: $table.odsDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get contractualEndDate =>
      $composableBuilder(
        column: $table.contractualEndDate,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdByName => $composableBuilder(
    column: $table.createdByName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
    builder: (column) => column,
  );

  Expression<T> zonesRefs<T extends Object>(
    Expression<T> Function($$ZonesTableAnnotationComposer a) f,
  ) {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> siteMembersRefs<T extends Object>(
    Expression<T> Function($$SiteMembersTableAnnotationComposer a) f,
  ) {
    final $$SiteMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.siteMembers,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiteMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.siteMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SitesTable,
          SiteRow,
          $$SitesTableFilterComposer,
          $$SitesTableOrderingComposer,
          $$SitesTableAnnotationComposer,
          $$SitesTableCreateCompanionBuilder,
          $$SitesTableUpdateCompanionBuilder,
          (SiteRow, $$SitesTableReferences),
          SiteRow,
          PrefetchHooks Function({bool zonesRefs, bool siteMembersRefs})
        > {
  $$SitesTableTableManager(_$AppDatabase db, $SitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nameAr = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> wilaya = const Value.absent(),
                Value<String> commune = const Value.absent(),
                Value<Decimal?> latitude = const Value.absent(),
                Value<Decimal?> longitude = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String?> contractNumber = const Value.absent(),
                Value<Decimal?> contractAmount = const Value.absent(),
                Value<int?> delayDays = const Value.absent(),
                Value<DateTime?> odsDate = const Value.absent(),
                Value<DateTime?> contractualEndDate = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitesCompanion(
                id: id,
                code: code,
                name: name,
                nameAr: nameAr,
                type: type,
                wilaya: wilaya,
                commune: commune,
                latitude: latitude,
                longitude: longitude,
                owner: owner,
                contractNumber: contractNumber,
                contractAmount: contractAmount,
                delayDays: delayDays,
                odsDate: odsDate,
                contractualEndDate: contractualEndDate,
                archivedAt: archivedAt,
                version: version,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                updatedByName: updatedByName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                Value<String?> nameAr = const Value.absent(),
                required String type,
                required String wilaya,
                required String commune,
                Value<Decimal?> latitude = const Value.absent(),
                Value<Decimal?> longitude = const Value.absent(),
                required String owner,
                Value<String?> contractNumber = const Value.absent(),
                Value<Decimal?> contractAmount = const Value.absent(),
                Value<int?> delayDays = const Value.absent(),
                Value<DateTime?> odsDate = const Value.absent(),
                Value<DateTime?> contractualEndDate = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                required int version,
                required DateTime createdAt,
                required String createdByName,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitesCompanion.insert(
                id: id,
                code: code,
                name: name,
                nameAr: nameAr,
                type: type,
                wilaya: wilaya,
                commune: commune,
                latitude: latitude,
                longitude: longitude,
                owner: owner,
                contractNumber: contractNumber,
                contractAmount: contractAmount,
                delayDays: delayDays,
                odsDate: odsDate,
                contractualEndDate: contractualEndDate,
                archivedAt: archivedAt,
                version: version,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                updatedByName: updatedByName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SitesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({zonesRefs = false, siteMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (zonesRefs) db.zones,
                    if (siteMembersRefs) db.siteMembers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (zonesRefs)
                        await $_getPrefetchedData<
                          SiteRow,
                          $SitesTable,
                          ZoneRow
                        >(
                          currentTable: table,
                          referencedTable: $$SitesTableReferences
                              ._zonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SitesTableReferences(db, table, p0).zonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.siteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (siteMembersRefs)
                        await $_getPrefetchedData<
                          SiteRow,
                          $SitesTable,
                          SiteMemberRow
                        >(
                          currentTable: table,
                          referencedTable: $$SitesTableReferences
                              ._siteMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SitesTableReferences(
                                db,
                                table,
                                p0,
                              ).siteMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.siteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SitesTable,
      SiteRow,
      $$SitesTableFilterComposer,
      $$SitesTableOrderingComposer,
      $$SitesTableAnnotationComposer,
      $$SitesTableCreateCompanionBuilder,
      $$SitesTableUpdateCompanionBuilder,
      (SiteRow, $$SitesTableReferences),
      SiteRow,
      PrefetchHooks Function({bool zonesRefs, bool siteMembersRefs})
    >;
typedef $$ZonesTableCreateCompanionBuilder =
    ZonesCompanion Function({
      required String id,
      required String siteId,
      Value<String?> clientId,
      required String block,
      Value<Decimal?> elevation,
      Value<String?> roomType,
      Value<int?> roomNumber,
      Value<String?> roomLabel,
      Value<DateTime?> archivedAt,
      required int version,
      Value<bool> isPending,
      required DateTime createdAt,
      Value<String?> createdByName,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ZonesTableUpdateCompanionBuilder =
    ZonesCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String?> clientId,
      Value<String> block,
      Value<Decimal?> elevation,
      Value<String?> roomType,
      Value<int?> roomNumber,
      Value<String?> roomLabel,
      Value<DateTime?> archivedAt,
      Value<int> version,
      Value<bool> isPending,
      Value<DateTime> createdAt,
      Value<String?> createdByName,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

final class $$ZonesTableReferences
    extends BaseReferences<_$AppDatabase, $ZonesTable, ZoneRow> {
  $$ZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SitesTable _siteIdTable(_$AppDatabase db) =>
      db.sites.createAlias($_aliasNameGenerator(db.zones.siteId, db.sites.id));

  $$SitesTableProcessedTableManager get siteId {
    final $_column = $_itemColumn<String>('site_id')!;

    final manager = $$SitesTableTableManager(
      $_db,
      $_db.sites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ZonesTableFilterComposer extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get block => $composableBuilder(
    column: $table.block,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get elevation =>
      $composableBuilder(
        column: $table.elevation,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get roomType => $composableBuilder(
    column: $table.roomType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomLabel => $composableBuilder(
    column: $table.roomLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPending => $composableBuilder(
    column: $table.isPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByName => $composableBuilder(
    column: $table.createdByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SitesTableFilterComposer get siteId {
    final $$SitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableFilterComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get block => $composableBuilder(
    column: $table.block,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get elevation => $composableBuilder(
    column: $table.elevation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomType => $composableBuilder(
    column: $table.roomType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomLabel => $composableBuilder(
    column: $table.roomLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPending => $composableBuilder(
    column: $table.isPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByName => $composableBuilder(
    column: $table.createdByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SitesTableOrderingComposer get siteId {
    final $$SitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableOrderingComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get block =>
      $composableBuilder(column: $table.block, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get elevation =>
      $composableBuilder(column: $table.elevation, builder: (column) => column);

  GeneratedColumn<String> get roomType =>
      $composableBuilder(column: $table.roomType, builder: (column) => column);

  GeneratedColumn<int> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomLabel =>
      $composableBuilder(column: $table.roomLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isPending =>
      $composableBuilder(column: $table.isPending, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdByName => $composableBuilder(
    column: $table.createdByName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SitesTableAnnotationComposer get siteId {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableAnnotationComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZonesTable,
          ZoneRow,
          $$ZonesTableFilterComposer,
          $$ZonesTableOrderingComposer,
          $$ZonesTableAnnotationComposer,
          $$ZonesTableCreateCompanionBuilder,
          $$ZonesTableUpdateCompanionBuilder,
          (ZoneRow, $$ZonesTableReferences),
          ZoneRow,
          PrefetchHooks Function({bool siteId})
        > {
  $$ZonesTableTableManager(_$AppDatabase db, $ZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String> block = const Value.absent(),
                Value<Decimal?> elevation = const Value.absent(),
                Value<String?> roomType = const Value.absent(),
                Value<int?> roomNumber = const Value.absent(),
                Value<String?> roomLabel = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isPending = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZonesCompanion(
                id: id,
                siteId: siteId,
                clientId: clientId,
                block: block,
                elevation: elevation,
                roomType: roomType,
                roomNumber: roomNumber,
                roomLabel: roomLabel,
                archivedAt: archivedAt,
                version: version,
                isPending: isPending,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                Value<String?> clientId = const Value.absent(),
                required String block,
                Value<Decimal?> elevation = const Value.absent(),
                Value<String?> roomType = const Value.absent(),
                Value<int?> roomNumber = const Value.absent(),
                Value<String?> roomLabel = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                required int version,
                Value<bool> isPending = const Value.absent(),
                required DateTime createdAt,
                Value<String?> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZonesCompanion.insert(
                id: id,
                siteId: siteId,
                clientId: clientId,
                block: block,
                elevation: elevation,
                roomType: roomType,
                roomNumber: roomNumber,
                roomLabel: roomLabel,
                archivedAt: archivedAt,
                version: version,
                isPending: isPending,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ZonesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({siteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (siteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.siteId,
                                referencedTable: $$ZonesTableReferences
                                    ._siteIdTable(db),
                                referencedColumn: $$ZonesTableReferences
                                    ._siteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZonesTable,
      ZoneRow,
      $$ZonesTableFilterComposer,
      $$ZonesTableOrderingComposer,
      $$ZonesTableAnnotationComposer,
      $$ZonesTableCreateCompanionBuilder,
      $$ZonesTableUpdateCompanionBuilder,
      (ZoneRow, $$ZonesTableReferences),
      ZoneRow,
      PrefetchHooks Function({bool siteId})
    >;
typedef $$SiteMembersTableCreateCompanionBuilder =
    SiteMembersCompanion Function({
      required String id,
      required String siteId,
      required String userId,
      required String fullName,
      required String role,
      required DateTime assignedAt,
      required int version,
      Value<int> rowid,
    });
typedef $$SiteMembersTableUpdateCompanionBuilder =
    SiteMembersCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String> userId,
      Value<String> fullName,
      Value<String> role,
      Value<DateTime> assignedAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$SiteMembersTableReferences
    extends BaseReferences<_$AppDatabase, $SiteMembersTable, SiteMemberRow> {
  $$SiteMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites.createAlias(
    $_aliasNameGenerator(db.siteMembers.siteId, db.sites.id),
  );

  $$SitesTableProcessedTableManager get siteId {
    final $_column = $_itemColumn<String>('site_id')!;

    final manager = $$SitesTableTableManager(
      $_db,
      $_db.sites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SiteMembersTableFilterComposer
    extends Composer<_$AppDatabase, $SiteMembersTable> {
  $$SiteMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  $$SitesTableFilterComposer get siteId {
    final $$SitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableFilterComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SiteMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $SiteMembersTable> {
  $$SiteMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  $$SitesTableOrderingComposer get siteId {
    final $$SitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableOrderingComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SiteMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SiteMembersTable> {
  $$SiteMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$SitesTableAnnotationComposer get siteId {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableAnnotationComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SiteMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SiteMembersTable,
          SiteMemberRow,
          $$SiteMembersTableFilterComposer,
          $$SiteMembersTableOrderingComposer,
          $$SiteMembersTableAnnotationComposer,
          $$SiteMembersTableCreateCompanionBuilder,
          $$SiteMembersTableUpdateCompanionBuilder,
          (SiteMemberRow, $$SiteMembersTableReferences),
          SiteMemberRow,
          PrefetchHooks Function({bool siteId})
        > {
  $$SiteMembersTableTableManager(_$AppDatabase db, $SiteMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SiteMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SiteMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SiteMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> assignedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SiteMembersCompanion(
                id: id,
                siteId: siteId,
                userId: userId,
                fullName: fullName,
                role: role,
                assignedAt: assignedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                required String userId,
                required String fullName,
                required String role,
                required DateTime assignedAt,
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => SiteMembersCompanion.insert(
                id: id,
                siteId: siteId,
                userId: userId,
                fullName: fullName,
                role: role,
                assignedAt: assignedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SiteMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({siteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (siteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.siteId,
                                referencedTable: $$SiteMembersTableReferences
                                    ._siteIdTable(db),
                                referencedColumn: $$SiteMembersTableReferences
                                    ._siteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SiteMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SiteMembersTable,
      SiteMemberRow,
      $$SiteMembersTableFilterComposer,
      $$SiteMembersTableOrderingComposer,
      $$SiteMembersTableAnnotationComposer,
      $$SiteMembersTableCreateCompanionBuilder,
      $$SiteMembersTableUpdateCompanionBuilder,
      (SiteMemberRow, $$SiteMembersTableReferences),
      SiteMemberRow,
      PrefetchHooks Function({bool siteId})
    >;
typedef $$OutboxOperationsTableCreateCompanionBuilder =
    OutboxOperationsCompanion Function({
      Value<int> id,
      required String clientId,
      required String ownerUserId,
      required String entity,
      required String operation,
      Value<String?> siteId,
      required String label,
      required String payloadJson,
      Value<int?> baseVersion,
      Value<OutboxStatus> status,
      Value<int> attempts,
      Value<String?> lastErrorCode,
      required DateTime createdAt,
    });
typedef $$OutboxOperationsTableUpdateCompanionBuilder =
    OutboxOperationsCompanion Function({
      Value<int> id,
      Value<String> clientId,
      Value<String> ownerUserId,
      Value<String> entity,
      Value<String> operation,
      Value<String?> siteId,
      Value<String> label,
      Value<String> payloadJson,
      Value<int?> baseVersion,
      Value<OutboxStatus> status,
      Value<int> attempts,
      Value<String?> lastErrorCode,
      Value<DateTime> createdAt,
    });

class $$OutboxOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxOperationsTable> {
  $$OutboxOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxStatus, OutboxStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxOperationsTable> {
  $$OutboxOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxOperationsTable> {
  $$OutboxOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OutboxStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOperationsTable,
          OutboxRow,
          $$OutboxOperationsTableFilterComposer,
          $$OutboxOperationsTableOrderingComposer,
          $$OutboxOperationsTableAnnotationComposer,
          $$OutboxOperationsTableCreateCompanionBuilder,
          $$OutboxOperationsTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$AppDatabase, $OutboxOperationsTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOperationsTableTableManager(
    _$AppDatabase db,
    $OutboxOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> ownerUserId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int?> baseVersion = const Value.absent(),
                Value<OutboxStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxOperationsCompanion(
                id: id,
                clientId: clientId,
                ownerUserId: ownerUserId,
                entity: entity,
                operation: operation,
                siteId: siteId,
                label: label,
                payloadJson: payloadJson,
                baseVersion: baseVersion,
                status: status,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientId,
                required String ownerUserId,
                required String entity,
                required String operation,
                Value<String?> siteId = const Value.absent(),
                required String label,
                required String payloadJson,
                Value<int?> baseVersion = const Value.absent(),
                Value<OutboxStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                required DateTime createdAt,
              }) => OutboxOperationsCompanion.insert(
                id: id,
                clientId: clientId,
                ownerUserId: ownerUserId,
                entity: entity,
                operation: operation,
                siteId: siteId,
                label: label,
                payloadJson: payloadJson,
                baseVersion: baseVersion,
                status: status,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOperationsTable,
      OutboxRow,
      $$OutboxOperationsTableFilterComposer,
      $$OutboxOperationsTableOrderingComposer,
      $$OutboxOperationsTableAnnotationComposer,
      $$OutboxOperationsTableCreateCompanionBuilder,
      $$OutboxOperationsTableUpdateCompanionBuilder,
      (
        OutboxRow,
        BaseReferences<_$AppDatabase, $OutboxOperationsTable, OutboxRow>,
      ),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$UserPrefsTableCreateCompanionBuilder =
    UserPrefsCompanion Function({
      required String userId,
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$UserPrefsTableUpdateCompanionBuilder =
    UserPrefsCompanion Function({
      Value<String> userId,
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserPrefsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPrefsTable> {
  $$UserPrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPrefsTable> {
  $$UserPrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPrefsTable> {
  $$UserPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPrefsTable,
          UserPrefRow,
          $$UserPrefsTableFilterComposer,
          $$UserPrefsTableOrderingComposer,
          $$UserPrefsTableAnnotationComposer,
          $$UserPrefsTableCreateCompanionBuilder,
          $$UserPrefsTableUpdateCompanionBuilder,
          (
            UserPrefRow,
            BaseReferences<_$AppDatabase, $UserPrefsTable, UserPrefRow>,
          ),
          UserPrefRow,
          PrefetchHooks Function()
        > {
  $$UserPrefsTableTableManager(_$AppDatabase db, $UserPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPrefsCompanion(
                userId: userId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserPrefsCompanion.insert(
                userId: userId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPrefsTable,
      UserPrefRow,
      $$UserPrefsTableFilterComposer,
      $$UserPrefsTableOrderingComposer,
      $$UserPrefsTableAnnotationComposer,
      $$UserPrefsTableCreateCompanionBuilder,
      $$UserPrefsTableUpdateCompanionBuilder,
      (
        UserPrefRow,
        BaseReferences<_$AppDatabase, $UserPrefsTable, UserPrefRow>,
      ),
      UserPrefRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$ZonesTableTableManager get zones =>
      $$ZonesTableTableManager(_db, _db.zones);
  $$SiteMembersTableTableManager get siteMembers =>
      $$SiteMembersTableTableManager(_db, _db.siteMembers);
  $$OutboxOperationsTableTableManager get outboxOperations =>
      $$OutboxOperationsTableTableManager(_db, _db.outboxOperations);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$UserPrefsTableTableManager get userPrefs =>
      $$UserPrefsTableTableManager(_db, _db.userPrefs);
}
