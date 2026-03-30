// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginacao.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaginacaoCollection on Isar {
  IsarCollection<Paginacao> get paginacaos => this.collection();
}

const PaginacaoSchema = CollectionSchema(
  name: r'Paginacao',
  id: -3695897472653108223,
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
  estimateSize: _paginacaoEstimateSize,
  serialize: _paginacaoSerialize,
  deserialize: _paginacaoDeserialize,
  deserializeProp: _paginacaoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _paginacaoGetId,
  getLinks: _paginacaoGetLinks,
  attach: _paginacaoAttach,
  version: '3.3.0-dev.1',
);

int _paginacaoEstimateSize(
  Paginacao object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _paginacaoSerialize(
  Paginacao object,
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

Paginacao _paginacaoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Paginacao(
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

P _paginacaoDeserializeProp<P>(
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

Id _paginacaoGetId(Paginacao object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _paginacaoGetLinks(Paginacao object) {
  return [];
}

void _paginacaoAttach(IsarCollection<dynamic> col, Id id, Paginacao object) {}

extension PaginacaoQueryWhereSort
    on QueryBuilder<Paginacao, Paginacao, QWhere> {
  QueryBuilder<Paginacao, Paginacao, QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PaginacaoQueryWhere
    on QueryBuilder<Paginacao, Paginacao, QWhereClause> {
  QueryBuilder<Paginacao, Paginacao, QAfterWhereClause> dataBaseIdEqualTo(
      Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterWhereClause> dataBaseIdNotEqualTo(
      Id dataBaseId) {
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

  QueryBuilder<Paginacao, Paginacao, QAfterWhereClause> dataBaseIdGreaterThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterWhereClause> dataBaseIdLessThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterWhereClause> dataBaseIdBetween(
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

extension PaginacaoQueryFilter
    on QueryBuilder<Paginacao, Paginacao, QFilterCondition> {
  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
      dataAtualizacaoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dataAtualizacao',
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
      dataAtualizacaoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dataAtualizacao',
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
      dataAtualizacaoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataAtualizacao',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> dataBaseIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> dataBaseIdLessThan(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> dataBaseIdBetween(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> endedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ended',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
      itensPorPaginaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itensPorPagina',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyEqualTo(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyGreaterThan(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyLessThan(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyBetween(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyStartsWith(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyEndsWith(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> paginaAtualEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paginaAtual',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> paginaAtualLessThan(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> paginaAtualBetween(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> totalItensEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalItens',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> totalItensLessThan(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> totalItensBetween(
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> totalPaginasEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPaginas',
        value: value,
      ));
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition>
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

  QueryBuilder<Paginacao, Paginacao, QAfterFilterCondition> totalPaginasBetween(
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

extension PaginacaoQueryObject
    on QueryBuilder<Paginacao, Paginacao, QFilterCondition> {}

extension PaginacaoQueryLinks
    on QueryBuilder<Paginacao, Paginacao, QFilterCondition> {}

extension PaginacaoQuerySortBy on QueryBuilder<Paginacao, Paginacao, QSortBy> {
  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByDataAtualizacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByDataAtualizacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByEnded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByEndedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByItensPorPagina() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByItensPorPaginaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByPaginaAtual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByPaginaAtualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByTotalItens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByTotalItensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByTotalPaginas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> sortByTotalPaginasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.desc);
    });
  }
}

extension PaginacaoQuerySortThenBy
    on QueryBuilder<Paginacao, Paginacao, QSortThenBy> {
  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByDataAtualizacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByDataAtualizacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataAtualizacao', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByEnded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByEndedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ended', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByItensPorPagina() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByItensPorPaginaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPorPagina', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByPaginaAtual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByPaginaAtualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paginaAtual', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByTotalItens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByTotalItensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalItens', Sort.desc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByTotalPaginas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.asc);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QAfterSortBy> thenByTotalPaginasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPaginas', Sort.desc);
    });
  }
}

extension PaginacaoQueryWhereDistinct
    on QueryBuilder<Paginacao, Paginacao, QDistinct> {
  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByDataAtualizacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataAtualizacao');
    });
  }

  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByEnded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ended');
    });
  }

  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByItensPorPagina() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensPorPagina');
    });
  }

  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByPaginaAtual() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paginaAtual');
    });
  }

  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByTotalItens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalItens');
    });
  }

  QueryBuilder<Paginacao, Paginacao, QDistinct> distinctByTotalPaginas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPaginas');
    });
  }
}

extension PaginacaoQueryProperty
    on QueryBuilder<Paginacao, Paginacao, QQueryProperty> {
  QueryBuilder<Paginacao, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<Paginacao, DateTime?, QQueryOperations>
      dataAtualizacaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataAtualizacao');
    });
  }

  QueryBuilder<Paginacao, bool, QQueryOperations> endedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ended');
    });
  }

  QueryBuilder<Paginacao, int, QQueryOperations> itensPorPaginaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensPorPagina');
    });
  }

  QueryBuilder<Paginacao, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<Paginacao, int, QQueryOperations> paginaAtualProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paginaAtual');
    });
  }

  QueryBuilder<Paginacao, int, QQueryOperations> totalItensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalItens');
    });
  }

  QueryBuilder<Paginacao, int, QQueryOperations> totalPaginasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPaginas');
    });
  }
}
