// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'licenciado_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLicenciadoDtoCollection on Isar {
  IsarCollection<LicenciadoDto> get licenciadoDtos => this.collection();
}

const LicenciadoDtoSchema = CollectionSchema(
  name: r'LicenciadoDto',
  id: 4017759059101818657,
  properties: {
    r'hashCode': PropertySchema(
      id: 0,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'nome': PropertySchema(
      id: 2,
      name: r'nome',
      type: IsarType.string,
    ),
    r'stringify': PropertySchema(
      id: 3,
      name: r'stringify',
      type: IsarType.bool,
    ),
    r'urlApi': PropertySchema(
      id: 4,
      name: r'urlApi',
      type: IsarType.string,
    )
  },
  estimateSize: _licenciadoDtoEstimateSize,
  serialize: _licenciadoDtoSerialize,
  deserialize: _licenciadoDtoDeserialize,
  deserializeProp: _licenciadoDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _licenciadoDtoGetId,
  getLinks: _licenciadoDtoGetLinks,
  attach: _licenciadoDtoAttach,
  version: '3.3.0-dev.1',
);

int _licenciadoDtoEstimateSize(
  LicenciadoDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.nome.length * 3;
  bytesCount += 3 + object.urlApi.length * 3;
  return bytesCount;
}

void _licenciadoDtoSerialize(
  LicenciadoDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeString(offsets[1], object.id);
  writer.writeString(offsets[2], object.nome);
  writer.writeBool(offsets[3], object.stringify);
  writer.writeString(offsets[4], object.urlApi);
}

LicenciadoDto _licenciadoDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LicenciadoDto(
    id: reader.readString(offsets[1]),
    nome: reader.readString(offsets[2]),
    urlApi: reader.readString(offsets[4]),
  );
  return object;
}

P _licenciadoDtoDeserializeProp<P>(
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
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _licenciadoDtoGetId(LicenciadoDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _licenciadoDtoGetLinks(LicenciadoDto object) {
  return [];
}

void _licenciadoDtoAttach(
    IsarCollection<dynamic> col, Id id, LicenciadoDto object) {}

extension LicenciadoDtoQueryWhereSort
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QWhere> {
  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LicenciadoDtoQueryWhere
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QWhereClause> {
  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterWhereClause>
      dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterWhereClause>
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterWhereClause>
      dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterWhereClause>
      dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterWhereClause>
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

extension LicenciadoDtoQueryFilter
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QFilterCondition> {
  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> nomeEqualTo(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeGreaterThan(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeLessThan(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> nomeBetween(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeStartsWith(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeEndsWith(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition> nomeMatches(
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

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      stringifyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      stringifyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      stringifyEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringify',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urlApi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urlApi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urlApi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urlApi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'urlApi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'urlApi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urlApi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urlApi',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urlApi',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterFilterCondition>
      urlApiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urlApi',
        value: '',
      ));
    });
  }
}

extension LicenciadoDtoQueryObject
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QFilterCondition> {}

extension LicenciadoDtoQueryLinks
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QFilterCondition> {}

extension LicenciadoDtoQuerySortBy
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QSortBy> {
  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy>
      sortByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByUrlApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlApi', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> sortByUrlApiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlApi', Sort.desc);
    });
  }
}

extension LicenciadoDtoQuerySortThenBy
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QSortThenBy> {
  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy>
      thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy>
      thenByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByUrlApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlApi', Sort.asc);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QAfterSortBy> thenByUrlApiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlApi', Sort.desc);
    });
  }
}

extension LicenciadoDtoQueryWhereDistinct
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QDistinct> {
  QueryBuilder<LicenciadoDto, LicenciadoDto, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QDistinct> distinctByNome(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QDistinct> distinctByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringify');
    });
  }

  QueryBuilder<LicenciadoDto, LicenciadoDto, QDistinct> distinctByUrlApi(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urlApi', caseSensitive: caseSensitive);
    });
  }
}

extension LicenciadoDtoQueryProperty
    on QueryBuilder<LicenciadoDto, LicenciadoDto, QQueryProperty> {
  QueryBuilder<LicenciadoDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<LicenciadoDto, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<LicenciadoDto, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LicenciadoDto, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }

  QueryBuilder<LicenciadoDto, bool?, QQueryOperations> stringifyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringify');
    });
  }

  QueryBuilder<LicenciadoDto, String, QQueryOperations> urlApiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urlApi');
    });
  }
}
