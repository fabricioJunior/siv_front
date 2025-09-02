// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTokenDtoCollection on Isar {
  IsarCollection<TokenDto> get tokenDtos => this.collection();
}

const TokenDtoSchema = CollectionSchema(
  name: r'TokenDto',
  id: -2886639869332665103,
  properties: {
    r'dataDeCriacao': PropertySchema(
      id: 0,
      name: r'dataDeCriacao',
      type: IsarType.dateTime,
    ),
    r'dataDeExpiracao': PropertySchema(
      id: 1,
      name: r'dataDeExpiracao',
      type: IsarType.dateTime,
    ),
    r'hashCode': PropertySchema(
      id: 2,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'jwtToken': PropertySchema(
      id: 3,
      name: r'jwtToken',
      type: IsarType.string,
    ),
    r'stringify': PropertySchema(
      id: 4,
      name: r'stringify',
      type: IsarType.bool,
    )
  },
  estimateSize: _tokenDtoEstimateSize,
  serialize: _tokenDtoSerialize,
  deserialize: _tokenDtoDeserialize,
  deserializeProp: _tokenDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _tokenDtoGetId,
  getLinks: _tokenDtoGetLinks,
  attach: _tokenDtoAttach,
  version: '3.1.8',
);

int _tokenDtoEstimateSize(
  TokenDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.jwtToken.length * 3;
  return bytesCount;
}

void _tokenDtoSerialize(
  TokenDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dataDeCriacao);
  writer.writeDateTime(offsets[1], object.dataDeExpiracao);
  writer.writeLong(offsets[2], object.hashCode);
  writer.writeString(offsets[3], object.jwtToken);
  writer.writeBool(offsets[4], object.stringify);
}

TokenDto _tokenDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TokenDto(
    dataDeCriacao: reader.readDateTime(offsets[0]),
    dataDeExpiracao: reader.readDateTime(offsets[1]),
    jwtToken: reader.readString(offsets[3]),
  );
  return object;
}

P _tokenDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tokenDtoGetId(TokenDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _tokenDtoGetLinks(TokenDto object) {
  return [];
}

void _tokenDtoAttach(IsarCollection<dynamic> col, Id id, TokenDto object) {}

extension TokenDtoQueryWhereSort on QueryBuilder<TokenDto, TokenDto, QWhere> {
  QueryBuilder<TokenDto, TokenDto, QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TokenDtoQueryWhere on QueryBuilder<TokenDto, TokenDto, QWhereClause> {
  QueryBuilder<TokenDto, TokenDto, QAfterWhereClause> dataBaseIdEqualTo(
      Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterWhereClause> dataBaseIdNotEqualTo(
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

  QueryBuilder<TokenDto, TokenDto, QAfterWhereClause> dataBaseIdGreaterThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterWhereClause> dataBaseIdLessThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterWhereClause> dataBaseIdBetween(
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

extension TokenDtoQueryFilter
    on QueryBuilder<TokenDto, TokenDto, QFilterCondition> {
  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataBaseIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataBaseIdGreaterThan(
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

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataBaseIdLessThan(
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

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataBaseIdBetween(
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

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataDeCriacaoEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataDeCriacao',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition>
      dataDeCriacaoGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataDeCriacao',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataDeCriacaoLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataDeCriacao',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> dataDeCriacaoBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataDeCriacao',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition>
      dataDeExpiracaoEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataDeExpiracao',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition>
      dataDeExpiracaoGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataDeExpiracao',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition>
      dataDeExpiracaoLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataDeExpiracao',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition>
      dataDeExpiracaoBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataDeExpiracao',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> hashCodeGreaterThan(
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

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> hashCodeLessThan(
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

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> hashCodeBetween(
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

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jwtToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jwtToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jwtToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jwtToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jwtToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jwtToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jwtToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jwtToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jwtToken',
        value: '',
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> jwtTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jwtToken',
        value: '',
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> stringifyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> stringifyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterFilterCondition> stringifyEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringify',
        value: value,
      ));
    });
  }
}

extension TokenDtoQueryObject
    on QueryBuilder<TokenDto, TokenDto, QFilterCondition> {}

extension TokenDtoQueryLinks
    on QueryBuilder<TokenDto, TokenDto, QFilterCondition> {}

extension TokenDtoQuerySortBy on QueryBuilder<TokenDto, TokenDto, QSortBy> {
  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByDataDeCriacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeCriacao', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByDataDeCriacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeCriacao', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByDataDeExpiracao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeExpiracao', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByDataDeExpiracaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeExpiracao', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByJwtToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jwtToken', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByJwtTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jwtToken', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> sortByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }
}

extension TokenDtoQuerySortThenBy
    on QueryBuilder<TokenDto, TokenDto, QSortThenBy> {
  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByDataDeCriacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeCriacao', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByDataDeCriacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeCriacao', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByDataDeExpiracao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeExpiracao', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByDataDeExpiracaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataDeExpiracao', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByJwtToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jwtToken', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByJwtTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jwtToken', Sort.desc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QAfterSortBy> thenByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }
}

extension TokenDtoQueryWhereDistinct
    on QueryBuilder<TokenDto, TokenDto, QDistinct> {
  QueryBuilder<TokenDto, TokenDto, QDistinct> distinctByDataDeCriacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataDeCriacao');
    });
  }

  QueryBuilder<TokenDto, TokenDto, QDistinct> distinctByDataDeExpiracao() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataDeExpiracao');
    });
  }

  QueryBuilder<TokenDto, TokenDto, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<TokenDto, TokenDto, QDistinct> distinctByJwtToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jwtToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TokenDto, TokenDto, QDistinct> distinctByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringify');
    });
  }
}

extension TokenDtoQueryProperty
    on QueryBuilder<TokenDto, TokenDto, QQueryProperty> {
  QueryBuilder<TokenDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<TokenDto, DateTime, QQueryOperations> dataDeCriacaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataDeCriacao');
    });
  }

  QueryBuilder<TokenDto, DateTime, QQueryOperations> dataDeExpiracaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataDeExpiracao');
    });
  }

  QueryBuilder<TokenDto, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<TokenDto, String, QQueryOperations> jwtTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jwtToken');
    });
  }

  QueryBuilder<TokenDto, bool?, QQueryOperations> stringifyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringify');
    });
  }
}
