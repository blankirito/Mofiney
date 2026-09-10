// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountEntriesTable extends AccountEntries
    with TableInfo<$AccountEntriesTable, AccountEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statementCycleDayMeta = const VerificationMeta(
    'statementCycleDay',
  );
  @override
  late final GeneratedColumn<int> statementCycleDay = GeneratedColumn<int>(
    'statement_cycle_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    openingBalance,
    currencyCode,
    isPrimary,
    isActive,
    creditLimit,
    statementCycleDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountEntry> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('statement_cycle_day')) {
      context.handle(
        _statementCycleDayMeta,
        statementCycleDay.isAcceptableOrUnknown(
          data['statement_cycle_day']!,
          _statementCycleDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      statementCycleDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}statement_cycle_day'],
      ),
    );
  }

  @override
  $AccountEntriesTable createAlias(String alias) {
    return $AccountEntriesTable(attachedDatabase, alias);
  }
}

class AccountEntry extends DataClass implements Insertable<AccountEntry> {
  final String id;
  final String name;

  /// bank | eWallet | cash | creditCard
  final String type;
  final double openingBalance;
  final String currencyCode;
  final bool isPrimary;
  final bool isActive;
  final double? creditLimit;
  final int? statementCycleDay;
  const AccountEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.currencyCode,
    required this.isPrimary,
    required this.isActive,
    this.creditLimit,
    this.statementCycleDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['currency_code'] = Variable<String>(currencyCode);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    if (!nullToAbsent || statementCycleDay != null) {
      map['statement_cycle_day'] = Variable<int>(statementCycleDay);
    }
    return map;
  }

  AccountEntriesCompanion toCompanion(bool nullToAbsent) {
    return AccountEntriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      openingBalance: Value(openingBalance),
      currencyCode: Value(currencyCode),
      isPrimary: Value(isPrimary),
      isActive: Value(isActive),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      statementCycleDay: statementCycleDay == null && nullToAbsent
          ? const Value.absent()
          : Value(statementCycleDay),
    );
  }

  factory AccountEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      statementCycleDay: serializer.fromJson<int?>(json['statementCycleDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isActive': serializer.toJson<bool>(isActive),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'statementCycleDay': serializer.toJson<int?>(statementCycleDay),
    };
  }

  AccountEntry copyWith({
    String? id,
    String? name,
    String? type,
    double? openingBalance,
    String? currencyCode,
    bool? isPrimary,
    bool? isActive,
    Value<double?> creditLimit = const Value.absent(),
    Value<int?> statementCycleDay = const Value.absent(),
  }) => AccountEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    openingBalance: openingBalance ?? this.openingBalance,
    currencyCode: currencyCode ?? this.currencyCode,
    isPrimary: isPrimary ?? this.isPrimary,
    isActive: isActive ?? this.isActive,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    statementCycleDay: statementCycleDay.present
        ? statementCycleDay.value
        : this.statementCycleDay,
  );
  AccountEntry copyWithCompanion(AccountEntriesCompanion data) {
    return AccountEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      statementCycleDay: data.statementCycleDay.present
          ? data.statementCycleDay.value
          : this.statementCycleDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('statementCycleDay: $statementCycleDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    openingBalance,
    currencyCode,
    isPrimary,
    isActive,
    creditLimit,
    statementCycleDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.openingBalance == this.openingBalance &&
          other.currencyCode == this.currencyCode &&
          other.isPrimary == this.isPrimary &&
          other.isActive == this.isActive &&
          other.creditLimit == this.creditLimit &&
          other.statementCycleDay == this.statementCycleDay);
}

