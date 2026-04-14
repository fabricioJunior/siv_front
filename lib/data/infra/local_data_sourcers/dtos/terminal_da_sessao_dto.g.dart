// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_da_sessao_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTerminalDaSessaoDtoCollection on Isar {
  IsarCollection<TerminalDaSessaoDto> get terminalDaSessaoDtos =>
      this.collection();
}

const TerminalDaSessaoDtoSchema = CollectionSchema(
  name: r'TerminalDaSessaoDto',
  id: -5952529021257383402,
  properties: {
    r'hashCode': PropertySchema(id: 0, name: r'hashCode', type: IsarType.long),
    r'id': PropertySchema(id: 1, name: r'id', type: IsarType.long),
    r'idEmpresa': PropertySchema(
      id: 2,
      name: r'idEmpresa',
      type: IsarType.long,
    ),
    r'nome': PropertySchema(id: 3, name: r'nome', type: IsarType.string),
  },

  estimateSize: _terminalDaSessaoDtoEstimateSize,
  serialize: _terminalDaSessaoDtoSerialize,
  deserialize: _terminalDaSessaoDtoDeserialize,
  deserializeProp: _terminalDaSessaoDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _terminalDaSessaoDtoGetId,
  getLinks: _terminalDaSessaoDtoGetLinks,
  attach: _terminalDaSessaoDtoAttach,
  version: '3.3.0-dev.1',
);

int _terminalDaSessaoDtoEstimateSize(
  TerminalDaSessaoDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _terminalDaSessaoDtoSerialize(
  TerminalDaSessaoDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeLong(offsets[1], object.id);
  writer.writeLong(offsets[2], object.idEmpresa);
  writer.writeString(offsets[3], object.nome);
}

TerminalDaSessaoDto _terminalDaSessaoDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TerminalDaSessaoDto(
    id: reader.readLong(offsets[1]),
    idEmpresa: reader.readLong(offsets[2]),
    nome: reader.readString(offsets[3]),
  );
  return object;
}

P _terminalDaSessaoDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _terminalDaSessaoDtoGetId(TerminalDaSessaoDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _terminalDaSessaoDtoGetLinks(
  TerminalDaSessaoDto object,
) {
  return [];
}

void _terminalDaSessaoDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  TerminalDaSessaoDto object,
) {}

extension TerminalDaSessaoDtoQueryWhereSort
    on QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QWhere> {
  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterWhere>
  anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TerminalDaSessaoDtoQueryWhere
    on QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QWhereClause> {
  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterWhereClause>
  dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: dataBaseId, upper: dataBaseId),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterWhereClause>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterWhereClause>
  dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterWhereClause>
  dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterWhereClause>
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

extension TerminalDaSessaoDtoQueryFilter
    on
        QueryBuilder<
          TerminalDaSessaoDto,
          TerminalDaSessaoDto,
          QFilterCondition
        > {
  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataBaseId', value: value),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idLessThan(int value, {bool include = false}) {
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idBetween(
    int lower,
    int upper, {
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idEmpresaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idEmpresa', value: value),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idEmpresaGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idEmpresa',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idEmpresaLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idEmpresa',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  idEmpresaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idEmpresa',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
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

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterFilterCondition>
  nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nome', value: ''),
      );
    });
  }
}

extension TerminalDaSessaoDtoQueryObject
    on
        QueryBuilder<
          TerminalDaSessaoDto,
          TerminalDaSessaoDto,
          QFilterCondition
        > {}

extension TerminalDaSessaoDtoQueryLinks
    on
        QueryBuilder<
          TerminalDaSessaoDto,
          TerminalDaSessaoDto,
          QFilterCondition
        > {}

extension TerminalDaSessaoDtoQuerySortBy
    on QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QSortBy> {
  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByIdEmpresa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idEmpresa', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByIdEmpresaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idEmpresa', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }
}

extension TerminalDaSessaoDtoQuerySortThenBy
    on QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QSortThenBy> {
  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByIdEmpresa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idEmpresa', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByIdEmpresaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idEmpresa', Sort.desc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QAfterSortBy>
  thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }
}

extension TerminalDaSessaoDtoQueryWhereDistinct
    on QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QDistinct> {
  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QDistinct>
  distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QDistinct>
  distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QDistinct>
  distinctByIdEmpresa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idEmpresa');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QDistinct>
  distinctByNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }
}

extension TerminalDaSessaoDtoQueryProperty
    on QueryBuilder<TerminalDaSessaoDto, TerminalDaSessaoDto, QQueryProperty> {
  QueryBuilder<TerminalDaSessaoDto, int, QQueryOperations>
  dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, int, QQueryOperations> idEmpresaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idEmpresa');
    });
  }

  QueryBuilder<TerminalDaSessaoDto, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }
}
