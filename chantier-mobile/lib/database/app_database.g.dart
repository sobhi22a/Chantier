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
  static const VerificationMeta _conflictJsonMeta = const VerificationMeta(
    'conflictJson',
  );
  @override
  late final GeneratedColumn<String> conflictJson = GeneratedColumn<String>(
    'conflict_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictFieldsMeta = const VerificationMeta(
    'conflictFields',
  );
  @override
  late final GeneratedColumn<String> conflictFields = GeneratedColumn<String>(
    'conflict_fields',
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
    conflictJson,
    conflictFields,
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
    if (data.containsKey('conflict_json')) {
      context.handle(
        _conflictJsonMeta,
        conflictJson.isAcceptableOrUnknown(
          data['conflict_json']!,
          _conflictJsonMeta,
        ),
      );
    }
    if (data.containsKey('conflict_fields')) {
      context.handle(
        _conflictFieldsMeta,
        conflictFields.isAcceptableOrUnknown(
          data['conflict_fields']!,
          _conflictFieldsMeta,
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
      conflictJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_json'],
      ),
      conflictFields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_fields'],
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

  /// Etat du serveur renvoye avec un `conflict` (`current`, forme de synchronisation, sans prix) :
  /// l'ecran « A verifier » l'affiche a cote de la version de l'utilisateur (ADR 0011).
  final String? conflictJson;

  /// Champs en desaccord d'un `conflict` (`conflictFields`), liste JSON : `["neededBy"]`.
  final String? conflictFields;

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
    this.conflictJson,
    this.conflictFields,
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
    if (!nullToAbsent || conflictJson != null) {
      map['conflict_json'] = Variable<String>(conflictJson);
    }
    if (!nullToAbsent || conflictFields != null) {
      map['conflict_fields'] = Variable<String>(conflictFields);
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
      conflictJson: conflictJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictJson),
      conflictFields: conflictFields == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictFields),
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
      conflictJson: serializer.fromJson<String?>(json['conflictJson']),
      conflictFields: serializer.fromJson<String?>(json['conflictFields']),
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
      'conflictJson': serializer.toJson<String?>(conflictJson),
      'conflictFields': serializer.toJson<String?>(conflictFields),
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
    Value<String?> conflictJson = const Value.absent(),
    Value<String?> conflictFields = const Value.absent(),
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
    conflictJson: conflictJson.present ? conflictJson.value : this.conflictJson,
    conflictFields: conflictFields.present
        ? conflictFields.value
        : this.conflictFields,
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
      conflictJson: data.conflictJson.present
          ? data.conflictJson.value
          : this.conflictJson,
      conflictFields: data.conflictFields.present
          ? data.conflictFields.value
          : this.conflictFields,
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
          ..write('conflictJson: $conflictJson, ')
          ..write('conflictFields: $conflictFields, ')
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
    conflictJson,
    conflictFields,
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
          other.conflictJson == this.conflictJson &&
          other.conflictFields == this.conflictFields &&
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
  final Value<String?> conflictJson;
  final Value<String?> conflictFields;
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
    this.conflictJson = const Value.absent(),
    this.conflictFields = const Value.absent(),
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
    this.conflictJson = const Value.absent(),
    this.conflictFields = const Value.absent(),
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
    Expression<String>? conflictJson,
    Expression<String>? conflictFields,
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
      if (conflictJson != null) 'conflict_json': conflictJson,
      if (conflictFields != null) 'conflict_fields': conflictFields,
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
    Value<String?>? conflictJson,
    Value<String?>? conflictFields,
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
      conflictJson: conflictJson ?? this.conflictJson,
      conflictFields: conflictFields ?? this.conflictFields,
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
    if (conflictJson.present) {
      map['conflict_json'] = Variable<String>(conflictJson.value);
    }
    if (conflictFields.present) {
      map['conflict_fields'] = Variable<String>(conflictFields.value);
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
          ..write('conflictJson: $conflictJson, ')
          ..write('conflictFields: $conflictFields, ')
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

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameFrMeta = const VerificationMeta('nameFr');
  @override
  late final GeneratedColumn<String> nameFr = GeneratedColumn<String>(
    'name_fr',
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  allowedUnits = GeneratedColumn<String>(
    'allowed_units',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ProductsTable.$converterallowedUnits);
  static const VerificationMeta _defaultUnitMeta = const VerificationMeta(
    'defaultUnit',
  );
  @override
  late final GeneratedColumn<String> defaultUnit = GeneratedColumn<String>(
    'default_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> bagMassKg =
      GeneratedColumn<String>(
        'bag_mass_kg',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($ProductsTable.$converterbagMassKgn);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    nameFr,
    nameAr,
    category,
    allowedUnits,
    defaultUnit,
    bagMassKg,
    isActive,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_fr')) {
      context.handle(
        _nameFrMeta,
        nameFr.isAcceptableOrUnknown(data['name_fr']!, _nameFrMeta),
      );
    } else if (isInserting) {
      context.missing(_nameFrMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('default_unit')) {
      context.handle(
        _defaultUnitMeta,
        defaultUnit.isAcceptableOrUnknown(
          data['default_unit']!,
          _defaultUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultUnitMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameFr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_fr'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      allowedUnits: $ProductsTable.$converterallowedUnits.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}allowed_units'],
        )!,
      ),
      defaultUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_unit'],
      )!,
      bagMassKg: $ProductsTable.$converterbagMassKgn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}bag_mass_kg'],
        ),
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterallowedUnits =
      const StringListTextConverter();
  static TypeConverter<Decimal, String> $converterbagMassKg =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<Decimal?, String?> $converterbagMassKgn =
      NullAwareTypeConverter.wrap($converterbagMassKg);
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String nameFr;
  final String? nameAr;

  /// `Binders`, `Steel`, `Masonry`, `Aggregates`, `Admixtures`, `FinishingWorks`, `Other`.
  final String category;

  /// Codes d'unites du referentiel (`sac`, `t`, `kg`...), au moins un.
  final List<String> allowedUnits;
  final String defaultUnit;

  /// Masse d'un sac en kg (50 le ciment, 25 le monocouche) ; vide si `sac` n'est pas autorise.
  final Decimal? bagMassKg;
  final bool isActive;

  /// Version serveur (`rowversion`) : comparee **numeriquement** (ADR 0009).
  final int version;
  const ProductRow({
    required this.id,
    required this.nameFr,
    this.nameAr,
    required this.category,
    required this.allowedUnits,
    required this.defaultUnit,
    this.bagMassKg,
    required this.isActive,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_fr'] = Variable<String>(nameFr);
    if (!nullToAbsent || nameAr != null) {
      map['name_ar'] = Variable<String>(nameAr);
    }
    map['category'] = Variable<String>(category);
    {
      map['allowed_units'] = Variable<String>(
        $ProductsTable.$converterallowedUnits.toSql(allowedUnits),
      );
    }
    map['default_unit'] = Variable<String>(defaultUnit);
    if (!nullToAbsent || bagMassKg != null) {
      map['bag_mass_kg'] = Variable<String>(
        $ProductsTable.$converterbagMassKgn.toSql(bagMassKg),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      nameFr: Value(nameFr),
      nameAr: nameAr == null && nullToAbsent
          ? const Value.absent()
          : Value(nameAr),
      category: Value(category),
      allowedUnits: Value(allowedUnits),
      defaultUnit: Value(defaultUnit),
      bagMassKg: bagMassKg == null && nullToAbsent
          ? const Value.absent()
          : Value(bagMassKg),
      isActive: Value(isActive),
      version: Value(version),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      nameFr: serializer.fromJson<String>(json['nameFr']),
      nameAr: serializer.fromJson<String?>(json['nameAr']),
      category: serializer.fromJson<String>(json['category']),
      allowedUnits: serializer.fromJson<List<String>>(json['allowedUnits']),
      defaultUnit: serializer.fromJson<String>(json['defaultUnit']),
      bagMassKg: serializer.fromJson<Decimal?>(json['bagMassKg']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameFr': serializer.toJson<String>(nameFr),
      'nameAr': serializer.toJson<String?>(nameAr),
      'category': serializer.toJson<String>(category),
      'allowedUnits': serializer.toJson<List<String>>(allowedUnits),
      'defaultUnit': serializer.toJson<String>(defaultUnit),
      'bagMassKg': serializer.toJson<Decimal?>(bagMassKg),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
    };
  }

  ProductRow copyWith({
    String? id,
    String? nameFr,
    Value<String?> nameAr = const Value.absent(),
    String? category,
    List<String>? allowedUnits,
    String? defaultUnit,
    Value<Decimal?> bagMassKg = const Value.absent(),
    bool? isActive,
    int? version,
  }) => ProductRow(
    id: id ?? this.id,
    nameFr: nameFr ?? this.nameFr,
    nameAr: nameAr.present ? nameAr.value : this.nameAr,
    category: category ?? this.category,
    allowedUnits: allowedUnits ?? this.allowedUnits,
    defaultUnit: defaultUnit ?? this.defaultUnit,
    bagMassKg: bagMassKg.present ? bagMassKg.value : this.bagMassKg,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      nameFr: data.nameFr.present ? data.nameFr.value : this.nameFr,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      category: data.category.present ? data.category.value : this.category,
      allowedUnits: data.allowedUnits.present
          ? data.allowedUnits.value
          : this.allowedUnits,
      defaultUnit: data.defaultUnit.present
          ? data.defaultUnit.value
          : this.defaultUnit,
      bagMassKg: data.bagMassKg.present ? data.bagMassKg.value : this.bagMassKg,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('category: $category, ')
          ..write('allowedUnits: $allowedUnits, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('bagMassKg: $bagMassKg, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameFr,
    nameAr,
    category,
    allowedUnits,
    defaultUnit,
    bagMassKg,
    isActive,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.nameFr == this.nameFr &&
          other.nameAr == this.nameAr &&
          other.category == this.category &&
          other.allowedUnits == this.allowedUnits &&
          other.defaultUnit == this.defaultUnit &&
          other.bagMassKg == this.bagMassKg &&
          other.isActive == this.isActive &&
          other.version == this.version);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> nameFr;
  final Value<String?> nameAr;
  final Value<String> category;
  final Value<List<String>> allowedUnits;
  final Value<String> defaultUnit;
  final Value<Decimal?> bagMassKg;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.category = const Value.absent(),
    this.allowedUnits = const Value.absent(),
    this.defaultUnit = const Value.absent(),
    this.bagMassKg = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String nameFr,
    this.nameAr = const Value.absent(),
    required String category,
    required List<String> allowedUnits,
    required String defaultUnit,
    this.bagMassKg = const Value.absent(),
    this.isActive = const Value.absent(),
    required int version,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameFr = Value(nameFr),
       category = Value(category),
       allowedUnits = Value(allowedUnits),
       defaultUnit = Value(defaultUnit),
       version = Value(version);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? nameFr,
    Expression<String>? nameAr,
    Expression<String>? category,
    Expression<String>? allowedUnits,
    Expression<String>? defaultUnit,
    Expression<String>? bagMassKg,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameFr != null) 'name_fr': nameFr,
      if (nameAr != null) 'name_ar': nameAr,
      if (category != null) 'category': category,
      if (allowedUnits != null) 'allowed_units': allowedUnits,
      if (defaultUnit != null) 'default_unit': defaultUnit,
      if (bagMassKg != null) 'bag_mass_kg': bagMassKg,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? nameFr,
    Value<String?>? nameAr,
    Value<String>? category,
    Value<List<String>>? allowedUnits,
    Value<String>? defaultUnit,
    Value<Decimal?>? bagMassKg,
    Value<bool>? isActive,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      category: category ?? this.category,
      allowedUnits: allowedUnits ?? this.allowedUnits,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      bagMassKg: bagMassKg ?? this.bagMassKg,
      isActive: isActive ?? this.isActive,
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
    if (nameFr.present) {
      map['name_fr'] = Variable<String>(nameFr.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (allowedUnits.present) {
      map['allowed_units'] = Variable<String>(
        $ProductsTable.$converterallowedUnits.toSql(allowedUnits.value),
      );
    }
    if (defaultUnit.present) {
      map['default_unit'] = Variable<String>(defaultUnit.value);
    }
    if (bagMassKg.present) {
      map['bag_mass_kg'] = Variable<String>(
        $ProductsTable.$converterbagMassKgn.toSql(bagMassKg.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('category: $category, ')
          ..write('allowedUnits: $allowedUnits, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('bagMassKg: $bagMassKg, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, SupplierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> productIds =
      GeneratedColumn<String>(
        'product_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($SuppliersTable.$converterproductIds);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    name,
    productIds,
    isActive,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      productIds: $SuppliersTable.$converterproductIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}product_ids'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterproductIds =
      const StringListTextConverter();
}

class SupplierRow extends DataClass implements Insertable<SupplierRow> {
  final String id;
  final String name;

  /// Identifiants des produits fournis (liste de GUID).
  final List<String> productIds;
  final bool isActive;
  final int version;
  const SupplierRow({
    required this.id,
    required this.name,
    required this.productIds,
    required this.isActive,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['product_ids'] = Variable<String>(
        $SuppliersTable.$converterproductIds.toSql(productIds),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      productIds: Value(productIds),
      isActive: Value(isActive),
      version: Value(version),
    );
  }

  factory SupplierRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      productIds: serializer.fromJson<List<String>>(json['productIds']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'productIds': serializer.toJson<List<String>>(productIds),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
    };
  }

  SupplierRow copyWith({
    String? id,
    String? name,
    List<String>? productIds,
    bool? isActive,
    int? version,
  }) => SupplierRow(
    id: id ?? this.id,
    name: name ?? this.name,
    productIds: productIds ?? this.productIds,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
  );
  SupplierRow copyWithCompanion(SuppliersCompanion data) {
    return SupplierRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      productIds: data.productIds.present
          ? data.productIds.value
          : this.productIds,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('productIds: $productIds, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, productIds, isActive, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.productIds == this.productIds &&
          other.isActive == this.isActive &&
          other.version == this.version);
}

class SuppliersCompanion extends UpdateCompanion<SupplierRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<List<String>> productIds;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.productIds = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    required List<String> productIds,
    this.isActive = const Value.absent(),
    required int version,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       productIds = Value(productIds),
       version = Value(version);
  static Insertable<SupplierRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? productIds,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (productIds != null) 'product_ids': productIds,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<List<String>>? productIds,
    Value<bool>? isActive,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      productIds: productIds ?? this.productIds,
      isActive: isActive ?? this.isActive,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (productIds.present) {
      map['product_ids'] = Variable<String>(
        $SuppliersTable.$converterproductIds.toSql(productIds.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('productIds: $productIds, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialRequestsTable extends MaterialRequests
    with TableInfo<$MaterialRequestsTable, MaterialRequestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialRequestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameArMeta = const VerificationMeta(
    'productNameAr',
  );
  @override
  late final GeneratedColumn<String> productNameAr = GeneratedColumn<String>(
    'product_name_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeProductNameMeta = const VerificationMeta(
    'freeProductName',
  );
  @override
  late final GeneratedColumn<String> freeProductName = GeneratedColumn<String>(
    'free_product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> quantityValue =
      GeneratedColumn<String>(
        'quantity_value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($MaterialRequestsTable.$converterquantityValue);
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> neededBy =
      GeneratedColumn<String>(
        'needed_by',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MaterialRequestsTable.$converterneededBy);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Normal'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusReasonCodeMeta = const VerificationMeta(
    'statusReasonCode',
  );
  @override
  late final GeneratedColumn<String> statusReasonCode = GeneratedColumn<String>(
    'status_reason_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusReasonNoteMeta = const VerificationMeta(
    'statusReasonNote',
  );
  @override
  late final GeneratedColumn<String> statusReasonNote = GeneratedColumn<String>(
    'status_reason_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> receivedValue =
      GeneratedColumn<String>(
        'received_value',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>(
        $MaterialRequestsTable.$converterreceivedValuen,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> remainingValue =
      GeneratedColumn<String>(
        'remaining_value',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>(
        $MaterialRequestsTable.$converterremainingValuen,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> varianceValue =
      GeneratedColumn<String>(
        'variance_value',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>(
        $MaterialRequestsTable.$convertervarianceValuen,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String>
  variancePercent = GeneratedColumn<String>(
    'variance_percent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Decimal?>($MaterialRequestsTable.$convertervariancePercentn);
  static const VerificationMeta _isSettledMeta = const VerificationMeta(
    'isSettled',
  );
  @override
  late final GeneratedColumn<bool> isSettled = GeneratedColumn<bool>(
    'is_settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _possibleDuplicateOfIdMeta =
      const VerificationMeta('possibleDuplicateOfId');
  @override
  late final GeneratedColumn<String> possibleDuplicateOfId =
      GeneratedColumn<String>(
        'possible_duplicate_of_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _possibleDuplicateOfNumberMeta =
      const VerificationMeta('possibleDuplicateOfNumber');
  @override
  late final GeneratedColumn<String> possibleDuplicateOfNumber =
      GeneratedColumn<String>(
        'possible_duplicate_of_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hasDeliveryWithoutOrderMeta =
      const VerificationMeta('hasDeliveryWithoutOrder');
  @override
  late final GeneratedColumn<bool> hasDeliveryWithoutOrder =
      GeneratedColumn<bool>(
        'has_delivery_without_order',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_delivery_without_order" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _orderJsonMeta = const VerificationMeta(
    'orderJson',
  );
  @override
  late final GeneratedColumn<String> orderJson = GeneratedColumn<String>(
    'order_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _historyJsonMeta = const VerificationMeta(
    'historyJson',
  );
  @override
  late final GeneratedColumn<String> historyJson = GeneratedColumn<String>(
    'history_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedByIdMeta = const VerificationMeta(
    'requestedById',
  );
  @override
  late final GeneratedColumn<String> requestedById = GeneratedColumn<String>(
    'requested_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedByNameMeta = const VerificationMeta(
    'requestedByName',
  );
  @override
  late final GeneratedColumn<String> requestedByName = GeneratedColumn<String>(
    'requested_by_name',
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
  static const VerificationMeta _archivedByNameMeta = const VerificationMeta(
    'archivedByName',
  );
  @override
  late final GeneratedColumn<String> archivedByName = GeneratedColumn<String>(
    'archived_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _clientCreatedAtMeta = const VerificationMeta(
    'clientCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientCreatedAt =
      GeneratedColumn<DateTime>(
        'client_created_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    siteId,
    clientId,
    number,
    productId,
    productName,
    productNameAr,
    freeProductName,
    quantityValue,
    quantityUnit,
    zoneId,
    neededBy,
    priority,
    note,
    status,
    statusReasonCode,
    statusReasonNote,
    receivedValue,
    remainingValue,
    varianceValue,
    variancePercent,
    isSettled,
    possibleDuplicateOfId,
    possibleDuplicateOfNumber,
    hasDeliveryWithoutOrder,
    orderJson,
    historyJson,
    requestedById,
    requestedByName,
    archivedAt,
    archivedByName,
    version,
    clientCreatedAt,
    isPending,
    createdAt,
    createdByName,
    updatedAt,
    updatedByName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialRequestRow> instance, {
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
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('product_name_ar')) {
      context.handle(
        _productNameArMeta,
        productNameAr.isAcceptableOrUnknown(
          data['product_name_ar']!,
          _productNameArMeta,
        ),
      );
    }
    if (data.containsKey('free_product_name')) {
      context.handle(
        _freeProductNameMeta,
        freeProductName.isAcceptableOrUnknown(
          data['free_product_name']!,
          _freeProductNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('status_reason_code')) {
      context.handle(
        _statusReasonCodeMeta,
        statusReasonCode.isAcceptableOrUnknown(
          data['status_reason_code']!,
          _statusReasonCodeMeta,
        ),
      );
    }
    if (data.containsKey('status_reason_note')) {
      context.handle(
        _statusReasonNoteMeta,
        statusReasonNote.isAcceptableOrUnknown(
          data['status_reason_note']!,
          _statusReasonNoteMeta,
        ),
      );
    }
    if (data.containsKey('is_settled')) {
      context.handle(
        _isSettledMeta,
        isSettled.isAcceptableOrUnknown(data['is_settled']!, _isSettledMeta),
      );
    }
    if (data.containsKey('possible_duplicate_of_id')) {
      context.handle(
        _possibleDuplicateOfIdMeta,
        possibleDuplicateOfId.isAcceptableOrUnknown(
          data['possible_duplicate_of_id']!,
          _possibleDuplicateOfIdMeta,
        ),
      );
    }
    if (data.containsKey('possible_duplicate_of_number')) {
      context.handle(
        _possibleDuplicateOfNumberMeta,
        possibleDuplicateOfNumber.isAcceptableOrUnknown(
          data['possible_duplicate_of_number']!,
          _possibleDuplicateOfNumberMeta,
        ),
      );
    }
    if (data.containsKey('has_delivery_without_order')) {
      context.handle(
        _hasDeliveryWithoutOrderMeta,
        hasDeliveryWithoutOrder.isAcceptableOrUnknown(
          data['has_delivery_without_order']!,
          _hasDeliveryWithoutOrderMeta,
        ),
      );
    }
    if (data.containsKey('order_json')) {
      context.handle(
        _orderJsonMeta,
        orderJson.isAcceptableOrUnknown(data['order_json']!, _orderJsonMeta),
      );
    }
    if (data.containsKey('history_json')) {
      context.handle(
        _historyJsonMeta,
        historyJson.isAcceptableOrUnknown(
          data['history_json']!,
          _historyJsonMeta,
        ),
      );
    }
    if (data.containsKey('requested_by_id')) {
      context.handle(
        _requestedByIdMeta,
        requestedById.isAcceptableOrUnknown(
          data['requested_by_id']!,
          _requestedByIdMeta,
        ),
      );
    }
    if (data.containsKey('requested_by_name')) {
      context.handle(
        _requestedByNameMeta,
        requestedByName.isAcceptableOrUnknown(
          data['requested_by_name']!,
          _requestedByNameMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('archived_by_name')) {
      context.handle(
        _archivedByNameMeta,
        archivedByName.isAcceptableOrUnknown(
          data['archived_by_name']!,
          _archivedByNameMeta,
        ),
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
    if (data.containsKey('client_created_at')) {
      context.handle(
        _clientCreatedAtMeta,
        clientCreatedAt.isAcceptableOrUnknown(
          data['client_created_at']!,
          _clientCreatedAtMeta,
        ),
      );
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {siteId, clientId},
  ];
  @override
  MaterialRequestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialRequestRow(
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
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      productNameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_ar'],
      ),
      freeProductName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_product_name'],
      ),
      quantityValue: $MaterialRequestsTable.$converterquantityValue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity_value'],
        )!,
      ),
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      ),
      neededBy: $MaterialRequestsTable.$converterneededBy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}needed_by'],
        )!,
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      statusReasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_reason_code'],
      ),
      statusReasonNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_reason_note'],
      ),
      receivedValue: $MaterialRequestsTable.$converterreceivedValuen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}received_value'],
        ),
      ),
      remainingValue: $MaterialRequestsTable.$converterremainingValuen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}remaining_value'],
        ),
      ),
      varianceValue: $MaterialRequestsTable.$convertervarianceValuen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}variance_value'],
        ),
      ),
      variancePercent: $MaterialRequestsTable.$convertervariancePercentn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}variance_percent'],
            ),
          ),
      isSettled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_settled'],
      )!,
      possibleDuplicateOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}possible_duplicate_of_id'],
      ),
      possibleDuplicateOfNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}possible_duplicate_of_number'],
      ),
      hasDeliveryWithoutOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_delivery_without_order'],
      )!,
      orderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_json'],
      ),
      historyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}history_json'],
      ),
      requestedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by_id'],
      ),
      requestedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by_name'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      archivedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_by_name'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_created_at'],
      ),
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
      updatedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_name'],
      ),
    );
  }

  @override
  $MaterialRequestsTable createAlias(String alias) {
    return $MaterialRequestsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterquantityValue =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<DateTime, String> $converterneededBy =
      const DateOnlyTextConverter();
  static TypeConverter<Decimal, String> $converterreceivedValue =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<Decimal?, String?> $converterreceivedValuen =
      NullAwareTypeConverter.wrap($converterreceivedValue);
  static TypeConverter<Decimal, String> $converterremainingValue =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<Decimal?, String?> $converterremainingValuen =
      NullAwareTypeConverter.wrap($converterremainingValue);
  static TypeConverter<Decimal, String> $convertervarianceValue =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<Decimal?, String?> $convertervarianceValuen =
      NullAwareTypeConverter.wrap($convertervarianceValue);
  static TypeConverter<Decimal, String> $convertervariancePercent =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $convertervariancePercentn =
      NullAwareTypeConverter.wrap($convertervariancePercent);
}

class MaterialRequestRow extends DataClass
    implements Insertable<MaterialRequestRow> {
  final String id;
  final String siteId;

  /// `clientId` de creation, unique par chantier (les `NULL` ne s'excluent pas).
  final String? clientId;

  /// `DEM-014` ; `null` tant que le serveur n'a pas donne le numero.
  final String? number;

  /// Produit du catalogue (peut etre absent de la table `products` : catalogue pas encore charge).
  final String? productId;
  final String? productName;
  final String? productNameAr;

  /// Nom libre (« Autre produit ») : exactement un de `productId` / `freeProductName`.
  final String? freeProductName;

  /// Quantite demandee : valeur (3 decimales) **et** unite, toujours ensemble.
  final Decimal quantityValue;
  final String quantityUnit;

  /// Zone du chantier (identifiant serveur, ou `clientId` d'une zone encore en attente).
  final String? zoneId;
  final DateTime neededBy;

  /// `Normal`, `Urgent`, `Blocking`.
  final String priority;
  final String? note;

  /// `Requested`, `Validated`, `Rejected`, `Ordered`, `PartiallyDelivered`, `Delivered`,
  /// `Received`, `Cancelled` (texte recu : une valeur inconnue est affichee telle quelle).
  final String status;
  final String? statusReasonCode;
  final String? statusReasonNote;

  /// Recu cumule, reste et ecart **dans l'unite de la demande**, calcules par le serveur ;
  /// vides tant que la demande n'est pas commandee.
  final Decimal? receivedValue;
  final Decimal? remainingValue;
  final Decimal? varianceValue;
  final Decimal? variancePercent;
  final bool isSettled;
  final String? possibleDuplicateOfId;
  final String? possibleDuplicateOfNumber;

  /// Livraison recue sans commande enregistree (badge).
  final bool hasDeliveryWithoutOrder;

  /// Commande incorporee **sans** `commercial` ; `null` sans commande active.
  final String? orderJson;

  /// Historique incorpore, sans evenement sensible.
  final String? historyJson;
  final String? requestedById;
  final String? requestedByName;
  final DateTime? archivedAt;
  final String? archivedByName;

  /// Version serveur (`rowversion`) : comparee **numeriquement** (ADR 0009). `0` = locale.
  final int version;

  /// « Saisi le » : heure du telephone, affichee, jamais utilisee pour decider.
  final DateTime? clientCreatedAt;

  /// Vrai tant que le serveur n'a pas confirme la creation.
  final bool isPending;
  final DateTime createdAt;
  final String? createdByName;
  final DateTime? updatedAt;
  final String? updatedByName;
  const MaterialRequestRow({
    required this.id,
    required this.siteId,
    this.clientId,
    this.number,
    this.productId,
    this.productName,
    this.productNameAr,
    this.freeProductName,
    required this.quantityValue,
    required this.quantityUnit,
    this.zoneId,
    required this.neededBy,
    required this.priority,
    this.note,
    required this.status,
    this.statusReasonCode,
    this.statusReasonNote,
    this.receivedValue,
    this.remainingValue,
    this.varianceValue,
    this.variancePercent,
    required this.isSettled,
    this.possibleDuplicateOfId,
    this.possibleDuplicateOfNumber,
    required this.hasDeliveryWithoutOrder,
    this.orderJson,
    this.historyJson,
    this.requestedById,
    this.requestedByName,
    this.archivedAt,
    this.archivedByName,
    required this.version,
    this.clientCreatedAt,
    required this.isPending,
    required this.createdAt,
    this.createdByName,
    this.updatedAt,
    this.updatedByName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || productNameAr != null) {
      map['product_name_ar'] = Variable<String>(productNameAr);
    }
    if (!nullToAbsent || freeProductName != null) {
      map['free_product_name'] = Variable<String>(freeProductName);
    }
    {
      map['quantity_value'] = Variable<String>(
        $MaterialRequestsTable.$converterquantityValue.toSql(quantityValue),
      );
    }
    map['quantity_unit'] = Variable<String>(quantityUnit);
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<String>(zoneId);
    }
    {
      map['needed_by'] = Variable<String>(
        $MaterialRequestsTable.$converterneededBy.toSql(neededBy),
      );
    }
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || statusReasonCode != null) {
      map['status_reason_code'] = Variable<String>(statusReasonCode);
    }
    if (!nullToAbsent || statusReasonNote != null) {
      map['status_reason_note'] = Variable<String>(statusReasonNote);
    }
    if (!nullToAbsent || receivedValue != null) {
      map['received_value'] = Variable<String>(
        $MaterialRequestsTable.$converterreceivedValuen.toSql(receivedValue),
      );
    }
    if (!nullToAbsent || remainingValue != null) {
      map['remaining_value'] = Variable<String>(
        $MaterialRequestsTable.$converterremainingValuen.toSql(remainingValue),
      );
    }
    if (!nullToAbsent || varianceValue != null) {
      map['variance_value'] = Variable<String>(
        $MaterialRequestsTable.$convertervarianceValuen.toSql(varianceValue),
      );
    }
    if (!nullToAbsent || variancePercent != null) {
      map['variance_percent'] = Variable<String>(
        $MaterialRequestsTable.$convertervariancePercentn.toSql(
          variancePercent,
        ),
      );
    }
    map['is_settled'] = Variable<bool>(isSettled);
    if (!nullToAbsent || possibleDuplicateOfId != null) {
      map['possible_duplicate_of_id'] = Variable<String>(possibleDuplicateOfId);
    }
    if (!nullToAbsent || possibleDuplicateOfNumber != null) {
      map['possible_duplicate_of_number'] = Variable<String>(
        possibleDuplicateOfNumber,
      );
    }
    map['has_delivery_without_order'] = Variable<bool>(hasDeliveryWithoutOrder);
    if (!nullToAbsent || orderJson != null) {
      map['order_json'] = Variable<String>(orderJson);
    }
    if (!nullToAbsent || historyJson != null) {
      map['history_json'] = Variable<String>(historyJson);
    }
    if (!nullToAbsent || requestedById != null) {
      map['requested_by_id'] = Variable<String>(requestedById);
    }
    if (!nullToAbsent || requestedByName != null) {
      map['requested_by_name'] = Variable<String>(requestedByName);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || archivedByName != null) {
      map['archived_by_name'] = Variable<String>(archivedByName);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || clientCreatedAt != null) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt);
    }
    map['is_pending'] = Variable<bool>(isPending);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || createdByName != null) {
      map['created_by_name'] = Variable<String>(createdByName);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedByName != null) {
      map['updated_by_name'] = Variable<String>(updatedByName);
    }
    return map;
  }

  MaterialRequestsCompanion toCompanion(bool nullToAbsent) {
    return MaterialRequestsCompanion(
      id: Value(id),
      siteId: Value(siteId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      productNameAr: productNameAr == null && nullToAbsent
          ? const Value.absent()
          : Value(productNameAr),
      freeProductName: freeProductName == null && nullToAbsent
          ? const Value.absent()
          : Value(freeProductName),
      quantityValue: Value(quantityValue),
      quantityUnit: Value(quantityUnit),
      zoneId: zoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(zoneId),
      neededBy: Value(neededBy),
      priority: Value(priority),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      statusReasonCode: statusReasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusReasonCode),
      statusReasonNote: statusReasonNote == null && nullToAbsent
          ? const Value.absent()
          : Value(statusReasonNote),
      receivedValue: receivedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedValue),
      remainingValue: remainingValue == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingValue),
      varianceValue: varianceValue == null && nullToAbsent
          ? const Value.absent()
          : Value(varianceValue),
      variancePercent: variancePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(variancePercent),
      isSettled: Value(isSettled),
      possibleDuplicateOfId: possibleDuplicateOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(possibleDuplicateOfId),
      possibleDuplicateOfNumber:
          possibleDuplicateOfNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(possibleDuplicateOfNumber),
      hasDeliveryWithoutOrder: Value(hasDeliveryWithoutOrder),
      orderJson: orderJson == null && nullToAbsent
          ? const Value.absent()
          : Value(orderJson),
      historyJson: historyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(historyJson),
      requestedById: requestedById == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedById),
      requestedByName: requestedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedByName),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      archivedByName: archivedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedByName),
      version: Value(version),
      clientCreatedAt: clientCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clientCreatedAt),
      isPending: Value(isPending),
      createdAt: Value(createdAt),
      createdByName: createdByName == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByName),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedByName: updatedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByName),
    );
  }

  factory MaterialRequestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialRequestRow(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      number: serializer.fromJson<String?>(json['number']),
      productId: serializer.fromJson<String?>(json['productId']),
      productName: serializer.fromJson<String?>(json['productName']),
      productNameAr: serializer.fromJson<String?>(json['productNameAr']),
      freeProductName: serializer.fromJson<String?>(json['freeProductName']),
      quantityValue: serializer.fromJson<Decimal>(json['quantityValue']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      zoneId: serializer.fromJson<String?>(json['zoneId']),
      neededBy: serializer.fromJson<DateTime>(json['neededBy']),
      priority: serializer.fromJson<String>(json['priority']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      statusReasonCode: serializer.fromJson<String?>(json['statusReasonCode']),
      statusReasonNote: serializer.fromJson<String?>(json['statusReasonNote']),
      receivedValue: serializer.fromJson<Decimal?>(json['receivedValue']),
      remainingValue: serializer.fromJson<Decimal?>(json['remainingValue']),
      varianceValue: serializer.fromJson<Decimal?>(json['varianceValue']),
      variancePercent: serializer.fromJson<Decimal?>(json['variancePercent']),
      isSettled: serializer.fromJson<bool>(json['isSettled']),
      possibleDuplicateOfId: serializer.fromJson<String?>(
        json['possibleDuplicateOfId'],
      ),
      possibleDuplicateOfNumber: serializer.fromJson<String?>(
        json['possibleDuplicateOfNumber'],
      ),
      hasDeliveryWithoutOrder: serializer.fromJson<bool>(
        json['hasDeliveryWithoutOrder'],
      ),
      orderJson: serializer.fromJson<String?>(json['orderJson']),
      historyJson: serializer.fromJson<String?>(json['historyJson']),
      requestedById: serializer.fromJson<String?>(json['requestedById']),
      requestedByName: serializer.fromJson<String?>(json['requestedByName']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      archivedByName: serializer.fromJson<String?>(json['archivedByName']),
      version: serializer.fromJson<int>(json['version']),
      clientCreatedAt: serializer.fromJson<DateTime?>(json['clientCreatedAt']),
      isPending: serializer.fromJson<bool>(json['isPending']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdByName: serializer.fromJson<String?>(json['createdByName']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      updatedByName: serializer.fromJson<String?>(json['updatedByName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'clientId': serializer.toJson<String?>(clientId),
      'number': serializer.toJson<String?>(number),
      'productId': serializer.toJson<String?>(productId),
      'productName': serializer.toJson<String?>(productName),
      'productNameAr': serializer.toJson<String?>(productNameAr),
      'freeProductName': serializer.toJson<String?>(freeProductName),
      'quantityValue': serializer.toJson<Decimal>(quantityValue),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'zoneId': serializer.toJson<String?>(zoneId),
      'neededBy': serializer.toJson<DateTime>(neededBy),
      'priority': serializer.toJson<String>(priority),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'statusReasonCode': serializer.toJson<String?>(statusReasonCode),
      'statusReasonNote': serializer.toJson<String?>(statusReasonNote),
      'receivedValue': serializer.toJson<Decimal?>(receivedValue),
      'remainingValue': serializer.toJson<Decimal?>(remainingValue),
      'varianceValue': serializer.toJson<Decimal?>(varianceValue),
      'variancePercent': serializer.toJson<Decimal?>(variancePercent),
      'isSettled': serializer.toJson<bool>(isSettled),
      'possibleDuplicateOfId': serializer.toJson<String?>(
        possibleDuplicateOfId,
      ),
      'possibleDuplicateOfNumber': serializer.toJson<String?>(
        possibleDuplicateOfNumber,
      ),
      'hasDeliveryWithoutOrder': serializer.toJson<bool>(
        hasDeliveryWithoutOrder,
      ),
      'orderJson': serializer.toJson<String?>(orderJson),
      'historyJson': serializer.toJson<String?>(historyJson),
      'requestedById': serializer.toJson<String?>(requestedById),
      'requestedByName': serializer.toJson<String?>(requestedByName),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'archivedByName': serializer.toJson<String?>(archivedByName),
      'version': serializer.toJson<int>(version),
      'clientCreatedAt': serializer.toJson<DateTime?>(clientCreatedAt),
      'isPending': serializer.toJson<bool>(isPending),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdByName': serializer.toJson<String?>(createdByName),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'updatedByName': serializer.toJson<String?>(updatedByName),
    };
  }

  MaterialRequestRow copyWith({
    String? id,
    String? siteId,
    Value<String?> clientId = const Value.absent(),
    Value<String?> number = const Value.absent(),
    Value<String?> productId = const Value.absent(),
    Value<String?> productName = const Value.absent(),
    Value<String?> productNameAr = const Value.absent(),
    Value<String?> freeProductName = const Value.absent(),
    Decimal? quantityValue,
    String? quantityUnit,
    Value<String?> zoneId = const Value.absent(),
    DateTime? neededBy,
    String? priority,
    Value<String?> note = const Value.absent(),
    String? status,
    Value<String?> statusReasonCode = const Value.absent(),
    Value<String?> statusReasonNote = const Value.absent(),
    Value<Decimal?> receivedValue = const Value.absent(),
    Value<Decimal?> remainingValue = const Value.absent(),
    Value<Decimal?> varianceValue = const Value.absent(),
    Value<Decimal?> variancePercent = const Value.absent(),
    bool? isSettled,
    Value<String?> possibleDuplicateOfId = const Value.absent(),
    Value<String?> possibleDuplicateOfNumber = const Value.absent(),
    bool? hasDeliveryWithoutOrder,
    Value<String?> orderJson = const Value.absent(),
    Value<String?> historyJson = const Value.absent(),
    Value<String?> requestedById = const Value.absent(),
    Value<String?> requestedByName = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<String?> archivedByName = const Value.absent(),
    int? version,
    Value<DateTime?> clientCreatedAt = const Value.absent(),
    bool? isPending,
    DateTime? createdAt,
    Value<String?> createdByName = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> updatedByName = const Value.absent(),
  }) => MaterialRequestRow(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    clientId: clientId.present ? clientId.value : this.clientId,
    number: number.present ? number.value : this.number,
    productId: productId.present ? productId.value : this.productId,
    productName: productName.present ? productName.value : this.productName,
    productNameAr: productNameAr.present
        ? productNameAr.value
        : this.productNameAr,
    freeProductName: freeProductName.present
        ? freeProductName.value
        : this.freeProductName,
    quantityValue: quantityValue ?? this.quantityValue,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    neededBy: neededBy ?? this.neededBy,
    priority: priority ?? this.priority,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    statusReasonCode: statusReasonCode.present
        ? statusReasonCode.value
        : this.statusReasonCode,
    statusReasonNote: statusReasonNote.present
        ? statusReasonNote.value
        : this.statusReasonNote,
    receivedValue: receivedValue.present
        ? receivedValue.value
        : this.receivedValue,
    remainingValue: remainingValue.present
        ? remainingValue.value
        : this.remainingValue,
    varianceValue: varianceValue.present
        ? varianceValue.value
        : this.varianceValue,
    variancePercent: variancePercent.present
        ? variancePercent.value
        : this.variancePercent,
    isSettled: isSettled ?? this.isSettled,
    possibleDuplicateOfId: possibleDuplicateOfId.present
        ? possibleDuplicateOfId.value
        : this.possibleDuplicateOfId,
    possibleDuplicateOfNumber: possibleDuplicateOfNumber.present
        ? possibleDuplicateOfNumber.value
        : this.possibleDuplicateOfNumber,
    hasDeliveryWithoutOrder:
        hasDeliveryWithoutOrder ?? this.hasDeliveryWithoutOrder,
    orderJson: orderJson.present ? orderJson.value : this.orderJson,
    historyJson: historyJson.present ? historyJson.value : this.historyJson,
    requestedById: requestedById.present
        ? requestedById.value
        : this.requestedById,
    requestedByName: requestedByName.present
        ? requestedByName.value
        : this.requestedByName,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    archivedByName: archivedByName.present
        ? archivedByName.value
        : this.archivedByName,
    version: version ?? this.version,
    clientCreatedAt: clientCreatedAt.present
        ? clientCreatedAt.value
        : this.clientCreatedAt,
    isPending: isPending ?? this.isPending,
    createdAt: createdAt ?? this.createdAt,
    createdByName: createdByName.present
        ? createdByName.value
        : this.createdByName,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedByName: updatedByName.present
        ? updatedByName.value
        : this.updatedByName,
  );
  MaterialRequestRow copyWithCompanion(MaterialRequestsCompanion data) {
    return MaterialRequestRow(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      number: data.number.present ? data.number.value : this.number,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productNameAr: data.productNameAr.present
          ? data.productNameAr.value
          : this.productNameAr,
      freeProductName: data.freeProductName.present
          ? data.freeProductName.value
          : this.freeProductName,
      quantityValue: data.quantityValue.present
          ? data.quantityValue.value
          : this.quantityValue,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      neededBy: data.neededBy.present ? data.neededBy.value : this.neededBy,
      priority: data.priority.present ? data.priority.value : this.priority,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      statusReasonCode: data.statusReasonCode.present
          ? data.statusReasonCode.value
          : this.statusReasonCode,
      statusReasonNote: data.statusReasonNote.present
          ? data.statusReasonNote.value
          : this.statusReasonNote,
      receivedValue: data.receivedValue.present
          ? data.receivedValue.value
          : this.receivedValue,
      remainingValue: data.remainingValue.present
          ? data.remainingValue.value
          : this.remainingValue,
      varianceValue: data.varianceValue.present
          ? data.varianceValue.value
          : this.varianceValue,
      variancePercent: data.variancePercent.present
          ? data.variancePercent.value
          : this.variancePercent,
      isSettled: data.isSettled.present ? data.isSettled.value : this.isSettled,
      possibleDuplicateOfId: data.possibleDuplicateOfId.present
          ? data.possibleDuplicateOfId.value
          : this.possibleDuplicateOfId,
      possibleDuplicateOfNumber: data.possibleDuplicateOfNumber.present
          ? data.possibleDuplicateOfNumber.value
          : this.possibleDuplicateOfNumber,
      hasDeliveryWithoutOrder: data.hasDeliveryWithoutOrder.present
          ? data.hasDeliveryWithoutOrder.value
          : this.hasDeliveryWithoutOrder,
      orderJson: data.orderJson.present ? data.orderJson.value : this.orderJson,
      historyJson: data.historyJson.present
          ? data.historyJson.value
          : this.historyJson,
      requestedById: data.requestedById.present
          ? data.requestedById.value
          : this.requestedById,
      requestedByName: data.requestedByName.present
          ? data.requestedByName.value
          : this.requestedByName,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      archivedByName: data.archivedByName.present
          ? data.archivedByName.value
          : this.archivedByName,
      version: data.version.present ? data.version.value : this.version,
      clientCreatedAt: data.clientCreatedAt.present
          ? data.clientCreatedAt.value
          : this.clientCreatedAt,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
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
    return (StringBuffer('MaterialRequestRow(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('clientId: $clientId, ')
          ..write('number: $number, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productNameAr: $productNameAr, ')
          ..write('freeProductName: $freeProductName, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('zoneId: $zoneId, ')
          ..write('neededBy: $neededBy, ')
          ..write('priority: $priority, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('statusReasonCode: $statusReasonCode, ')
          ..write('statusReasonNote: $statusReasonNote, ')
          ..write('receivedValue: $receivedValue, ')
          ..write('remainingValue: $remainingValue, ')
          ..write('varianceValue: $varianceValue, ')
          ..write('variancePercent: $variancePercent, ')
          ..write('isSettled: $isSettled, ')
          ..write('possibleDuplicateOfId: $possibleDuplicateOfId, ')
          ..write('possibleDuplicateOfNumber: $possibleDuplicateOfNumber, ')
          ..write('hasDeliveryWithoutOrder: $hasDeliveryWithoutOrder, ')
          ..write('orderJson: $orderJson, ')
          ..write('historyJson: $historyJson, ')
          ..write('requestedById: $requestedById, ')
          ..write('requestedByName: $requestedByName, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('archivedByName: $archivedByName, ')
          ..write('version: $version, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('isPending: $isPending, ')
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
    siteId,
    clientId,
    number,
    productId,
    productName,
    productNameAr,
    freeProductName,
    quantityValue,
    quantityUnit,
    zoneId,
    neededBy,
    priority,
    note,
    status,
    statusReasonCode,
    statusReasonNote,
    receivedValue,
    remainingValue,
    varianceValue,
    variancePercent,
    isSettled,
    possibleDuplicateOfId,
    possibleDuplicateOfNumber,
    hasDeliveryWithoutOrder,
    orderJson,
    historyJson,
    requestedById,
    requestedByName,
    archivedAt,
    archivedByName,
    version,
    clientCreatedAt,
    isPending,
    createdAt,
    createdByName,
    updatedAt,
    updatedByName,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialRequestRow &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.clientId == this.clientId &&
          other.number == this.number &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.productNameAr == this.productNameAr &&
          other.freeProductName == this.freeProductName &&
          other.quantityValue == this.quantityValue &&
          other.quantityUnit == this.quantityUnit &&
          other.zoneId == this.zoneId &&
          other.neededBy == this.neededBy &&
          other.priority == this.priority &&
          other.note == this.note &&
          other.status == this.status &&
          other.statusReasonCode == this.statusReasonCode &&
          other.statusReasonNote == this.statusReasonNote &&
          other.receivedValue == this.receivedValue &&
          other.remainingValue == this.remainingValue &&
          other.varianceValue == this.varianceValue &&
          other.variancePercent == this.variancePercent &&
          other.isSettled == this.isSettled &&
          other.possibleDuplicateOfId == this.possibleDuplicateOfId &&
          other.possibleDuplicateOfNumber == this.possibleDuplicateOfNumber &&
          other.hasDeliveryWithoutOrder == this.hasDeliveryWithoutOrder &&
          other.orderJson == this.orderJson &&
          other.historyJson == this.historyJson &&
          other.requestedById == this.requestedById &&
          other.requestedByName == this.requestedByName &&
          other.archivedAt == this.archivedAt &&
          other.archivedByName == this.archivedByName &&
          other.version == this.version &&
          other.clientCreatedAt == this.clientCreatedAt &&
          other.isPending == this.isPending &&
          other.createdAt == this.createdAt &&
          other.createdByName == this.createdByName &&
          other.updatedAt == this.updatedAt &&
          other.updatedByName == this.updatedByName);
}

class MaterialRequestsCompanion extends UpdateCompanion<MaterialRequestRow> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String?> clientId;
  final Value<String?> number;
  final Value<String?> productId;
  final Value<String?> productName;
  final Value<String?> productNameAr;
  final Value<String?> freeProductName;
  final Value<Decimal> quantityValue;
  final Value<String> quantityUnit;
  final Value<String?> zoneId;
  final Value<DateTime> neededBy;
  final Value<String> priority;
  final Value<String?> note;
  final Value<String> status;
  final Value<String?> statusReasonCode;
  final Value<String?> statusReasonNote;
  final Value<Decimal?> receivedValue;
  final Value<Decimal?> remainingValue;
  final Value<Decimal?> varianceValue;
  final Value<Decimal?> variancePercent;
  final Value<bool> isSettled;
  final Value<String?> possibleDuplicateOfId;
  final Value<String?> possibleDuplicateOfNumber;
  final Value<bool> hasDeliveryWithoutOrder;
  final Value<String?> orderJson;
  final Value<String?> historyJson;
  final Value<String?> requestedById;
  final Value<String?> requestedByName;
  final Value<DateTime?> archivedAt;
  final Value<String?> archivedByName;
  final Value<int> version;
  final Value<DateTime?> clientCreatedAt;
  final Value<bool> isPending;
  final Value<DateTime> createdAt;
  final Value<String?> createdByName;
  final Value<DateTime?> updatedAt;
  final Value<String?> updatedByName;
  final Value<int> rowid;
  const MaterialRequestsCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.number = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productNameAr = const Value.absent(),
    this.freeProductName = const Value.absent(),
    this.quantityValue = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.neededBy = const Value.absent(),
    this.priority = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.statusReasonCode = const Value.absent(),
    this.statusReasonNote = const Value.absent(),
    this.receivedValue = const Value.absent(),
    this.remainingValue = const Value.absent(),
    this.varianceValue = const Value.absent(),
    this.variancePercent = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.possibleDuplicateOfId = const Value.absent(),
    this.possibleDuplicateOfNumber = const Value.absent(),
    this.hasDeliveryWithoutOrder = const Value.absent(),
    this.orderJson = const Value.absent(),
    this.historyJson = const Value.absent(),
    this.requestedById = const Value.absent(),
    this.requestedByName = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.archivedByName = const Value.absent(),
    this.version = const Value.absent(),
    this.clientCreatedAt = const Value.absent(),
    this.isPending = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialRequestsCompanion.insert({
    required String id,
    required String siteId,
    this.clientId = const Value.absent(),
    this.number = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productNameAr = const Value.absent(),
    this.freeProductName = const Value.absent(),
    required Decimal quantityValue,
    required String quantityUnit,
    this.zoneId = const Value.absent(),
    required DateTime neededBy,
    this.priority = const Value.absent(),
    this.note = const Value.absent(),
    required String status,
    this.statusReasonCode = const Value.absent(),
    this.statusReasonNote = const Value.absent(),
    this.receivedValue = const Value.absent(),
    this.remainingValue = const Value.absent(),
    this.varianceValue = const Value.absent(),
    this.variancePercent = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.possibleDuplicateOfId = const Value.absent(),
    this.possibleDuplicateOfNumber = const Value.absent(),
    this.hasDeliveryWithoutOrder = const Value.absent(),
    this.orderJson = const Value.absent(),
    this.historyJson = const Value.absent(),
    this.requestedById = const Value.absent(),
    this.requestedByName = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.archivedByName = const Value.absent(),
    required int version,
    this.clientCreatedAt = const Value.absent(),
    this.isPending = const Value.absent(),
    required DateTime createdAt,
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       quantityValue = Value(quantityValue),
       quantityUnit = Value(quantityUnit),
       neededBy = Value(neededBy),
       status = Value(status),
       version = Value(version),
       createdAt = Value(createdAt);
  static Insertable<MaterialRequestRow> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? clientId,
    Expression<String>? number,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? productNameAr,
    Expression<String>? freeProductName,
    Expression<String>? quantityValue,
    Expression<String>? quantityUnit,
    Expression<String>? zoneId,
    Expression<String>? neededBy,
    Expression<String>? priority,
    Expression<String>? note,
    Expression<String>? status,
    Expression<String>? statusReasonCode,
    Expression<String>? statusReasonNote,
    Expression<String>? receivedValue,
    Expression<String>? remainingValue,
    Expression<String>? varianceValue,
    Expression<String>? variancePercent,
    Expression<bool>? isSettled,
    Expression<String>? possibleDuplicateOfId,
    Expression<String>? possibleDuplicateOfNumber,
    Expression<bool>? hasDeliveryWithoutOrder,
    Expression<String>? orderJson,
    Expression<String>? historyJson,
    Expression<String>? requestedById,
    Expression<String>? requestedByName,
    Expression<DateTime>? archivedAt,
    Expression<String>? archivedByName,
    Expression<int>? version,
    Expression<DateTime>? clientCreatedAt,
    Expression<bool>? isPending,
    Expression<DateTime>? createdAt,
    Expression<String>? createdByName,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedByName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (clientId != null) 'client_id': clientId,
      if (number != null) 'number': number,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (productNameAr != null) 'product_name_ar': productNameAr,
      if (freeProductName != null) 'free_product_name': freeProductName,
      if (quantityValue != null) 'quantity_value': quantityValue,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (zoneId != null) 'zone_id': zoneId,
      if (neededBy != null) 'needed_by': neededBy,
      if (priority != null) 'priority': priority,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (statusReasonCode != null) 'status_reason_code': statusReasonCode,
      if (statusReasonNote != null) 'status_reason_note': statusReasonNote,
      if (receivedValue != null) 'received_value': receivedValue,
      if (remainingValue != null) 'remaining_value': remainingValue,
      if (varianceValue != null) 'variance_value': varianceValue,
      if (variancePercent != null) 'variance_percent': variancePercent,
      if (isSettled != null) 'is_settled': isSettled,
      if (possibleDuplicateOfId != null)
        'possible_duplicate_of_id': possibleDuplicateOfId,
      if (possibleDuplicateOfNumber != null)
        'possible_duplicate_of_number': possibleDuplicateOfNumber,
      if (hasDeliveryWithoutOrder != null)
        'has_delivery_without_order': hasDeliveryWithoutOrder,
      if (orderJson != null) 'order_json': orderJson,
      if (historyJson != null) 'history_json': historyJson,
      if (requestedById != null) 'requested_by_id': requestedById,
      if (requestedByName != null) 'requested_by_name': requestedByName,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (archivedByName != null) 'archived_by_name': archivedByName,
      if (version != null) 'version': version,
      if (clientCreatedAt != null) 'client_created_at': clientCreatedAt,
      if (isPending != null) 'is_pending': isPending,
      if (createdAt != null) 'created_at': createdAt,
      if (createdByName != null) 'created_by_name': createdByName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedByName != null) 'updated_by_name': updatedByName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String?>? clientId,
    Value<String?>? number,
    Value<String?>? productId,
    Value<String?>? productName,
    Value<String?>? productNameAr,
    Value<String?>? freeProductName,
    Value<Decimal>? quantityValue,
    Value<String>? quantityUnit,
    Value<String?>? zoneId,
    Value<DateTime>? neededBy,
    Value<String>? priority,
    Value<String?>? note,
    Value<String>? status,
    Value<String?>? statusReasonCode,
    Value<String?>? statusReasonNote,
    Value<Decimal?>? receivedValue,
    Value<Decimal?>? remainingValue,
    Value<Decimal?>? varianceValue,
    Value<Decimal?>? variancePercent,
    Value<bool>? isSettled,
    Value<String?>? possibleDuplicateOfId,
    Value<String?>? possibleDuplicateOfNumber,
    Value<bool>? hasDeliveryWithoutOrder,
    Value<String?>? orderJson,
    Value<String?>? historyJson,
    Value<String?>? requestedById,
    Value<String?>? requestedByName,
    Value<DateTime?>? archivedAt,
    Value<String?>? archivedByName,
    Value<int>? version,
    Value<DateTime?>? clientCreatedAt,
    Value<bool>? isPending,
    Value<DateTime>? createdAt,
    Value<String?>? createdByName,
    Value<DateTime?>? updatedAt,
    Value<String?>? updatedByName,
    Value<int>? rowid,
  }) {
    return MaterialRequestsCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      clientId: clientId ?? this.clientId,
      number: number ?? this.number,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productNameAr: productNameAr ?? this.productNameAr,
      freeProductName: freeProductName ?? this.freeProductName,
      quantityValue: quantityValue ?? this.quantityValue,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      zoneId: zoneId ?? this.zoneId,
      neededBy: neededBy ?? this.neededBy,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      status: status ?? this.status,
      statusReasonCode: statusReasonCode ?? this.statusReasonCode,
      statusReasonNote: statusReasonNote ?? this.statusReasonNote,
      receivedValue: receivedValue ?? this.receivedValue,
      remainingValue: remainingValue ?? this.remainingValue,
      varianceValue: varianceValue ?? this.varianceValue,
      variancePercent: variancePercent ?? this.variancePercent,
      isSettled: isSettled ?? this.isSettled,
      possibleDuplicateOfId:
          possibleDuplicateOfId ?? this.possibleDuplicateOfId,
      possibleDuplicateOfNumber:
          possibleDuplicateOfNumber ?? this.possibleDuplicateOfNumber,
      hasDeliveryWithoutOrder:
          hasDeliveryWithoutOrder ?? this.hasDeliveryWithoutOrder,
      orderJson: orderJson ?? this.orderJson,
      historyJson: historyJson ?? this.historyJson,
      requestedById: requestedById ?? this.requestedById,
      requestedByName: requestedByName ?? this.requestedByName,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedByName: archivedByName ?? this.archivedByName,
      version: version ?? this.version,
      clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
      isPending: isPending ?? this.isPending,
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
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productNameAr.present) {
      map['product_name_ar'] = Variable<String>(productNameAr.value);
    }
    if (freeProductName.present) {
      map['free_product_name'] = Variable<String>(freeProductName.value);
    }
    if (quantityValue.present) {
      map['quantity_value'] = Variable<String>(
        $MaterialRequestsTable.$converterquantityValue.toSql(
          quantityValue.value,
        ),
      );
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (neededBy.present) {
      map['needed_by'] = Variable<String>(
        $MaterialRequestsTable.$converterneededBy.toSql(neededBy.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusReasonCode.present) {
      map['status_reason_code'] = Variable<String>(statusReasonCode.value);
    }
    if (statusReasonNote.present) {
      map['status_reason_note'] = Variable<String>(statusReasonNote.value);
    }
    if (receivedValue.present) {
      map['received_value'] = Variable<String>(
        $MaterialRequestsTable.$converterreceivedValuen.toSql(
          receivedValue.value,
        ),
      );
    }
    if (remainingValue.present) {
      map['remaining_value'] = Variable<String>(
        $MaterialRequestsTable.$converterremainingValuen.toSql(
          remainingValue.value,
        ),
      );
    }
    if (varianceValue.present) {
      map['variance_value'] = Variable<String>(
        $MaterialRequestsTable.$convertervarianceValuen.toSql(
          varianceValue.value,
        ),
      );
    }
    if (variancePercent.present) {
      map['variance_percent'] = Variable<String>(
        $MaterialRequestsTable.$convertervariancePercentn.toSql(
          variancePercent.value,
        ),
      );
    }
    if (isSettled.present) {
      map['is_settled'] = Variable<bool>(isSettled.value);
    }
    if (possibleDuplicateOfId.present) {
      map['possible_duplicate_of_id'] = Variable<String>(
        possibleDuplicateOfId.value,
      );
    }
    if (possibleDuplicateOfNumber.present) {
      map['possible_duplicate_of_number'] = Variable<String>(
        possibleDuplicateOfNumber.value,
      );
    }
    if (hasDeliveryWithoutOrder.present) {
      map['has_delivery_without_order'] = Variable<bool>(
        hasDeliveryWithoutOrder.value,
      );
    }
    if (orderJson.present) {
      map['order_json'] = Variable<String>(orderJson.value);
    }
    if (historyJson.present) {
      map['history_json'] = Variable<String>(historyJson.value);
    }
    if (requestedById.present) {
      map['requested_by_id'] = Variable<String>(requestedById.value);
    }
    if (requestedByName.present) {
      map['requested_by_name'] = Variable<String>(requestedByName.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (archivedByName.present) {
      map['archived_by_name'] = Variable<String>(archivedByName.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientCreatedAt.present) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt.value);
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
    return (StringBuffer('MaterialRequestsCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('clientId: $clientId, ')
          ..write('number: $number, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productNameAr: $productNameAr, ')
          ..write('freeProductName: $freeProductName, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('zoneId: $zoneId, ')
          ..write('neededBy: $neededBy, ')
          ..write('priority: $priority, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('statusReasonCode: $statusReasonCode, ')
          ..write('statusReasonNote: $statusReasonNote, ')
          ..write('receivedValue: $receivedValue, ')
          ..write('remainingValue: $remainingValue, ')
          ..write('varianceValue: $varianceValue, ')
          ..write('variancePercent: $variancePercent, ')
          ..write('isSettled: $isSettled, ')
          ..write('possibleDuplicateOfId: $possibleDuplicateOfId, ')
          ..write('possibleDuplicateOfNumber: $possibleDuplicateOfNumber, ')
          ..write('hasDeliveryWithoutOrder: $hasDeliveryWithoutOrder, ')
          ..write('orderJson: $orderJson, ')
          ..write('historyJson: $historyJson, ')
          ..write('requestedById: $requestedById, ')
          ..write('requestedByName: $requestedByName, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('archivedByName: $archivedByName, ')
          ..write('version: $version, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('isPending: $isPending, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdByName: $createdByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByName: $updatedByName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTable extends Deliveries
    with TableInfo<$DeliveriesTable, DeliveryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unattachedReasonMeta = const VerificationMeta(
    'unattachedReason',
  );
  @override
  late final GeneratedColumn<String> unattachedReason = GeneratedColumn<String>(
    'unattached_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierNameMeta = const VerificationMeta(
    'supplierName',
  );
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
    'supplier_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeSupplierNameMeta = const VerificationMeta(
    'freeSupplierName',
  );
  @override
  late final GeneratedColumn<String> freeSupplierName = GeneratedColumn<String>(
    'free_supplier_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameArMeta = const VerificationMeta(
    'productNameAr',
  );
  @override
  late final GeneratedColumn<String> productNameAr = GeneratedColumn<String>(
    'product_name_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeProductNameMeta = const VerificationMeta(
    'freeProductName',
  );
  @override
  late final GeneratedColumn<String> freeProductName = GeneratedColumn<String>(
    'free_product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> quantityValue =
      GeneratedColumn<String>(
        'quantity_value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($DeliveriesTable.$converterquantityValue);
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String>
  quantityInRequestValue = GeneratedColumn<String>(
    'quantity_in_request_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Decimal?>($DeliveriesTable.$converterquantityInRequestValuen);
  static const VerificationMeta _quantityInRequestUnitMeta =
      const VerificationMeta('quantityInRequestUnit');
  @override
  late final GeneratedColumn<String> quantityInRequestUnit =
      GeneratedColumn<String>(
        'quantity_in_request_unit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> deliveryDate =
      GeneratedColumn<String>(
        'delivery_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DeliveriesTable.$converterdeliveryDate);
  static const VerificationMeta _deliveryNoteNumberMeta =
      const VerificationMeta('deliveryNoteNumber');
  @override
  late final GeneratedColumn<String> deliveryNoteNumber =
      GeneratedColumn<String>(
        'delivery_note_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _conformityMeta = const VerificationMeta(
    'conformity',
  );
  @override
  late final GeneratedColumn<String> conformity = GeneratedColumn<String>(
    'conformity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Conform'),
  );
  static const VerificationMeta _reserveReasonCodeMeta = const VerificationMeta(
    'reserveReasonCode',
  );
  @override
  late final GeneratedColumn<String> reserveReasonCode =
      GeneratedColumn<String>(
        'reserve_reason_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reserveNoteMeta = const VerificationMeta(
    'reserveNote',
  );
  @override
  late final GeneratedColumn<String> reserveNote = GeneratedColumn<String>(
    'reserve_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Recorded'),
  );
  static const VerificationMeta _cancelReasonCodeMeta = const VerificationMeta(
    'cancelReasonCode',
  );
  @override
  late final GeneratedColumn<String> cancelReasonCode = GeneratedColumn<String>(
    'cancel_reason_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonNoteMeta = const VerificationMeta(
    'cancelReasonNote',
  );
  @override
  late final GeneratedColumn<String> cancelReasonNote = GeneratedColumn<String>(
    'cancel_reason_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _possibleDuplicateOfIdMeta =
      const VerificationMeta('possibleDuplicateOfId');
  @override
  late final GeneratedColumn<String> possibleDuplicateOfId =
      GeneratedColumn<String>(
        'possible_duplicate_of_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _possibleDuplicateOfNumberMeta =
      const VerificationMeta('possibleDuplicateOfNumber');
  @override
  late final GeneratedColumn<String> possibleDuplicateOfNumber =
      GeneratedColumn<String>(
        'possible_duplicate_of_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _historyJsonMeta = const VerificationMeta(
    'historyJson',
  );
  @override
  late final GeneratedColumn<String> historyJson = GeneratedColumn<String>(
    'history_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _clientCreatedAtMeta = const VerificationMeta(
    'clientCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientCreatedAt =
      GeneratedColumn<DateTime>(
        'client_created_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    siteId,
    clientId,
    number,
    requestId,
    unattachedReason,
    supplierId,
    supplierName,
    freeSupplierName,
    productId,
    productName,
    productNameAr,
    freeProductName,
    quantityValue,
    quantityUnit,
    quantityInRequestValue,
    quantityInRequestUnit,
    deliveryDate,
    deliveryNoteNumber,
    conformity,
    reserveReasonCode,
    reserveNote,
    status,
    cancelReasonCode,
    cancelReasonNote,
    possibleDuplicateOfId,
    possibleDuplicateOfNumber,
    historyJson,
    version,
    clientCreatedAt,
    isPending,
    createdAt,
    createdByName,
    updatedAt,
    updatedByName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryRow> instance, {
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
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('unattached_reason')) {
      context.handle(
        _unattachedReasonMeta,
        unattachedReason.isAcceptableOrUnknown(
          data['unattached_reason']!,
          _unattachedReasonMeta,
        ),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
        _supplierNameMeta,
        supplierName.isAcceptableOrUnknown(
          data['supplier_name']!,
          _supplierNameMeta,
        ),
      );
    }
    if (data.containsKey('free_supplier_name')) {
      context.handle(
        _freeSupplierNameMeta,
        freeSupplierName.isAcceptableOrUnknown(
          data['free_supplier_name']!,
          _freeSupplierNameMeta,
        ),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('product_name_ar')) {
      context.handle(
        _productNameArMeta,
        productNameAr.isAcceptableOrUnknown(
          data['product_name_ar']!,
          _productNameArMeta,
        ),
      );
    }
    if (data.containsKey('free_product_name')) {
      context.handle(
        _freeProductNameMeta,
        freeProductName.isAcceptableOrUnknown(
          data['free_product_name']!,
          _freeProductNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('quantity_in_request_unit')) {
      context.handle(
        _quantityInRequestUnitMeta,
        quantityInRequestUnit.isAcceptableOrUnknown(
          data['quantity_in_request_unit']!,
          _quantityInRequestUnitMeta,
        ),
      );
    }
    if (data.containsKey('delivery_note_number')) {
      context.handle(
        _deliveryNoteNumberMeta,
        deliveryNoteNumber.isAcceptableOrUnknown(
          data['delivery_note_number']!,
          _deliveryNoteNumberMeta,
        ),
      );
    }
    if (data.containsKey('conformity')) {
      context.handle(
        _conformityMeta,
        conformity.isAcceptableOrUnknown(data['conformity']!, _conformityMeta),
      );
    }
    if (data.containsKey('reserve_reason_code')) {
      context.handle(
        _reserveReasonCodeMeta,
        reserveReasonCode.isAcceptableOrUnknown(
          data['reserve_reason_code']!,
          _reserveReasonCodeMeta,
        ),
      );
    }
    if (data.containsKey('reserve_note')) {
      context.handle(
        _reserveNoteMeta,
        reserveNote.isAcceptableOrUnknown(
          data['reserve_note']!,
          _reserveNoteMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('cancel_reason_code')) {
      context.handle(
        _cancelReasonCodeMeta,
        cancelReasonCode.isAcceptableOrUnknown(
          data['cancel_reason_code']!,
          _cancelReasonCodeMeta,
        ),
      );
    }
    if (data.containsKey('cancel_reason_note')) {
      context.handle(
        _cancelReasonNoteMeta,
        cancelReasonNote.isAcceptableOrUnknown(
          data['cancel_reason_note']!,
          _cancelReasonNoteMeta,
        ),
      );
    }
    if (data.containsKey('possible_duplicate_of_id')) {
      context.handle(
        _possibleDuplicateOfIdMeta,
        possibleDuplicateOfId.isAcceptableOrUnknown(
          data['possible_duplicate_of_id']!,
          _possibleDuplicateOfIdMeta,
        ),
      );
    }
    if (data.containsKey('possible_duplicate_of_number')) {
      context.handle(
        _possibleDuplicateOfNumberMeta,
        possibleDuplicateOfNumber.isAcceptableOrUnknown(
          data['possible_duplicate_of_number']!,
          _possibleDuplicateOfNumberMeta,
        ),
      );
    }
    if (data.containsKey('history_json')) {
      context.handle(
        _historyJsonMeta,
        historyJson.isAcceptableOrUnknown(
          data['history_json']!,
          _historyJsonMeta,
        ),
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
    if (data.containsKey('client_created_at')) {
      context.handle(
        _clientCreatedAtMeta,
        clientCreatedAt.isAcceptableOrUnknown(
          data['client_created_at']!,
          _clientCreatedAtMeta,
        ),
      );
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {siteId, clientId},
  ];
  @override
  DeliveryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryRow(
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
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      unattachedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unattached_reason'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      supplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_name'],
      ),
      freeSupplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_supplier_name'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      productNameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_ar'],
      ),
      freeProductName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_product_name'],
      ),
      quantityValue: $DeliveriesTable.$converterquantityValue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity_value'],
        )!,
      ),
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      quantityInRequestValue: $DeliveriesTable.$converterquantityInRequestValuen
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}quantity_in_request_value'],
            ),
          ),
      quantityInRequestUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_in_request_unit'],
      ),
      deliveryDate: $DeliveriesTable.$converterdeliveryDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}delivery_date'],
        )!,
      ),
      deliveryNoteNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_note_number'],
      ),
      conformity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conformity'],
      )!,
      reserveReasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reserve_reason_code'],
      ),
      reserveNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reserve_note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cancelReasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason_code'],
      ),
      cancelReasonNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason_note'],
      ),
      possibleDuplicateOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}possible_duplicate_of_id'],
      ),
      possibleDuplicateOfNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}possible_duplicate_of_number'],
      ),
      historyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}history_json'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_created_at'],
      ),
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
      updatedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_name'],
      ),
    );
  }

  @override
  $DeliveriesTable createAlias(String alias) {
    return $DeliveriesTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterquantityValue =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<Decimal, String> $converterquantityInRequestValue =
      const DecimalTextConverter(scale: 3);
  static TypeConverter<Decimal?, String?> $converterquantityInRequestValuen =
      NullAwareTypeConverter.wrap($converterquantityInRequestValue);
  static TypeConverter<DateTime, String> $converterdeliveryDate =
      const DateOnlyTextConverter();
}

class DeliveryRow extends DataClass implements Insertable<DeliveryRow> {
  final String id;
  final String siteId;
  final String? clientId;

  /// `LIV-006` ; `null` tant que le serveur n'a pas donne le numero.
  final String? number;

  /// Demande liee ; `null` = livraison **non rattachee** (fait de chantier).
  final String? requestId;

  /// `NoRequestChosen`, `RequestNotOpen`, `RequestMissing` : present si `requestId` est vide.
  final String? unattachedReason;
  final String? supplierId;
  final String? supplierName;
  final String? freeSupplierName;
  final String? productId;
  final String? productName;
  final String? productNameAr;
  final String? freeProductName;

  /// Quantite recue, dans l'unite de la saisie (valeur **et** unite).
  final Decimal quantityValue;
  final String quantityUnit;

  /// Equivalent dans l'unite de la demande (10 T = 200 sacs), si rattachee.
  final Decimal? quantityInRequestValue;
  final String? quantityInRequestUnit;
  final DateTime deliveryDate;
  final String? deliveryNoteNumber;

  /// `Conform`, `WithReserve`.
  final String conformity;
  final String? reserveReasonCode;
  final String? reserveNote;

  /// `Recorded`, `Cancelled`.
  final String status;
  final String? cancelReasonCode;
  final String? cancelReasonNote;
  final String? possibleDuplicateOfId;
  final String? possibleDuplicateOfNumber;

  /// Historique incorpore, sans evenement sensible (`MaterialJsonGuard`).
  final String? historyJson;
  final int version;
  final DateTime? clientCreatedAt;
  final bool isPending;
  final DateTime createdAt;
  final String? createdByName;
  final DateTime? updatedAt;
  final String? updatedByName;
  const DeliveryRow({
    required this.id,
    required this.siteId,
    this.clientId,
    this.number,
    this.requestId,
    this.unattachedReason,
    this.supplierId,
    this.supplierName,
    this.freeSupplierName,
    this.productId,
    this.productName,
    this.productNameAr,
    this.freeProductName,
    required this.quantityValue,
    required this.quantityUnit,
    this.quantityInRequestValue,
    this.quantityInRequestUnit,
    required this.deliveryDate,
    this.deliveryNoteNumber,
    required this.conformity,
    this.reserveReasonCode,
    this.reserveNote,
    required this.status,
    this.cancelReasonCode,
    this.cancelReasonNote,
    this.possibleDuplicateOfId,
    this.possibleDuplicateOfNumber,
    this.historyJson,
    required this.version,
    this.clientCreatedAt,
    required this.isPending,
    required this.createdAt,
    this.createdByName,
    this.updatedAt,
    this.updatedByName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    if (!nullToAbsent || unattachedReason != null) {
      map['unattached_reason'] = Variable<String>(unattachedReason);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || supplierName != null) {
      map['supplier_name'] = Variable<String>(supplierName);
    }
    if (!nullToAbsent || freeSupplierName != null) {
      map['free_supplier_name'] = Variable<String>(freeSupplierName);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || productNameAr != null) {
      map['product_name_ar'] = Variable<String>(productNameAr);
    }
    if (!nullToAbsent || freeProductName != null) {
      map['free_product_name'] = Variable<String>(freeProductName);
    }
    {
      map['quantity_value'] = Variable<String>(
        $DeliveriesTable.$converterquantityValue.toSql(quantityValue),
      );
    }
    map['quantity_unit'] = Variable<String>(quantityUnit);
    if (!nullToAbsent || quantityInRequestValue != null) {
      map['quantity_in_request_value'] = Variable<String>(
        $DeliveriesTable.$converterquantityInRequestValuen.toSql(
          quantityInRequestValue,
        ),
      );
    }
    if (!nullToAbsent || quantityInRequestUnit != null) {
      map['quantity_in_request_unit'] = Variable<String>(quantityInRequestUnit);
    }
    {
      map['delivery_date'] = Variable<String>(
        $DeliveriesTable.$converterdeliveryDate.toSql(deliveryDate),
      );
    }
    if (!nullToAbsent || deliveryNoteNumber != null) {
      map['delivery_note_number'] = Variable<String>(deliveryNoteNumber);
    }
    map['conformity'] = Variable<String>(conformity);
    if (!nullToAbsent || reserveReasonCode != null) {
      map['reserve_reason_code'] = Variable<String>(reserveReasonCode);
    }
    if (!nullToAbsent || reserveNote != null) {
      map['reserve_note'] = Variable<String>(reserveNote);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || cancelReasonCode != null) {
      map['cancel_reason_code'] = Variable<String>(cancelReasonCode);
    }
    if (!nullToAbsent || cancelReasonNote != null) {
      map['cancel_reason_note'] = Variable<String>(cancelReasonNote);
    }
    if (!nullToAbsent || possibleDuplicateOfId != null) {
      map['possible_duplicate_of_id'] = Variable<String>(possibleDuplicateOfId);
    }
    if (!nullToAbsent || possibleDuplicateOfNumber != null) {
      map['possible_duplicate_of_number'] = Variable<String>(
        possibleDuplicateOfNumber,
      );
    }
    if (!nullToAbsent || historyJson != null) {
      map['history_json'] = Variable<String>(historyJson);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || clientCreatedAt != null) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt);
    }
    map['is_pending'] = Variable<bool>(isPending);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || createdByName != null) {
      map['created_by_name'] = Variable<String>(createdByName);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedByName != null) {
      map['updated_by_name'] = Variable<String>(updatedByName);
    }
    return map;
  }

  DeliveriesCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesCompanion(
      id: Value(id),
      siteId: Value(siteId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      unattachedReason: unattachedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(unattachedReason),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      supplierName: supplierName == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierName),
      freeSupplierName: freeSupplierName == null && nullToAbsent
          ? const Value.absent()
          : Value(freeSupplierName),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      productNameAr: productNameAr == null && nullToAbsent
          ? const Value.absent()
          : Value(productNameAr),
      freeProductName: freeProductName == null && nullToAbsent
          ? const Value.absent()
          : Value(freeProductName),
      quantityValue: Value(quantityValue),
      quantityUnit: Value(quantityUnit),
      quantityInRequestValue: quantityInRequestValue == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityInRequestValue),
      quantityInRequestUnit: quantityInRequestUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityInRequestUnit),
      deliveryDate: Value(deliveryDate),
      deliveryNoteNumber: deliveryNoteNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryNoteNumber),
      conformity: Value(conformity),
      reserveReasonCode: reserveReasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(reserveReasonCode),
      reserveNote: reserveNote == null && nullToAbsent
          ? const Value.absent()
          : Value(reserveNote),
      status: Value(status),
      cancelReasonCode: cancelReasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReasonCode),
      cancelReasonNote: cancelReasonNote == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReasonNote),
      possibleDuplicateOfId: possibleDuplicateOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(possibleDuplicateOfId),
      possibleDuplicateOfNumber:
          possibleDuplicateOfNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(possibleDuplicateOfNumber),
      historyJson: historyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(historyJson),
      version: Value(version),
      clientCreatedAt: clientCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clientCreatedAt),
      isPending: Value(isPending),
      createdAt: Value(createdAt),
      createdByName: createdByName == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByName),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedByName: updatedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByName),
    );
  }

  factory DeliveryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryRow(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      number: serializer.fromJson<String?>(json['number']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      unattachedReason: serializer.fromJson<String?>(json['unattachedReason']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      supplierName: serializer.fromJson<String?>(json['supplierName']),
      freeSupplierName: serializer.fromJson<String?>(json['freeSupplierName']),
      productId: serializer.fromJson<String?>(json['productId']),
      productName: serializer.fromJson<String?>(json['productName']),
      productNameAr: serializer.fromJson<String?>(json['productNameAr']),
      freeProductName: serializer.fromJson<String?>(json['freeProductName']),
      quantityValue: serializer.fromJson<Decimal>(json['quantityValue']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      quantityInRequestValue: serializer.fromJson<Decimal?>(
        json['quantityInRequestValue'],
      ),
      quantityInRequestUnit: serializer.fromJson<String?>(
        json['quantityInRequestUnit'],
      ),
      deliveryDate: serializer.fromJson<DateTime>(json['deliveryDate']),
      deliveryNoteNumber: serializer.fromJson<String?>(
        json['deliveryNoteNumber'],
      ),
      conformity: serializer.fromJson<String>(json['conformity']),
      reserveReasonCode: serializer.fromJson<String?>(
        json['reserveReasonCode'],
      ),
      reserveNote: serializer.fromJson<String?>(json['reserveNote']),
      status: serializer.fromJson<String>(json['status']),
      cancelReasonCode: serializer.fromJson<String?>(json['cancelReasonCode']),
      cancelReasonNote: serializer.fromJson<String?>(json['cancelReasonNote']),
      possibleDuplicateOfId: serializer.fromJson<String?>(
        json['possibleDuplicateOfId'],
      ),
      possibleDuplicateOfNumber: serializer.fromJson<String?>(
        json['possibleDuplicateOfNumber'],
      ),
      historyJson: serializer.fromJson<String?>(json['historyJson']),
      version: serializer.fromJson<int>(json['version']),
      clientCreatedAt: serializer.fromJson<DateTime?>(json['clientCreatedAt']),
      isPending: serializer.fromJson<bool>(json['isPending']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdByName: serializer.fromJson<String?>(json['createdByName']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      updatedByName: serializer.fromJson<String?>(json['updatedByName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'clientId': serializer.toJson<String?>(clientId),
      'number': serializer.toJson<String?>(number),
      'requestId': serializer.toJson<String?>(requestId),
      'unattachedReason': serializer.toJson<String?>(unattachedReason),
      'supplierId': serializer.toJson<String?>(supplierId),
      'supplierName': serializer.toJson<String?>(supplierName),
      'freeSupplierName': serializer.toJson<String?>(freeSupplierName),
      'productId': serializer.toJson<String?>(productId),
      'productName': serializer.toJson<String?>(productName),
      'productNameAr': serializer.toJson<String?>(productNameAr),
      'freeProductName': serializer.toJson<String?>(freeProductName),
      'quantityValue': serializer.toJson<Decimal>(quantityValue),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'quantityInRequestValue': serializer.toJson<Decimal?>(
        quantityInRequestValue,
      ),
      'quantityInRequestUnit': serializer.toJson<String?>(
        quantityInRequestUnit,
      ),
      'deliveryDate': serializer.toJson<DateTime>(deliveryDate),
      'deliveryNoteNumber': serializer.toJson<String?>(deliveryNoteNumber),
      'conformity': serializer.toJson<String>(conformity),
      'reserveReasonCode': serializer.toJson<String?>(reserveReasonCode),
      'reserveNote': serializer.toJson<String?>(reserveNote),
      'status': serializer.toJson<String>(status),
      'cancelReasonCode': serializer.toJson<String?>(cancelReasonCode),
      'cancelReasonNote': serializer.toJson<String?>(cancelReasonNote),
      'possibleDuplicateOfId': serializer.toJson<String?>(
        possibleDuplicateOfId,
      ),
      'possibleDuplicateOfNumber': serializer.toJson<String?>(
        possibleDuplicateOfNumber,
      ),
      'historyJson': serializer.toJson<String?>(historyJson),
      'version': serializer.toJson<int>(version),
      'clientCreatedAt': serializer.toJson<DateTime?>(clientCreatedAt),
      'isPending': serializer.toJson<bool>(isPending),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdByName': serializer.toJson<String?>(createdByName),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'updatedByName': serializer.toJson<String?>(updatedByName),
    };
  }

  DeliveryRow copyWith({
    String? id,
    String? siteId,
    Value<String?> clientId = const Value.absent(),
    Value<String?> number = const Value.absent(),
    Value<String?> requestId = const Value.absent(),
    Value<String?> unattachedReason = const Value.absent(),
    Value<String?> supplierId = const Value.absent(),
    Value<String?> supplierName = const Value.absent(),
    Value<String?> freeSupplierName = const Value.absent(),
    Value<String?> productId = const Value.absent(),
    Value<String?> productName = const Value.absent(),
    Value<String?> productNameAr = const Value.absent(),
    Value<String?> freeProductName = const Value.absent(),
    Decimal? quantityValue,
    String? quantityUnit,
    Value<Decimal?> quantityInRequestValue = const Value.absent(),
    Value<String?> quantityInRequestUnit = const Value.absent(),
    DateTime? deliveryDate,
    Value<String?> deliveryNoteNumber = const Value.absent(),
    String? conformity,
    Value<String?> reserveReasonCode = const Value.absent(),
    Value<String?> reserveNote = const Value.absent(),
    String? status,
    Value<String?> cancelReasonCode = const Value.absent(),
    Value<String?> cancelReasonNote = const Value.absent(),
    Value<String?> possibleDuplicateOfId = const Value.absent(),
    Value<String?> possibleDuplicateOfNumber = const Value.absent(),
    Value<String?> historyJson = const Value.absent(),
    int? version,
    Value<DateTime?> clientCreatedAt = const Value.absent(),
    bool? isPending,
    DateTime? createdAt,
    Value<String?> createdByName = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> updatedByName = const Value.absent(),
  }) => DeliveryRow(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    clientId: clientId.present ? clientId.value : this.clientId,
    number: number.present ? number.value : this.number,
    requestId: requestId.present ? requestId.value : this.requestId,
    unattachedReason: unattachedReason.present
        ? unattachedReason.value
        : this.unattachedReason,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    supplierName: supplierName.present ? supplierName.value : this.supplierName,
    freeSupplierName: freeSupplierName.present
        ? freeSupplierName.value
        : this.freeSupplierName,
    productId: productId.present ? productId.value : this.productId,
    productName: productName.present ? productName.value : this.productName,
    productNameAr: productNameAr.present
        ? productNameAr.value
        : this.productNameAr,
    freeProductName: freeProductName.present
        ? freeProductName.value
        : this.freeProductName,
    quantityValue: quantityValue ?? this.quantityValue,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    quantityInRequestValue: quantityInRequestValue.present
        ? quantityInRequestValue.value
        : this.quantityInRequestValue,
    quantityInRequestUnit: quantityInRequestUnit.present
        ? quantityInRequestUnit.value
        : this.quantityInRequestUnit,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    deliveryNoteNumber: deliveryNoteNumber.present
        ? deliveryNoteNumber.value
        : this.deliveryNoteNumber,
    conformity: conformity ?? this.conformity,
    reserveReasonCode: reserveReasonCode.present
        ? reserveReasonCode.value
        : this.reserveReasonCode,
    reserveNote: reserveNote.present ? reserveNote.value : this.reserveNote,
    status: status ?? this.status,
    cancelReasonCode: cancelReasonCode.present
        ? cancelReasonCode.value
        : this.cancelReasonCode,
    cancelReasonNote: cancelReasonNote.present
        ? cancelReasonNote.value
        : this.cancelReasonNote,
    possibleDuplicateOfId: possibleDuplicateOfId.present
        ? possibleDuplicateOfId.value
        : this.possibleDuplicateOfId,
    possibleDuplicateOfNumber: possibleDuplicateOfNumber.present
        ? possibleDuplicateOfNumber.value
        : this.possibleDuplicateOfNumber,
    historyJson: historyJson.present ? historyJson.value : this.historyJson,
    version: version ?? this.version,
    clientCreatedAt: clientCreatedAt.present
        ? clientCreatedAt.value
        : this.clientCreatedAt,
    isPending: isPending ?? this.isPending,
    createdAt: createdAt ?? this.createdAt,
    createdByName: createdByName.present
        ? createdByName.value
        : this.createdByName,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedByName: updatedByName.present
        ? updatedByName.value
        : this.updatedByName,
  );
  DeliveryRow copyWithCompanion(DeliveriesCompanion data) {
    return DeliveryRow(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      number: data.number.present ? data.number.value : this.number,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      unattachedReason: data.unattachedReason.present
          ? data.unattachedReason.value
          : this.unattachedReason,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      freeSupplierName: data.freeSupplierName.present
          ? data.freeSupplierName.value
          : this.freeSupplierName,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productNameAr: data.productNameAr.present
          ? data.productNameAr.value
          : this.productNameAr,
      freeProductName: data.freeProductName.present
          ? data.freeProductName.value
          : this.freeProductName,
      quantityValue: data.quantityValue.present
          ? data.quantityValue.value
          : this.quantityValue,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      quantityInRequestValue: data.quantityInRequestValue.present
          ? data.quantityInRequestValue.value
          : this.quantityInRequestValue,
      quantityInRequestUnit: data.quantityInRequestUnit.present
          ? data.quantityInRequestUnit.value
          : this.quantityInRequestUnit,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      deliveryNoteNumber: data.deliveryNoteNumber.present
          ? data.deliveryNoteNumber.value
          : this.deliveryNoteNumber,
      conformity: data.conformity.present
          ? data.conformity.value
          : this.conformity,
      reserveReasonCode: data.reserveReasonCode.present
          ? data.reserveReasonCode.value
          : this.reserveReasonCode,
      reserveNote: data.reserveNote.present
          ? data.reserveNote.value
          : this.reserveNote,
      status: data.status.present ? data.status.value : this.status,
      cancelReasonCode: data.cancelReasonCode.present
          ? data.cancelReasonCode.value
          : this.cancelReasonCode,
      cancelReasonNote: data.cancelReasonNote.present
          ? data.cancelReasonNote.value
          : this.cancelReasonNote,
      possibleDuplicateOfId: data.possibleDuplicateOfId.present
          ? data.possibleDuplicateOfId.value
          : this.possibleDuplicateOfId,
      possibleDuplicateOfNumber: data.possibleDuplicateOfNumber.present
          ? data.possibleDuplicateOfNumber.value
          : this.possibleDuplicateOfNumber,
      historyJson: data.historyJson.present
          ? data.historyJson.value
          : this.historyJson,
      version: data.version.present ? data.version.value : this.version,
      clientCreatedAt: data.clientCreatedAt.present
          ? data.clientCreatedAt.value
          : this.clientCreatedAt,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
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
    return (StringBuffer('DeliveryRow(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('clientId: $clientId, ')
          ..write('number: $number, ')
          ..write('requestId: $requestId, ')
          ..write('unattachedReason: $unattachedReason, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierName: $supplierName, ')
          ..write('freeSupplierName: $freeSupplierName, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productNameAr: $productNameAr, ')
          ..write('freeProductName: $freeProductName, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('quantityInRequestValue: $quantityInRequestValue, ')
          ..write('quantityInRequestUnit: $quantityInRequestUnit, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryNoteNumber: $deliveryNoteNumber, ')
          ..write('conformity: $conformity, ')
          ..write('reserveReasonCode: $reserveReasonCode, ')
          ..write('reserveNote: $reserveNote, ')
          ..write('status: $status, ')
          ..write('cancelReasonCode: $cancelReasonCode, ')
          ..write('cancelReasonNote: $cancelReasonNote, ')
          ..write('possibleDuplicateOfId: $possibleDuplicateOfId, ')
          ..write('possibleDuplicateOfNumber: $possibleDuplicateOfNumber, ')
          ..write('historyJson: $historyJson, ')
          ..write('version: $version, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('isPending: $isPending, ')
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
    siteId,
    clientId,
    number,
    requestId,
    unattachedReason,
    supplierId,
    supplierName,
    freeSupplierName,
    productId,
    productName,
    productNameAr,
    freeProductName,
    quantityValue,
    quantityUnit,
    quantityInRequestValue,
    quantityInRequestUnit,
    deliveryDate,
    deliveryNoteNumber,
    conformity,
    reserveReasonCode,
    reserveNote,
    status,
    cancelReasonCode,
    cancelReasonNote,
    possibleDuplicateOfId,
    possibleDuplicateOfNumber,
    historyJson,
    version,
    clientCreatedAt,
    isPending,
    createdAt,
    createdByName,
    updatedAt,
    updatedByName,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryRow &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.clientId == this.clientId &&
          other.number == this.number &&
          other.requestId == this.requestId &&
          other.unattachedReason == this.unattachedReason &&
          other.supplierId == this.supplierId &&
          other.supplierName == this.supplierName &&
          other.freeSupplierName == this.freeSupplierName &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.productNameAr == this.productNameAr &&
          other.freeProductName == this.freeProductName &&
          other.quantityValue == this.quantityValue &&
          other.quantityUnit == this.quantityUnit &&
          other.quantityInRequestValue == this.quantityInRequestValue &&
          other.quantityInRequestUnit == this.quantityInRequestUnit &&
          other.deliveryDate == this.deliveryDate &&
          other.deliveryNoteNumber == this.deliveryNoteNumber &&
          other.conformity == this.conformity &&
          other.reserveReasonCode == this.reserveReasonCode &&
          other.reserveNote == this.reserveNote &&
          other.status == this.status &&
          other.cancelReasonCode == this.cancelReasonCode &&
          other.cancelReasonNote == this.cancelReasonNote &&
          other.possibleDuplicateOfId == this.possibleDuplicateOfId &&
          other.possibleDuplicateOfNumber == this.possibleDuplicateOfNumber &&
          other.historyJson == this.historyJson &&
          other.version == this.version &&
          other.clientCreatedAt == this.clientCreatedAt &&
          other.isPending == this.isPending &&
          other.createdAt == this.createdAt &&
          other.createdByName == this.createdByName &&
          other.updatedAt == this.updatedAt &&
          other.updatedByName == this.updatedByName);
}

class DeliveriesCompanion extends UpdateCompanion<DeliveryRow> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String?> clientId;
  final Value<String?> number;
  final Value<String?> requestId;
  final Value<String?> unattachedReason;
  final Value<String?> supplierId;
  final Value<String?> supplierName;
  final Value<String?> freeSupplierName;
  final Value<String?> productId;
  final Value<String?> productName;
  final Value<String?> productNameAr;
  final Value<String?> freeProductName;
  final Value<Decimal> quantityValue;
  final Value<String> quantityUnit;
  final Value<Decimal?> quantityInRequestValue;
  final Value<String?> quantityInRequestUnit;
  final Value<DateTime> deliveryDate;
  final Value<String?> deliveryNoteNumber;
  final Value<String> conformity;
  final Value<String?> reserveReasonCode;
  final Value<String?> reserveNote;
  final Value<String> status;
  final Value<String?> cancelReasonCode;
  final Value<String?> cancelReasonNote;
  final Value<String?> possibleDuplicateOfId;
  final Value<String?> possibleDuplicateOfNumber;
  final Value<String?> historyJson;
  final Value<int> version;
  final Value<DateTime?> clientCreatedAt;
  final Value<bool> isPending;
  final Value<DateTime> createdAt;
  final Value<String?> createdByName;
  final Value<DateTime?> updatedAt;
  final Value<String?> updatedByName;
  final Value<int> rowid;
  const DeliveriesCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.number = const Value.absent(),
    this.requestId = const Value.absent(),
    this.unattachedReason = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.freeSupplierName = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productNameAr = const Value.absent(),
    this.freeProductName = const Value.absent(),
    this.quantityValue = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.quantityInRequestValue = const Value.absent(),
    this.quantityInRequestUnit = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.deliveryNoteNumber = const Value.absent(),
    this.conformity = const Value.absent(),
    this.reserveReasonCode = const Value.absent(),
    this.reserveNote = const Value.absent(),
    this.status = const Value.absent(),
    this.cancelReasonCode = const Value.absent(),
    this.cancelReasonNote = const Value.absent(),
    this.possibleDuplicateOfId = const Value.absent(),
    this.possibleDuplicateOfNumber = const Value.absent(),
    this.historyJson = const Value.absent(),
    this.version = const Value.absent(),
    this.clientCreatedAt = const Value.absent(),
    this.isPending = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveriesCompanion.insert({
    required String id,
    required String siteId,
    this.clientId = const Value.absent(),
    this.number = const Value.absent(),
    this.requestId = const Value.absent(),
    this.unattachedReason = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.freeSupplierName = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productNameAr = const Value.absent(),
    this.freeProductName = const Value.absent(),
    required Decimal quantityValue,
    required String quantityUnit,
    this.quantityInRequestValue = const Value.absent(),
    this.quantityInRequestUnit = const Value.absent(),
    required DateTime deliveryDate,
    this.deliveryNoteNumber = const Value.absent(),
    this.conformity = const Value.absent(),
    this.reserveReasonCode = const Value.absent(),
    this.reserveNote = const Value.absent(),
    this.status = const Value.absent(),
    this.cancelReasonCode = const Value.absent(),
    this.cancelReasonNote = const Value.absent(),
    this.possibleDuplicateOfId = const Value.absent(),
    this.possibleDuplicateOfNumber = const Value.absent(),
    this.historyJson = const Value.absent(),
    required int version,
    this.clientCreatedAt = const Value.absent(),
    this.isPending = const Value.absent(),
    required DateTime createdAt,
    this.createdByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       quantityValue = Value(quantityValue),
       quantityUnit = Value(quantityUnit),
       deliveryDate = Value(deliveryDate),
       version = Value(version),
       createdAt = Value(createdAt);
  static Insertable<DeliveryRow> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? clientId,
    Expression<String>? number,
    Expression<String>? requestId,
    Expression<String>? unattachedReason,
    Expression<String>? supplierId,
    Expression<String>? supplierName,
    Expression<String>? freeSupplierName,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? productNameAr,
    Expression<String>? freeProductName,
    Expression<String>? quantityValue,
    Expression<String>? quantityUnit,
    Expression<String>? quantityInRequestValue,
    Expression<String>? quantityInRequestUnit,
    Expression<String>? deliveryDate,
    Expression<String>? deliveryNoteNumber,
    Expression<String>? conformity,
    Expression<String>? reserveReasonCode,
    Expression<String>? reserveNote,
    Expression<String>? status,
    Expression<String>? cancelReasonCode,
    Expression<String>? cancelReasonNote,
    Expression<String>? possibleDuplicateOfId,
    Expression<String>? possibleDuplicateOfNumber,
    Expression<String>? historyJson,
    Expression<int>? version,
    Expression<DateTime>? clientCreatedAt,
    Expression<bool>? isPending,
    Expression<DateTime>? createdAt,
    Expression<String>? createdByName,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedByName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (clientId != null) 'client_id': clientId,
      if (number != null) 'number': number,
      if (requestId != null) 'request_id': requestId,
      if (unattachedReason != null) 'unattached_reason': unattachedReason,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierName != null) 'supplier_name': supplierName,
      if (freeSupplierName != null) 'free_supplier_name': freeSupplierName,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (productNameAr != null) 'product_name_ar': productNameAr,
      if (freeProductName != null) 'free_product_name': freeProductName,
      if (quantityValue != null) 'quantity_value': quantityValue,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (quantityInRequestValue != null)
        'quantity_in_request_value': quantityInRequestValue,
      if (quantityInRequestUnit != null)
        'quantity_in_request_unit': quantityInRequestUnit,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (deliveryNoteNumber != null)
        'delivery_note_number': deliveryNoteNumber,
      if (conformity != null) 'conformity': conformity,
      if (reserveReasonCode != null) 'reserve_reason_code': reserveReasonCode,
      if (reserveNote != null) 'reserve_note': reserveNote,
      if (status != null) 'status': status,
      if (cancelReasonCode != null) 'cancel_reason_code': cancelReasonCode,
      if (cancelReasonNote != null) 'cancel_reason_note': cancelReasonNote,
      if (possibleDuplicateOfId != null)
        'possible_duplicate_of_id': possibleDuplicateOfId,
      if (possibleDuplicateOfNumber != null)
        'possible_duplicate_of_number': possibleDuplicateOfNumber,
      if (historyJson != null) 'history_json': historyJson,
      if (version != null) 'version': version,
      if (clientCreatedAt != null) 'client_created_at': clientCreatedAt,
      if (isPending != null) 'is_pending': isPending,
      if (createdAt != null) 'created_at': createdAt,
      if (createdByName != null) 'created_by_name': createdByName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedByName != null) 'updated_by_name': updatedByName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveriesCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String?>? clientId,
    Value<String?>? number,
    Value<String?>? requestId,
    Value<String?>? unattachedReason,
    Value<String?>? supplierId,
    Value<String?>? supplierName,
    Value<String?>? freeSupplierName,
    Value<String?>? productId,
    Value<String?>? productName,
    Value<String?>? productNameAr,
    Value<String?>? freeProductName,
    Value<Decimal>? quantityValue,
    Value<String>? quantityUnit,
    Value<Decimal?>? quantityInRequestValue,
    Value<String?>? quantityInRequestUnit,
    Value<DateTime>? deliveryDate,
    Value<String?>? deliveryNoteNumber,
    Value<String>? conformity,
    Value<String?>? reserveReasonCode,
    Value<String?>? reserveNote,
    Value<String>? status,
    Value<String?>? cancelReasonCode,
    Value<String?>? cancelReasonNote,
    Value<String?>? possibleDuplicateOfId,
    Value<String?>? possibleDuplicateOfNumber,
    Value<String?>? historyJson,
    Value<int>? version,
    Value<DateTime?>? clientCreatedAt,
    Value<bool>? isPending,
    Value<DateTime>? createdAt,
    Value<String?>? createdByName,
    Value<DateTime?>? updatedAt,
    Value<String?>? updatedByName,
    Value<int>? rowid,
  }) {
    return DeliveriesCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      clientId: clientId ?? this.clientId,
      number: number ?? this.number,
      requestId: requestId ?? this.requestId,
      unattachedReason: unattachedReason ?? this.unattachedReason,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      freeSupplierName: freeSupplierName ?? this.freeSupplierName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productNameAr: productNameAr ?? this.productNameAr,
      freeProductName: freeProductName ?? this.freeProductName,
      quantityValue: quantityValue ?? this.quantityValue,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      quantityInRequestValue:
          quantityInRequestValue ?? this.quantityInRequestValue,
      quantityInRequestUnit:
          quantityInRequestUnit ?? this.quantityInRequestUnit,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryNoteNumber: deliveryNoteNumber ?? this.deliveryNoteNumber,
      conformity: conformity ?? this.conformity,
      reserveReasonCode: reserveReasonCode ?? this.reserveReasonCode,
      reserveNote: reserveNote ?? this.reserveNote,
      status: status ?? this.status,
      cancelReasonCode: cancelReasonCode ?? this.cancelReasonCode,
      cancelReasonNote: cancelReasonNote ?? this.cancelReasonNote,
      possibleDuplicateOfId:
          possibleDuplicateOfId ?? this.possibleDuplicateOfId,
      possibleDuplicateOfNumber:
          possibleDuplicateOfNumber ?? this.possibleDuplicateOfNumber,
      historyJson: historyJson ?? this.historyJson,
      version: version ?? this.version,
      clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
      isPending: isPending ?? this.isPending,
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
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (unattachedReason.present) {
      map['unattached_reason'] = Variable<String>(unattachedReason.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (freeSupplierName.present) {
      map['free_supplier_name'] = Variable<String>(freeSupplierName.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productNameAr.present) {
      map['product_name_ar'] = Variable<String>(productNameAr.value);
    }
    if (freeProductName.present) {
      map['free_product_name'] = Variable<String>(freeProductName.value);
    }
    if (quantityValue.present) {
      map['quantity_value'] = Variable<String>(
        $DeliveriesTable.$converterquantityValue.toSql(quantityValue.value),
      );
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (quantityInRequestValue.present) {
      map['quantity_in_request_value'] = Variable<String>(
        $DeliveriesTable.$converterquantityInRequestValuen.toSql(
          quantityInRequestValue.value,
        ),
      );
    }
    if (quantityInRequestUnit.present) {
      map['quantity_in_request_unit'] = Variable<String>(
        quantityInRequestUnit.value,
      );
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<String>(
        $DeliveriesTable.$converterdeliveryDate.toSql(deliveryDate.value),
      );
    }
    if (deliveryNoteNumber.present) {
      map['delivery_note_number'] = Variable<String>(deliveryNoteNumber.value);
    }
    if (conformity.present) {
      map['conformity'] = Variable<String>(conformity.value);
    }
    if (reserveReasonCode.present) {
      map['reserve_reason_code'] = Variable<String>(reserveReasonCode.value);
    }
    if (reserveNote.present) {
      map['reserve_note'] = Variable<String>(reserveNote.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cancelReasonCode.present) {
      map['cancel_reason_code'] = Variable<String>(cancelReasonCode.value);
    }
    if (cancelReasonNote.present) {
      map['cancel_reason_note'] = Variable<String>(cancelReasonNote.value);
    }
    if (possibleDuplicateOfId.present) {
      map['possible_duplicate_of_id'] = Variable<String>(
        possibleDuplicateOfId.value,
      );
    }
    if (possibleDuplicateOfNumber.present) {
      map['possible_duplicate_of_number'] = Variable<String>(
        possibleDuplicateOfNumber.value,
      );
    }
    if (historyJson.present) {
      map['history_json'] = Variable<String>(historyJson.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientCreatedAt.present) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt.value);
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
    return (StringBuffer('DeliveriesCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('clientId: $clientId, ')
          ..write('number: $number, ')
          ..write('requestId: $requestId, ')
          ..write('unattachedReason: $unattachedReason, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierName: $supplierName, ')
          ..write('freeSupplierName: $freeSupplierName, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productNameAr: $productNameAr, ')
          ..write('freeProductName: $freeProductName, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('quantityInRequestValue: $quantityInRequestValue, ')
          ..write('quantityInRequestUnit: $quantityInRequestUnit, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryNoteNumber: $deliveryNoteNumber, ')
          ..write('conformity: $conformity, ')
          ..write('reserveReasonCode: $reserveReasonCode, ')
          ..write('reserveNote: $reserveNote, ')
          ..write('status: $status, ')
          ..write('cancelReasonCode: $cancelReasonCode, ')
          ..write('cancelReasonNote: $cancelReasonNote, ')
          ..write('possibleDuplicateOfId: $possibleDuplicateOfId, ')
          ..write('possibleDuplicateOfNumber: $possibleDuplicateOfNumber, ')
          ..write('historyJson: $historyJson, ')
          ..write('version: $version, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('isPending: $isPending, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdByName: $createdByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByName: $updatedByName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveryPhotosTable extends DeliveryPhotos
    with TableInfo<$DeliveryPhotosTable, DeliveryPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryPhotosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<String> deliveryId = GeneratedColumn<String>(
    'delivery_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('image/jpeg'),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentStatusMeta = const VerificationMeta(
    'contentStatus',
  );
  @override
  late final GeneratedColumn<String> contentStatus = GeneratedColumn<String>(
    'content_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pending'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    deliveryId,
    clientId,
    takenAt,
    contentType,
    sizeBytes,
    contentStatus,
    version,
    isPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryPhotoRow> instance, {
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
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('content_status')) {
      context.handle(
        _contentStatusMeta,
        contentStatus.isAcceptableOrUnknown(
          data['content_status']!,
          _contentStatusMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {siteId, clientId},
  ];
  @override
  DeliveryPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryPhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      contentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_status'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pending'],
      )!,
    );
  }

  @override
  $DeliveryPhotosTable createAlias(String alias) {
    return $DeliveryPhotosTable(attachedDatabase, alias);
  }
}

class DeliveryPhotoRow extends DataClass
    implements Insertable<DeliveryPhotoRow> {
  final String id;
  final String siteId;

  /// Livraison portee (identifiant serveur, ou `clientId` d'une livraison encore en attente).
  final String deliveryId;
  final String? clientId;
  final DateTime takenAt;
  final String contentType;
  final int? sizeBytes;

  /// `Pending` (binaire pas encore recu par le serveur) ou `Uploaded`.
  final String contentStatus;
  final int version;
  final bool isPending;
  const DeliveryPhotoRow({
    required this.id,
    required this.siteId,
    required this.deliveryId,
    this.clientId,
    required this.takenAt,
    required this.contentType,
    this.sizeBytes,
    required this.contentStatus,
    required this.version,
    required this.isPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    map['delivery_id'] = Variable<String>(deliveryId);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['content_type'] = Variable<String>(contentType);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['content_status'] = Variable<String>(contentStatus);
    map['version'] = Variable<int>(version);
    map['is_pending'] = Variable<bool>(isPending);
    return map;
  }

  DeliveryPhotosCompanion toCompanion(bool nullToAbsent) {
    return DeliveryPhotosCompanion(
      id: Value(id),
      siteId: Value(siteId),
      deliveryId: Value(deliveryId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      takenAt: Value(takenAt),
      contentType: Value(contentType),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      contentStatus: Value(contentStatus),
      version: Value(version),
      isPending: Value(isPending),
    );
  }

  factory DeliveryPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryPhotoRow(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      deliveryId: serializer.fromJson<String>(json['deliveryId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      contentType: serializer.fromJson<String>(json['contentType']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      contentStatus: serializer.fromJson<String>(json['contentStatus']),
      version: serializer.fromJson<int>(json['version']),
      isPending: serializer.fromJson<bool>(json['isPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'deliveryId': serializer.toJson<String>(deliveryId),
      'clientId': serializer.toJson<String?>(clientId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'contentType': serializer.toJson<String>(contentType),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'contentStatus': serializer.toJson<String>(contentStatus),
      'version': serializer.toJson<int>(version),
      'isPending': serializer.toJson<bool>(isPending),
    };
  }

  DeliveryPhotoRow copyWith({
    String? id,
    String? siteId,
    String? deliveryId,
    Value<String?> clientId = const Value.absent(),
    DateTime? takenAt,
    String? contentType,
    Value<int?> sizeBytes = const Value.absent(),
    String? contentStatus,
    int? version,
    bool? isPending,
  }) => DeliveryPhotoRow(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    deliveryId: deliveryId ?? this.deliveryId,
    clientId: clientId.present ? clientId.value : this.clientId,
    takenAt: takenAt ?? this.takenAt,
    contentType: contentType ?? this.contentType,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    contentStatus: contentStatus ?? this.contentStatus,
    version: version ?? this.version,
    isPending: isPending ?? this.isPending,
  );
  DeliveryPhotoRow copyWithCompanion(DeliveryPhotosCompanion data) {
    return DeliveryPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      contentStatus: data.contentStatus.present
          ? data.contentStatus.value
          : this.contentStatus,
      version: data.version.present ? data.version.value : this.version,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryPhotoRow(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('clientId: $clientId, ')
          ..write('takenAt: $takenAt, ')
          ..write('contentType: $contentType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('contentStatus: $contentStatus, ')
          ..write('version: $version, ')
          ..write('isPending: $isPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    deliveryId,
    clientId,
    takenAt,
    contentType,
    sizeBytes,
    contentStatus,
    version,
    isPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryPhotoRow &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.deliveryId == this.deliveryId &&
          other.clientId == this.clientId &&
          other.takenAt == this.takenAt &&
          other.contentType == this.contentType &&
          other.sizeBytes == this.sizeBytes &&
          other.contentStatus == this.contentStatus &&
          other.version == this.version &&
          other.isPending == this.isPending);
}

class DeliveryPhotosCompanion extends UpdateCompanion<DeliveryPhotoRow> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String> deliveryId;
  final Value<String?> clientId;
  final Value<DateTime> takenAt;
  final Value<String> contentType;
  final Value<int?> sizeBytes;
  final Value<String> contentStatus;
  final Value<int> version;
  final Value<bool> isPending;
  final Value<int> rowid;
  const DeliveryPhotosCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.contentType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.contentStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.isPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveryPhotosCompanion.insert({
    required String id,
    required String siteId,
    required String deliveryId,
    this.clientId = const Value.absent(),
    required DateTime takenAt,
    this.contentType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.contentStatus = const Value.absent(),
    required int version,
    this.isPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       deliveryId = Value(deliveryId),
       takenAt = Value(takenAt),
       version = Value(version);
  static Insertable<DeliveryPhotoRow> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? deliveryId,
    Expression<String>? clientId,
    Expression<DateTime>? takenAt,
    Expression<String>? contentType,
    Expression<int>? sizeBytes,
    Expression<String>? contentStatus,
    Expression<int>? version,
    Expression<bool>? isPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (clientId != null) 'client_id': clientId,
      if (takenAt != null) 'taken_at': takenAt,
      if (contentType != null) 'content_type': contentType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (contentStatus != null) 'content_status': contentStatus,
      if (version != null) 'version': version,
      if (isPending != null) 'is_pending': isPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveryPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String>? deliveryId,
    Value<String?>? clientId,
    Value<DateTime>? takenAt,
    Value<String>? contentType,
    Value<int?>? sizeBytes,
    Value<String>? contentStatus,
    Value<int>? version,
    Value<bool>? isPending,
    Value<int>? rowid,
  }) {
    return DeliveryPhotosCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      deliveryId: deliveryId ?? this.deliveryId,
      clientId: clientId ?? this.clientId,
      takenAt: takenAt ?? this.takenAt,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      contentStatus: contentStatus ?? this.contentStatus,
      version: version ?? this.version,
      isPending: isPending ?? this.isPending,
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
    if (deliveryId.present) {
      map['delivery_id'] = Variable<String>(deliveryId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (contentStatus.present) {
      map['content_status'] = Variable<String>(contentStatus.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isPending.present) {
      map['is_pending'] = Variable<bool>(isPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryPhotosCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('clientId: $clientId, ')
          ..write('takenAt: $takenAt, ')
          ..write('contentType: $contentType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('contentStatus: $contentStatus, ')
          ..write('version: $version, ')
          ..write('isPending: $isPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingPhotoFilesTable extends PendingPhotoFiles
    with TableInfo<$PendingPhotoFilesTable, PendingPhotoFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingPhotoFilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<String> deliveryId = GeneratedColumn<String>(
    'delivery_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('image/jpeg'),
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
    clientId,
    ownerUserId,
    siteId,
    deliveryId,
    relativePath,
    sha256,
    sizeBytes,
    contentType,
    takenAt,
    attempts,
    lastErrorCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_photo_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingPhotoFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  PendingPhotoFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingPhotoFileRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
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
  $PendingPhotoFilesTable createAlias(String alias) {
    return $PendingPhotoFilesTable(attachedDatabase, alias);
  }
}

class PendingPhotoFileRow extends DataClass
    implements Insertable<PendingPhotoFileRow> {
  /// `clientId` de la photo (cree a la prise, pas a l'envoi).
  final String clientId;
  final String ownerUserId;
  final String siteId;

  /// Livraison portee (identifiant serveur, ou `clientId` d'une livraison en attente).
  final String deliveryId;

  /// Chemin **relatif** au dossier prive du proprietaire.
  final String relativePath;
  final String sha256;
  final int sizeBytes;
  final String contentType;
  final DateTime takenAt;
  final int attempts;
  final String? lastErrorCode;
  final DateTime createdAt;
  const PendingPhotoFileRow({
    required this.clientId,
    required this.ownerUserId,
    required this.siteId,
    required this.deliveryId,
    required this.relativePath,
    required this.sha256,
    required this.sizeBytes,
    required this.contentType,
    required this.takenAt,
    required this.attempts,
    this.lastErrorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['site_id'] = Variable<String>(siteId);
    map['delivery_id'] = Variable<String>(deliveryId);
    map['relative_path'] = Variable<String>(relativePath);
    map['sha256'] = Variable<String>(sha256);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['content_type'] = Variable<String>(contentType);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingPhotoFilesCompanion toCompanion(bool nullToAbsent) {
    return PendingPhotoFilesCompanion(
      clientId: Value(clientId),
      ownerUserId: Value(ownerUserId),
      siteId: Value(siteId),
      deliveryId: Value(deliveryId),
      relativePath: Value(relativePath),
      sha256: Value(sha256),
      sizeBytes: Value(sizeBytes),
      contentType: Value(contentType),
      takenAt: Value(takenAt),
      attempts: Value(attempts),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      createdAt: Value(createdAt),
    );
  }

  factory PendingPhotoFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingPhotoFileRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      siteId: serializer.fromJson<String>(json['siteId']),
      deliveryId: serializer.fromJson<String>(json['deliveryId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      contentType: serializer.fromJson<String>(json['contentType']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'siteId': serializer.toJson<String>(siteId),
      'deliveryId': serializer.toJson<String>(deliveryId),
      'relativePath': serializer.toJson<String>(relativePath),
      'sha256': serializer.toJson<String>(sha256),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'contentType': serializer.toJson<String>(contentType),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingPhotoFileRow copyWith({
    String? clientId,
    String? ownerUserId,
    String? siteId,
    String? deliveryId,
    String? relativePath,
    String? sha256,
    int? sizeBytes,
    String? contentType,
    DateTime? takenAt,
    int? attempts,
    Value<String?> lastErrorCode = const Value.absent(),
    DateTime? createdAt,
  }) => PendingPhotoFileRow(
    clientId: clientId ?? this.clientId,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    siteId: siteId ?? this.siteId,
    deliveryId: deliveryId ?? this.deliveryId,
    relativePath: relativePath ?? this.relativePath,
    sha256: sha256 ?? this.sha256,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    contentType: contentType ?? this.contentType,
    takenAt: takenAt ?? this.takenAt,
    attempts: attempts ?? this.attempts,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingPhotoFileRow copyWithCompanion(PendingPhotoFilesCompanion data) {
    return PendingPhotoFileRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingPhotoFileRow(')
          ..write('clientId: $clientId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('siteId: $siteId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('relativePath: $relativePath, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('contentType: $contentType, ')
          ..write('takenAt: $takenAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    ownerUserId,
    siteId,
    deliveryId,
    relativePath,
    sha256,
    sizeBytes,
    contentType,
    takenAt,
    attempts,
    lastErrorCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingPhotoFileRow &&
          other.clientId == this.clientId &&
          other.ownerUserId == this.ownerUserId &&
          other.siteId == this.siteId &&
          other.deliveryId == this.deliveryId &&
          other.relativePath == this.relativePath &&
          other.sha256 == this.sha256 &&
          other.sizeBytes == this.sizeBytes &&
          other.contentType == this.contentType &&
          other.takenAt == this.takenAt &&
          other.attempts == this.attempts &&
          other.lastErrorCode == this.lastErrorCode &&
          other.createdAt == this.createdAt);
}

class PendingPhotoFilesCompanion extends UpdateCompanion<PendingPhotoFileRow> {
  final Value<String> clientId;
  final Value<String> ownerUserId;
  final Value<String> siteId;
  final Value<String> deliveryId;
  final Value<String> relativePath;
  final Value<String> sha256;
  final Value<int> sizeBytes;
  final Value<String> contentType;
  final Value<DateTime> takenAt;
  final Value<int> attempts;
  final Value<String?> lastErrorCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingPhotoFilesCompanion({
    this.clientId = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.contentType = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingPhotoFilesCompanion.insert({
    required String clientId,
    required String ownerUserId,
    required String siteId,
    required String deliveryId,
    required String relativePath,
    required String sha256,
    required int sizeBytes,
    this.contentType = const Value.absent(),
    required DateTime takenAt,
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       ownerUserId = Value(ownerUserId),
       siteId = Value(siteId),
       deliveryId = Value(deliveryId),
       relativePath = Value(relativePath),
       sha256 = Value(sha256),
       sizeBytes = Value(sizeBytes),
       takenAt = Value(takenAt),
       createdAt = Value(createdAt);
  static Insertable<PendingPhotoFileRow> custom({
    Expression<String>? clientId,
    Expression<String>? ownerUserId,
    Expression<String>? siteId,
    Expression<String>? deliveryId,
    Expression<String>? relativePath,
    Expression<String>? sha256,
    Expression<int>? sizeBytes,
    Expression<String>? contentType,
    Expression<DateTime>? takenAt,
    Expression<int>? attempts,
    Expression<String>? lastErrorCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (siteId != null) 'site_id': siteId,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (relativePath != null) 'relative_path': relativePath,
      if (sha256 != null) 'sha256': sha256,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (contentType != null) 'content_type': contentType,
      if (takenAt != null) 'taken_at': takenAt,
      if (attempts != null) 'attempts': attempts,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingPhotoFilesCompanion copyWith({
    Value<String>? clientId,
    Value<String>? ownerUserId,
    Value<String>? siteId,
    Value<String>? deliveryId,
    Value<String>? relativePath,
    Value<String>? sha256,
    Value<int>? sizeBytes,
    Value<String>? contentType,
    Value<DateTime>? takenAt,
    Value<int>? attempts,
    Value<String?>? lastErrorCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingPhotoFilesCompanion(
      clientId: clientId ?? this.clientId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      siteId: siteId ?? this.siteId,
      deliveryId: deliveryId ?? this.deliveryId,
      relativePath: relativePath ?? this.relativePath,
      sha256: sha256 ?? this.sha256,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      contentType: contentType ?? this.contentType,
      takenAt: takenAt ?? this.takenAt,
      attempts: attempts ?? this.attempts,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<String>(deliveryId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingPhotoFilesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('siteId: $siteId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('relativePath: $relativePath, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('contentType: $contentType, ')
          ..write('takenAt: $takenAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
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
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
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
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
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

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
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
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
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
  late final $ProductsTable products = $ProductsTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $MaterialRequestsTable materialRequests = $MaterialRequestsTable(
    this,
  );
  late final $DeliveriesTable deliveries = $DeliveriesTable(this);
  late final $DeliveryPhotosTable deliveryPhotos = $DeliveryPhotosTable(this);
  late final $PendingPhotoFilesTable pendingPhotoFiles =
      $PendingPhotoFilesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
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
  late final Index idxProductsActive = Index(
    'idx_products_active',
    'CREATE INDEX idx_products_active ON products (is_active)',
  );
  late final Index idxMaterialRequestsSiteStatus = Index(
    'idx_material_requests_site_status',
    'CREATE INDEX idx_material_requests_site_status ON material_requests (site_id, status)',
  );
  late final Index idxMaterialRequestsSiteProduct = Index(
    'idx_material_requests_site_product',
    'CREATE INDEX idx_material_requests_site_product ON material_requests (site_id, product_id)',
  );
  late final Index idxDeliveriesSiteRequest = Index(
    'idx_deliveries_site_request',
    'CREATE INDEX idx_deliveries_site_request ON deliveries (site_id, request_id)',
  );
  late final Index idxDeliveryPhotosDelivery = Index(
    'idx_delivery_photos_delivery',
    'CREATE INDEX idx_delivery_photos_delivery ON delivery_photos (delivery_id)',
  );
  late final Index idxPendingPhotoFilesOwner = Index(
    'idx_pending_photo_files_owner',
    'CREATE INDEX idx_pending_photo_files_owner ON pending_photo_files (owner_user_id)',
  );
  late final SitesDao sitesDao = SitesDao(this as AppDatabase);
  late final ZonesDao zonesDao = ZonesDao(this as AppDatabase);
  late final SiteMembersDao siteMembersDao = SiteMembersDao(
    this as AppDatabase,
  );
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  late final UserPrefsDao userPrefsDao = UserPrefsDao(this as AppDatabase);
  late final ProductsDao productsDao = ProductsDao(this as AppDatabase);
  late final SuppliersDao suppliersDao = SuppliersDao(this as AppDatabase);
  late final MaterialRequestsDao materialRequestsDao = MaterialRequestsDao(
    this as AppDatabase,
  );
  late final DeliveriesDao deliveriesDao = DeliveriesDao(this as AppDatabase);
  late final DeliveryPhotosDao deliveryPhotosDao = DeliveryPhotosDao(
    this as AppDatabase,
  );
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
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
    products,
    suppliers,
    materialRequests,
    deliveries,
    deliveryPhotos,
    pendingPhotoFiles,
    appSettings,
    idxZonesSiteId,
    idxSiteMembersSiteId,
    idxOutboxOwnerStatus,
    idxProductsActive,
    idxMaterialRequestsSiteStatus,
    idxMaterialRequestsSiteProduct,
    idxDeliveriesSiteRequest,
    idxDeliveryPhotosDelivery,
    idxPendingPhotoFilesOwner,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sites',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('material_requests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sites',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deliveries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sites',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('delivery_photos', kind: UpdateKind.delete)],
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

  static MultiTypedResultKey<$MaterialRequestsTable, List<MaterialRequestRow>>
  _materialRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.materialRequests,
    aliasName: $_aliasNameGenerator(db.sites.id, db.materialRequests.siteId),
  );

  $$MaterialRequestsTableProcessedTableManager get materialRequestsRefs {
    final manager = $$MaterialRequestsTableTableManager(
      $_db,
      $_db.materialRequests,
    ).filter((f) => f.siteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _materialRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeliveriesTable, List<DeliveryRow>>
  _deliveriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deliveries,
    aliasName: $_aliasNameGenerator(db.sites.id, db.deliveries.siteId),
  );

  $$DeliveriesTableProcessedTableManager get deliveriesRefs {
    final manager = $$DeliveriesTableTableManager(
      $_db,
      $_db.deliveries,
    ).filter((f) => f.siteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_deliveriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeliveryPhotosTable, List<DeliveryPhotoRow>>
  _deliveryPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deliveryPhotos,
    aliasName: $_aliasNameGenerator(db.sites.id, db.deliveryPhotos.siteId),
  );

  $$DeliveryPhotosTableProcessedTableManager get deliveryPhotosRefs {
    final manager = $$DeliveryPhotosTableTableManager(
      $_db,
      $_db.deliveryPhotos,
    ).filter((f) => f.siteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_deliveryPhotosRefsTable($_db));
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

  Expression<bool> materialRequestsRefs(
    Expression<bool> Function($$MaterialRequestsTableFilterComposer f) f,
  ) {
    final $$MaterialRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.materialRequests,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialRequestsTableFilterComposer(
            $db: $db,
            $table: $db.materialRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deliveriesRefs(
    Expression<bool> Function($$DeliveriesTableFilterComposer f) f,
  ) {
    final $$DeliveriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveries,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableFilterComposer(
            $db: $db,
            $table: $db.deliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deliveryPhotosRefs(
    Expression<bool> Function($$DeliveryPhotosTableFilterComposer f) f,
  ) {
    final $$DeliveryPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveryPhotos,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveryPhotosTableFilterComposer(
            $db: $db,
            $table: $db.deliveryPhotos,
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

  Expression<T> materialRequestsRefs<T extends Object>(
    Expression<T> Function($$MaterialRequestsTableAnnotationComposer a) f,
  ) {
    final $$MaterialRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.materialRequests,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.materialRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deliveriesRefs<T extends Object>(
    Expression<T> Function($$DeliveriesTableAnnotationComposer a) f,
  ) {
    final $$DeliveriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveries,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deliveryPhotosRefs<T extends Object>(
    Expression<T> Function($$DeliveryPhotosTableAnnotationComposer a) f,
  ) {
    final $$DeliveryPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveryPhotos,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveryPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveryPhotos,
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
          PrefetchHooks Function({
            bool zonesRefs,
            bool siteMembersRefs,
            bool materialRequestsRefs,
            bool deliveriesRefs,
            bool deliveryPhotosRefs,
          })
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
              ({
                zonesRefs = false,
                siteMembersRefs = false,
                materialRequestsRefs = false,
                deliveriesRefs = false,
                deliveryPhotosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (zonesRefs) db.zones,
                    if (siteMembersRefs) db.siteMembers,
                    if (materialRequestsRefs) db.materialRequests,
                    if (deliveriesRefs) db.deliveries,
                    if (deliveryPhotosRefs) db.deliveryPhotos,
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
                      if (materialRequestsRefs)
                        await $_getPrefetchedData<
                          SiteRow,
                          $SitesTable,
                          MaterialRequestRow
                        >(
                          currentTable: table,
                          referencedTable: $$SitesTableReferences
                              ._materialRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SitesTableReferences(
                                db,
                                table,
                                p0,
                              ).materialRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.siteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deliveriesRefs)
                        await $_getPrefetchedData<
                          SiteRow,
                          $SitesTable,
                          DeliveryRow
                        >(
                          currentTable: table,
                          referencedTable: $$SitesTableReferences
                              ._deliveriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SitesTableReferences(
                                db,
                                table,
                                p0,
                              ).deliveriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.siteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deliveryPhotosRefs)
                        await $_getPrefetchedData<
                          SiteRow,
                          $SitesTable,
                          DeliveryPhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$SitesTableReferences
                              ._deliveryPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SitesTableReferences(
                                db,
                                table,
                                p0,
                              ).deliveryPhotosRefs,
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
      PrefetchHooks Function({
        bool zonesRefs,
        bool siteMembersRefs,
        bool materialRequestsRefs,
        bool deliveriesRefs,
        bool deliveryPhotosRefs,
      })
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
      Value<String?> conflictJson,
      Value<String?> conflictFields,
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
      Value<String?> conflictJson,
      Value<String?> conflictFields,
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

  ColumnFilters<String> get conflictJson => $composableBuilder(
    column: $table.conflictJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictFields => $composableBuilder(
    column: $table.conflictFields,
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

  ColumnOrderings<String> get conflictJson => $composableBuilder(
    column: $table.conflictJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictFields => $composableBuilder(
    column: $table.conflictFields,
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

  GeneratedColumn<String> get conflictJson => $composableBuilder(
    column: $table.conflictJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictFields => $composableBuilder(
    column: $table.conflictFields,
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
                Value<String?> conflictJson = const Value.absent(),
                Value<String?> conflictFields = const Value.absent(),
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
                conflictJson: conflictJson,
                conflictFields: conflictFields,
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
                Value<String?> conflictJson = const Value.absent(),
                Value<String?> conflictFields = const Value.absent(),
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
                conflictJson: conflictJson,
                conflictFields: conflictFields,
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
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String nameFr,
      Value<String?> nameAr,
      required String category,
      required List<String> allowedUnits,
      required String defaultUnit,
      Value<Decimal?> bagMassKg,
      Value<bool> isActive,
      required int version,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> nameFr,
      Value<String?> nameAr,
      Value<String> category,
      Value<List<String>> allowedUnits,
      Value<String> defaultUnit,
      Value<Decimal?> bagMassKg,
      Value<bool> isActive,
      Value<int> version,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get nameFr => $composableBuilder(
    column: $table.nameFr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get allowedUnits => $composableBuilder(
    column: $table.allowedUnits,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get defaultUnit => $composableBuilder(
    column: $table.defaultUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get bagMassKg =>
      $composableBuilder(
        column: $table.bagMassKg,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get nameFr => $composableBuilder(
    column: $table.nameFr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowedUnits => $composableBuilder(
    column: $table.allowedUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultUnit => $composableBuilder(
    column: $table.defaultUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bagMassKg => $composableBuilder(
    column: $table.bagMassKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameFr =>
      $composableBuilder(column: $table.nameFr, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get allowedUnits =>
      $composableBuilder(
        column: $table.allowedUnits,
        builder: (column) => column,
      );

  GeneratedColumn<String> get defaultUnit => $composableBuilder(
    column: $table.defaultUnit,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String> get bagMassKg =>
      $composableBuilder(column: $table.bagMassKg, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameFr = const Value.absent(),
                Value<String?> nameAr = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<List<String>> allowedUnits = const Value.absent(),
                Value<String> defaultUnit = const Value.absent(),
                Value<Decimal?> bagMassKg = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                nameFr: nameFr,
                nameAr: nameAr,
                category: category,
                allowedUnits: allowedUnits,
                defaultUnit: defaultUnit,
                bagMassKg: bagMassKg,
                isActive: isActive,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameFr,
                Value<String?> nameAr = const Value.absent(),
                required String category,
                required List<String> allowedUnits,
                required String defaultUnit,
                Value<Decimal?> bagMassKg = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                nameFr: nameFr,
                nameAr: nameAr,
                category: category,
                allowedUnits: allowedUnits,
                defaultUnit: defaultUnit,
                bagMassKg: bagMassKg,
                isActive: isActive,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$SuppliersTableCreateCompanionBuilder =
    SuppliersCompanion Function({
      required String id,
      required String name,
      required List<String> productIds,
      Value<bool> isActive,
      required int version,
      Value<int> rowid,
    });
typedef $$SuppliersTableUpdateCompanionBuilder =
    SuppliersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<List<String>> productIds,
      Value<bool> isActive,
      Value<int> version,
      Value<int> rowid,
    });

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get productIds => $composableBuilder(
    column: $table.productIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productIds => $composableBuilder(
    column: $table.productIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get productIds =>
      $composableBuilder(
        column: $table.productIds,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          SupplierRow,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (
            SupplierRow,
            BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>,
          ),
          SupplierRow,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<String>> productIds = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                productIds: productIds,
                isActive: isActive,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required List<String> productIds,
                Value<bool> isActive = const Value.absent(),
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                productIds: productIds,
                isActive: isActive,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      SupplierRow,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (
        SupplierRow,
        BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>,
      ),
      SupplierRow,
      PrefetchHooks Function()
    >;
typedef $$MaterialRequestsTableCreateCompanionBuilder =
    MaterialRequestsCompanion Function({
      required String id,
      required String siteId,
      Value<String?> clientId,
      Value<String?> number,
      Value<String?> productId,
      Value<String?> productName,
      Value<String?> productNameAr,
      Value<String?> freeProductName,
      required Decimal quantityValue,
      required String quantityUnit,
      Value<String?> zoneId,
      required DateTime neededBy,
      Value<String> priority,
      Value<String?> note,
      required String status,
      Value<String?> statusReasonCode,
      Value<String?> statusReasonNote,
      Value<Decimal?> receivedValue,
      Value<Decimal?> remainingValue,
      Value<Decimal?> varianceValue,
      Value<Decimal?> variancePercent,
      Value<bool> isSettled,
      Value<String?> possibleDuplicateOfId,
      Value<String?> possibleDuplicateOfNumber,
      Value<bool> hasDeliveryWithoutOrder,
      Value<String?> orderJson,
      Value<String?> historyJson,
      Value<String?> requestedById,
      Value<String?> requestedByName,
      Value<DateTime?> archivedAt,
      Value<String?> archivedByName,
      required int version,
      Value<DateTime?> clientCreatedAt,
      Value<bool> isPending,
      required DateTime createdAt,
      Value<String?> createdByName,
      Value<DateTime?> updatedAt,
      Value<String?> updatedByName,
      Value<int> rowid,
    });
typedef $$MaterialRequestsTableUpdateCompanionBuilder =
    MaterialRequestsCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String?> clientId,
      Value<String?> number,
      Value<String?> productId,
      Value<String?> productName,
      Value<String?> productNameAr,
      Value<String?> freeProductName,
      Value<Decimal> quantityValue,
      Value<String> quantityUnit,
      Value<String?> zoneId,
      Value<DateTime> neededBy,
      Value<String> priority,
      Value<String?> note,
      Value<String> status,
      Value<String?> statusReasonCode,
      Value<String?> statusReasonNote,
      Value<Decimal?> receivedValue,
      Value<Decimal?> remainingValue,
      Value<Decimal?> varianceValue,
      Value<Decimal?> variancePercent,
      Value<bool> isSettled,
      Value<String?> possibleDuplicateOfId,
      Value<String?> possibleDuplicateOfNumber,
      Value<bool> hasDeliveryWithoutOrder,
      Value<String?> orderJson,
      Value<String?> historyJson,
      Value<String?> requestedById,
      Value<String?> requestedByName,
      Value<DateTime?> archivedAt,
      Value<String?> archivedByName,
      Value<int> version,
      Value<DateTime?> clientCreatedAt,
      Value<bool> isPending,
      Value<DateTime> createdAt,
      Value<String?> createdByName,
      Value<DateTime?> updatedAt,
      Value<String?> updatedByName,
      Value<int> rowid,
    });

final class $$MaterialRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaterialRequestsTable,
          MaterialRequestRow
        > {
  $$MaterialRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites.createAlias(
    $_aliasNameGenerator(db.materialRequests.siteId, db.sites.id),
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

class $$MaterialRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialRequestsTable> {
  $$MaterialRequestsTableFilterComposer({
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

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameAr => $composableBuilder(
    column: $table.productNameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeProductName => $composableBuilder(
    column: $table.freeProductName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get quantityValue =>
      $composableBuilder(
        column: $table.quantityValue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get neededBy =>
      $composableBuilder(
        column: $table.neededBy,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusReasonCode => $composableBuilder(
    column: $table.statusReasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusReasonNote => $composableBuilder(
    column: $table.statusReasonNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get receivedValue =>
      $composableBuilder(
        column: $table.receivedValue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String>
  get remainingValue => $composableBuilder(
    column: $table.remainingValue,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get varianceValue =>
      $composableBuilder(
        column: $table.varianceValue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String>
  get variancePercent => $composableBuilder(
    column: $table.variancePercent,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get possibleDuplicateOfId => $composableBuilder(
    column: $table.possibleDuplicateOfId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get possibleDuplicateOfNumber => $composableBuilder(
    column: $table.possibleDuplicateOfNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDeliveryWithoutOrder => $composableBuilder(
    column: $table.hasDeliveryWithoutOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderJson => $composableBuilder(
    column: $table.orderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedById => $composableBuilder(
    column: $table.requestedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedByName => $composableBuilder(
    column: $table.archivedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
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

  ColumnFilters<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
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

class $$MaterialRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialRequestsTable> {
  $$MaterialRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameAr => $composableBuilder(
    column: $table.productNameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeProductName => $composableBuilder(
    column: $table.freeProductName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get neededBy => $composableBuilder(
    column: $table.neededBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusReasonCode => $composableBuilder(
    column: $table.statusReasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusReasonNote => $composableBuilder(
    column: $table.statusReasonNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedValue => $composableBuilder(
    column: $table.receivedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remainingValue => $composableBuilder(
    column: $table.remainingValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get varianceValue => $composableBuilder(
    column: $table.varianceValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variancePercent => $composableBuilder(
    column: $table.variancePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get possibleDuplicateOfId => $composableBuilder(
    column: $table.possibleDuplicateOfId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get possibleDuplicateOfNumber => $composableBuilder(
    column: $table.possibleDuplicateOfNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDeliveryWithoutOrder => $composableBuilder(
    column: $table.hasDeliveryWithoutOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderJson => $composableBuilder(
    column: $table.orderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedById => $composableBuilder(
    column: $table.requestedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedByName => $composableBuilder(
    column: $table.archivedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
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

  ColumnOrderings<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
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

class $$MaterialRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialRequestsTable> {
  $$MaterialRequestsTableAnnotationComposer({
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

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productNameAr => $composableBuilder(
    column: $table.productNameAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeProductName => $composableBuilder(
    column: $table.freeProductName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal, String> get quantityValue =>
      $composableBuilder(
        column: $table.quantityValue,
        builder: (column) => column,
      );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get neededBy =>
      $composableBuilder(column: $table.neededBy, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get statusReasonCode => $composableBuilder(
    column: $table.statusReasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusReasonNote => $composableBuilder(
    column: $table.statusReasonNote,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String> get receivedValue =>
      $composableBuilder(
        column: $table.receivedValue,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get remainingValue =>
      $composableBuilder(
        column: $table.remainingValue,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get varianceValue =>
      $composableBuilder(
        column: $table.varianceValue,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get variancePercent =>
      $composableBuilder(
        column: $table.variancePercent,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isSettled =>
      $composableBuilder(column: $table.isSettled, builder: (column) => column);

  GeneratedColumn<String> get possibleDuplicateOfId => $composableBuilder(
    column: $table.possibleDuplicateOfId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get possibleDuplicateOfNumber => $composableBuilder(
    column: $table.possibleDuplicateOfNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDeliveryWithoutOrder => $composableBuilder(
    column: $table.hasDeliveryWithoutOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderJson =>
      $composableBuilder(column: $table.orderJson, builder: (column) => column);

  GeneratedColumn<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedById => $composableBuilder(
    column: $table.requestedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archivedByName => $composableBuilder(
    column: $table.archivedByName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => column,
  );

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

  GeneratedColumn<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
    builder: (column) => column,
  );

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

class $$MaterialRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialRequestsTable,
          MaterialRequestRow,
          $$MaterialRequestsTableFilterComposer,
          $$MaterialRequestsTableOrderingComposer,
          $$MaterialRequestsTableAnnotationComposer,
          $$MaterialRequestsTableCreateCompanionBuilder,
          $$MaterialRequestsTableUpdateCompanionBuilder,
          (MaterialRequestRow, $$MaterialRequestsTableReferences),
          MaterialRequestRow,
          PrefetchHooks Function({bool siteId})
        > {
  $$MaterialRequestsTableTableManager(
    _$AppDatabase db,
    $MaterialRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> productNameAr = const Value.absent(),
                Value<String?> freeProductName = const Value.absent(),
                Value<Decimal> quantityValue = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<String?> zoneId = const Value.absent(),
                Value<DateTime> neededBy = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> statusReasonCode = const Value.absent(),
                Value<String?> statusReasonNote = const Value.absent(),
                Value<Decimal?> receivedValue = const Value.absent(),
                Value<Decimal?> remainingValue = const Value.absent(),
                Value<Decimal?> varianceValue = const Value.absent(),
                Value<Decimal?> variancePercent = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<String?> possibleDuplicateOfId = const Value.absent(),
                Value<String?> possibleDuplicateOfNumber = const Value.absent(),
                Value<bool> hasDeliveryWithoutOrder = const Value.absent(),
                Value<String?> orderJson = const Value.absent(),
                Value<String?> historyJson = const Value.absent(),
                Value<String?> requestedById = const Value.absent(),
                Value<String?> requestedByName = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String?> archivedByName = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> clientCreatedAt = const Value.absent(),
                Value<bool> isPending = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialRequestsCompanion(
                id: id,
                siteId: siteId,
                clientId: clientId,
                number: number,
                productId: productId,
                productName: productName,
                productNameAr: productNameAr,
                freeProductName: freeProductName,
                quantityValue: quantityValue,
                quantityUnit: quantityUnit,
                zoneId: zoneId,
                neededBy: neededBy,
                priority: priority,
                note: note,
                status: status,
                statusReasonCode: statusReasonCode,
                statusReasonNote: statusReasonNote,
                receivedValue: receivedValue,
                remainingValue: remainingValue,
                varianceValue: varianceValue,
                variancePercent: variancePercent,
                isSettled: isSettled,
                possibleDuplicateOfId: possibleDuplicateOfId,
                possibleDuplicateOfNumber: possibleDuplicateOfNumber,
                hasDeliveryWithoutOrder: hasDeliveryWithoutOrder,
                orderJson: orderJson,
                historyJson: historyJson,
                requestedById: requestedById,
                requestedByName: requestedByName,
                archivedAt: archivedAt,
                archivedByName: archivedByName,
                version: version,
                clientCreatedAt: clientCreatedAt,
                isPending: isPending,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                updatedByName: updatedByName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                Value<String?> clientId = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> productNameAr = const Value.absent(),
                Value<String?> freeProductName = const Value.absent(),
                required Decimal quantityValue,
                required String quantityUnit,
                Value<String?> zoneId = const Value.absent(),
                required DateTime neededBy,
                Value<String> priority = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String status,
                Value<String?> statusReasonCode = const Value.absent(),
                Value<String?> statusReasonNote = const Value.absent(),
                Value<Decimal?> receivedValue = const Value.absent(),
                Value<Decimal?> remainingValue = const Value.absent(),
                Value<Decimal?> varianceValue = const Value.absent(),
                Value<Decimal?> variancePercent = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<String?> possibleDuplicateOfId = const Value.absent(),
                Value<String?> possibleDuplicateOfNumber = const Value.absent(),
                Value<bool> hasDeliveryWithoutOrder = const Value.absent(),
                Value<String?> orderJson = const Value.absent(),
                Value<String?> historyJson = const Value.absent(),
                Value<String?> requestedById = const Value.absent(),
                Value<String?> requestedByName = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String?> archivedByName = const Value.absent(),
                required int version,
                Value<DateTime?> clientCreatedAt = const Value.absent(),
                Value<bool> isPending = const Value.absent(),
                required DateTime createdAt,
                Value<String?> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialRequestsCompanion.insert(
                id: id,
                siteId: siteId,
                clientId: clientId,
                number: number,
                productId: productId,
                productName: productName,
                productNameAr: productNameAr,
                freeProductName: freeProductName,
                quantityValue: quantityValue,
                quantityUnit: quantityUnit,
                zoneId: zoneId,
                neededBy: neededBy,
                priority: priority,
                note: note,
                status: status,
                statusReasonCode: statusReasonCode,
                statusReasonNote: statusReasonNote,
                receivedValue: receivedValue,
                remainingValue: remainingValue,
                varianceValue: varianceValue,
                variancePercent: variancePercent,
                isSettled: isSettled,
                possibleDuplicateOfId: possibleDuplicateOfId,
                possibleDuplicateOfNumber: possibleDuplicateOfNumber,
                hasDeliveryWithoutOrder: hasDeliveryWithoutOrder,
                orderJson: orderJson,
                historyJson: historyJson,
                requestedById: requestedById,
                requestedByName: requestedByName,
                archivedAt: archivedAt,
                archivedByName: archivedByName,
                version: version,
                clientCreatedAt: clientCreatedAt,
                isPending: isPending,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                updatedByName: updatedByName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaterialRequestsTableReferences(db, table, e),
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
                                referencedTable:
                                    $$MaterialRequestsTableReferences
                                        ._siteIdTable(db),
                                referencedColumn:
                                    $$MaterialRequestsTableReferences
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

typedef $$MaterialRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialRequestsTable,
      MaterialRequestRow,
      $$MaterialRequestsTableFilterComposer,
      $$MaterialRequestsTableOrderingComposer,
      $$MaterialRequestsTableAnnotationComposer,
      $$MaterialRequestsTableCreateCompanionBuilder,
      $$MaterialRequestsTableUpdateCompanionBuilder,
      (MaterialRequestRow, $$MaterialRequestsTableReferences),
      MaterialRequestRow,
      PrefetchHooks Function({bool siteId})
    >;
typedef $$DeliveriesTableCreateCompanionBuilder =
    DeliveriesCompanion Function({
      required String id,
      required String siteId,
      Value<String?> clientId,
      Value<String?> number,
      Value<String?> requestId,
      Value<String?> unattachedReason,
      Value<String?> supplierId,
      Value<String?> supplierName,
      Value<String?> freeSupplierName,
      Value<String?> productId,
      Value<String?> productName,
      Value<String?> productNameAr,
      Value<String?> freeProductName,
      required Decimal quantityValue,
      required String quantityUnit,
      Value<Decimal?> quantityInRequestValue,
      Value<String?> quantityInRequestUnit,
      required DateTime deliveryDate,
      Value<String?> deliveryNoteNumber,
      Value<String> conformity,
      Value<String?> reserveReasonCode,
      Value<String?> reserveNote,
      Value<String> status,
      Value<String?> cancelReasonCode,
      Value<String?> cancelReasonNote,
      Value<String?> possibleDuplicateOfId,
      Value<String?> possibleDuplicateOfNumber,
      Value<String?> historyJson,
      required int version,
      Value<DateTime?> clientCreatedAt,
      Value<bool> isPending,
      required DateTime createdAt,
      Value<String?> createdByName,
      Value<DateTime?> updatedAt,
      Value<String?> updatedByName,
      Value<int> rowid,
    });
typedef $$DeliveriesTableUpdateCompanionBuilder =
    DeliveriesCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String?> clientId,
      Value<String?> number,
      Value<String?> requestId,
      Value<String?> unattachedReason,
      Value<String?> supplierId,
      Value<String?> supplierName,
      Value<String?> freeSupplierName,
      Value<String?> productId,
      Value<String?> productName,
      Value<String?> productNameAr,
      Value<String?> freeProductName,
      Value<Decimal> quantityValue,
      Value<String> quantityUnit,
      Value<Decimal?> quantityInRequestValue,
      Value<String?> quantityInRequestUnit,
      Value<DateTime> deliveryDate,
      Value<String?> deliveryNoteNumber,
      Value<String> conformity,
      Value<String?> reserveReasonCode,
      Value<String?> reserveNote,
      Value<String> status,
      Value<String?> cancelReasonCode,
      Value<String?> cancelReasonNote,
      Value<String?> possibleDuplicateOfId,
      Value<String?> possibleDuplicateOfNumber,
      Value<String?> historyJson,
      Value<int> version,
      Value<DateTime?> clientCreatedAt,
      Value<bool> isPending,
      Value<DateTime> createdAt,
      Value<String?> createdByName,
      Value<DateTime?> updatedAt,
      Value<String?> updatedByName,
      Value<int> rowid,
    });

final class $$DeliveriesTableReferences
    extends BaseReferences<_$AppDatabase, $DeliveriesTable, DeliveryRow> {
  $$DeliveriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites.createAlias(
    $_aliasNameGenerator(db.deliveries.siteId, db.sites.id),
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

class $$DeliveriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableFilterComposer({
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

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unattachedReason => $composableBuilder(
    column: $table.unattachedReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeSupplierName => $composableBuilder(
    column: $table.freeSupplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameAr => $composableBuilder(
    column: $table.productNameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeProductName => $composableBuilder(
    column: $table.freeProductName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get quantityValue =>
      $composableBuilder(
        column: $table.quantityValue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String>
  get quantityInRequestValue => $composableBuilder(
    column: $table.quantityInRequestValue,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get quantityInRequestUnit => $composableBuilder(
    column: $table.quantityInRequestUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get deliveryDate =>
      $composableBuilder(
        column: $table.deliveryDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get deliveryNoteNumber => $composableBuilder(
    column: $table.deliveryNoteNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conformity => $composableBuilder(
    column: $table.conformity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reserveReasonCode => $composableBuilder(
    column: $table.reserveReasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reserveNote => $composableBuilder(
    column: $table.reserveNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReasonCode => $composableBuilder(
    column: $table.cancelReasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReasonNote => $composableBuilder(
    column: $table.cancelReasonNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get possibleDuplicateOfId => $composableBuilder(
    column: $table.possibleDuplicateOfId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get possibleDuplicateOfNumber => $composableBuilder(
    column: $table.possibleDuplicateOfNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
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

  ColumnFilters<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
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

class $$DeliveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableOrderingComposer({
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

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unattachedReason => $composableBuilder(
    column: $table.unattachedReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeSupplierName => $composableBuilder(
    column: $table.freeSupplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameAr => $composableBuilder(
    column: $table.productNameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeProductName => $composableBuilder(
    column: $table.freeProductName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityInRequestValue => $composableBuilder(
    column: $table.quantityInRequestValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityInRequestUnit => $composableBuilder(
    column: $table.quantityInRequestUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryNoteNumber => $composableBuilder(
    column: $table.deliveryNoteNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conformity => $composableBuilder(
    column: $table.conformity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reserveReasonCode => $composableBuilder(
    column: $table.reserveReasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reserveNote => $composableBuilder(
    column: $table.reserveNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReasonCode => $composableBuilder(
    column: $table.cancelReasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReasonNote => $composableBuilder(
    column: $table.cancelReasonNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get possibleDuplicateOfId => $composableBuilder(
    column: $table.possibleDuplicateOfId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get possibleDuplicateOfNumber => $composableBuilder(
    column: $table.possibleDuplicateOfNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
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

  ColumnOrderings<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
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

class $$DeliveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableAnnotationComposer({
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

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get unattachedReason => $composableBuilder(
    column: $table.unattachedReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeSupplierName => $composableBuilder(
    column: $table.freeSupplierName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productNameAr => $composableBuilder(
    column: $table.productNameAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeProductName => $composableBuilder(
    column: $table.freeProductName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal, String> get quantityValue =>
      $composableBuilder(
        column: $table.quantityValue,
        builder: (column) => column,
      );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String>
  get quantityInRequestValue => $composableBuilder(
    column: $table.quantityInRequestValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityInRequestUnit => $composableBuilder(
    column: $table.quantityInRequestUnit,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get deliveryDate =>
      $composableBuilder(
        column: $table.deliveryDate,
        builder: (column) => column,
      );

  GeneratedColumn<String> get deliveryNoteNumber => $composableBuilder(
    column: $table.deliveryNoteNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conformity => $composableBuilder(
    column: $table.conformity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reserveReasonCode => $composableBuilder(
    column: $table.reserveReasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reserveNote => $composableBuilder(
    column: $table.reserveNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get cancelReasonCode => $composableBuilder(
    column: $table.cancelReasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelReasonNote => $composableBuilder(
    column: $table.cancelReasonNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get possibleDuplicateOfId => $composableBuilder(
    column: $table.possibleDuplicateOfId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get possibleDuplicateOfNumber => $composableBuilder(
    column: $table.possibleDuplicateOfNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => column,
  );

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

  GeneratedColumn<String> get updatedByName => $composableBuilder(
    column: $table.updatedByName,
    builder: (column) => column,
  );

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

class $$DeliveriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveriesTable,
          DeliveryRow,
          $$DeliveriesTableFilterComposer,
          $$DeliveriesTableOrderingComposer,
          $$DeliveriesTableAnnotationComposer,
          $$DeliveriesTableCreateCompanionBuilder,
          $$DeliveriesTableUpdateCompanionBuilder,
          (DeliveryRow, $$DeliveriesTableReferences),
          DeliveryRow,
          PrefetchHooks Function({bool siteId})
        > {
  $$DeliveriesTableTableManager(_$AppDatabase db, $DeliveriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> unattachedReason = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplierName = const Value.absent(),
                Value<String?> freeSupplierName = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> productNameAr = const Value.absent(),
                Value<String?> freeProductName = const Value.absent(),
                Value<Decimal> quantityValue = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<Decimal?> quantityInRequestValue = const Value.absent(),
                Value<String?> quantityInRequestUnit = const Value.absent(),
                Value<DateTime> deliveryDate = const Value.absent(),
                Value<String?> deliveryNoteNumber = const Value.absent(),
                Value<String> conformity = const Value.absent(),
                Value<String?> reserveReasonCode = const Value.absent(),
                Value<String?> reserveNote = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> cancelReasonCode = const Value.absent(),
                Value<String?> cancelReasonNote = const Value.absent(),
                Value<String?> possibleDuplicateOfId = const Value.absent(),
                Value<String?> possibleDuplicateOfNumber = const Value.absent(),
                Value<String?> historyJson = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> clientCreatedAt = const Value.absent(),
                Value<bool> isPending = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveriesCompanion(
                id: id,
                siteId: siteId,
                clientId: clientId,
                number: number,
                requestId: requestId,
                unattachedReason: unattachedReason,
                supplierId: supplierId,
                supplierName: supplierName,
                freeSupplierName: freeSupplierName,
                productId: productId,
                productName: productName,
                productNameAr: productNameAr,
                freeProductName: freeProductName,
                quantityValue: quantityValue,
                quantityUnit: quantityUnit,
                quantityInRequestValue: quantityInRequestValue,
                quantityInRequestUnit: quantityInRequestUnit,
                deliveryDate: deliveryDate,
                deliveryNoteNumber: deliveryNoteNumber,
                conformity: conformity,
                reserveReasonCode: reserveReasonCode,
                reserveNote: reserveNote,
                status: status,
                cancelReasonCode: cancelReasonCode,
                cancelReasonNote: cancelReasonNote,
                possibleDuplicateOfId: possibleDuplicateOfId,
                possibleDuplicateOfNumber: possibleDuplicateOfNumber,
                historyJson: historyJson,
                version: version,
                clientCreatedAt: clientCreatedAt,
                isPending: isPending,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                updatedByName: updatedByName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                Value<String?> clientId = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> unattachedReason = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplierName = const Value.absent(),
                Value<String?> freeSupplierName = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> productNameAr = const Value.absent(),
                Value<String?> freeProductName = const Value.absent(),
                required Decimal quantityValue,
                required String quantityUnit,
                Value<Decimal?> quantityInRequestValue = const Value.absent(),
                Value<String?> quantityInRequestUnit = const Value.absent(),
                required DateTime deliveryDate,
                Value<String?> deliveryNoteNumber = const Value.absent(),
                Value<String> conformity = const Value.absent(),
                Value<String?> reserveReasonCode = const Value.absent(),
                Value<String?> reserveNote = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> cancelReasonCode = const Value.absent(),
                Value<String?> cancelReasonNote = const Value.absent(),
                Value<String?> possibleDuplicateOfId = const Value.absent(),
                Value<String?> possibleDuplicateOfNumber = const Value.absent(),
                Value<String?> historyJson = const Value.absent(),
                required int version,
                Value<DateTime?> clientCreatedAt = const Value.absent(),
                Value<bool> isPending = const Value.absent(),
                required DateTime createdAt,
                Value<String?> createdByName = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveriesCompanion.insert(
                id: id,
                siteId: siteId,
                clientId: clientId,
                number: number,
                requestId: requestId,
                unattachedReason: unattachedReason,
                supplierId: supplierId,
                supplierName: supplierName,
                freeSupplierName: freeSupplierName,
                productId: productId,
                productName: productName,
                productNameAr: productNameAr,
                freeProductName: freeProductName,
                quantityValue: quantityValue,
                quantityUnit: quantityUnit,
                quantityInRequestValue: quantityInRequestValue,
                quantityInRequestUnit: quantityInRequestUnit,
                deliveryDate: deliveryDate,
                deliveryNoteNumber: deliveryNoteNumber,
                conformity: conformity,
                reserveReasonCode: reserveReasonCode,
                reserveNote: reserveNote,
                status: status,
                cancelReasonCode: cancelReasonCode,
                cancelReasonNote: cancelReasonNote,
                possibleDuplicateOfId: possibleDuplicateOfId,
                possibleDuplicateOfNumber: possibleDuplicateOfNumber,
                historyJson: historyJson,
                version: version,
                clientCreatedAt: clientCreatedAt,
                isPending: isPending,
                createdAt: createdAt,
                createdByName: createdByName,
                updatedAt: updatedAt,
                updatedByName: updatedByName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeliveriesTableReferences(db, table, e),
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
                                referencedTable: $$DeliveriesTableReferences
                                    ._siteIdTable(db),
                                referencedColumn: $$DeliveriesTableReferences
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

typedef $$DeliveriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveriesTable,
      DeliveryRow,
      $$DeliveriesTableFilterComposer,
      $$DeliveriesTableOrderingComposer,
      $$DeliveriesTableAnnotationComposer,
      $$DeliveriesTableCreateCompanionBuilder,
      $$DeliveriesTableUpdateCompanionBuilder,
      (DeliveryRow, $$DeliveriesTableReferences),
      DeliveryRow,
      PrefetchHooks Function({bool siteId})
    >;
typedef $$DeliveryPhotosTableCreateCompanionBuilder =
    DeliveryPhotosCompanion Function({
      required String id,
      required String siteId,
      required String deliveryId,
      Value<String?> clientId,
      required DateTime takenAt,
      Value<String> contentType,
      Value<int?> sizeBytes,
      Value<String> contentStatus,
      required int version,
      Value<bool> isPending,
      Value<int> rowid,
    });
typedef $$DeliveryPhotosTableUpdateCompanionBuilder =
    DeliveryPhotosCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String> deliveryId,
      Value<String?> clientId,
      Value<DateTime> takenAt,
      Value<String> contentType,
      Value<int?> sizeBytes,
      Value<String> contentStatus,
      Value<int> version,
      Value<bool> isPending,
      Value<int> rowid,
    });

final class $$DeliveryPhotosTableReferences
    extends
        BaseReferences<_$AppDatabase, $DeliveryPhotosTable, DeliveryPhotoRow> {
  $$DeliveryPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites.createAlias(
    $_aliasNameGenerator(db.deliveryPhotos.siteId, db.sites.id),
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

class $$DeliveryPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryPhotosTable> {
  $$DeliveryPhotosTableFilterComposer({
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

  ColumnFilters<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentStatus => $composableBuilder(
    column: $table.contentStatus,
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

class $$DeliveryPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryPhotosTable> {
  $$DeliveryPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentStatus => $composableBuilder(
    column: $table.contentStatus,
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

class $$DeliveryPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryPhotosTable> {
  $$DeliveryPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get contentStatus => $composableBuilder(
    column: $table.contentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isPending =>
      $composableBuilder(column: $table.isPending, builder: (column) => column);

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

class $$DeliveryPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveryPhotosTable,
          DeliveryPhotoRow,
          $$DeliveryPhotosTableFilterComposer,
          $$DeliveryPhotosTableOrderingComposer,
          $$DeliveryPhotosTableAnnotationComposer,
          $$DeliveryPhotosTableCreateCompanionBuilder,
          $$DeliveryPhotosTableUpdateCompanionBuilder,
          (DeliveryPhotoRow, $$DeliveryPhotosTableReferences),
          DeliveryPhotoRow,
          PrefetchHooks Function({bool siteId})
        > {
  $$DeliveryPhotosTableTableManager(
    _$AppDatabase db,
    $DeliveryPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> deliveryId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String> contentStatus = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveryPhotosCompanion(
                id: id,
                siteId: siteId,
                deliveryId: deliveryId,
                clientId: clientId,
                takenAt: takenAt,
                contentType: contentType,
                sizeBytes: sizeBytes,
                contentStatus: contentStatus,
                version: version,
                isPending: isPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                required String deliveryId,
                Value<String?> clientId = const Value.absent(),
                required DateTime takenAt,
                Value<String> contentType = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String> contentStatus = const Value.absent(),
                required int version,
                Value<bool> isPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveryPhotosCompanion.insert(
                id: id,
                siteId: siteId,
                deliveryId: deliveryId,
                clientId: clientId,
                takenAt: takenAt,
                contentType: contentType,
                sizeBytes: sizeBytes,
                contentStatus: contentStatus,
                version: version,
                isPending: isPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeliveryPhotosTableReferences(db, table, e),
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
                                referencedTable: $$DeliveryPhotosTableReferences
                                    ._siteIdTable(db),
                                referencedColumn:
                                    $$DeliveryPhotosTableReferences
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

typedef $$DeliveryPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveryPhotosTable,
      DeliveryPhotoRow,
      $$DeliveryPhotosTableFilterComposer,
      $$DeliveryPhotosTableOrderingComposer,
      $$DeliveryPhotosTableAnnotationComposer,
      $$DeliveryPhotosTableCreateCompanionBuilder,
      $$DeliveryPhotosTableUpdateCompanionBuilder,
      (DeliveryPhotoRow, $$DeliveryPhotosTableReferences),
      DeliveryPhotoRow,
      PrefetchHooks Function({bool siteId})
    >;
typedef $$PendingPhotoFilesTableCreateCompanionBuilder =
    PendingPhotoFilesCompanion Function({
      required String clientId,
      required String ownerUserId,
      required String siteId,
      required String deliveryId,
      required String relativePath,
      required String sha256,
      required int sizeBytes,
      Value<String> contentType,
      required DateTime takenAt,
      Value<int> attempts,
      Value<String?> lastErrorCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingPhotoFilesTableUpdateCompanionBuilder =
    PendingPhotoFilesCompanion Function({
      Value<String> clientId,
      Value<String> ownerUserId,
      Value<String> siteId,
      Value<String> deliveryId,
      Value<String> relativePath,
      Value<String> sha256,
      Value<int> sizeBytes,
      Value<String> contentType,
      Value<DateTime> takenAt,
      Value<int> attempts,
      Value<String?> lastErrorCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingPhotoFilesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingPhotoFilesTable> {
  $$PendingPhotoFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
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

class $$PendingPhotoFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingPhotoFilesTable> {
  $$PendingPhotoFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
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

class $$PendingPhotoFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingPhotoFilesTable> {
  $$PendingPhotoFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingPhotoFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingPhotoFilesTable,
          PendingPhotoFileRow,
          $$PendingPhotoFilesTableFilterComposer,
          $$PendingPhotoFilesTableOrderingComposer,
          $$PendingPhotoFilesTableAnnotationComposer,
          $$PendingPhotoFilesTableCreateCompanionBuilder,
          $$PendingPhotoFilesTableUpdateCompanionBuilder,
          (
            PendingPhotoFileRow,
            BaseReferences<
              _$AppDatabase,
              $PendingPhotoFilesTable,
              PendingPhotoFileRow
            >,
          ),
          PendingPhotoFileRow,
          PrefetchHooks Function()
        > {
  $$PendingPhotoFilesTableTableManager(
    _$AppDatabase db,
    $PendingPhotoFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingPhotoFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingPhotoFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingPhotoFilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<String> ownerUserId = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> deliveryId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingPhotoFilesCompanion(
                clientId: clientId,
                ownerUserId: ownerUserId,
                siteId: siteId,
                deliveryId: deliveryId,
                relativePath: relativePath,
                sha256: sha256,
                sizeBytes: sizeBytes,
                contentType: contentType,
                takenAt: takenAt,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required String ownerUserId,
                required String siteId,
                required String deliveryId,
                required String relativePath,
                required String sha256,
                required int sizeBytes,
                Value<String> contentType = const Value.absent(),
                required DateTime takenAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingPhotoFilesCompanion.insert(
                clientId: clientId,
                ownerUserId: ownerUserId,
                siteId: siteId,
                deliveryId: deliveryId,
                relativePath: relativePath,
                sha256: sha256,
                sizeBytes: sizeBytes,
                contentType: contentType,
                takenAt: takenAt,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingPhotoFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingPhotoFilesTable,
      PendingPhotoFileRow,
      $$PendingPhotoFilesTableFilterComposer,
      $$PendingPhotoFilesTableOrderingComposer,
      $$PendingPhotoFilesTableAnnotationComposer,
      $$PendingPhotoFilesTableCreateCompanionBuilder,
      $$PendingPhotoFilesTableUpdateCompanionBuilder,
      (
        PendingPhotoFileRow,
        BaseReferences<
          _$AppDatabase,
          $PendingPhotoFilesTable,
          PendingPhotoFileRow
        >,
      ),
      PendingPhotoFileRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
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
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$MaterialRequestsTableTableManager get materialRequests =>
      $$MaterialRequestsTableTableManager(_db, _db.materialRequests);
  $$DeliveriesTableTableManager get deliveries =>
      $$DeliveriesTableTableManager(_db, _db.deliveries);
  $$DeliveryPhotosTableTableManager get deliveryPhotos =>
      $$DeliveryPhotosTableTableManager(_db, _db.deliveryPhotos);
  $$PendingPhotoFilesTableTableManager get pendingPhotoFiles =>
      $$PendingPhotoFilesTableTableManager(_db, _db.pendingPhotoFiles);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