class AccountEntriesCompanion extends UpdateCompanion<AccountEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> openingBalance;
  final Value<String> currencyCode;
  final Value<bool> isPrimary;
  final Value<bool> isActive;
  final Value<double?> creditLimit;
  final Value<int?> statementCycleDay;
  final Value<int> rowid;
  const AccountEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.statementCycleDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountEntriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required double openingBalance,
    required String currencyCode,
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.statementCycleDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       openingBalance = Value(openingBalance),
       currencyCode = Value(currencyCode);
  static Insertable<AccountEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? openingBalance,
    Expression<String>? currencyCode,
    Expression<bool>? isPrimary,
    Expression<bool>? isActive,
    Expression<double>? creditLimit,
    Expression<int>? statementCycleDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isActive != null) 'is_active': isActive,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (statementCycleDay != null) 'statement_cycle_day': statementCycleDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? openingBalance,
    Value<String>? currencyCode,
    Value<bool>? isPrimary,
    Value<bool>? isActive,
    Value<double?>? creditLimit,
    Value<int?>? statementCycleDay,
    Value<int>? rowid,
  }) {
    return AccountEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      currencyCode: currencyCode ?? this.currencyCode,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      creditLimit: creditLimit ?? this.creditLimit,
      statementCycleDay: statementCycleDay ?? this.statementCycleDay,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (statementCycleDay.present) {
      map['statement_cycle_day'] = Variable<int>(statementCycleDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('statementCycleDay: $statementCycleDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionEntriesTable extends TransactionEntries
    with TableInfo<$TransactionEntriesTable, TransactionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MYR'),
  );
  static const VerificationMeta _accountAmountMeta = const VerificationMeta(
    'accountAmount',
  );
  @override
  late final GeneratedColumn<double> accountAmount = GeneratedColumn<double>(
    'account_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationAccountAmountMeta =
      const VerificationMeta('destinationAccountAmount');
  @override
  late final GeneratedColumn<double> destinationAccountAmount =
      GeneratedColumn<double>(
        'destination_account_amount',
        aliasedName,
        true,
        type: DriftSqlType.double,
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
  static const VerificationMeta _transactionDateTimeMeta =
      const VerificationMeta('transactionDateTime');
  @override
  late final GeneratedColumn<DateTime> transactionDateTime =
      GeneratedColumn<DateTime>(
        'date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationAccountMeta =
      const VerificationMeta('destinationAccount');
  @override
  late final GeneratedColumn<String> destinationAccount =
      GeneratedColumn<String>(
        'destination_account',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
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
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    accountId,
    account,
    amount,
    currencyCode,
    accountAmount,
    destinationAccountAmount,
    type,
    transactionDateTime,
    paymentMethod,
    destinationAccount,
    destinationAccountId,
    note,
    tags,
    receiptPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('account_amount')) {
      context.handle(
        _accountAmountMeta,
        accountAmount.isAcceptableOrUnknown(
          data['account_amount']!,
          _accountAmountMeta,
        ),
      );
    }
    if (data.containsKey('destination_account_amount')) {
      context.handle(
        _destinationAccountAmountMeta,
        destinationAccountAmount.isAcceptableOrUnknown(
          data['destination_account_amount']!,
          _destinationAccountAmountMeta,
        ),
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
    if (data.containsKey('date_time')) {
      context.handle(
        _transactionDateTimeMeta,
        transactionDateTime.isAcceptableOrUnknown(
          data['date_time']!,
          _transactionDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateTimeMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('destination_account')) {
      context.handle(
        _destinationAccountMeta,
        destinationAccount.isAcceptableOrUnknown(
          data['destination_account']!,
          _destinationAccountMeta,
        ),
      );
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      accountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}account_amount'],
      ),
      destinationAccountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_account_amount'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      transactionDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      destinationAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account'],
      ),
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
    );
  }

  @override
  $TransactionEntriesTable createAlias(String alias) {
    return $TransactionEntriesTable(attachedDatabase, alias);
  }
}

class TransactionEntry extends DataClass
    implements Insertable<TransactionEntry> {
  final String id;
  final String title;
  final String category;
  final String accountId;
  final String account;
  final double amount;
  final String currencyCode;
  final double? accountAmount;
  final double? destinationAccountAmount;

  /// expense | income | transfer
  final String type;
  final DateTime transactionDateTime;
  final String? paymentMethod;
  final String? destinationAccount;
  final String? destinationAccountId;
  final String? note;
  final String? tags;
  final String? receiptPath;
  const TransactionEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.accountId,
    required this.account,
    required this.amount,
    required this.currencyCode,
    this.accountAmount,
    this.destinationAccountAmount,
    required this.type,
    required this.transactionDateTime,
    this.paymentMethod,
    this.destinationAccount,
    this.destinationAccountId,
    this.note,
    this.tags,
    this.receiptPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['account_id'] = Variable<String>(accountId);
    map['account'] = Variable<String>(account);
    map['amount'] = Variable<double>(amount);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || accountAmount != null) {
      map['account_amount'] = Variable<double>(accountAmount);
    }
    if (!nullToAbsent || destinationAccountAmount != null) {
      map['destination_account_amount'] = Variable<double>(
        destinationAccountAmount,
      );
    }
    map['type'] = Variable<String>(type);
    map['date_time'] = Variable<DateTime>(transactionDateTime);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || destinationAccount != null) {
      map['destination_account'] = Variable<String>(destinationAccount);
    }
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    return map;
  }

  TransactionEntriesCompanion toCompanion(bool nullToAbsent) {
    return TransactionEntriesCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      accountId: Value(accountId),
      account: Value(account),
      amount: Value(amount),
      currencyCode: Value(currencyCode),
      accountAmount: accountAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(accountAmount),
      destinationAccountAmount: destinationAccountAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountAmount),
      type: Value(type),
      transactionDateTime: Value(transactionDateTime),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      destinationAccount: destinationAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccount),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
    );
  }

  factory TransactionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      accountId: serializer.fromJson<String>(json['accountId']),
      account: serializer.fromJson<String>(json['account']),
      amount: serializer.fromJson<double>(json['amount']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      accountAmount: serializer.fromJson<double?>(json['accountAmount']),
      destinationAccountAmount: serializer.fromJson<double?>(
        json['destinationAccountAmount'],
      ),
      type: serializer.fromJson<String>(json['type']),
      transactionDateTime: serializer.fromJson<DateTime>(
        json['transactionDateTime'],
      ),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      destinationAccount: serializer.fromJson<String?>(
        json['destinationAccount'],
      ),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<String?>(json['tags']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'accountId': serializer.toJson<String>(accountId),
      'account': serializer.toJson<String>(account),
      'amount': serializer.toJson<double>(amount),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'accountAmount': serializer.toJson<double?>(accountAmount),
      'destinationAccountAmount': serializer.toJson<double?>(
        destinationAccountAmount,
      ),
      'type': serializer.toJson<String>(type),
      'transactionDateTime': serializer.toJson<DateTime>(transactionDateTime),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'destinationAccount': serializer.toJson<String?>(destinationAccount),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<String?>(tags),
      'receiptPath': serializer.toJson<String?>(receiptPath),
    };
  }

  TransactionEntry copyWith({
    String? id,
    String? title,
    String? category,
    String? accountId,
    String? account,
    double? amount,
    String? currencyCode,
    Value<double?> accountAmount = const Value.absent(),
    Value<double?> destinationAccountAmount = const Value.absent(),
    String? type,
    DateTime? transactionDateTime,
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> destinationAccount = const Value.absent(),
    Value<String?> destinationAccountId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
  }) => TransactionEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    accountId: accountId ?? this.accountId,
    account: account ?? this.account,
    amount: amount ?? this.amount,
    currencyCode: currencyCode ?? this.currencyCode,
    accountAmount: accountAmount.present
        ? accountAmount.value
        : this.accountAmount,
    destinationAccountAmount: destinationAccountAmount.present
        ? destinationAccountAmount.value
        : this.destinationAccountAmount,
    type: type ?? this.type,
    transactionDateTime: transactionDateTime ?? this.transactionDateTime,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    destinationAccount: destinationAccount.present
        ? destinationAccount.value
        : this.destinationAccount,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    note: note.present ? note.value : this.note,
    tags: tags.present ? tags.value : this.tags,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
  );
  TransactionEntry copyWithCompanion(TransactionEntriesCompanion data) {
    return TransactionEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      account: data.account.present ? data.account.value : this.account,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      accountAmount: data.accountAmount.present
          ? data.accountAmount.value
          : this.accountAmount,
      destinationAccountAmount: data.destinationAccountAmount.present
          ? data.destinationAccountAmount.value
          : this.destinationAccountAmount,
      type: data.type.present ? data.type.value : this.type,
      transactionDateTime: data.transactionDateTime.present
          ? data.transactionDateTime.value
          : this.transactionDateTime,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      destinationAccount: data.destinationAccount.present
          ? data.destinationAccount.value
          : this.destinationAccount,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('accountId: $accountId, ')
          ..write('account: $account, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('accountAmount: $accountAmount, ')
          ..write('destinationAccountAmount: $destinationAccountAmount, ')
          ..write('type: $type, ')
          ..write('transactionDateTime: $transactionDateTime, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('destinationAccount: $destinationAccount, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('receiptPath: $receiptPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    accountId,
    account,
    amount,
    currencyCode,
    accountAmount,
    destinationAccountAmount,
    type,
    transactionDateTime,
    paymentMethod,
    destinationAccount,
    destinationAccountId,
    note,
    tags,
    receiptPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.accountId == this.accountId &&
          other.account == this.account &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.accountAmount == this.accountAmount &&
          other.destinationAccountAmount == this.destinationAccountAmount &&
          other.type == this.type &&
          other.transactionDateTime == this.transactionDateTime &&
          other.paymentMethod == this.paymentMethod &&
          other.destinationAccount == this.destinationAccount &&
          other.destinationAccountId == this.destinationAccountId &&
          other.note == this.note &&
          other.tags == this.tags &&
          other.receiptPath == this.receiptPath);
}

class TransactionEntriesCompanion extends UpdateCompanion<TransactionEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<String> accountId;
  final Value<String> account;
  final Value<double> amount;
  final Value<String> currencyCode;
  final Value<double?> accountAmount;
  final Value<double?> destinationAccountAmount;
  final Value<String> type;
  final Value<DateTime> transactionDateTime;
  final Value<String?> paymentMethod;
  final Value<String?> destinationAccount;
  final Value<String?> destinationAccountId;
  final Value<String?> note;
  final Value<String?> tags;
  final Value<String?> receiptPath;
  final Value<int> rowid;
  const TransactionEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.accountId = const Value.absent(),
    this.account = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.accountAmount = const Value.absent(),
    this.destinationAccountAmount = const Value.absent(),
    this.type = const Value.absent(),
    this.transactionDateTime = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.destinationAccount = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionEntriesCompanion.insert({
    required String id,
    required String title,
    required String category,
    required String accountId,
    required String account,
    required double amount,
    this.currencyCode = const Value.absent(),
    this.accountAmount = const Value.absent(),
    this.destinationAccountAmount = const Value.absent(),
    required String type,
    required DateTime transactionDateTime,
    this.paymentMethod = const Value.absent(),
    this.destinationAccount = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       accountId = Value(accountId),
       account = Value(account),
       amount = Value(amount),
       type = Value(type),
       transactionDateTime = Value(transactionDateTime);
  static Insertable<TransactionEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? accountId,
    Expression<String>? account,
    Expression<double>? amount,
    Expression<String>? currencyCode,
    Expression<double>? accountAmount,
    Expression<double>? destinationAccountAmount,
    Expression<String>? type,
    Expression<DateTime>? transactionDateTime,
    Expression<String>? paymentMethod,
    Expression<String>? destinationAccount,
    Expression<String>? destinationAccountId,
    Expression<String>? note,
    Expression<String>? tags,
    Expression<String>? receiptPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (accountId != null) 'account_id': accountId,
      if (account != null) 'account': account,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (accountAmount != null) 'account_amount': accountAmount,
      if (destinationAccountAmount != null)
        'destination_account_amount': destinationAccountAmount,
      if (type != null) 'type': type,
      if (transactionDateTime != null) 'date_time': transactionDateTime,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (destinationAccount != null) 'destination_account': destinationAccount,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<String>? accountId,
    Value<String>? account,
    Value<double>? amount,
    Value<String>? currencyCode,
    Value<double?>? accountAmount,
    Value<double?>? destinationAccountAmount,
    Value<String>? type,
    Value<DateTime>? transactionDateTime,
    Value<String?>? paymentMethod,
    Value<String?>? destinationAccount,
    Value<String?>? destinationAccountId,
    Value<String?>? note,
    Value<String?>? tags,
    Value<String?>? receiptPath,
    Value<int>? rowid,
  }) {
    return TransactionEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      account: account ?? this.account,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      accountAmount: accountAmount ?? this.accountAmount,
      destinationAccountAmount:
          destinationAccountAmount ?? this.destinationAccountAmount,
      type: type ?? this.type,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      receiptPath: receiptPath ?? this.receiptPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (accountAmount.present) {
      map['account_amount'] = Variable<double>(accountAmount.value);
    }
    if (destinationAccountAmount.present) {
      map['destination_account_amount'] = Variable<double>(
        destinationAccountAmount.value,
      );
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (transactionDateTime.present) {
      map['date_time'] = Variable<DateTime>(transactionDateTime.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (destinationAccount.present) {
      map['destination_account'] = Variable<String>(destinationAccount.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('accountId: $accountId, ')
          ..write('account: $account, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('accountAmount: $accountAmount, ')
          ..write('destinationAccountAmount: $destinationAccountAmount, ')
          ..write('type: $type, ')
          ..write('transactionDateTime: $transactionDateTime, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('destinationAccount: $destinationAccount, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsEntriesTable extends AppSettingsEntries
    with TableInfo<$AppSettingsEntriesTable, AppSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _monthlyBudgetMeta = const VerificationMeta(
    'monthlyBudget',
  );
  @override
  late final GeneratedColumn<double> monthlyBudget = GeneratedColumn<double>(
    'monthly_budget',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MYR'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, monthlyBudget, baseCurrency];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_budget')) {
      context.handle(
        _monthlyBudgetMeta,
        monthlyBudget.isAcceptableOrUnknown(
          data['monthly_budget']!,
          _monthlyBudgetMeta,
        ),
      );
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthlyBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_budget'],
      ),
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
    );
  }

  @override
  $AppSettingsEntriesTable createAlias(String alias) {
    return $AppSettingsEntriesTable(attachedDatabase, alias);
  }
}

class AppSettingsEntry extends DataClass
    implements Insertable<AppSettingsEntry> {
  final int id;
  final double? monthlyBudget;
  final String baseCurrency;
  const AppSettingsEntry({
    required this.id,
    this.monthlyBudget,
    required this.baseCurrency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || monthlyBudget != null) {
      map['monthly_budget'] = Variable<double>(monthlyBudget);
    }
    map['base_currency'] = Variable<String>(baseCurrency);
    return map;
  }

  AppSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsEntriesCompanion(
      id: Value(id),
      monthlyBudget: monthlyBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyBudget),
      baseCurrency: Value(baseCurrency),
    );
  }

  factory AppSettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsEntry(
      id: serializer.fromJson<int>(json['id']),
      monthlyBudget: serializer.fromJson<double?>(json['monthlyBudget']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyBudget': serializer.toJson<double?>(monthlyBudget),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
    };
  }

  AppSettingsEntry copyWith({
    int? id,
    Value<double?> monthlyBudget = const Value.absent(),
    String? baseCurrency,
  }) => AppSettingsEntry(
    id: id ?? this.id,
    monthlyBudget: monthlyBudget.present
        ? monthlyBudget.value
        : this.monthlyBudget,
    baseCurrency: baseCurrency ?? this.baseCurrency,
  );
  AppSettingsEntry copyWithCompanion(AppSettingsEntriesCompanion data) {
    return AppSettingsEntry(
      id: data.id.present ? data.id.value : this.id,
      monthlyBudget: data.monthlyBudget.present
          ? data.monthlyBudget.value
          : this.monthlyBudget,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntry(')
          ..write('id: $id, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('baseCurrency: $baseCurrency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, monthlyBudget, baseCurrency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsEntry &&
          other.id == this.id &&
          other.monthlyBudget == this.monthlyBudget &&
          other.baseCurrency == this.baseCurrency);
}

class AppSettingsEntriesCompanion extends UpdateCompanion<AppSettingsEntry> {
  final Value<int> id;
  final Value<double?> monthlyBudget;
  final Value<String> baseCurrency;
  const AppSettingsEntriesCompanion({
    this.id = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.baseCurrency = const Value.absent(),
  });
  AppSettingsEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.baseCurrency = const Value.absent(),
  });
  static Insertable<AppSettingsEntry> custom({
    Expression<int>? id,
    Expression<double>? monthlyBudget,
    Expression<String>? baseCurrency,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
      if (baseCurrency != null) 'base_currency': baseCurrency,
    });
  }

  AppSettingsEntriesCompanion copyWith({
    Value<int>? id,
    Value<double?>? monthlyBudget,
    Value<String>? baseCurrency,
  }) {
    return AppSettingsEntriesCompanion(
      id: id ?? this.id,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      baseCurrency: baseCurrency ?? this.baseCurrency,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyBudget.present) {
      map['monthly_budget'] = Variable<double>(monthlyBudget.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntriesCompanion(')
          ..write('id: $id, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('baseCurrency: $baseCurrency')
          ..write(')'))
        .toString();
  }
}

class $CategoryEntriesTable extends CategoryEntries
    with TableInfo<$CategoryEntriesTable, CategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    iconCodePoint,
    isDefault,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryEntry> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CategoryEntriesTable createAlias(String alias) {
    return $CategoryEntriesTable(attachedDatabase, alias);
  }
}

class CategoryEntry extends DataClass implements Insertable<CategoryEntry> {
  final String id;
  final String name;

  /// expense | income
  final String type;

  /// Material icon codePoint
  final int iconCodePoint;
  final bool isDefault;
  final bool isActive;
  const CategoryEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.isDefault,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CategoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return CategoryEntriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      iconCodePoint: Value(iconCodePoint),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
    );
  }

  factory CategoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CategoryEntry copyWith({
    String? id,
    String? name,
    String? type,
    int? iconCodePoint,
    bool? isDefault,
    bool? isActive,
  }) => CategoryEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
  );
  CategoryEntry copyWithCompanion(CategoryEntriesCompanion data) {
    return CategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, iconCodePoint, isDefault, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.iconCodePoint == this.iconCodePoint &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive);
}

class CategoryEntriesCompanion extends UpdateCompanion<CategoryEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> iconCodePoint;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CategoryEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryEntriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required int iconCodePoint,
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<CategoryEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? iconCodePoint,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int>? iconCodePoint,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CategoryEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetEntriesTable extends CategoryBudgetEntries
    with TableInfo<$CategoryBudgetEntriesTable, CategoryBudgetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyBudgetMeta = const VerificationMeta(
    'monthlyBudget',
  );
  @override
  late final GeneratedColumn<double> monthlyBudget = GeneratedColumn<double>(
    'monthly_budget',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [categoryId, monthlyBudget];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryBudgetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('monthly_budget')) {
      context.handle(
        _monthlyBudgetMeta,
        monthlyBudget.isAcceptableOrUnknown(
          data['monthly_budget']!,
          _monthlyBudgetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyBudgetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  CategoryBudgetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudgetEntry(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      monthlyBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_budget'],
      )!,
    );
  }

  @override
  $CategoryBudgetEntriesTable createAlias(String alias) {
    return $CategoryBudgetEntriesTable(attachedDatabase, alias);
  }
}

class CategoryBudgetEntry extends DataClass
    implements Insertable<CategoryBudgetEntry> {
  /// One recurring monthly limit per category.
  final String categoryId;
  final double monthlyBudget;
  const CategoryBudgetEntry({
    required this.categoryId,
    required this.monthlyBudget,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['monthly_budget'] = Variable<double>(monthlyBudget);
    return map;
  }

  CategoryBudgetEntriesCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetEntriesCompanion(
      categoryId: Value(categoryId),
      monthlyBudget: Value(monthlyBudget),
    );
  }

  factory CategoryBudgetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudgetEntry(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      monthlyBudget: serializer.fromJson<double>(json['monthlyBudget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'monthlyBudget': serializer.toJson<double>(monthlyBudget),
    };
  }

  CategoryBudgetEntry copyWith({String? categoryId, double? monthlyBudget}) =>
      CategoryBudgetEntry(
        categoryId: categoryId ?? this.categoryId,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      );
  CategoryBudgetEntry copyWithCompanion(CategoryBudgetEntriesCompanion data) {
    return CategoryBudgetEntry(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      monthlyBudget: data.monthlyBudget.present
          ? data.monthlyBudget.value
          : this.monthlyBudget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetEntry(')
          ..write('categoryId: $categoryId, ')
          ..write('monthlyBudget: $monthlyBudget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, monthlyBudget);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudgetEntry &&
          other.categoryId == this.categoryId &&
          other.monthlyBudget == this.monthlyBudget);
}

class CategoryBudgetEntriesCompanion
    extends UpdateCompanion<CategoryBudgetEntry> {
  final Value<String> categoryId;
  final Value<double> monthlyBudget;
  final Value<int> rowid;
  const CategoryBudgetEntriesCompanion({
    this.categoryId = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryBudgetEntriesCompanion.insert({
    required String categoryId,
    required double monthlyBudget,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       monthlyBudget = Value(monthlyBudget);
  static Insertable<CategoryBudgetEntry> custom({
    Expression<String>? categoryId,
    Expression<double>? monthlyBudget,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryBudgetEntriesCompanion copyWith({
    Value<String>? categoryId,
    Value<double>? monthlyBudget,
    Value<int>? rowid,
  }) {
    return CategoryBudgetEntriesCompanion(
      categoryId: categoryId ?? this.categoryId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (monthlyBudget.present) {
      map['monthly_budget'] = Variable<double>(monthlyBudget.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetEntriesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringScheduleEntriesTable extends RecurringScheduleEntries
    with TableInfo<$RecurringScheduleEntriesTable, RecurringScheduleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringScheduleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDateMeta = const VerificationMeta(
    'nextDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDate = GeneratedColumn<DateTime>(
    'next_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    accountId,
    category,
    amount,
    type,
    frequency,
    nextDate,
    iconCodePoint,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringScheduleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('next_date')) {
      context.handle(
        _nextDateMeta,
        nextDate.isAcceptableOrUnknown(data['next_date']!, _nextDateMeta),
      );
    } else if (isInserting) {
      context.missing(_nextDateMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringScheduleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringScheduleEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      nextDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_date'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RecurringScheduleEntriesTable createAlias(String alias) {
    return $RecurringScheduleEntriesTable(attachedDatabase, alias);
  }
}

class RecurringScheduleEntry extends DataClass
    implements Insertable<RecurringScheduleEntry> {
  final String id;
  final String title;
  final String accountId;
  final String category;
  final double amount;

  /// expense | income
  final String type;

  /// Monthly for now; designed to support more frequencies later.
  final String frequency;
  final DateTime nextDate;
  final int iconCodePoint;
  final bool isActive;
  const RecurringScheduleEntry({
    required this.id,
    required this.title,
    required this.accountId,
    required this.category,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.nextDate,
    required this.iconCodePoint,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['account_id'] = Variable<String>(accountId);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['frequency'] = Variable<String>(frequency);
    map['next_date'] = Variable<DateTime>(nextDate);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RecurringScheduleEntriesCompanion toCompanion(bool nullToAbsent) {
    return RecurringScheduleEntriesCompanion(
      id: Value(id),
      title: Value(title),
      accountId: Value(accountId),
      category: Value(category),
      amount: Value(amount),
      type: Value(type),
      frequency: Value(frequency),
      nextDate: Value(nextDate),
      iconCodePoint: Value(iconCodePoint),
      isActive: Value(isActive),
    );
  }

  factory RecurringScheduleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringScheduleEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      accountId: serializer.fromJson<String>(json['accountId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextDate: serializer.fromJson<DateTime>(json['nextDate']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'accountId': serializer.toJson<String>(accountId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'frequency': serializer.toJson<String>(frequency),
      'nextDate': serializer.toJson<DateTime>(nextDate),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RecurringScheduleEntry copyWith({
    String? id,
    String? title,
    String? accountId,
    String? category,
    double? amount,
    String? type,
    String? frequency,
    DateTime? nextDate,
    int? iconCodePoint,
    bool? isActive,
  }) => RecurringScheduleEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    accountId: accountId ?? this.accountId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    frequency: frequency ?? this.frequency,
    nextDate: nextDate ?? this.nextDate,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    isActive: isActive ?? this.isActive,
  );
  RecurringScheduleEntry copyWithCompanion(
    RecurringScheduleEntriesCompanion data,
  ) {
    return RecurringScheduleEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDate: data.nextDate.present ? data.nextDate.value : this.nextDate,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringScheduleEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('nextDate: $nextDate, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    accountId,
    category,
    amount,
    type,
    frequency,
    nextDate,
    iconCodePoint,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringScheduleEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.accountId == this.accountId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.frequency == this.frequency &&
          other.nextDate == this.nextDate &&
          other.iconCodePoint == this.iconCodePoint &&
          other.isActive == this.isActive);
}

class RecurringScheduleEntriesCompanion
    extends UpdateCompanion<RecurringScheduleEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> accountId;
  final Value<String> category;
  final Value<double> amount;
  final Value<String> type;
  final Value<String> frequency;
  final Value<DateTime> nextDate;
  final Value<int> iconCodePoint;
  final Value<bool> isActive;
  final Value<int> rowid;
  const RecurringScheduleEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.accountId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDate = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringScheduleEntriesCompanion.insert({
    required String id,
    required String title,
    required String accountId,
    required String category,
    required double amount,
    required String type,
    required String frequency,
    required DateTime nextDate,
    required int iconCodePoint,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       accountId = Value(accountId),
       category = Value(category),
       amount = Value(amount),
       type = Value(type),
       frequency = Value(frequency),
       nextDate = Value(nextDate),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<RecurringScheduleEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? accountId,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? frequency,
    Expression<DateTime>? nextDate,
    Expression<int>? iconCodePoint,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (accountId != null) 'account_id': accountId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (frequency != null) 'frequency': frequency,
      if (nextDate != null) 'next_date': nextDate,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringScheduleEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? accountId,
    Value<String>? category,
    Value<double>? amount,
    Value<String>? type,
    Value<String>? frequency,
    Value<DateTime>? nextDate,
    Value<int>? iconCodePoint,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return RecurringScheduleEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextDate.present) {
      map['next_date'] = Variable<DateTime>(nextDate.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringScheduleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('nextDate: $nextDate, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountEntriesTable accountEntries = $AccountEntriesTable(this);
  late final $TransactionEntriesTable transactionEntries =
      $TransactionEntriesTable(this);
  late final $AppSettingsEntriesTable appSettingsEntries =
      $AppSettingsEntriesTable(this);
  late final $CategoryEntriesTable categoryEntries = $CategoryEntriesTable(
    this,
  );
  late final $CategoryBudgetEntriesTable categoryBudgetEntries =
      $CategoryBudgetEntriesTable(this);
  late final $RecurringScheduleEntriesTable recurringScheduleEntries =
      $RecurringScheduleEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountEntries,
    transactionEntries,
    appSettingsEntries,
    categoryEntries,
    categoryBudgetEntries,
    recurringScheduleEntries,
  ];
}

typedef $$AccountEntriesTableCreateCompanionBuilder =
    AccountEntriesCompanion Function({
      required String id,
      required String name,
      required String type,
      required double openingBalance,
      required String currencyCode,
      Value<bool> isPrimary,
      Value<bool> isActive,
      Value<double?> creditLimit,
      Value<int?> statementCycleDay,
      Value<int> rowid,
    });
typedef $$AccountEntriesTableUpdateCompanionBuilder =
    AccountEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<double> openingBalance,
      Value<String> currencyCode,
      Value<bool> isPrimary,
      Value<bool> isActive,
      Value<double?> creditLimit,
      Value<int?> statementCycleDay,
      Value<int> rowid,
    });

class $$AccountEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statementCycleDay => $composableBuilder(
    column: $table.statementCycleDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statementCycleDay => $composableBuilder(
    column: $table.statementCycleDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statementCycleDay => $composableBuilder(
    column: $table.statementCycleDay,
    builder: (column) => column,
  );
}

class $$AccountEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountEntriesTable,
          AccountEntry,
          $$AccountEntriesTableFilterComposer,
          $$AccountEntriesTableOrderingComposer,
          $$AccountEntriesTableAnnotationComposer,
          $$AccountEntriesTableCreateCompanionBuilder,
          $$AccountEntriesTableUpdateCompanionBuilder,
          (
            AccountEntry,
            BaseReferences<_$AppDatabase, $AccountEntriesTable, AccountEntry>,
          ),
          AccountEntry,
          PrefetchHooks Function()
        > {
  $$AccountEntriesTableTableManager(
    _$AppDatabase db,
    $AccountEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<int?> statementCycleDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountEntriesCompanion(
                id: id,
                name: name,
                type: type,
                openingBalance: openingBalance,
                currencyCode: currencyCode,
                isPrimary: isPrimary,
                isActive: isActive,
                creditLimit: creditLimit,
                statementCycleDay: statementCycleDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required double openingBalance,
                required String currencyCode,
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<int?> statementCycleDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountEntriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                openingBalance: openingBalance,
                currencyCode: currencyCode,
                isPrimary: isPrimary,
                isActive: isActive,
                creditLimit: creditLimit,
                statementCycleDay: statementCycleDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountEntriesTable, AccountEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AccountEntriesTable,
                    AccountEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountEntriesTable,
      AccountEntry,
      $$AccountEntriesTableFilterComposer,
      $$AccountEntriesTableOrderingComposer,
      $$AccountEntriesTableAnnotationComposer,
      $$AccountEntriesTableCreateCompanionBuilder,
      $$AccountEntriesTableUpdateCompanionBuilder,
      (
        AccountEntry,
        BaseReferences<_$AppDatabase, $AccountEntriesTable, AccountEntry>,
      ),
      AccountEntry,
      PrefetchHooks Function()
    >;
typedef $$TransactionEntriesTableCreateCompanionBuilder =
    TransactionEntriesCompanion Function({
      required String id,
      required String title,
      required String category,
      required String accountId,
      required String account,
      required double amount,
      Value<String> currencyCode,
      Value<double?> accountAmount,
      Value<double?> destinationAccountAmount,
      required String type,
      required DateTime transactionDateTime,
      Value<String?> paymentMethod,
      Value<String?> destinationAccount,
      Value<String?> destinationAccountId,
      Value<String?> note,
      Value<String?> tags,
      Value<String?> receiptPath,
      Value<int> rowid,
    });
typedef $$TransactionEntriesTableUpdateCompanionBuilder =
    TransactionEntriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> category,
      Value<String> accountId,
      Value<String> account,
      Value<double> amount,
      Value<String> currencyCode,
      Value<double?> accountAmount,
      Value<double?> destinationAccountAmount,
      Value<String> type,
      Value<DateTime> transactionDateTime,
      Value<String?> paymentMethod,
      Value<String?> destinationAccount,
      Value<String?> destinationAccountId,
      Value<String?> note,
      Value<String?> tags,
      Value<String?> receiptPath,
      Value<int> rowid,
    });

class $$TransactionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accountAmount => $composableBuilder(
    column: $table.accountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationAccountAmount => $composableBuilder(
    column: $table.destinationAccountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDateTime => $composableBuilder(
    column: $table.transactionDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccount => $composableBuilder(
    column: $table.destinationAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accountAmount => $composableBuilder(
    column: $table.accountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationAccountAmount => $composableBuilder(
    column: $table.destinationAccountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDateTime => $composableBuilder(
    column: $table.transactionDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccount => $composableBuilder(
    column: $table.destinationAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accountAmount => $composableBuilder(
    column: $table.accountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get destinationAccountAmount => $composableBuilder(
    column: $table.destinationAccountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDateTime => $composableBuilder(
    column: $table.transactionDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccount => $composableBuilder(
    column: $table.destinationAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );
}

class $$TransactionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionEntriesTable,
          TransactionEntry,
          $$TransactionEntriesTableFilterComposer,
          $$TransactionEntriesTableOrderingComposer,
          $$TransactionEntriesTableAnnotationComposer,
          $$TransactionEntriesTableCreateCompanionBuilder,
          $$TransactionEntriesTableUpdateCompanionBuilder,
          (
            TransactionEntry,
            BaseReferences<
              _$AppDatabase,
              $TransactionEntriesTable,
              TransactionEntry
            >,
          ),
          TransactionEntry,
          PrefetchHooks Function()
        > {
  $$TransactionEntriesTableTableManager(
    _$AppDatabase db,
    $TransactionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> account = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<double?> accountAmount = const Value.absent(),
                Value<double?> destinationAccountAmount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> transactionDateTime = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> destinationAccount = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion(
                id: id,
                title: title,
                category: category,
                accountId: accountId,
                account: account,
                amount: amount,
                currencyCode: currencyCode,
                accountAmount: accountAmount,
                destinationAccountAmount: destinationAccountAmount,
                type: type,
                transactionDateTime: transactionDateTime,
                paymentMethod: paymentMethod,
                destinationAccount: destinationAccount,
                destinationAccountId: destinationAccountId,
                note: note,
                tags: tags,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String category,
                required String accountId,
                required String account,
                required double amount,
                Value<String> currencyCode = const Value.absent(),
                Value<double?> accountAmount = const Value.absent(),
                Value<double?> destinationAccountAmount = const Value.absent(),
                required String type,
                required DateTime transactionDateTime,
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> destinationAccount = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion.insert(
                id: id,
                title: title,
                category: category,
                accountId: accountId,
                account: account,
                amount: amount,
                currencyCode: currencyCode,
                accountAmount: accountAmount,
                destinationAccountAmount: destinationAccountAmount,
                type: type,
                transactionDateTime: transactionDateTime,
                paymentMethod: paymentMethod,
                destinationAccount: destinationAccount,
                destinationAccountId: destinationAccountId,
                note: note,
                tags: tags,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionEntriesTable, TransactionEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionEntriesTable,
                    TransactionEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionEntriesTable,
      TransactionEntry,
      $$TransactionEntriesTableFilterComposer,
      $$TransactionEntriesTableOrderingComposer,
      $$TransactionEntriesTableAnnotationComposer,
      $$TransactionEntriesTableCreateCompanionBuilder,
      $$TransactionEntriesTableUpdateCompanionBuilder,
      (
        TransactionEntry,
        BaseReferences<
          _$AppDatabase,
          $TransactionEntriesTable,
          TransactionEntry
        >,
      ),
      TransactionEntry,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsEntriesTableCreateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      Value<int> id,
      Value<double?> monthlyBudget,
      Value<String> baseCurrency,
    });
typedef $$AppSettingsEntriesTableUpdateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      Value<int> id,
      Value<double?> monthlyBudget,
      Value<String> baseCurrency,
    });

class $$AppSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableFilterComposer({
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

  ColumnFilters<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableOrderingComposer({
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

  ColumnOrderings<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );
}

class $$AppSettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingsEntry,
          $$AppSettingsEntriesTableFilterComposer,
          $$AppSettingsEntriesTableOrderingComposer,
          $$AppSettingsEntriesTableAnnotationComposer,
          $$AppSettingsEntriesTableCreateCompanionBuilder,
          $$AppSettingsEntriesTableUpdateCompanionBuilder,
          (
            AppSettingsEntry,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsEntriesTable,
              AppSettingsEntry
            >,
          ),
          AppSettingsEntry,
          PrefetchHooks Function()
        > {
  $$AppSettingsEntriesTableTableManager(
    _$AppDatabase db,
    $AppSettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double?> monthlyBudget = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
              }) => AppSettingsEntriesCompanion(
                id: id,
                monthlyBudget: monthlyBudget,
                baseCurrency: baseCurrency,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double?> monthlyBudget = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
              }) => AppSettingsEntriesCompanion.insert(
                id: id,
                monthlyBudget: monthlyBudget,
                baseCurrency: baseCurrency,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsEntriesTable, AppSettingsEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsEntriesTable,
                    AppSettingsEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsEntriesTable,
      AppSettingsEntry,
      $$AppSettingsEntriesTableFilterComposer,
      $$AppSettingsEntriesTableOrderingComposer,
      $$AppSettingsEntriesTableAnnotationComposer,
      $$AppSettingsEntriesTableCreateCompanionBuilder,
      $$AppSettingsEntriesTableUpdateCompanionBuilder,
      (
        AppSettingsEntry,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingsEntry
        >,
      ),
      AppSettingsEntry,
      PrefetchHooks Function()
    >;
typedef $$CategoryEntriesTableCreateCompanionBuilder =
    CategoryEntriesCompanion Function({
      required String id,
      required String name,
      required String type,
      required int iconCodePoint,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$CategoryEntriesTableUpdateCompanionBuilder =
    CategoryEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<int> iconCodePoint,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CategoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CategoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryEntriesTable,
          CategoryEntry,
          $$CategoryEntriesTableFilterComposer,
          $$CategoryEntriesTableOrderingComposer,
          $$CategoryEntriesTableAnnotationComposer,
          $$CategoryEntriesTableCreateCompanionBuilder,
          $$CategoryEntriesTableUpdateCompanionBuilder,
          (
            CategoryEntry,
            BaseReferences<_$AppDatabase, $CategoryEntriesTable, CategoryEntry>,
          ),
          CategoryEntry,
          PrefetchHooks Function()
        > {
  $$CategoryEntriesTableTableManager(
    _$AppDatabase db,
    $CategoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryEntriesCompanion(
                id: id,
                name: name,
                type: type,
                iconCodePoint: iconCodePoint,
                isDefault: isDefault,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required int iconCodePoint,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryEntriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                iconCodePoint: iconCodePoint,
                isDefault: isDefault,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryEntriesTable, CategoryEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CategoryEntriesTable,
                    CategoryEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryEntriesTable,
      CategoryEntry,
      $$CategoryEntriesTableFilterComposer,
      $$CategoryEntriesTableOrderingComposer,
      $$CategoryEntriesTableAnnotationComposer,
      $$CategoryEntriesTableCreateCompanionBuilder,
      $$CategoryEntriesTableUpdateCompanionBuilder,
      (
        CategoryEntry,
        BaseReferences<_$AppDatabase, $CategoryEntriesTable, CategoryEntry>,
      ),
      CategoryEntry,
      PrefetchHooks Function()
    >;
typedef $$CategoryBudgetEntriesTableCreateCompanionBuilder =
    CategoryBudgetEntriesCompanion Function({
      required String categoryId,
      required double monthlyBudget,
      Value<int> rowid,
    });
typedef $$CategoryBudgetEntriesTableUpdateCompanionBuilder =
    CategoryBudgetEntriesCompanion Function({
      Value<String> categoryId,
      Value<double> monthlyBudget,
      Value<int> rowid,
    });

class $$CategoryBudgetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryBudgetEntriesTable> {
  $$CategoryBudgetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryBudgetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryBudgetEntriesTable> {
  $$CategoryBudgetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryBudgetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryBudgetEntriesTable> {
  $$CategoryBudgetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => column,
  );
}

class $$CategoryBudgetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryBudgetEntriesTable,
          CategoryBudgetEntry,
          $$CategoryBudgetEntriesTableFilterComposer,
          $$CategoryBudgetEntriesTableOrderingComposer,
          $$CategoryBudgetEntriesTableAnnotationComposer,
          $$CategoryBudgetEntriesTableCreateCompanionBuilder,
          $$CategoryBudgetEntriesTableUpdateCompanionBuilder,
          (
            CategoryBudgetEntry,
            BaseReferences<
              _$AppDatabase,
              $CategoryBudgetEntriesTable,
              CategoryBudgetEntry
            >,
          ),
          CategoryBudgetEntry,
          PrefetchHooks Function()
        > {
  $$CategoryBudgetEntriesTableTableManager(
    _$AppDatabase db,
    $CategoryBudgetEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CategoryBudgetEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CategoryBudgetEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryBudgetEntriesCompanion(
                categoryId: categoryId,
                monthlyBudget: monthlyBudget,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required double monthlyBudget,
                Value<int> rowid = const Value.absent(),
              }) => CategoryBudgetEntriesCompanion.insert(
                categoryId: categoryId,
                monthlyBudget: monthlyBudget,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryBudgetEntriesTable, CategoryBudgetEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CategoryBudgetEntriesTable,
                    CategoryBudgetEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryBudgetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryBudgetEntriesTable,
      CategoryBudgetEntry,
      $$CategoryBudgetEntriesTableFilterComposer,
      $$CategoryBudgetEntriesTableOrderingComposer,
      $$CategoryBudgetEntriesTableAnnotationComposer,
      $$CategoryBudgetEntriesTableCreateCompanionBuilder,
      $$CategoryBudgetEntriesTableUpdateCompanionBuilder,
      (
        CategoryBudgetEntry,
        BaseReferences<
          _$AppDatabase,
          $CategoryBudgetEntriesTable,
          CategoryBudgetEntry
        >,
      ),
      CategoryBudgetEntry,
      PrefetchHooks Function()
    >;
typedef $$RecurringScheduleEntriesTableCreateCompanionBuilder =
    RecurringScheduleEntriesCompanion Function({
      required String id,
      required String title,
      required String accountId,
      required String category,
      required double amount,
      required String type,
      required String frequency,
      required DateTime nextDate,
      required int iconCodePoint,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$RecurringScheduleEntriesTableUpdateCompanionBuilder =
    RecurringScheduleEntriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> accountId,
      Value<String> category,
      Value<double> amount,
      Value<String> type,
      Value<String> frequency,
      Value<DateTime> nextDate,
      Value<int> iconCodePoint,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$RecurringScheduleEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringScheduleEntriesTable> {
  $$RecurringScheduleEntriesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDate => $composableBuilder(
    column: $table.nextDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringScheduleEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringScheduleEntriesTable> {
  $$RecurringScheduleEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDate => $composableBuilder(
    column: $table.nextDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringScheduleEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringScheduleEntriesTable> {
  $$RecurringScheduleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDate =>
      $composableBuilder(column: $table.nextDate, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$RecurringScheduleEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringScheduleEntriesTable,
          RecurringScheduleEntry,
          $$RecurringScheduleEntriesTableFilterComposer,
          $$RecurringScheduleEntriesTableOrderingComposer,
          $$RecurringScheduleEntriesTableAnnotationComposer,
          $$RecurringScheduleEntriesTableCreateCompanionBuilder,
          $$RecurringScheduleEntriesTableUpdateCompanionBuilder,
          (
            RecurringScheduleEntry,
            BaseReferences<
              _$AppDatabase,
              $RecurringScheduleEntriesTable,
              RecurringScheduleEntry
            >,
          ),
          RecurringScheduleEntry,
          PrefetchHooks Function()
        > {
  $$RecurringScheduleEntriesTableTableManager(
    _$AppDatabase db,
    $RecurringScheduleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringScheduleEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringScheduleEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringScheduleEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> nextDate = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringScheduleEntriesCompanion(
                id: id,
                title: title,
                accountId: accountId,
                category: category,
                amount: amount,
                type: type,
                frequency: frequency,
                nextDate: nextDate,
                iconCodePoint: iconCodePoint,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String accountId,
                required String category,
                required double amount,
                required String type,
                required String frequency,
                required DateTime nextDate,
                required int iconCodePoint,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringScheduleEntriesCompanion.insert(
                id: id,
                title: title,
                accountId: accountId,
                category: category,
                amount: amount,
                type: type,
                frequency: frequency,
                nextDate: nextDate,
                iconCodePoint: iconCodePoint,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RecurringScheduleEntriesTable,
                    RecurringScheduleEntry
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecurringScheduleEntriesTable,
                    RecurringScheduleEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringScheduleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringScheduleEntriesTable,
      RecurringScheduleEntry,
      $$RecurringScheduleEntriesTableFilterComposer,
      $$RecurringScheduleEntriesTableOrderingComposer,
      $$RecurringScheduleEntriesTableAnnotationComposer,
      $$RecurringScheduleEntriesTableCreateCompanionBuilder,
      $$RecurringScheduleEntriesTableUpdateCompanionBuilder,
      (
        RecurringScheduleEntry,
        BaseReferences<
          _$AppDatabase,
          $RecurringScheduleEntriesTable,
          RecurringScheduleEntry
        >,
      ),
      RecurringScheduleEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountEntriesTableTableManager get accountEntries =>
      $$AccountEntriesTableTableManager(_db, _db.accountEntries);
  $$TransactionEntriesTableTableManager get transactionEntries =>
      $$TransactionEntriesTableTableManager(_db, _db.transactionEntries);
  $$AppSettingsEntriesTableTableManager get appSettingsEntries =>
      $$AppSettingsEntriesTableTableManager(_db, _db.appSettingsEntries);
  $$CategoryEntriesTableTableManager get categoryEntries =>
      $$CategoryEntriesTableTableManager(_db, _db.categoryEntries);
  $$CategoryBudgetEntriesTableTableManager get categoryBudgetEntries =>
      $$CategoryBudgetEntriesTableTableManager(_db, _db.categoryBudgetEntries);
  $$RecurringScheduleEntriesTableTableManager get recurringScheduleEntries =>
      $$RecurringScheduleEntriesTableTableManager(
        _db,
        _db.recurringScheduleEntries,
      );
}
