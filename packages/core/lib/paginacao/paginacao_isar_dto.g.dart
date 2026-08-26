// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginacao_isar_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaginacaoIsarDtoCollection on Isar {
  IsarCollection<PaginacaoIsarDto> get paginacaoIsarDtos => this.collection();
}

const PaginacaoIsarDtoSchema = CollectionSchema(
  name: r'PaginacaoIsarDto',
  id: 8373761600524942808,
  properties: {
    r'dataAtualizacao': PropertySchema(
      id: 0,
      name: r'dataAtualizacao',
      type: IsarType.dateTime,
    ),
    r'ended': PropertySchema(
      id: 1,
      name: r'ended',
      type: IsarType.bool,
    ),
    r'itensPorPagina': PropertySchema(
      id: 2,
      name: r'itensPorPagina',
      type: IsarType.long,
    ),
    r'key': PropertySchema(
      id: 3,
      name: r'key',
      type: IsarType.string,
    ),
    r'paginaAtual': PropertySchema(
      id: 4,
      name: r'paginaAtual',
      type: IsarType.long,
    ),
    r'totalItens': PropertySchema(
      id: 5,
      name: r'totalItens',
      type: IsarType.long,
    ),
    r'totalPaginas': PropertySchema(
      id: 6,
      name: r'totalPaginas',
      type: IsarType.long,
    )
  },
  estimateSize: _paginacaoIsarDtoEstimateSize,
  serialize: _paginacaoIsarDtoSerialize,
  deserialize: _paginacaoIsarDtoDeserialize,
  deserializeProp: _paginacaoIsarDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _paginacaoIsarDtoGetId,
  getLinks: _paginacaoIsarDtoGetLinks,
  attach: _paginacaoIsarDtoAttach,
  version: '3.3.2',
);

int _paginacaoIsarDtoEstimateSize(
  PaginacaoIsarDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _paginacaoIsarDtoSerialize(
  PaginacaoIsarDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dataAtualizacao);
  writer.writeBool(offsets[1], object.ended);
  writer.writeLong(offsets[2], object.itensPorPagina);
  writer.writeString(offsets[3], object.key);
  writer.writeLong(offsets[4], object.paginaAtual);
  writer.writeLong(offsets[5], object.totalItens);
  writer.writeLong(offsets[6], object.totalPaginas);
}

PaginacaoIsarDto _paginacaoIsarDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaginacaoIsarDto(
    dataAtualizacao: reader.readDateTimeOrNull(offsets[0]),
    ended: reader.readBoolOrNull(offsets[1]) ?? false,
    itensPorPagina: reader.readLong(offsets[2]),
    key: reader.readString(offsets[3]),
    paginaAtual: reader.readLong(offsets[4]),
    totalItens: reader.readLong(offsets[5]),
    totalPaginas: reader.readLong(offsets[6]),
  );
  return object;
}

P _paginacaoIsarDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paginacaoIsarDtoGetId(PaginacaoIsarDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _paginacaoIsarDtoGetLinks(PaginacaoIsarDto object) {
  return [];
}

void _paginacaoIsarDtoAttach(
    IsarCollection<dynamic> col, Id id, PaginacaoIsarDto object) {}

extension PaginacaoIsarDtoQueryWhereSort
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QWhere> {
  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterWhere>
      anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PaginacaoIsarDtoQueryWhere
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QWhereClause> {
  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterWhereClause>
      dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterWhereClause>
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

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterWhereClause>
      dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterWhereClause>
      dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterWhereClause>
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

extension PaginacaoIsarDtoQueryFilter
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QFilterCondition> {
  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataAtualizacaoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dataAtualizacao',
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataAtualizacaoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dataAtualizacao',
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataAtualizacaoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataAtualizacao',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataAtualizacaoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataAtualizacao',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataAtualizacaoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataAtualizacao',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataAtualizacaoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataAtualizacao',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
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

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
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

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
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

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      endedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ended',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      itensPorPaginaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itensPorPagina',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      itensPorPaginaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itensPorPagina',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      itensPorPaginaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itensPorPagina',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      itensPorPaginaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itensPorPagina',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      paginaAtualEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paginaAtual',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      paginaAtualGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paginaAtual',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      paginaAtualLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paginaAtual',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      paginaAtualBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paginaAtual',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalItensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalItens',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalItensGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalItens',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalItensLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalItens',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalItensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalItens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalPaginasEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPaginas',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalPaginasGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPaginas',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalPaginasLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPaginas',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterFilterCondition>
      totalPaginasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPaginas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaginacaoIsarDtoQueryObject
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QFilterCondition> {}

extension PaginacaoIsarDtoQueryLinks
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QFilterCondition> {}

extension PaginacaoIsarDtoQuerySortBy
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QSortBy> {
  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByDataAtualizacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByDataAtualizacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy> sortByEnded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByEndedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByItensPorPagina() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByItensPorPaginaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByPaginaAtual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByPaginaAtualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByTotalItens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByTotalItensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByTotalPaginas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      sortByTotalPaginasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.desc);
    });
  }
}

extension PaginacaoIsarDtoQuerySortThenBy
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QSortThenBy> {
  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByDataAtualizacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByDataAtualizacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy> thenByEnded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByEndedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByItensPorPagina() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByItensPorPaginaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByPaginaAtual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByPaginaAtualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByTotalItens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByTotalItensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.desc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByTotalPaginas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.asc);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QAfterSortBy>
      thenByTotalPaginasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.desc);
    });
  }
}

extension PaginacaoIsarDtoQueryWhereDistinct
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct> {
  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct>
      distinctByDataAtualizacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataAtualizacao');
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct>
      distinctByEnded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ended');
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct>
      distinctByItensPorPagina() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensPorPagina');
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct>
      distinctByPaginaAtual() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paginaAtual');
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct>
      distinctByTotalItens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalItens');
    });
  }

  QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QDistinct>
      distinctByTotalPaginas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPaginas');
    });
  }
}

extension PaginacaoIsarDtoQueryProperty
    on QueryBuilder<PaginacaoIsarDto, PaginacaoIsarDto, QQueryProperty> {
  QueryBuilder<PaginacaoIsarDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<PaginacaoIsarDto, DateTime?, QQueryOperations>
      dataAtualizacaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataAtualizacao');
    });
  }

  QueryBuilder<PaginacaoIsarDto, bool, QQueryOperations> endedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ended');
    });
  }

  QueryBuilder<PaginacaoIsarDto, int, QQueryOperations>
      itensPorPaginaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensPorPagina');
    });
  }

  QueryBuilder<PaginacaoIsarDto, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<PaginacaoIsarDto, int, QQueryOperations> paginaAtualProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paginaAtual');
    });
  }

  QueryBuilder<PaginacaoIsarDto, int, QQueryOperations> totalItensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalItens');
    });
  }

  QueryBuilder<PaginacaoIsarDto, int, QQueryOperations> totalPaginasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPaginas');
    });
  }
}
