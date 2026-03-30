// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmpresaDtoCollection on Isar {
  IsarCollection<EmpresaDto> get empresaDtos => this.collection();
}

const EmpresaDtoSchema = CollectionSchema(
  name: r'EmpresaDto',
  id: -7543039627240877726,
  properties: {
    r'id': PropertySchema(
      id: 0,
      name: r'id',
      type: IsarType.long,
    ),
    r'nome': PropertySchema(
      id: 1,
      name: r'nome',
      type: IsarType.string,
    )
  },
  estimateSize: _empresaDtoEstimateSize,
  serialize: _empresaDtoSerialize,
  deserialize: _empresaDtoDeserialize,
  deserializeProp: _empresaDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _empresaDtoGetId,
  getLinks: _empresaDtoGetLinks,
  attach: _empresaDtoAttach,
  version: '3.3.0-dev.1',
);

int _empresaDtoEstimateSize(
  EmpresaDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _empresaDtoSerialize(
  EmpresaDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.id);
  writer.writeString(offsets[1], object.nome);
}

EmpresaDto _empresaDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmpresaDto(
    id: reader.readLong(offsets[0]),
    nome: reader.readString(offsets[1]),
  );
  return object;
}

P _empresaDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _empresaDtoGetId(EmpresaDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _empresaDtoGetLinks(EmpresaDto object) {
  return [];
}

void _empresaDtoAttach(IsarCollection<dynamic> col, Id id, EmpresaDto object) {}

extension EmpresaDtoQueryWhereSort
    on QueryBuilder<EmpresaDto, EmpresaDto, QWhere> {
  QueryBuilder<EmpresaDto, EmpresaDto, QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EmpresaDtoQueryWhere
    on QueryBuilder<EmpresaDto, EmpresaDto, QWhereClause> {
  QueryBuilder<EmpresaDto, EmpresaDto, QAfterWhereClause> dataBaseIdEqualTo(
      Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterWhereClause> dataBaseIdNotEqualTo(
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

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterWhereClause> dataBaseIdGreaterThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterWhereClause> dataBaseIdLessThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterWhereClause> dataBaseIdBetween(
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

extension EmpresaDtoQueryFilter
    on QueryBuilder<EmpresaDto, EmpresaDto, QFilterCondition> {
  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> dataBaseIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition>
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

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition>
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

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> dataBaseIdBetween(
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

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> idEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> idLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> idBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterFilterCondition> nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nome',
        value: '',
      ));
    });
  }
}

extension EmpresaDtoQueryObject
    on QueryBuilder<EmpresaDto, EmpresaDto, QFilterCondition> {}

extension EmpresaDtoQueryLinks
    on QueryBuilder<EmpresaDto, EmpresaDto, QFilterCondition> {}

extension EmpresaDtoQuerySortBy
    on QueryBuilder<EmpresaDto, EmpresaDto, QSortBy> {
  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }
}

extension EmpresaDtoQuerySortThenBy
    on QueryBuilder<EmpresaDto, EmpresaDto, QSortThenBy> {
  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QAfterSortBy> thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }
}

extension EmpresaDtoQueryWhereDistinct
    on QueryBuilder<EmpresaDto, EmpresaDto, QDistinct> {
  QueryBuilder<EmpresaDto, EmpresaDto, QDistinct> distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }

  QueryBuilder<EmpresaDto, EmpresaDto, QDistinct> distinctByNome(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }
}

extension EmpresaDtoQueryProperty
    on QueryBuilder<EmpresaDto, EmpresaDto, QQueryProperty> {
  QueryBuilder<EmpresaDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<EmpresaDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmpresaDto, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }
}
