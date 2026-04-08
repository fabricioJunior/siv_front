// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabela_de_preco_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTabelaDePrecoDtoCollection on Isar {
  IsarCollection<TabelaDePrecoDto> get tabelaDePrecoDtos => this.collection();
}

const TabelaDePrecoDtoSchema = CollectionSchema(
  name: r'TabelaDePrecoDto',
  id: -5020471522758576192,
  properties: {
    r'hashCode': PropertySchema(id: 0, name: r'hashCode', type: IsarType.long),
    r'id': PropertySchema(id: 1, name: r'id', type: IsarType.long),
    r'inativa': PropertySchema(id: 2, name: r'inativa', type: IsarType.bool),
    r'nome': PropertySchema(id: 3, name: r'nome', type: IsarType.string),
    r'terminador': PropertySchema(
      id: 4,
      name: r'terminador',
      type: IsarType.double,
    ),
  },

  estimateSize: _tabelaDePrecoDtoEstimateSize,
  serialize: _tabelaDePrecoDtoSerialize,
  deserialize: _tabelaDePrecoDtoDeserialize,
  deserializeProp: _tabelaDePrecoDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _tabelaDePrecoDtoGetId,
  getLinks: _tabelaDePrecoDtoGetLinks,
  attach: _tabelaDePrecoDtoAttach,
  version: '3.3.0-dev.1',
);

int _tabelaDePrecoDtoEstimateSize(
  TabelaDePrecoDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _tabelaDePrecoDtoSerialize(
  TabelaDePrecoDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeLong(offsets[1], object.id);
  writer.writeBool(offsets[2], object.inativa);
  writer.writeString(offsets[3], object.nome);
  writer.writeDouble(offsets[4], object.terminador);
}

TabelaDePrecoDto _tabelaDePrecoDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TabelaDePrecoDto(
    id: reader.readLongOrNull(offsets[1]),
    inativa: reader.readBool(offsets[2]),
    nome: reader.readString(offsets[3]),
    terminador: reader.readDoubleOrNull(offsets[4]),
  );
  return object;
}

P _tabelaDePrecoDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tabelaDePrecoDtoGetId(TabelaDePrecoDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _tabelaDePrecoDtoGetLinks(TabelaDePrecoDto object) {
  return [];
}

void _tabelaDePrecoDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  TabelaDePrecoDto object,
) {}

extension TabelaDePrecoDtoQueryWhereSort
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QWhere> {
  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterWhere>
  anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TabelaDePrecoDtoQueryWhere
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QWhereClause> {
  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterWhereClause>
  dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: dataBaseId, upper: dataBaseId),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterWhereClause>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterWhereClause>
  dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterWhereClause>
  dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterWhereClause>
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

extension TabelaDePrecoDtoQueryFilter
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QFilterCondition> {
  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataBaseId', value: value),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
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

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  idEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  idGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  idLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  idBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  inativaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inativa', value: value),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  terminadorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'terminador'),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  terminadorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'terminador'),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  terminadorEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'terminador',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  terminadorGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'terminador',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  terminadorLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'terminador',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterFilterCondition>
  terminadorBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'terminador',
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

extension TabelaDePrecoDtoQueryObject
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QFilterCondition> {}

extension TabelaDePrecoDtoQueryLinks
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QFilterCondition> {}

extension TabelaDePrecoDtoQuerySortBy
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QSortBy> {
  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByInativa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inativa', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByInativaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inativa', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy> sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByTerminador() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terminador', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  sortByTerminadorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terminador', Sort.desc);
    });
  }
}

extension TabelaDePrecoDtoQuerySortThenBy
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QSortThenBy> {
  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByInativa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inativa', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByInativaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inativa', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy> thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByTerminador() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terminador', Sort.asc);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QAfterSortBy>
  thenByTerminadorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terminador', Sort.desc);
    });
  }
}

extension TabelaDePrecoDtoQueryWhereDistinct
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QDistinct> {
  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QDistinct>
  distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QDistinct> distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QDistinct>
  distinctByInativa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inativa');
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QDistinct> distinctByNome({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QDistinct>
  distinctByTerminador() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'terminador');
    });
  }
}

extension TabelaDePrecoDtoQueryProperty
    on QueryBuilder<TabelaDePrecoDto, TabelaDePrecoDto, QQueryProperty> {
  QueryBuilder<TabelaDePrecoDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<TabelaDePrecoDto, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<TabelaDePrecoDto, int?, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TabelaDePrecoDto, bool, QQueryOperations> inativaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inativa');
    });
  }

  QueryBuilder<TabelaDePrecoDto, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }

  QueryBuilder<TabelaDePrecoDto, double?, QQueryOperations>
  terminadorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'terminador');
    });
  }
}
