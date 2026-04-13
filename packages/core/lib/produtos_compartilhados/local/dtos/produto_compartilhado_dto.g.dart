// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_compartilhado_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProdutoCompartilhadoDtoCollection on Isar {
  IsarCollection<ProdutoCompartilhadoDto> get produtoCompartilhadoDtos =>
      this.collection();
}

const ProdutoCompartilhadoDtoSchema = CollectionSchema(
  name: r'ProdutoCompartilhadoDto',
  id: 4902712132762689867,
  properties: {
    r'corNome': PropertySchema(
      id: 0,
      name: r'corNome',
      type: IsarType.string,
    ),
    r'hash': PropertySchema(
      id: 1,
      name: r'hash',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 2,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'hashLista': PropertySchema(
      id: 3,
      name: r'hashLista',
      type: IsarType.string,
    ),
    r'nome': PropertySchema(
      id: 4,
      name: r'nome',
      type: IsarType.string,
    ),
    r'produtoId': PropertySchema(
      id: 5,
      name: r'produtoId',
      type: IsarType.long,
    ),
    r'quantidade': PropertySchema(
      id: 6,
      name: r'quantidade',
      type: IsarType.long,
    ),
    r'stringify': PropertySchema(
      id: 7,
      name: r'stringify',
      type: IsarType.bool,
    ),
    r'tamanhoNome': PropertySchema(
      id: 8,
      name: r'tamanhoNome',
      type: IsarType.string,
    ),
    r'valorUnitario': PropertySchema(
      id: 9,
      name: r'valorUnitario',
      type: IsarType.double,
    )
  },
  estimateSize: _produtoCompartilhadoDtoEstimateSize,
  serialize: _produtoCompartilhadoDtoSerialize,
  deserialize: _produtoCompartilhadoDtoDeserialize,
  deserializeProp: _produtoCompartilhadoDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {
    r'hashLista': IndexSchema(
      id: 3798802709609415085,
      name: r'hashLista',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hashLista',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _produtoCompartilhadoDtoGetId,
  getLinks: _produtoCompartilhadoDtoGetLinks,
  attach: _produtoCompartilhadoDtoAttach,
  version: '3.3.0-dev.1',
);

int _produtoCompartilhadoDtoEstimateSize(
  ProdutoCompartilhadoDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.corNome.length * 3;
  bytesCount += 3 + object.hash.length * 3;
  bytesCount += 3 + object.hashLista.length * 3;
  bytesCount += 3 + object.nome.length * 3;
  bytesCount += 3 + object.tamanhoNome.length * 3;
  return bytesCount;
}

void _produtoCompartilhadoDtoSerialize(
  ProdutoCompartilhadoDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.corNome);
  writer.writeString(offsets[1], object.hash);
  writer.writeLong(offsets[2], object.hashCode);
  writer.writeString(offsets[3], object.hashLista);
  writer.writeString(offsets[4], object.nome);
  writer.writeLong(offsets[5], object.produtoId);
  writer.writeLong(offsets[6], object.quantidade);
  writer.writeBool(offsets[7], object.stringify);
  writer.writeString(offsets[8], object.tamanhoNome);
  writer.writeDouble(offsets[9], object.valorUnitario);
}

ProdutoCompartilhadoDto _produtoCompartilhadoDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProdutoCompartilhadoDto(
    corNome: reader.readString(offsets[0]),
    hash: reader.readString(offsets[1]),
    hashLista: reader.readString(offsets[3]),
    nome: reader.readString(offsets[4]),
    produtoId: reader.readLong(offsets[5]),
    quantidade: reader.readLong(offsets[6]),
    tamanhoNome: reader.readString(offsets[8]),
    valorUnitario: reader.readDouble(offsets[9]),
  );
  return object;
}

P _produtoCompartilhadoDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _produtoCompartilhadoDtoGetId(ProdutoCompartilhadoDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _produtoCompartilhadoDtoGetLinks(
    ProdutoCompartilhadoDto object) {
  return [];
}

void _produtoCompartilhadoDtoAttach(
    IsarCollection<dynamic> col, Id id, ProdutoCompartilhadoDto object) {}

extension ProdutoCompartilhadoDtoQueryWhereSort
    on QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QWhere> {
  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterWhere>
      anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProdutoCompartilhadoDtoQueryWhere on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QWhereClause> {
  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterWhereClause> dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterWhereClause> dataBaseIdNotEqualTo(Id dataBaseId) {
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterWhereClause>
      dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterWhereClause>
      dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterWhereClause> dataBaseIdBetween(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterWhereClause> hashListaEqualTo(String hashLista) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hashLista',
        value: [hashLista],
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterWhereClause> hashListaNotEqualTo(String hashLista) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hashLista',
              lower: [],
              upper: [hashLista],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hashLista',
              lower: [hashLista],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hashLista',
              lower: [hashLista],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hashLista',
              lower: [],
              upper: [hashLista],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProdutoCompartilhadoDtoQueryFilter on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QFilterCondition> {
  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'corNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'corNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'corNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'corNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'corNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'corNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      corNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'corNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      corNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'corNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'corNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> corNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'corNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> dataBaseIdGreaterThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> dataBaseIdLessThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> dataBaseIdBetween(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      hashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      hashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashCodeGreaterThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashCodeLessThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashCodeBetween(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashLista',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashLista',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashLista',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashLista',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hashLista',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hashLista',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      hashListaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hashLista',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      hashListaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hashLista',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashLista',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> hashListaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hashLista',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeEqualTo(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeGreaterThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeLessThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeBetween(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeStartsWith(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeEndsWith(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      nomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      nomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> produtoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'produtoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> produtoIdGreaterThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> produtoIdLessThan(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> produtoIdBetween(
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

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> quantidadeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantidade',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> quantidadeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantidade',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> quantidadeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantidade',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> quantidadeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantidade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> stringifyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> stringifyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> stringifyEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringify',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tamanhoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tamanhoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tamanhoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tamanhoNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tamanhoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tamanhoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      tamanhoNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tamanhoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
          QAfterFilterCondition>
      tamanhoNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tamanhoNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tamanhoNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> tamanhoNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tamanhoNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> valorUnitarioEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valorUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> valorUnitarioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valorUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> valorUnitarioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valorUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto,
      QAfterFilterCondition> valorUnitarioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valorUnitario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ProdutoCompartilhadoDtoQueryObject on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QFilterCondition> {}

extension ProdutoCompartilhadoDtoQueryLinks on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QFilterCondition> {}

extension ProdutoCompartilhadoDtoQuerySortBy
    on QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QSortBy> {
  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByCorNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByCorNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByHashLista() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashLista', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByHashListaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashLista', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByProdutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByProdutoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByQuantidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByQuantidadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByTamanhoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByTamanhoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByValorUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valorUnitario', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      sortByValorUnitarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valorUnitario', Sort.desc);
    });
  }
}

extension ProdutoCompartilhadoDtoQuerySortThenBy on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QSortThenBy> {
  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByCorNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByCorNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByHashLista() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashLista', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByHashListaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashLista', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByProdutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByProdutoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByQuantidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByQuantidadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByTamanhoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByTamanhoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByValorUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valorUnitario', Sort.asc);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QAfterSortBy>
      thenByValorUnitarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valorUnitario', Sort.desc);
    });
  }
}

extension ProdutoCompartilhadoDtoQueryWhereDistinct on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct> {
  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByCorNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'corNome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByHashLista({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashLista', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByProdutoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'produtoId');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByQuantidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantidade');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringify');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByTamanhoNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tamanhoNome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QDistinct>
      distinctByValorUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valorUnitario');
    });
  }
}

extension ProdutoCompartilhadoDtoQueryProperty on QueryBuilder<
    ProdutoCompartilhadoDto, ProdutoCompartilhadoDto, QQueryProperty> {
  QueryBuilder<ProdutoCompartilhadoDto, int, QQueryOperations>
      dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, String, QQueryOperations>
      corNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'corNome');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, String, QQueryOperations>
      hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, int, QQueryOperations>
      hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, String, QQueryOperations>
      hashListaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashLista');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, String, QQueryOperations>
      nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, int, QQueryOperations>
      produtoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'produtoId');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, int, QQueryOperations>
      quantidadeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantidade');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, bool?, QQueryOperations>
      stringifyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringify');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, String, QQueryOperations>
      tamanhoNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tamanhoNome');
    });
  }

  QueryBuilder<ProdutoCompartilhadoDto, double, QQueryOperations>
      valorUnitarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valorUnitario');
    });
  }
}
