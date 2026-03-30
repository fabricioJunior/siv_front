// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codigo_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCodigoDtoCollection on Isar {
  IsarCollection<CodigoDto> get codigoDtos => this.collection();
}

const CodigoDtoSchema = CollectionSchema(
  name: r'CodigoDto',
  id: -9160587924011446633,
  properties: {
    r'codigo': PropertySchema(
      id: 0,
      name: r'codigo',
      type: IsarType.string,
    ),
    r'produtoId': PropertySchema(
      id: 1,
      name: r'produtoId',
      type: IsarType.long,
    ),
    r'tipoIndex': PropertySchema(
      id: 2,
      name: r'tipoIndex',
      type: IsarType.long,
    )
  },
  estimateSize: _codigoDtoEstimateSize,
  serialize: _codigoDtoSerialize,
  deserialize: _codigoDtoDeserialize,
  deserializeProp: _codigoDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _codigoDtoGetId,
  getLinks: _codigoDtoGetLinks,
  attach: _codigoDtoAttach,
  version: '3.3.0-dev.1',
);

int _codigoDtoEstimateSize(
  CodigoDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigo.length * 3;
  return bytesCount;
}

void _codigoDtoSerialize(
  CodigoDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.codigo);
  writer.writeLong(offsets[1], object.produtoId);
  writer.writeLong(offsets[2], object.tipoIndex);
}

CodigoDto _codigoDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CodigoDto(
    codigo: reader.readString(offsets[0]),
    produtoId: reader.readLong(offsets[1]),
    tipoIndex: reader.readLong(offsets[2]),
  );
  return object;
}

P _codigoDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _codigoDtoGetId(CodigoDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _codigoDtoGetLinks(CodigoDto object) {
  return [];
}

void _codigoDtoAttach(IsarCollection<dynamic> col, Id id, CodigoDto object) {}

extension CodigoDtoQueryWhereSort
    on QueryBuilder<CodigoDto, CodigoDto, QWhere> {
  QueryBuilder<CodigoDto, CodigoDto, QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CodigoDtoQueryWhere
    on QueryBuilder<CodigoDto, CodigoDto, QWhereClause> {
  QueryBuilder<CodigoDto, CodigoDto, QAfterWhereClause> dataBaseIdEqualTo(
      Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterWhereClause> dataBaseIdNotEqualTo(
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

  QueryBuilder<CodigoDto, CodigoDto, QAfterWhereClause> dataBaseIdGreaterThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterWhereClause> dataBaseIdLessThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterWhereClause> dataBaseIdBetween(
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

extension CodigoDtoQueryFilter
    on QueryBuilder<CodigoDto, CodigoDto, QFilterCondition> {
  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> codigoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> dataBaseIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition>
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

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> dataBaseIdLessThan(
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

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> dataBaseIdBetween(
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

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> produtoIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'produtoId',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition>
      produtoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'produtoId',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> produtoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'produtoId',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> produtoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'produtoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> tipoIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition>
      tipoIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> tipoIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterFilterCondition> tipoIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CodigoDtoQueryObject
    on QueryBuilder<CodigoDto, CodigoDto, QFilterCondition> {}

extension CodigoDtoQueryLinks
    on QueryBuilder<CodigoDto, CodigoDto, QFilterCondition> {}

extension CodigoDtoQuerySortBy on QueryBuilder<CodigoDto, CodigoDto, QSortBy> {
  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> sortByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> sortByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> sortByProdutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> sortByProdutoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.desc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> sortByTipoIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoIndex', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> sortByTipoIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoIndex', Sort.desc);
    });
  }
}

extension CodigoDtoQuerySortThenBy
    on QueryBuilder<CodigoDto, CodigoDto, QSortThenBy> {
  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByProdutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByProdutoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.desc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByTipoIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoIndex', Sort.asc);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QAfterSortBy> thenByTipoIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoIndex', Sort.desc);
    });
  }
}

extension CodigoDtoQueryWhereDistinct
    on QueryBuilder<CodigoDto, CodigoDto, QDistinct> {
  QueryBuilder<CodigoDto, CodigoDto, QDistinct> distinctByCodigo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QDistinct> distinctByProdutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'produtoId');
    });
  }

  QueryBuilder<CodigoDto, CodigoDto, QDistinct> distinctByTipoIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoIndex');
    });
  }
}

extension CodigoDtoQueryProperty
    on QueryBuilder<CodigoDto, CodigoDto, QQueryProperty> {
  QueryBuilder<CodigoDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<CodigoDto, String, QQueryOperations> codigoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigo');
    });
  }

  QueryBuilder<CodigoDto, int, QQueryOperations> produtoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'produtoId');
    });
  }

  QueryBuilder<CodigoDto, int, QQueryOperations> tipoIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoIndex');
    });
  }
}
