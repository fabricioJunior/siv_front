// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preco_da_referencia_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPrecoDaReferenciaDtoCollection on Isar {
  IsarCollection<PrecoDaReferenciaDto> get precoDaReferenciaDtos =>
      this.collection();
}

const PrecoDaReferenciaDtoSchema = CollectionSchema(
  name: r'PrecoDaReferenciaDto',
  id: 8562752919205862277,
  properties: {
    r'atualizadoEm': PropertySchema(
      id: 0,
      name: r'atualizadoEm',
      type: IsarType.dateTime,
    ),
    r'hashCode': PropertySchema(id: 1, name: r'hashCode', type: IsarType.long),
    r'operadorId': PropertySchema(
      id: 2,
      name: r'operadorId',
      type: IsarType.long,
    ),
    r'referenciaId': PropertySchema(
      id: 3,
      name: r'referenciaId',
      type: IsarType.long,
    ),
    r'referenciaIdExterno': PropertySchema(
      id: 4,
      name: r'referenciaIdExterno',
      type: IsarType.string,
    ),
    r'referenciaNome': PropertySchema(
      id: 5,
      name: r'referenciaNome',
      type: IsarType.string,
    ),
    r'tabelaDePrecoId': PropertySchema(
      id: 6,
      name: r'tabelaDePrecoId',
      type: IsarType.long,
    ),
    r'valor': PropertySchema(id: 7, name: r'valor', type: IsarType.double),
  },

  estimateSize: _precoDaReferenciaDtoEstimateSize,
  serialize: _precoDaReferenciaDtoSerialize,
  deserialize: _precoDaReferenciaDtoDeserialize,
  deserializeProp: _precoDaReferenciaDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _precoDaReferenciaDtoGetId,
  getLinks: _precoDaReferenciaDtoGetLinks,
  attach: _precoDaReferenciaDtoAttach,
  version: '3.3.0-dev.1',
);

int _precoDaReferenciaDtoEstimateSize(
  PrecoDaReferenciaDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.referenciaIdExterno.length * 3;
  bytesCount += 3 + object.referenciaNome.length * 3;
  return bytesCount;
}

void _precoDaReferenciaDtoSerialize(
  PrecoDaReferenciaDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.atualizadoEm);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeLong(offsets[2], object.operadorId);
  writer.writeLong(offsets[3], object.referenciaId);
  writer.writeString(offsets[4], object.referenciaIdExterno);
  writer.writeString(offsets[5], object.referenciaNome);
  writer.writeLong(offsets[6], object.tabelaDePrecoId);
  writer.writeDouble(offsets[7], object.valor);
}

PrecoDaReferenciaDto _precoDaReferenciaDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PrecoDaReferenciaDto(
    atualizadoEm: reader.readDateTimeOrNull(offsets[0]),
    operadorId: reader.readLong(offsets[2]),
    referenciaId: reader.readLong(offsets[3]),
    referenciaIdExterno: reader.readString(offsets[4]),
    referenciaNome: reader.readString(offsets[5]),
    tabelaDePrecoId: reader.readLong(offsets[6]),
    valor: reader.readDouble(offsets[7]),
  );
  return object;
}

P _precoDaReferenciaDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _precoDaReferenciaDtoGetId(PrecoDaReferenciaDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _precoDaReferenciaDtoGetLinks(
  PrecoDaReferenciaDto object,
) {
  return [];
}

void _precoDaReferenciaDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  PrecoDaReferenciaDto object,
) {}

