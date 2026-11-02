// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leituras_entrada_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLeiturasEntradaDtoCollection on Isar {
  IsarCollection<LeiturasEntradaDto> get leiturasEntradaDtos =>
      this.collection();
}

const LeiturasEntradaDtoSchema = CollectionSchema(
  name: r'LeiturasEntradaDto',
  id: -6097224007405219745,
  properties: {
    r'atualizadoEm': PropertySchema(
      id: 0,
      name: r'atualizadoEm',
      type: IsarType.dateTime,
    ),
    r'deltasJson': PropertySchema(
      id: 1,
      name: r'deltasJson',
      type: IsarType.string,
    ),
    r'loteId': PropertySchema(
      id: 2,
      name: r'loteId',
      type: IsarType.string,
    ),
    r'operador': PropertySchema(
      id: 3,
      name: r'operador',
      type: IsarType.string,
    ),
    r'pedidoId': PropertySchema(
      id: 4,
      name: r'pedidoId',
      type: IsarType.long,
    )
  },
  estimateSize: _leiturasEntradaDtoEstimateSize,
  serialize: _leiturasEntradaDtoSerialize,
  deserialize: _leiturasEntradaDtoDeserialize,
  deserializeProp: _leiturasEntradaDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _leiturasEntradaDtoGetId,
  getLinks: _leiturasEntradaDtoGetLinks,
  attach: _leiturasEntradaDtoAttach,
  version: '3.3.2',
);

int _leiturasEntradaDtoEstimateSize(
  LeiturasEntradaDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deltasJson.length * 3;
  bytesCount += 3 + object.loteId.length * 3;
  {
    final value = object.operador;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _leiturasEntradaDtoSerialize(
  LeiturasEntradaDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.atualizadoEm);
  writer.writeString(offsets[1], object.deltasJson);
  writer.writeString(offsets[2], object.loteId);
  writer.writeString(offsets[3], object.operador);
  writer.writeLong(offsets[4], object.pedidoId);
}

LeiturasEntradaDto _leiturasEntradaDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LeiturasEntradaDto(
    atualizadoEm: reader.readDateTime(offsets[0]),
    deltasJson: reader.readString(offsets[1]),
    loteId: reader.readString(offsets[2]),
    operador: reader.readStringOrNull(offsets[3]),
    pedidoId: reader.readLong(offsets[4]),
  );
  return object;
}

P _leiturasEntradaDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _leiturasEntradaDtoGetId(LeiturasEntradaDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _leiturasEntradaDtoGetLinks(
    LeiturasEntradaDto object) {
  return [];
}

void _leiturasEntradaDtoAttach(
    IsarCollection<dynamic> col, Id id, LeiturasEntradaDto object) {}

extension LeiturasEntradaDtoQueryWhereSort
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QWhere> {
  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterWhere>
      anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LeiturasEntradaDtoQueryWhere
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QWhereClause> {
  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterWhereClause>
      dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterWhereClause>
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

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterWhereClause>
      dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterWhereClause>
      dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterWhereClause>
      dataBaseIdBetween(
    Id lowerDataBaseId,
    Id upperDataBaseId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerDataBaseId,
        includeLower: includeLower,
        upper: upperDataBaseId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LeiturasEntradaDtoQueryFilter
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QFilterCondition> {
  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      atualizadoEmEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'atualizadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      atualizadoEmGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'atualizadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      atualizadoEmLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'atualizadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      atualizadoEmBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'atualizadoEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      dataBaseIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      dataBaseIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      dataBaseIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataBaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deltasJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deltasJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deltasJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deltasJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deltasJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deltasJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deltasJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deltasJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deltasJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      deltasJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deltasJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      loteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'operador',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'operador',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operador',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operador',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operador',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operador',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operador',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operador',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operador',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operador',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operador',
        value: '',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      operadorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operador',
        value: '',
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      pedidoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pedidoId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      pedidoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pedidoId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      pedidoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pedidoId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterFilterCondition>
      pedidoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pedidoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LeiturasEntradaDtoQueryObject
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QFilterCondition> {}

extension LeiturasEntradaDtoQueryLinks
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QFilterCondition> {}

extension LeiturasEntradaDtoQuerySortBy
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QSortBy> {
  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByDeltasJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltasJson', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByDeltasJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltasJson', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByLoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteId', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByLoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteId', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByOperador() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operador', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByOperadorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operador', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByPedidoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      sortByPedidoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.desc);
    });
  }
}

extension LeiturasEntradaDtoQuerySortThenBy
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QSortThenBy> {
  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByDeltasJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltasJson', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByDeltasJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltasJson', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByLoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteId', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByLoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteId', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByOperador() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operador', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByOperadorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operador', Sort.desc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByPedidoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.asc);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QAfterSortBy>
      thenByPedidoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.desc);
    });
  }
}

extension LeiturasEntradaDtoQueryWhereDistinct
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QDistinct> {
  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QDistinct>
      distinctByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'atualizadoEm');
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QDistinct>
      distinctByDeltasJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deltasJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QDistinct>
      distinctByLoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QDistinct>
      distinctByOperador({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operador', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QDistinct>
      distinctByPedidoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pedidoId');
    });
  }
}

extension LeiturasEntradaDtoQueryProperty
    on QueryBuilder<LeiturasEntradaDto, LeiturasEntradaDto, QQueryProperty> {
  QueryBuilder<LeiturasEntradaDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<LeiturasEntradaDto, DateTime, QQueryOperations>
      atualizadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'atualizadoEm');
    });
  }

  QueryBuilder<LeiturasEntradaDto, String, QQueryOperations>
      deltasJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deltasJson');
    });
  }

  QueryBuilder<LeiturasEntradaDto, String, QQueryOperations> loteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loteId');
    });
  }

  QueryBuilder<LeiturasEntradaDto, String?, QQueryOperations>
      operadorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operador');
    });
  }

  QueryBuilder<LeiturasEntradaDto, int, QQueryOperations> pedidoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pedidoId');
    });
  }
}
