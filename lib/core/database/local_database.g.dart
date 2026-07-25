// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $AthletesTable extends Athletes with TableInfo<$AthletesTable, Athlete> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AthletesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kanaMeta = const VerificationMeta('kana');
  @override
  late final GeneratedColumn<String> kana = GeneratedColumn<String>(
    'kana',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jerseyNumberMeta = const VerificationMeta(
    'jerseyNumber',
  );
  @override
  late final GeneratedColumn<int> jerseyNumber = GeneratedColumn<int>(
    'jersey_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _coachCommentMeta = const VerificationMeta(
    'coachComment',
  );
  @override
  late final GeneratedColumn<String> coachComment = GeneratedColumn<String>(
    'coach_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kana,
    grade,
    position,
    birthDate,
    photoPath,
    jerseyNumber,
    isActive,
    coachComment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'athletes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Athlete> instance, {
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
    if (data.containsKey('kana')) {
      context.handle(
        _kanaMeta,
        kana.isAcceptableOrUnknown(data['kana']!, _kanaMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('jersey_number')) {
      context.handle(
        _jerseyNumberMeta,
        jerseyNumber.isAcceptableOrUnknown(
          data['jersey_number']!,
          _jerseyNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('coach_comment')) {
      context.handle(
        _coachCommentMeta,
        coachComment.isAcceptableOrUnknown(
          data['coach_comment']!,
          _coachCommentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Athlete map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Athlete(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kana'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      jerseyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jersey_number'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      coachComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coach_comment'],
      ),
    );
  }

  @override
  $AthletesTable createAlias(String alias) {
    return $AthletesTable(attachedDatabase, alias);
  }
}

class Athlete extends DataClass implements Insertable<Athlete> {
  final String id;
  final String name;
  final String? kana;
  final int grade;
  final String? position;
  final DateTime? birthDate;
  final String? photoPath;
  final int? jerseyNumber;
  final bool isActive;

  /// コーチが自由記述するコメント（選手個人ページで編集）。
  final String? coachComment;
  const Athlete({
    required this.id,
    required this.name,
    this.kana,
    required this.grade,
    this.position,
    this.birthDate,
    this.photoPath,
    this.jerseyNumber,
    required this.isActive,
    this.coachComment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || kana != null) {
      map['kana'] = Variable<String>(kana);
    }
    map['grade'] = Variable<int>(grade);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || jerseyNumber != null) {
      map['jersey_number'] = Variable<int>(jerseyNumber);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || coachComment != null) {
      map['coach_comment'] = Variable<String>(coachComment);
    }
    return map;
  }

  AthletesCompanion toCompanion(bool nullToAbsent) {
    return AthletesCompanion(
      id: Value(id),
      name: Value(name),
      kana: kana == null && nullToAbsent ? const Value.absent() : Value(kana),
      grade: Value(grade),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      jerseyNumber: jerseyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(jerseyNumber),
      isActive: Value(isActive),
      coachComment: coachComment == null && nullToAbsent
          ? const Value.absent()
          : Value(coachComment),
    );
  }

  factory Athlete.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Athlete(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kana: serializer.fromJson<String?>(json['kana']),
      grade: serializer.fromJson<int>(json['grade']),
      position: serializer.fromJson<String?>(json['position']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      jerseyNumber: serializer.fromJson<int?>(json['jerseyNumber']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      coachComment: serializer.fromJson<String?>(json['coachComment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kana': serializer.toJson<String?>(kana),
      'grade': serializer.toJson<int>(grade),
      'position': serializer.toJson<String?>(position),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'photoPath': serializer.toJson<String?>(photoPath),
      'jerseyNumber': serializer.toJson<int?>(jerseyNumber),
      'isActive': serializer.toJson<bool>(isActive),
      'coachComment': serializer.toJson<String?>(coachComment),
    };
  }

  Athlete copyWith({
    String? id,
    String? name,
    Value<String?> kana = const Value.absent(),
    int? grade,
    Value<String?> position = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<int?> jerseyNumber = const Value.absent(),
    bool? isActive,
    Value<String?> coachComment = const Value.absent(),
  }) => Athlete(
    id: id ?? this.id,
    name: name ?? this.name,
    kana: kana.present ? kana.value : this.kana,
    grade: grade ?? this.grade,
    position: position.present ? position.value : this.position,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    jerseyNumber: jerseyNumber.present ? jerseyNumber.value : this.jerseyNumber,
    isActive: isActive ?? this.isActive,
    coachComment: coachComment.present ? coachComment.value : this.coachComment,
  );
  Athlete copyWithCompanion(AthletesCompanion data) {
    return Athlete(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kana: data.kana.present ? data.kana.value : this.kana,
      grade: data.grade.present ? data.grade.value : this.grade,
      position: data.position.present ? data.position.value : this.position,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      jerseyNumber: data.jerseyNumber.present
          ? data.jerseyNumber.value
          : this.jerseyNumber,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      coachComment: data.coachComment.present
          ? data.coachComment.value
          : this.coachComment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Athlete(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kana: $kana, ')
          ..write('grade: $grade, ')
          ..write('position: $position, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoPath: $photoPath, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('isActive: $isActive, ')
          ..write('coachComment: $coachComment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kana,
    grade,
    position,
    birthDate,
    photoPath,
    jerseyNumber,
    isActive,
    coachComment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Athlete &&
          other.id == this.id &&
          other.name == this.name &&
          other.kana == this.kana &&
          other.grade == this.grade &&
          other.position == this.position &&
          other.birthDate == this.birthDate &&
          other.photoPath == this.photoPath &&
          other.jerseyNumber == this.jerseyNumber &&
          other.isActive == this.isActive &&
          other.coachComment == this.coachComment);
}

class AthletesCompanion extends UpdateCompanion<Athlete> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> kana;
  final Value<int> grade;
  final Value<String?> position;
  final Value<DateTime?> birthDate;
  final Value<String?> photoPath;
  final Value<int?> jerseyNumber;
  final Value<bool> isActive;
  final Value<String?> coachComment;
  final Value<int> rowid;
  const AthletesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kana = const Value.absent(),
    this.grade = const Value.absent(),
    this.position = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.isActive = const Value.absent(),
    this.coachComment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AthletesCompanion.insert({
    required String id,
    required String name,
    this.kana = const Value.absent(),
    required int grade,
    this.position = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.isActive = const Value.absent(),
    this.coachComment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       grade = Value(grade);
  static Insertable<Athlete> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kana,
    Expression<int>? grade,
    Expression<String>? position,
    Expression<DateTime>? birthDate,
    Expression<String>? photoPath,
    Expression<int>? jerseyNumber,
    Expression<bool>? isActive,
    Expression<String>? coachComment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kana != null) 'kana': kana,
      if (grade != null) 'grade': grade,
      if (position != null) 'position': position,
      if (birthDate != null) 'birth_date': birthDate,
      if (photoPath != null) 'photo_path': photoPath,
      if (jerseyNumber != null) 'jersey_number': jerseyNumber,
      if (isActive != null) 'is_active': isActive,
      if (coachComment != null) 'coach_comment': coachComment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AthletesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? kana,
    Value<int>? grade,
    Value<String?>? position,
    Value<DateTime?>? birthDate,
    Value<String?>? photoPath,
    Value<int?>? jerseyNumber,
    Value<bool>? isActive,
    Value<String?>? coachComment,
    Value<int>? rowid,
  }) {
    return AthletesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kana: kana ?? this.kana,
      grade: grade ?? this.grade,
      position: position ?? this.position,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      isActive: isActive ?? this.isActive,
      coachComment: coachComment ?? this.coachComment,
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
    if (kana.present) {
      map['kana'] = Variable<String>(kana.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (jerseyNumber.present) {
      map['jersey_number'] = Variable<int>(jerseyNumber.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (coachComment.present) {
      map['coach_comment'] = Variable<String>(coachComment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AthletesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kana: $kana, ')
          ..write('grade: $grade, ')
          ..write('position: $position, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoPath: $photoPath, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('isActive: $isActive, ')
          ..write('coachComment: $coachComment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementItemsTable extends MeasurementItems
    with TableInfo<$MeasurementItemsTable, MeasurementItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _higherIsBetterMeta = const VerificationMeta(
    'higherIsBetter',
  );
  @override
  late final GeneratedColumn<bool> higherIsBetter = GeneratedColumn<bool>(
    'higher_is_better',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("higher_is_better" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AbilityCategory, String>
  abilityCategory =
      GeneratedColumn<String>(
        'ability_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AbilityCategory>(
        $MeasurementItemsTable.$converterabilityCategory,
      );
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    name,
    unit,
    higherIsBetter,
    abilityCategory,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('higher_is_better')) {
      context.handle(
        _higherIsBetterMeta,
        higherIsBetter.isAcceptableOrUnknown(
          data['higher_is_better']!,
          _higherIsBetterMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      higherIsBetter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}higher_is_better'],
      )!,
      abilityCategory: $MeasurementItemsTable.$converterabilityCategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ability_category'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MeasurementItemsTable createAlias(String alias) {
    return $MeasurementItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AbilityCategory, String, String>
  $converterabilityCategory = const EnumNameConverter<AbilityCategory>(
    AbilityCategory.values,
  );
}

class MeasurementItem extends DataClass implements Insertable<MeasurementItem> {
  final String id;
  final String key;
  final String name;
  final String unit;
  final bool higherIsBetter;
  final AbilityCategory abilityCategory;
  final bool isActive;
  final int sortOrder;
  const MeasurementItem({
    required this.id,
    required this.key,
    required this.name,
    required this.unit,
    required this.higherIsBetter,
    required this.abilityCategory,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['higher_is_better'] = Variable<bool>(higherIsBetter);
    {
      map['ability_category'] = Variable<String>(
        $MeasurementItemsTable.$converterabilityCategory.toSql(abilityCategory),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MeasurementItemsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementItemsCompanion(
      id: Value(id),
      key: Value(key),
      name: Value(name),
      unit: Value(unit),
      higherIsBetter: Value(higherIsBetter),
      abilityCategory: Value(abilityCategory),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory MeasurementItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementItem(
      id: serializer.fromJson<String>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      higherIsBetter: serializer.fromJson<bool>(json['higherIsBetter']),
      abilityCategory: $MeasurementItemsTable.$converterabilityCategory
          .fromJson(serializer.fromJson<String>(json['abilityCategory'])),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'higherIsBetter': serializer.toJson<bool>(higherIsBetter),
      'abilityCategory': serializer.toJson<String>(
        $MeasurementItemsTable.$converterabilityCategory.toJson(
          abilityCategory,
        ),
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MeasurementItem copyWith({
    String? id,
    String? key,
    String? name,
    String? unit,
    bool? higherIsBetter,
    AbilityCategory? abilityCategory,
    bool? isActive,
    int? sortOrder,
  }) => MeasurementItem(
    id: id ?? this.id,
    key: key ?? this.key,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    higherIsBetter: higherIsBetter ?? this.higherIsBetter,
    abilityCategory: abilityCategory ?? this.abilityCategory,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MeasurementItem copyWithCompanion(MeasurementItemsCompanion data) {
    return MeasurementItem(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      higherIsBetter: data.higherIsBetter.present
          ? data.higherIsBetter.value
          : this.higherIsBetter,
      abilityCategory: data.abilityCategory.present
          ? data.abilityCategory.value
          : this.abilityCategory,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementItem(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('higherIsBetter: $higherIsBetter, ')
          ..write('abilityCategory: $abilityCategory, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    key,
    name,
    unit,
    higherIsBetter,
    abilityCategory,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementItem &&
          other.id == this.id &&
          other.key == this.key &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.higherIsBetter == this.higherIsBetter &&
          other.abilityCategory == this.abilityCategory &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class MeasurementItemsCompanion extends UpdateCompanion<MeasurementItem> {
  final Value<String> id;
  final Value<String> key;
  final Value<String> name;
  final Value<String> unit;
  final Value<bool> higherIsBetter;
  final Value<AbilityCategory> abilityCategory;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MeasurementItemsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.higherIsBetter = const Value.absent(),
    this.abilityCategory = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementItemsCompanion.insert({
    required String id,
    required String key,
    required String name,
    required String unit,
    this.higherIsBetter = const Value.absent(),
    required AbilityCategory abilityCategory,
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       key = Value(key),
       name = Value(name),
       unit = Value(unit),
       abilityCategory = Value(abilityCategory);
  static Insertable<MeasurementItem> custom({
    Expression<String>? id,
    Expression<String>? key,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<bool>? higherIsBetter,
    Expression<String>? abilityCategory,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (higherIsBetter != null) 'higher_is_better': higherIsBetter,
      if (abilityCategory != null) 'ability_category': abilityCategory,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? key,
    Value<String>? name,
    Value<String>? unit,
    Value<bool>? higherIsBetter,
    Value<AbilityCategory>? abilityCategory,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return MeasurementItemsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      higherIsBetter: higherIsBetter ?? this.higherIsBetter,
      abilityCategory: abilityCategory ?? this.abilityCategory,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (higherIsBetter.present) {
      map['higher_is_better'] = Variable<bool>(higherIsBetter.value);
    }
    if (abilityCategory.present) {
      map['ability_category'] = Variable<String>(
        $MeasurementItemsTable.$converterabilityCategory.toSql(
          abilityCategory.value,
        ),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementItemsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('higherIsBetter: $higherIsBetter, ')
          ..write('abilityCategory: $abilityCategory, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementSessionsTable extends MeasurementSessions
    with TableInfo<$MeasurementSessionsTable, MeasurementSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measurementDateMeta = const VerificationMeta(
    'measurementDate',
  );
  @override
  late final GeneratedColumn<DateTime> measurementDate =
      GeneratedColumn<DateTime>(
        'measurement_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [id, measurementDate, label, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('measurement_date')) {
      context.handle(
        _measurementDateMeta,
        measurementDate.isAcceptableOrUnknown(
          data['measurement_date']!,
          _measurementDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measurementDateMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      measurementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measurement_date'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $MeasurementSessionsTable createAlias(String alias) {
    return $MeasurementSessionsTable(attachedDatabase, alias);
  }
}

class MeasurementSession extends DataClass
    implements Insertable<MeasurementSession> {
  final String id;
  final DateTime measurementDate;
  final String? label;
  final String? note;
  const MeasurementSession({
    required this.id,
    required this.measurementDate,
    this.label,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['measurement_date'] = Variable<DateTime>(measurementDate);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MeasurementSessionsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementSessionsCompanion(
      id: Value(id),
      measurementDate: Value(measurementDate),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MeasurementSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementSession(
      id: serializer.fromJson<String>(json['id']),
      measurementDate: serializer.fromJson<DateTime>(json['measurementDate']),
      label: serializer.fromJson<String?>(json['label']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'measurementDate': serializer.toJson<DateTime>(measurementDate),
      'label': serializer.toJson<String?>(label),
      'note': serializer.toJson<String?>(note),
    };
  }

  MeasurementSession copyWith({
    String? id,
    DateTime? measurementDate,
    Value<String?> label = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => MeasurementSession(
    id: id ?? this.id,
    measurementDate: measurementDate ?? this.measurementDate,
    label: label.present ? label.value : this.label,
    note: note.present ? note.value : this.note,
  );
  MeasurementSession copyWithCompanion(MeasurementSessionsCompanion data) {
    return MeasurementSession(
      id: data.id.present ? data.id.value : this.id,
      measurementDate: data.measurementDate.present
          ? data.measurementDate.value
          : this.measurementDate,
      label: data.label.present ? data.label.value : this.label,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementSession(')
          ..write('id: $id, ')
          ..write('measurementDate: $measurementDate, ')
          ..write('label: $label, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, measurementDate, label, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementSession &&
          other.id == this.id &&
          other.measurementDate == this.measurementDate &&
          other.label == this.label &&
          other.note == this.note);
}

class MeasurementSessionsCompanion extends UpdateCompanion<MeasurementSession> {
  final Value<String> id;
  final Value<DateTime> measurementDate;
  final Value<String?> label;
  final Value<String?> note;
  final Value<int> rowid;
  const MeasurementSessionsCompanion({
    this.id = const Value.absent(),
    this.measurementDate = const Value.absent(),
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementSessionsCompanion.insert({
    required String id,
    required DateTime measurementDate,
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       measurementDate = Value(measurementDate);
  static Insertable<MeasurementSession> custom({
    Expression<String>? id,
    Expression<DateTime>? measurementDate,
    Expression<String>? label,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (measurementDate != null) 'measurement_date': measurementDate,
      if (label != null) 'label': label,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? measurementDate,
    Value<String?>? label,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return MeasurementSessionsCompanion(
      id: id ?? this.id,
      measurementDate: measurementDate ?? this.measurementDate,
      label: label ?? this.label,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (measurementDate.present) {
      map['measurement_date'] = Variable<DateTime>(measurementDate.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementSessionsCompanion(')
          ..write('id: $id, ')
          ..write('measurementDate: $measurementDate, ')
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementRecordsTable extends MeasurementRecords
    with TableInfo<$MeasurementRecordsTable, MeasurementRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _athleteIdMeta = const VerificationMeta(
    'athleteId',
  );
  @override
  late final GeneratedColumn<String> athleteId = GeneratedColumn<String>(
    'athlete_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES athletes (id)',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_sessions (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_items (id)',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    athleteId,
    sessionId,
    itemId,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('athlete_id')) {
      context.handle(
        _athleteIdMeta,
        athleteId.isAcceptableOrUnknown(data['athlete_id']!, _athleteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_athleteIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {athleteId, sessionId, itemId},
  ];
  @override
  MeasurementRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      athleteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}athlete_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MeasurementRecordsTable createAlias(String alias) {
    return $MeasurementRecordsTable(attachedDatabase, alias);
  }
}

class MeasurementRecord extends DataClass
    implements Insertable<MeasurementRecord> {
  final String id;
  final String athleteId;
  final String sessionId;
  final String itemId;
  final double value;
  const MeasurementRecord({
    required this.id,
    required this.athleteId,
    required this.sessionId,
    required this.itemId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['athlete_id'] = Variable<String>(athleteId);
    map['session_id'] = Variable<String>(sessionId);
    map['item_id'] = Variable<String>(itemId);
    map['value'] = Variable<double>(value);
    return map;
  }

  MeasurementRecordsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementRecordsCompanion(
      id: Value(id),
      athleteId: Value(athleteId),
      sessionId: Value(sessionId),
      itemId: Value(itemId),
      value: Value(value),
    );
  }

  factory MeasurementRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementRecord(
      id: serializer.fromJson<String>(json['id']),
      athleteId: serializer.fromJson<String>(json['athleteId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'athleteId': serializer.toJson<String>(athleteId),
      'sessionId': serializer.toJson<String>(sessionId),
      'itemId': serializer.toJson<String>(itemId),
      'value': serializer.toJson<double>(value),
    };
  }

  MeasurementRecord copyWith({
    String? id,
    String? athleteId,
    String? sessionId,
    String? itemId,
    double? value,
  }) => MeasurementRecord(
    id: id ?? this.id,
    athleteId: athleteId ?? this.athleteId,
    sessionId: sessionId ?? this.sessionId,
    itemId: itemId ?? this.itemId,
    value: value ?? this.value,
  );
  MeasurementRecord copyWithCompanion(MeasurementRecordsCompanion data) {
    return MeasurementRecord(
      id: data.id.present ? data.id.value : this.id,
      athleteId: data.athleteId.present ? data.athleteId.value : this.athleteId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementRecord(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, athleteId, sessionId, itemId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementRecord &&
          other.id == this.id &&
          other.athleteId == this.athleteId &&
          other.sessionId == this.sessionId &&
          other.itemId == this.itemId &&
          other.value == this.value);
}

class MeasurementRecordsCompanion extends UpdateCompanion<MeasurementRecord> {
  final Value<String> id;
  final Value<String> athleteId;
  final Value<String> sessionId;
  final Value<String> itemId;
  final Value<double> value;
  final Value<int> rowid;
  const MeasurementRecordsCompanion({
    this.id = const Value.absent(),
    this.athleteId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementRecordsCompanion.insert({
    required String id,
    required String athleteId,
    required String sessionId,
    required String itemId,
    required double value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       athleteId = Value(athleteId),
       sessionId = Value(sessionId),
       itemId = Value(itemId),
       value = Value(value);
  static Insertable<MeasurementRecord> custom({
    Expression<String>? id,
    Expression<String>? athleteId,
    Expression<String>? sessionId,
    Expression<String>? itemId,
    Expression<double>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (athleteId != null) 'athlete_id': athleteId,
      if (sessionId != null) 'session_id': sessionId,
      if (itemId != null) 'item_id': itemId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? athleteId,
    Value<String>? sessionId,
    Value<String>? itemId,
    Value<double>? value,
    Value<int>? rowid,
  }) {
    return MeasurementRecordsCompanion(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      sessionId: sessionId ?? this.sessionId,
      itemId: itemId ?? this.itemId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (athleteId.present) {
      map['athlete_id'] = Variable<String>(athleteId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementRecordsCompanion(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvaluationCriteriaTable extends EvaluationCriteria
    with TableInfo<$EvaluationCriteriaTable, EvaluationCriterion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvaluationCriteriaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemKeyMeta = const VerificationMeta(
    'itemKey',
  );
  @override
  late final GeneratedColumn<String> itemKey = GeneratedColumn<String>(
    'item_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageGroupMinMeta = const VerificationMeta(
    'ageGroupMin',
  );
  @override
  late final GeneratedColumn<int> ageGroupMin = GeneratedColumn<int>(
    'age_group_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageGroupMaxMeta = const VerificationMeta(
    'ageGroupMax',
  );
  @override
  late final GeneratedColumn<int> ageGroupMax = GeneratedColumn<int>(
    'age_group_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    itemKey,
    gender,
    ageGroupMin,
    ageGroupMax,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evaluation_criteria';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvaluationCriterion> instance, {
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
    if (data.containsKey('item_key')) {
      context.handle(
        _itemKeyMeta,
        itemKey.isAcceptableOrUnknown(data['item_key']!, _itemKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_itemKeyMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('age_group_min')) {
      context.handle(
        _ageGroupMinMeta,
        ageGroupMin.isAcceptableOrUnknown(
          data['age_group_min']!,
          _ageGroupMinMeta,
        ),
      );
    }
    if (data.containsKey('age_group_max')) {
      context.handle(
        _ageGroupMaxMeta,
        ageGroupMax.isAcceptableOrUnknown(
          data['age_group_max']!,
          _ageGroupMaxMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvaluationCriterion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvaluationCriterion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      itemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_key'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      ageGroupMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_group_min'],
      ),
      ageGroupMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_group_max'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $EvaluationCriteriaTable createAlias(String alias) {
    return $EvaluationCriteriaTable(attachedDatabase, alias);
  }
}

class EvaluationCriterion extends DataClass
    implements Insertable<EvaluationCriterion> {
  final String id;
  final String name;
  final String itemKey;
  final String? gender;
  final int? ageGroupMin;
  final int? ageGroupMax;

  /// ポジション別に基準値が異なる項目向け（例: G/F/C）。
  /// nullは「ポジション共通」を意味する。
  final String? position;
  const EvaluationCriterion({
    required this.id,
    required this.name,
    required this.itemKey,
    this.gender,
    this.ageGroupMin,
    this.ageGroupMax,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['item_key'] = Variable<String>(itemKey);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || ageGroupMin != null) {
      map['age_group_min'] = Variable<int>(ageGroupMin);
    }
    if (!nullToAbsent || ageGroupMax != null) {
      map['age_group_max'] = Variable<int>(ageGroupMax);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    return map;
  }

  EvaluationCriteriaCompanion toCompanion(bool nullToAbsent) {
    return EvaluationCriteriaCompanion(
      id: Value(id),
      name: Value(name),
      itemKey: Value(itemKey),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      ageGroupMin: ageGroupMin == null && nullToAbsent
          ? const Value.absent()
          : Value(ageGroupMin),
      ageGroupMax: ageGroupMax == null && nullToAbsent
          ? const Value.absent()
          : Value(ageGroupMax),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory EvaluationCriterion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvaluationCriterion(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      itemKey: serializer.fromJson<String>(json['itemKey']),
      gender: serializer.fromJson<String?>(json['gender']),
      ageGroupMin: serializer.fromJson<int?>(json['ageGroupMin']),
      ageGroupMax: serializer.fromJson<int?>(json['ageGroupMax']),
      position: serializer.fromJson<String?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'itemKey': serializer.toJson<String>(itemKey),
      'gender': serializer.toJson<String?>(gender),
      'ageGroupMin': serializer.toJson<int?>(ageGroupMin),
      'ageGroupMax': serializer.toJson<int?>(ageGroupMax),
      'position': serializer.toJson<String?>(position),
    };
  }

  EvaluationCriterion copyWith({
    String? id,
    String? name,
    String? itemKey,
    Value<String?> gender = const Value.absent(),
    Value<int?> ageGroupMin = const Value.absent(),
    Value<int?> ageGroupMax = const Value.absent(),
    Value<String?> position = const Value.absent(),
  }) => EvaluationCriterion(
    id: id ?? this.id,
    name: name ?? this.name,
    itemKey: itemKey ?? this.itemKey,
    gender: gender.present ? gender.value : this.gender,
    ageGroupMin: ageGroupMin.present ? ageGroupMin.value : this.ageGroupMin,
    ageGroupMax: ageGroupMax.present ? ageGroupMax.value : this.ageGroupMax,
    position: position.present ? position.value : this.position,
  );
  EvaluationCriterion copyWithCompanion(EvaluationCriteriaCompanion data) {
    return EvaluationCriterion(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      itemKey: data.itemKey.present ? data.itemKey.value : this.itemKey,
      gender: data.gender.present ? data.gender.value : this.gender,
      ageGroupMin: data.ageGroupMin.present
          ? data.ageGroupMin.value
          : this.ageGroupMin,
      ageGroupMax: data.ageGroupMax.present
          ? data.ageGroupMax.value
          : this.ageGroupMax,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvaluationCriterion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('itemKey: $itemKey, ')
          ..write('gender: $gender, ')
          ..write('ageGroupMin: $ageGroupMin, ')
          ..write('ageGroupMax: $ageGroupMax, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    itemKey,
    gender,
    ageGroupMin,
    ageGroupMax,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvaluationCriterion &&
          other.id == this.id &&
          other.name == this.name &&
          other.itemKey == this.itemKey &&
          other.gender == this.gender &&
          other.ageGroupMin == this.ageGroupMin &&
          other.ageGroupMax == this.ageGroupMax &&
          other.position == this.position);
}

class EvaluationCriteriaCompanion extends UpdateCompanion<EvaluationCriterion> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> itemKey;
  final Value<String?> gender;
  final Value<int?> ageGroupMin;
  final Value<int?> ageGroupMax;
  final Value<String?> position;
  final Value<int> rowid;
  const EvaluationCriteriaCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.itemKey = const Value.absent(),
    this.gender = const Value.absent(),
    this.ageGroupMin = const Value.absent(),
    this.ageGroupMax = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvaluationCriteriaCompanion.insert({
    required String id,
    required String name,
    required String itemKey,
    this.gender = const Value.absent(),
    this.ageGroupMin = const Value.absent(),
    this.ageGroupMax = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       itemKey = Value(itemKey);
  static Insertable<EvaluationCriterion> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? itemKey,
    Expression<String>? gender,
    Expression<int>? ageGroupMin,
    Expression<int>? ageGroupMax,
    Expression<String>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (itemKey != null) 'item_key': itemKey,
      if (gender != null) 'gender': gender,
      if (ageGroupMin != null) 'age_group_min': ageGroupMin,
      if (ageGroupMax != null) 'age_group_max': ageGroupMax,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvaluationCriteriaCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? itemKey,
    Value<String?>? gender,
    Value<int?>? ageGroupMin,
    Value<int?>? ageGroupMax,
    Value<String?>? position,
    Value<int>? rowid,
  }) {
    return EvaluationCriteriaCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      itemKey: itemKey ?? this.itemKey,
      gender: gender ?? this.gender,
      ageGroupMin: ageGroupMin ?? this.ageGroupMin,
      ageGroupMax: ageGroupMax ?? this.ageGroupMax,
      position: position ?? this.position,
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
    if (itemKey.present) {
      map['item_key'] = Variable<String>(itemKey.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (ageGroupMin.present) {
      map['age_group_min'] = Variable<int>(ageGroupMin.value);
    }
    if (ageGroupMax.present) {
      map['age_group_max'] = Variable<int>(ageGroupMax.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvaluationCriteriaCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('itemKey: $itemKey, ')
          ..write('gender: $gender, ')
          ..write('ageGroupMin: $ageGroupMin, ')
          ..write('ageGroupMax: $ageGroupMax, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScoreBandsTable extends ScoreBands
    with TableInfo<$ScoreBandsTable, ScoreBand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreBandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criteriaIdMeta = const VerificationMeta(
    'criteriaId',
  );
  @override
  late final GeneratedColumn<String> criteriaId = GeneratedColumn<String>(
    'criteria_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evaluation_criteria (id)',
    ),
  );
  static const VerificationMeta _minValueMeta = const VerificationMeta(
    'minValue',
  );
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
    'min_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxValueMeta = const VerificationMeta(
    'maxValue',
  );
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
    'max_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criteriaId,
    minValue,
    maxValue,
    score,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_bands';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScoreBand> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criteria_id')) {
      context.handle(
        _criteriaIdMeta,
        criteriaId.isAcceptableOrUnknown(data['criteria_id']!, _criteriaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_criteriaIdMeta);
    }
    if (data.containsKey('min_value')) {
      context.handle(
        _minValueMeta,
        minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta),
      );
    }
    if (data.containsKey('max_value')) {
      context.handle(
        _maxValueMeta,
        maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScoreBand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreBand(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criteriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criteria_id'],
      )!,
      minValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_value'],
      ),
      maxValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_value'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
    );
  }

  @override
  $ScoreBandsTable createAlias(String alias) {
    return $ScoreBandsTable(attachedDatabase, alias);
  }
}

class ScoreBand extends DataClass implements Insertable<ScoreBand> {
  final String id;
  final String criteriaId;
  final double? minValue;
  final double? maxValue;
  final int score;
  const ScoreBand({
    required this.id,
    required this.criteriaId,
    this.minValue,
    this.maxValue,
    required this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criteria_id'] = Variable<String>(criteriaId);
    if (!nullToAbsent || minValue != null) {
      map['min_value'] = Variable<double>(minValue);
    }
    if (!nullToAbsent || maxValue != null) {
      map['max_value'] = Variable<double>(maxValue);
    }
    map['score'] = Variable<int>(score);
    return map;
  }

  ScoreBandsCompanion toCompanion(bool nullToAbsent) {
    return ScoreBandsCompanion(
      id: Value(id),
      criteriaId: Value(criteriaId),
      minValue: minValue == null && nullToAbsent
          ? const Value.absent()
          : Value(minValue),
      maxValue: maxValue == null && nullToAbsent
          ? const Value.absent()
          : Value(maxValue),
      score: Value(score),
    );
  }

  factory ScoreBand.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreBand(
      id: serializer.fromJson<String>(json['id']),
      criteriaId: serializer.fromJson<String>(json['criteriaId']),
      minValue: serializer.fromJson<double?>(json['minValue']),
      maxValue: serializer.fromJson<double?>(json['maxValue']),
      score: serializer.fromJson<int>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criteriaId': serializer.toJson<String>(criteriaId),
      'minValue': serializer.toJson<double?>(minValue),
      'maxValue': serializer.toJson<double?>(maxValue),
      'score': serializer.toJson<int>(score),
    };
  }

  ScoreBand copyWith({
    String? id,
    String? criteriaId,
    Value<double?> minValue = const Value.absent(),
    Value<double?> maxValue = const Value.absent(),
    int? score,
  }) => ScoreBand(
    id: id ?? this.id,
    criteriaId: criteriaId ?? this.criteriaId,
    minValue: minValue.present ? minValue.value : this.minValue,
    maxValue: maxValue.present ? maxValue.value : this.maxValue,
    score: score ?? this.score,
  );
  ScoreBand copyWithCompanion(ScoreBandsCompanion data) {
    return ScoreBand(
      id: data.id.present ? data.id.value : this.id,
      criteriaId: data.criteriaId.present
          ? data.criteriaId.value
          : this.criteriaId,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreBand(')
          ..write('id: $id, ')
          ..write('criteriaId: $criteriaId, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, criteriaId, minValue, maxValue, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreBand &&
          other.id == this.id &&
          other.criteriaId == this.criteriaId &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.score == this.score);
}

class ScoreBandsCompanion extends UpdateCompanion<ScoreBand> {
  final Value<String> id;
  final Value<String> criteriaId;
  final Value<double?> minValue;
  final Value<double?> maxValue;
  final Value<int> score;
  final Value<int> rowid;
  const ScoreBandsCompanion({
    this.id = const Value.absent(),
    this.criteriaId = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoreBandsCompanion.insert({
    required String id,
    required String criteriaId,
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    required int score,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criteriaId = Value(criteriaId),
       score = Value(score);
  static Insertable<ScoreBand> custom({
    Expression<String>? id,
    Expression<String>? criteriaId,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<int>? score,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criteriaId != null) 'criteria_id': criteriaId,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (score != null) 'score': score,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoreBandsCompanion copyWith({
    Value<String>? id,
    Value<String>? criteriaId,
    Value<double?>? minValue,
    Value<double?>? maxValue,
    Value<int>? score,
    Value<int>? rowid,
  }) {
    return ScoreBandsCompanion(
      id: id ?? this.id,
      criteriaId: criteriaId ?? this.criteriaId,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      score: score ?? this.score,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criteriaId.present) {
      map['criteria_id'] = Variable<String>(criteriaId.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreBandsCompanion(')
          ..write('id: $id, ')
          ..write('criteriaId: $criteriaId, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('score: $score, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AthletesTable athletes = $AthletesTable(this);
  late final $MeasurementItemsTable measurementItems = $MeasurementItemsTable(
    this,
  );
  late final $MeasurementSessionsTable measurementSessions =
      $MeasurementSessionsTable(this);
  late final $MeasurementRecordsTable measurementRecords =
      $MeasurementRecordsTable(this);
  late final $EvaluationCriteriaTable evaluationCriteria =
      $EvaluationCriteriaTable(this);
  late final $ScoreBandsTable scoreBands = $ScoreBandsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    athletes,
    measurementItems,
    measurementSessions,
    measurementRecords,
    evaluationCriteria,
    scoreBands,
  ];
}

typedef $$AthletesTableCreateCompanionBuilder =
    AthletesCompanion Function({
      required String id,
      required String name,
      Value<String?> kana,
      required int grade,
      Value<String?> position,
      Value<DateTime?> birthDate,
      Value<String?> photoPath,
      Value<int?> jerseyNumber,
      Value<bool> isActive,
      Value<String?> coachComment,
      Value<int> rowid,
    });
typedef $$AthletesTableUpdateCompanionBuilder =
    AthletesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> kana,
      Value<int> grade,
      Value<String?> position,
      Value<DateTime?> birthDate,
      Value<String?> photoPath,
      Value<int?> jerseyNumber,
      Value<bool> isActive,
      Value<String?> coachComment,
      Value<int> rowid,
    });

final class $$AthletesTableReferences
    extends BaseReferences<_$AppDatabase, $AthletesTable, Athlete> {
  $$AthletesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementRecordsTable, List<MeasurementRecord>>
  _measurementRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementRecords,
        aliasName: 'athletes__id__measurement_records__athlete_id',
      );

  $$MeasurementRecordsTableProcessedTableManager get measurementRecordsRefs {
    final manager = $$MeasurementRecordsTableTableManager(
      $_db,
      $_db.measurementRecords,
    ).filter((f) => f.athleteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AthletesTableFilterComposer
    extends Composer<_$AppDatabase, $AthletesTable> {
  $$AthletesTableFilterComposer({
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

  ColumnFilters<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coachComment => $composableBuilder(
    column: $table.coachComment,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementRecordsRefs(
    Expression<bool> Function($$MeasurementRecordsTableFilterComposer f) f,
  ) {
    final $$MeasurementRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementRecords,
      getReferencedColumn: (t) => t.athleteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementRecordsTableFilterComposer(
            $db: $db,
            $table: $db.measurementRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AthletesTableOrderingComposer
    extends Composer<_$AppDatabase, $AthletesTable> {
  $$AthletesTableOrderingComposer({
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

  ColumnOrderings<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coachComment => $composableBuilder(
    column: $table.coachComment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AthletesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AthletesTable> {
  $$AthletesTableAnnotationComposer({
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

  GeneratedColumn<String> get kana =>
      $composableBuilder(column: $table.kana, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get coachComment => $composableBuilder(
    column: $table.coachComment,
    builder: (column) => column,
  );

  Expression<T> measurementRecordsRefs<T extends Object>(
    Expression<T> Function($$MeasurementRecordsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementRecords,
          getReferencedColumn: (t) => t.athleteId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AthletesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AthletesTable,
          Athlete,
          $$AthletesTableFilterComposer,
          $$AthletesTableOrderingComposer,
          $$AthletesTableAnnotationComposer,
          $$AthletesTableCreateCompanionBuilder,
          $$AthletesTableUpdateCompanionBuilder,
          (Athlete, $$AthletesTableReferences),
          Athlete,
          PrefetchHooks Function({bool measurementRecordsRefs})
        > {
  $$AthletesTableTableManager(_$AppDatabase db, $AthletesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AthletesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AthletesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AthletesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> kana = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int?> jerseyNumber = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> coachComment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AthletesCompanion(
                id: id,
                name: name,
                kana: kana,
                grade: grade,
                position: position,
                birthDate: birthDate,
                photoPath: photoPath,
                jerseyNumber: jerseyNumber,
                isActive: isActive,
                coachComment: coachComment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> kana = const Value.absent(),
                required int grade,
                Value<String?> position = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int?> jerseyNumber = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> coachComment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AthletesCompanion.insert(
                id: id,
                name: name,
                kana: kana,
                grade: grade,
                position: position,
                birthDate: birthDate,
                photoPath: photoPath,
                jerseyNumber: jerseyNumber,
                isActive: isActive,
                coachComment: coachComment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AthletesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementRecordsRefs) db.measurementRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementRecordsRefs)
                    await $_getPrefetchedData<
                      Athlete,
                      $AthletesTable,
                      MeasurementRecord
                    >(
                      currentTable: table,
                      referencedTable: $$AthletesTableReferences
                          ._measurementRecordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$AthletesTableReferences(
                        db,
                        table,
                        p0,
                      ).measurementRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.athleteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AthletesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AthletesTable,
      Athlete,
      $$AthletesTableFilterComposer,
      $$AthletesTableOrderingComposer,
      $$AthletesTableAnnotationComposer,
      $$AthletesTableCreateCompanionBuilder,
      $$AthletesTableUpdateCompanionBuilder,
      (Athlete, $$AthletesTableReferences),
      Athlete,
      PrefetchHooks Function({bool measurementRecordsRefs})
    >;
typedef $$MeasurementItemsTableCreateCompanionBuilder =
    MeasurementItemsCompanion Function({
      required String id,
      required String key,
      required String name,
      required String unit,
      Value<bool> higherIsBetter,
      required AbilityCategory abilityCategory,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$MeasurementItemsTableUpdateCompanionBuilder =
    MeasurementItemsCompanion Function({
      Value<String> id,
      Value<String> key,
      Value<String> name,
      Value<String> unit,
      Value<bool> higherIsBetter,
      Value<AbilityCategory> abilityCategory,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$MeasurementItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MeasurementItemsTable, MeasurementItem> {
  $$MeasurementItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MeasurementRecordsTable, List<MeasurementRecord>>
  _measurementRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementRecords,
        aliasName: 'measurement_items__id__measurement_records__item_id',
      );

  $$MeasurementRecordsTableProcessedTableManager get measurementRecordsRefs {
    final manager = $$MeasurementRecordsTableTableManager(
      $_db,
      $_db.measurementRecords,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementItemsTable> {
  $$MeasurementItemsTableFilterComposer({
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get higherIsBetter => $composableBuilder(
    column: $table.higherIsBetter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AbilityCategory, AbilityCategory, String>
  get abilityCategory => $composableBuilder(
    column: $table.abilityCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementRecordsRefs(
    Expression<bool> Function($$MeasurementRecordsTableFilterComposer f) f,
  ) {
    final $$MeasurementRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementRecords,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementRecordsTableFilterComposer(
            $db: $db,
            $table: $db.measurementRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementItemsTable> {
  $$MeasurementItemsTableOrderingComposer({
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get higherIsBetter => $composableBuilder(
    column: $table.higherIsBetter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilityCategory => $composableBuilder(
    column: $table.abilityCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementItemsTable> {
  $$MeasurementItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get higherIsBetter => $composableBuilder(
    column: $table.higherIsBetter,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AbilityCategory, String>
  get abilityCategory => $composableBuilder(
    column: $table.abilityCategory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> measurementRecordsRefs<T extends Object>(
    Expression<T> Function($$MeasurementRecordsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementRecords,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementItemsTable,
          MeasurementItem,
          $$MeasurementItemsTableFilterComposer,
          $$MeasurementItemsTableOrderingComposer,
          $$MeasurementItemsTableAnnotationComposer,
          $$MeasurementItemsTableCreateCompanionBuilder,
          $$MeasurementItemsTableUpdateCompanionBuilder,
          (MeasurementItem, $$MeasurementItemsTableReferences),
          MeasurementItem,
          PrefetchHooks Function({bool measurementRecordsRefs})
        > {
  $$MeasurementItemsTableTableManager(
    _$AppDatabase db,
    $MeasurementItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> higherIsBetter = const Value.absent(),
                Value<AbilityCategory> abilityCategory = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementItemsCompanion(
                id: id,
                key: key,
                name: name,
                unit: unit,
                higherIsBetter: higherIsBetter,
                abilityCategory: abilityCategory,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String key,
                required String name,
                required String unit,
                Value<bool> higherIsBetter = const Value.absent(),
                required AbilityCategory abilityCategory,
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementItemsCompanion.insert(
                id: id,
                key: key,
                name: name,
                unit: unit,
                higherIsBetter: higherIsBetter,
                abilityCategory: abilityCategory,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementRecordsRefs) db.measurementRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementRecordsRefs)
                    await $_getPrefetchedData<
                      MeasurementItem,
                      $MeasurementItemsTable,
                      MeasurementRecord
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementItemsTableReferences
                          ._measurementRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).measurementRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementItemsTable,
      MeasurementItem,
      $$MeasurementItemsTableFilterComposer,
      $$MeasurementItemsTableOrderingComposer,
      $$MeasurementItemsTableAnnotationComposer,
      $$MeasurementItemsTableCreateCompanionBuilder,
      $$MeasurementItemsTableUpdateCompanionBuilder,
      (MeasurementItem, $$MeasurementItemsTableReferences),
      MeasurementItem,
      PrefetchHooks Function({bool measurementRecordsRefs})
    >;
typedef $$MeasurementSessionsTableCreateCompanionBuilder =
    MeasurementSessionsCompanion Function({
      required String id,
      required DateTime measurementDate,
      Value<String?> label,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$MeasurementSessionsTableUpdateCompanionBuilder =
    MeasurementSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> measurementDate,
      Value<String?> label,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$MeasurementSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementSessionsTable,
          MeasurementSession
        > {
  $$MeasurementSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MeasurementRecordsTable, List<MeasurementRecord>>
  _measurementRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementRecords,
        aliasName: 'measurement_sessions__id__measurement_records__session_id',
      );

  $$MeasurementRecordsTableProcessedTableManager get measurementRecordsRefs {
    final manager = $$MeasurementRecordsTableTableManager(
      $_db,
      $_db.measurementRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementSessionsTable> {
  $$MeasurementSessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get measurementDate => $composableBuilder(
    column: $table.measurementDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementRecordsRefs(
    Expression<bool> Function($$MeasurementRecordsTableFilterComposer f) f,
  ) {
    final $$MeasurementRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementRecordsTableFilterComposer(
            $db: $db,
            $table: $db.measurementRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementSessionsTable> {
  $$MeasurementSessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get measurementDate => $composableBuilder(
    column: $table.measurementDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementSessionsTable> {
  $$MeasurementSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get measurementDate => $composableBuilder(
    column: $table.measurementDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> measurementRecordsRefs<T extends Object>(
    Expression<T> Function($$MeasurementRecordsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementSessionsTable,
          MeasurementSession,
          $$MeasurementSessionsTableFilterComposer,
          $$MeasurementSessionsTableOrderingComposer,
          $$MeasurementSessionsTableAnnotationComposer,
          $$MeasurementSessionsTableCreateCompanionBuilder,
          $$MeasurementSessionsTableUpdateCompanionBuilder,
          (MeasurementSession, $$MeasurementSessionsTableReferences),
          MeasurementSession,
          PrefetchHooks Function({bool measurementRecordsRefs})
        > {
  $$MeasurementSessionsTableTableManager(
    _$AppDatabase db,
    $MeasurementSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MeasurementSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> measurementDate = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementSessionsCompanion(
                id: id,
                measurementDate: measurementDate,
                label: label,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime measurementDate,
                Value<String?> label = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementSessionsCompanion.insert(
                id: id,
                measurementDate: measurementDate,
                label: label,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementRecordsRefs) db.measurementRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementRecordsRefs)
                    await $_getPrefetchedData<
                      MeasurementSession,
                      $MeasurementSessionsTable,
                      MeasurementRecord
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementSessionsTableReferences
                          ._measurementRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).measurementRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementSessionsTable,
      MeasurementSession,
      $$MeasurementSessionsTableFilterComposer,
      $$MeasurementSessionsTableOrderingComposer,
      $$MeasurementSessionsTableAnnotationComposer,
      $$MeasurementSessionsTableCreateCompanionBuilder,
      $$MeasurementSessionsTableUpdateCompanionBuilder,
      (MeasurementSession, $$MeasurementSessionsTableReferences),
      MeasurementSession,
      PrefetchHooks Function({bool measurementRecordsRefs})
    >;
typedef $$MeasurementRecordsTableCreateCompanionBuilder =
    MeasurementRecordsCompanion Function({
      required String id,
      required String athleteId,
      required String sessionId,
      required String itemId,
      required double value,
      Value<int> rowid,
    });
typedef $$MeasurementRecordsTableUpdateCompanionBuilder =
    MeasurementRecordsCompanion Function({
      Value<String> id,
      Value<String> athleteId,
      Value<String> sessionId,
      Value<String> itemId,
      Value<double> value,
      Value<int> rowid,
    });

final class $$MeasurementRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementRecordsTable,
          MeasurementRecord
        > {
  $$MeasurementRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AthletesTable _athleteIdTable(_$AppDatabase db) =>
      db.athletes.createAlias('measurement_records__athlete_id__athletes__id');

  $$AthletesTableProcessedTableManager get athleteId {
    final $_column = $_itemColumn<String>('athlete_id')!;

    final manager = $$AthletesTableTableManager(
      $_db,
      $_db.athletes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_athleteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MeasurementSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .measurementSessions
      .createAlias('measurement_records__session_id__measurement_sessions__id');

  $$MeasurementSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$MeasurementSessionsTableTableManager(
      $_db,
      $_db.measurementSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MeasurementItemsTable _itemIdTable(_$AppDatabase db) => db
      .measurementItems
      .createAlias('measurement_records__item_id__measurement_items__id');

  $$MeasurementItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$MeasurementItemsTableTableManager(
      $_db,
      $_db.measurementItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementRecordsTable> {
  $$MeasurementRecordsTableFilterComposer({
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

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$AthletesTableFilterComposer get athleteId {
    final $$AthletesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.athleteId,
      referencedTable: $db.athletes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AthletesTableFilterComposer(
            $db: $db,
            $table: $db.athletes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementSessionsTableFilterComposer get sessionId {
    final $$MeasurementSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.measurementSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementSessionsTableFilterComposer(
            $db: $db,
            $table: $db.measurementSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementItemsTableFilterComposer get itemId {
    final $$MeasurementItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.measurementItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementItemsTableFilterComposer(
            $db: $db,
            $table: $db.measurementItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementRecordsTable> {
  $$MeasurementRecordsTableOrderingComposer({
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

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$AthletesTableOrderingComposer get athleteId {
    final $$AthletesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.athleteId,
      referencedTable: $db.athletes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AthletesTableOrderingComposer(
            $db: $db,
            $table: $db.athletes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementSessionsTableOrderingComposer get sessionId {
    final $$MeasurementSessionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.measurementSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementSessionsTableOrderingComposer(
                $db: $db,
                $table: $db.measurementSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$MeasurementItemsTableOrderingComposer get itemId {
    final $$MeasurementItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.measurementItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementItemsTableOrderingComposer(
            $db: $db,
            $table: $db.measurementItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementRecordsTable> {
  $$MeasurementRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$AthletesTableAnnotationComposer get athleteId {
    final $$AthletesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.athleteId,
      referencedTable: $db.athletes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AthletesTableAnnotationComposer(
            $db: $db,
            $table: $db.athletes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementSessionsTableAnnotationComposer get sessionId {
    final $$MeasurementSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.measurementSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$MeasurementItemsTableAnnotationComposer get itemId {
    final $$MeasurementItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.measurementItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementRecordsTable,
          MeasurementRecord,
          $$MeasurementRecordsTableFilterComposer,
          $$MeasurementRecordsTableOrderingComposer,
          $$MeasurementRecordsTableAnnotationComposer,
          $$MeasurementRecordsTableCreateCompanionBuilder,
          $$MeasurementRecordsTableUpdateCompanionBuilder,
          (MeasurementRecord, $$MeasurementRecordsTableReferences),
          MeasurementRecord,
          PrefetchHooks Function({bool athleteId, bool sessionId, bool itemId})
        > {
  $$MeasurementRecordsTableTableManager(
    _$AppDatabase db,
    $MeasurementRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> athleteId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementRecordsCompanion(
                id: id,
                athleteId: athleteId,
                sessionId: sessionId,
                itemId: itemId,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String athleteId,
                required String sessionId,
                required String itemId,
                required double value,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementRecordsCompanion.insert(
                id: id,
                athleteId: athleteId,
                sessionId: sessionId,
                itemId: itemId,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({athleteId = false, sessionId = false, itemId = false}) {
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
                        if (athleteId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.athleteId,
                                    referencedTable:
                                        $$MeasurementRecordsTableReferences
                                            ._athleteIdTable(db),
                                    referencedColumn:
                                        $$MeasurementRecordsTableReferences
                                            ._athleteIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$MeasurementRecordsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$MeasurementRecordsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$MeasurementRecordsTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$MeasurementRecordsTableReferences
                                            ._itemIdTable(db)
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

typedef $$MeasurementRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementRecordsTable,
      MeasurementRecord,
      $$MeasurementRecordsTableFilterComposer,
      $$MeasurementRecordsTableOrderingComposer,
      $$MeasurementRecordsTableAnnotationComposer,
      $$MeasurementRecordsTableCreateCompanionBuilder,
      $$MeasurementRecordsTableUpdateCompanionBuilder,
      (MeasurementRecord, $$MeasurementRecordsTableReferences),
      MeasurementRecord,
      PrefetchHooks Function({bool athleteId, bool sessionId, bool itemId})
    >;
typedef $$EvaluationCriteriaTableCreateCompanionBuilder =
    EvaluationCriteriaCompanion Function({
      required String id,
      required String name,
      required String itemKey,
      Value<String?> gender,
      Value<int?> ageGroupMin,
      Value<int?> ageGroupMax,
      Value<String?> position,
      Value<int> rowid,
    });
typedef $$EvaluationCriteriaTableUpdateCompanionBuilder =
    EvaluationCriteriaCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> itemKey,
      Value<String?> gender,
      Value<int?> ageGroupMin,
      Value<int?> ageGroupMax,
      Value<String?> position,
      Value<int> rowid,
    });

final class $$EvaluationCriteriaTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EvaluationCriteriaTable,
          EvaluationCriterion
        > {
  $$EvaluationCriteriaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ScoreBandsTable, List<ScoreBand>>
  _scoreBandsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scoreBands,
    aliasName: 'evaluation_criteria__id__score_bands__criteria_id',
  );

  $$ScoreBandsTableProcessedTableManager get scoreBandsRefs {
    final manager = $$ScoreBandsTableTableManager(
      $_db,
      $_db.scoreBands,
    ).filter((f) => f.criteriaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scoreBandsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EvaluationCriteriaTableFilterComposer
    extends Composer<_$AppDatabase, $EvaluationCriteriaTable> {
  $$EvaluationCriteriaTableFilterComposer({
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

  ColumnFilters<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageGroupMin => $composableBuilder(
    column: $table.ageGroupMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageGroupMax => $composableBuilder(
    column: $table.ageGroupMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scoreBandsRefs(
    Expression<bool> Function($$ScoreBandsTableFilterComposer f) f,
  ) {
    final $$ScoreBandsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreBands,
      getReferencedColumn: (t) => t.criteriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreBandsTableFilterComposer(
            $db: $db,
            $table: $db.scoreBands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EvaluationCriteriaTableOrderingComposer
    extends Composer<_$AppDatabase, $EvaluationCriteriaTable> {
  $$EvaluationCriteriaTableOrderingComposer({
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

  ColumnOrderings<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageGroupMin => $composableBuilder(
    column: $table.ageGroupMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageGroupMax => $composableBuilder(
    column: $table.ageGroupMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EvaluationCriteriaTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvaluationCriteriaTable> {
  $$EvaluationCriteriaTableAnnotationComposer({
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

  GeneratedColumn<String> get itemKey =>
      $composableBuilder(column: $table.itemKey, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get ageGroupMin => $composableBuilder(
    column: $table.ageGroupMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageGroupMax => $composableBuilder(
    column: $table.ageGroupMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> scoreBandsRefs<T extends Object>(
    Expression<T> Function($$ScoreBandsTableAnnotationComposer a) f,
  ) {
    final $$ScoreBandsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreBands,
      getReferencedColumn: (t) => t.criteriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreBandsTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreBands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EvaluationCriteriaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvaluationCriteriaTable,
          EvaluationCriterion,
          $$EvaluationCriteriaTableFilterComposer,
          $$EvaluationCriteriaTableOrderingComposer,
          $$EvaluationCriteriaTableAnnotationComposer,
          $$EvaluationCriteriaTableCreateCompanionBuilder,
          $$EvaluationCriteriaTableUpdateCompanionBuilder,
          (EvaluationCriterion, $$EvaluationCriteriaTableReferences),
          EvaluationCriterion,
          PrefetchHooks Function({bool scoreBandsRefs})
        > {
  $$EvaluationCriteriaTableTableManager(
    _$AppDatabase db,
    $EvaluationCriteriaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvaluationCriteriaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvaluationCriteriaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvaluationCriteriaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> itemKey = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<int?> ageGroupMin = const Value.absent(),
                Value<int?> ageGroupMax = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvaluationCriteriaCompanion(
                id: id,
                name: name,
                itemKey: itemKey,
                gender: gender,
                ageGroupMin: ageGroupMin,
                ageGroupMax: ageGroupMax,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String itemKey,
                Value<String?> gender = const Value.absent(),
                Value<int?> ageGroupMin = const Value.absent(),
                Value<int?> ageGroupMax = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvaluationCriteriaCompanion.insert(
                id: id,
                name: name,
                itemKey: itemKey,
                gender: gender,
                ageGroupMin: ageGroupMin,
                ageGroupMax: ageGroupMax,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvaluationCriteriaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scoreBandsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scoreBandsRefs) db.scoreBands],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scoreBandsRefs)
                    await $_getPrefetchedData<
                      EvaluationCriterion,
                      $EvaluationCriteriaTable,
                      ScoreBand
                    >(
                      currentTable: table,
                      referencedTable: $$EvaluationCriteriaTableReferences
                          ._scoreBandsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EvaluationCriteriaTableReferences(
                            db,
                            table,
                            p0,
                          ).scoreBandsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.criteriaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EvaluationCriteriaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvaluationCriteriaTable,
      EvaluationCriterion,
      $$EvaluationCriteriaTableFilterComposer,
      $$EvaluationCriteriaTableOrderingComposer,
      $$EvaluationCriteriaTableAnnotationComposer,
      $$EvaluationCriteriaTableCreateCompanionBuilder,
      $$EvaluationCriteriaTableUpdateCompanionBuilder,
      (EvaluationCriterion, $$EvaluationCriteriaTableReferences),
      EvaluationCriterion,
      PrefetchHooks Function({bool scoreBandsRefs})
    >;
typedef $$ScoreBandsTableCreateCompanionBuilder =
    ScoreBandsCompanion Function({
      required String id,
      required String criteriaId,
      Value<double?> minValue,
      Value<double?> maxValue,
      required int score,
      Value<int> rowid,
    });
typedef $$ScoreBandsTableUpdateCompanionBuilder =
    ScoreBandsCompanion Function({
      Value<String> id,
      Value<String> criteriaId,
      Value<double?> minValue,
      Value<double?> maxValue,
      Value<int> score,
      Value<int> rowid,
    });

final class $$ScoreBandsTableReferences
    extends BaseReferences<_$AppDatabase, $ScoreBandsTable, ScoreBand> {
  $$ScoreBandsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EvaluationCriteriaTable _criteriaIdTable(_$AppDatabase db) => db
      .evaluationCriteria
      .createAlias('score_bands__criteria_id__evaluation_criteria__id');

  $$EvaluationCriteriaTableProcessedTableManager get criteriaId {
    final $_column = $_itemColumn<String>('criteria_id')!;

    final manager = $$EvaluationCriteriaTableTableManager(
      $_db,
      $_db.evaluationCriteria,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_criteriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScoreBandsTableFilterComposer
    extends Composer<_$AppDatabase, $ScoreBandsTable> {
  $$ScoreBandsTableFilterComposer({
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

  ColumnFilters<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  $$EvaluationCriteriaTableFilterComposer get criteriaId {
    final $$EvaluationCriteriaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.criteriaId,
      referencedTable: $db.evaluationCriteria,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvaluationCriteriaTableFilterComposer(
            $db: $db,
            $table: $db.evaluationCriteria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreBandsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoreBandsTable> {
  $$ScoreBandsTableOrderingComposer({
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

  ColumnOrderings<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  $$EvaluationCriteriaTableOrderingComposer get criteriaId {
    final $$EvaluationCriteriaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.criteriaId,
      referencedTable: $db.evaluationCriteria,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvaluationCriteriaTableOrderingComposer(
            $db: $db,
            $table: $db.evaluationCriteria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreBandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoreBandsTable> {
  $$ScoreBandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  $$EvaluationCriteriaTableAnnotationComposer get criteriaId {
    final $$EvaluationCriteriaTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.criteriaId,
          referencedTable: $db.evaluationCriteria,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvaluationCriteriaTableAnnotationComposer(
                $db: $db,
                $table: $db.evaluationCriteria,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScoreBandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScoreBandsTable,
          ScoreBand,
          $$ScoreBandsTableFilterComposer,
          $$ScoreBandsTableOrderingComposer,
          $$ScoreBandsTableAnnotationComposer,
          $$ScoreBandsTableCreateCompanionBuilder,
          $$ScoreBandsTableUpdateCompanionBuilder,
          (ScoreBand, $$ScoreBandsTableReferences),
          ScoreBand,
          PrefetchHooks Function({bool criteriaId})
        > {
  $$ScoreBandsTableTableManager(_$AppDatabase db, $ScoreBandsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreBandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreBandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreBandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> criteriaId = const Value.absent(),
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScoreBandsCompanion(
                id: id,
                criteriaId: criteriaId,
                minValue: minValue,
                maxValue: maxValue,
                score: score,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String criteriaId,
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                required int score,
                Value<int> rowid = const Value.absent(),
              }) => ScoreBandsCompanion.insert(
                id: id,
                criteriaId: criteriaId,
                minValue: minValue,
                maxValue: maxValue,
                score: score,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScoreBandsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({criteriaId = false}) {
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
                    if (criteriaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.criteriaId,
                                referencedTable: $$ScoreBandsTableReferences
                                    ._criteriaIdTable(db),
                                referencedColumn: $$ScoreBandsTableReferences
                                    ._criteriaIdTable(db)
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

typedef $$ScoreBandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScoreBandsTable,
      ScoreBand,
      $$ScoreBandsTableFilterComposer,
      $$ScoreBandsTableOrderingComposer,
      $$ScoreBandsTableAnnotationComposer,
      $$ScoreBandsTableCreateCompanionBuilder,
      $$ScoreBandsTableUpdateCompanionBuilder,
      (ScoreBand, $$ScoreBandsTableReferences),
      ScoreBand,
      PrefetchHooks Function({bool criteriaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AthletesTableTableManager get athletes =>
      $$AthletesTableTableManager(_db, _db.athletes);
  $$MeasurementItemsTableTableManager get measurementItems =>
      $$MeasurementItemsTableTableManager(_db, _db.measurementItems);
  $$MeasurementSessionsTableTableManager get measurementSessions =>
      $$MeasurementSessionsTableTableManager(_db, _db.measurementSessions);
  $$MeasurementRecordsTableTableManager get measurementRecords =>
      $$MeasurementRecordsTableTableManager(_db, _db.measurementRecords);
  $$EvaluationCriteriaTableTableManager get evaluationCriteria =>
      $$EvaluationCriteriaTableTableManager(_db, _db.evaluationCriteria);
  $$ScoreBandsTableTableManager get scoreBands =>
      $$ScoreBandsTableTableManager(_db, _db.scoreBands);
}