extension PrecoDaReferenciaDtoQueryWhereSort
    on QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QWhere> {
  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterWhere>
  anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PrecoDaReferenciaDtoQueryWhere
    on QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QWhereClause> {
  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterWhereClause>
  dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: dataBaseId, upper: dataBaseId),
      );
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterWhereClause>
  dataBaseIdNotEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: dataBaseId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: dataBaseId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: dataBaseId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: dataBaseId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterWhereClause>
  dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterWhereClause>
  dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterWhereClause>
  dataBaseIdBetween(
    Id lowerDataBaseId,
    Id upperDataBaseId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerDataBaseId,
          includeLower: includeLower,
          upper: upperDataBaseId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PrecoDaReferenciaDtoQueryFilter
    on
        QueryBuilder<
          PrecoDaReferenciaDto,
          PrecoDaReferenciaDto,
          QFilterCondition
        > {
  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  atualizadoEmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'atualizadoEm'),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  atualizadoEmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'atualizadoEm'),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  atualizadoEmEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'atualizadoEm', value: value),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  atualizadoEmGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'atualizadoEm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  atualizadoEmLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'atualizadoEm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  atualizadoEmBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'atualizadoEm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataBaseId', value: value),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  dataBaseIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataBaseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  dataBaseIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataBaseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  dataBaseIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataBaseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  hashCodeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hashCode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  hashCodeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hashCode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hashCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  operadorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'operadorId', value: value),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  operadorIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'operadorId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  operadorIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'operadorId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  operadorIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'operadorId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenciaId', value: value),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenciaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenciaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenciaId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenciaIdExterno',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'referenciaIdExterno',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenciaIdExterno', value: ''),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaIdExternoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'referenciaIdExterno',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'referenciaNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenciaNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenciaNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenciaNome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'referenciaNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'referenciaNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'referenciaNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'referenciaNome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenciaNome', value: ''),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  referenciaNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'referenciaNome', value: ''),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  tabelaDePrecoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tabelaDePrecoId', value: value),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  tabelaDePrecoIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tabelaDePrecoId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  tabelaDePrecoIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tabelaDePrecoId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  tabelaDePrecoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tabelaDePrecoId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  valorEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'valor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  valorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'valor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  valorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'valor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PrecoDaReferenciaDto,
    PrecoDaReferenciaDto,
    QAfterFilterCondition
  >
  valorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'valor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension PrecoDaReferenciaDtoQueryObject
    on
        QueryBuilder<
          PrecoDaReferenciaDto,
          PrecoDaReferenciaDto,
          QFilterCondition
        > {}

extension PrecoDaReferenciaDtoQueryLinks
    on
        QueryBuilder<
          PrecoDaReferenciaDto,
          PrecoDaReferenciaDto,
          QFilterCondition
        > {}

extension PrecoDaReferenciaDtoQuerySortBy
    on QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QSortBy> {
  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByOperadorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operadorId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByOperadorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operadorId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByReferenciaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByReferenciaIdExterno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByReferenciaIdExternoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByReferenciaNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaNome', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByReferenciaNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaNome', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByTabelaDePrecoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaDePrecoId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByTabelaDePrecoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaDePrecoId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByValor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  sortByValorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.desc);
    });
  }
}

extension PrecoDaReferenciaDtoQuerySortThenBy
    on QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QSortThenBy> {
  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByOperadorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operadorId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByOperadorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operadorId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByReferenciaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByReferenciaIdExterno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByReferenciaIdExternoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByReferenciaNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaNome', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByReferenciaNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaNome', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByTabelaDePrecoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaDePrecoId', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByTabelaDePrecoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaDePrecoId', Sort.desc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByValor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.asc);
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QAfterSortBy>
  thenByValorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.desc);
    });
  }
}

extension PrecoDaReferenciaDtoQueryWhereDistinct
    on QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct> {
  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'atualizadoEm');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByOperadorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operadorId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenciaId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByReferenciaIdExterno({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'referenciaIdExterno',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByReferenciaNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'referenciaNome',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByTabelaDePrecoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tabelaDePrecoId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, PrecoDaReferenciaDto, QDistinct>
  distinctByValor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valor');
    });
  }
}

extension PrecoDaReferenciaDtoQueryProperty
    on
        QueryBuilder<
          PrecoDaReferenciaDto,
          PrecoDaReferenciaDto,
          QQueryProperty
        > {
  QueryBuilder<PrecoDaReferenciaDto, int, QQueryOperations>
  dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, DateTime?, QQueryOperations>
  atualizadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'atualizadoEm');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, int, QQueryOperations>
  operadorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operadorId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, int, QQueryOperations>
  referenciaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, String, QQueryOperations>
  referenciaIdExternoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaIdExterno');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, String, QQueryOperations>
  referenciaNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaNome');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, int, QQueryOperations>
  tabelaDePrecoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tabelaDePrecoId');
    });
  }

  QueryBuilder<PrecoDaReferenciaDto, double, QQueryOperations> valorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valor');
    });
  }
}
