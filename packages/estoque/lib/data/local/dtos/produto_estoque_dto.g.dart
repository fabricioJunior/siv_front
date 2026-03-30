// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_estoque_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProdutoEstoqueDtoCollection on Isar {
  IsarCollection<ProdutoEstoqueDto> get produtoEstoqueDtos => this.collection();
}

const ProdutoEstoqueDtoSchema = CollectionSchema(
  name: r'ProdutoEstoqueDto',
  id: -6565322416163939010,
  properties: {
    r'atualizadoEm': PropertySchema(
      id: 0,
      name: r'atualizadoEm',
      type: IsarType.dateTime,
    ),
    r'corId': PropertySchema(id: 1, name: r'corId', type: IsarType.long),
    r'corNome': PropertySchema(id: 2, name: r'corNome', type: IsarType.string),
    r'empresaId': PropertySchema(
      id: 3,
      name: r'empresaId',
      type: IsarType.long,
    ),
    r'hashCode': PropertySchema(id: 4, name: r'hashCode', type: IsarType.long),
    r'idDoProduto': PropertySchema(
      id: 5,
      name: r'idDoProduto',
      type: IsarType.long,
    ),
    r'nome': PropertySchema(id: 6, name: r'nome', type: IsarType.string),
    r'produtoIdExterno': PropertySchema(
      id: 7,
      name: r'produtoIdExterno',
      type: IsarType.string,
    ),
    r'referenciaId': PropertySchema(
      id: 8,
      name: r'referenciaId',
      type: IsarType.long,
    ),
    r'referenciaIdExterno': PropertySchema(
      id: 9,
      name: r'referenciaIdExterno',
      type: IsarType.string,
    ),
    r'saldo': PropertySchema(id: 10, name: r'saldo', type: IsarType.double),
    r'tamanhoId': PropertySchema(
      id: 11,
      name: r'tamanhoId',
      type: IsarType.long,
    ),
    r'tamanhoNome': PropertySchema(
      id: 12,
      name: r'tamanhoNome',
      type: IsarType.string,
    ),
    r'unidadeMedida': PropertySchema(
      id: 13,
      name: r'unidadeMedida',
      type: IsarType.string,
    ),
  },

  estimateSize: _produtoEstoqueDtoEstimateSize,
  serialize: _produtoEstoqueDtoSerialize,
  deserialize: _produtoEstoqueDtoDeserialize,
  deserializeProp: _produtoEstoqueDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _produtoEstoqueDtoGetId,
  getLinks: _produtoEstoqueDtoGetLinks,
  attach: _produtoEstoqueDtoAttach,
  version: '3.3.0-dev.1',
);

int _produtoEstoqueDtoEstimateSize(
  ProdutoEstoqueDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.corNome.length * 3;
  bytesCount += 3 + object.nome.length * 3;
  {
    final value = object.produtoIdExterno;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.referenciaIdExterno;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tamanhoNome.length * 3;
  {
    final value = object.unidadeMedida;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _produtoEstoqueDtoSerialize(
  ProdutoEstoqueDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.atualizadoEm);
  writer.writeLong(offsets[1], object.corId);
  writer.writeString(offsets[2], object.corNome);
  writer.writeLong(offsets[3], object.empresaId);
  writer.writeLong(offsets[4], object.hashCode);
  writer.writeLong(offsets[5], object.idDoProduto);
  writer.writeString(offsets[6], object.nome);
  writer.writeString(offsets[7], object.produtoIdExterno);
  writer.writeLong(offsets[8], object.referenciaId);
  writer.writeString(offsets[9], object.referenciaIdExterno);
  writer.writeDouble(offsets[10], object.saldo);
  writer.writeLong(offsets[11], object.tamanhoId);
  writer.writeString(offsets[12], object.tamanhoNome);
  writer.writeString(offsets[13], object.unidadeMedida);
}

ProdutoEstoqueDto _produtoEstoqueDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProdutoEstoqueDto(
    atualizadoEm: reader.readDateTimeOrNull(offsets[0]),
    corId: reader.readLong(offsets[1]),
    corNome: reader.readString(offsets[2]),
    empresaId: reader.readLong(offsets[3]),
    idDoProduto: reader.readLong(offsets[5]),
    nome: reader.readString(offsets[6]),
    produtoIdExterno: reader.readStringOrNull(offsets[7]),
    referenciaId: reader.readLong(offsets[8]),
    referenciaIdExterno: reader.readStringOrNull(offsets[9]),
    saldo: reader.readDouble(offsets[10]),
    tamanhoId: reader.readLong(offsets[11]),
    tamanhoNome: reader.readString(offsets[12]),
    unidadeMedida: reader.readStringOrNull(offsets[13]),
  );
  return object;
}

P _produtoEstoqueDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _produtoEstoqueDtoGetId(ProdutoEstoqueDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _produtoEstoqueDtoGetLinks(
  ProdutoEstoqueDto object,
) {
  return [];
}

void _produtoEstoqueDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  ProdutoEstoqueDto object,
) {}

extension ProdutoEstoqueDtoQueryWhereSort
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QWhere> {
  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterWhere>
  anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProdutoEstoqueDtoQueryWhere
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QWhereClause> {
  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterWhereClause>
  dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: dataBaseId, upper: dataBaseId),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterWhereClause>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterWhereClause>
  dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterWhereClause>
  dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterWhereClause>
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

extension ProdutoEstoqueDtoQueryFilter
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QFilterCondition> {
  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  atualizadoEmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'atualizadoEm'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  atualizadoEmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'atualizadoEm'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  atualizadoEmEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'atualizadoEm', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  atualizadoEmGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'atualizadoEm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  atualizadoEmLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'atualizadoEm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  atualizadoEmBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'atualizadoEm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'corId', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'corId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'corId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'corId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'corNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'corNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'corNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'corNome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'corNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'corNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'corNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'corNome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'corNome', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  corNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'corNome', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataBaseId', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  empresaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'empresaId', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  empresaIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'empresaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  empresaIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'empresaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  empresaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'empresaId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  idDoProdutoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idDoProduto', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  idDoProdutoGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idDoProduto',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  idDoProdutoLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idDoProduto',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  idDoProdutoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idDoProduto',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'produtoIdExterno'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'produtoIdExterno'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'produtoIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'produtoIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'produtoIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'produtoIdExterno',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'produtoIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'produtoIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'produtoIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'produtoIdExterno',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'produtoIdExterno', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  produtoIdExternoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'produtoIdExterno', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenciaId', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenciaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenciaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenciaId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'referenciaIdExterno'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'referenciaIdExterno'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenciaIdExterno',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'referenciaIdExterno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'referenciaIdExterno',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenciaIdExterno', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  referenciaIdExternoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'referenciaIdExterno',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  saldoEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'saldo',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  saldoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'saldo',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  saldoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'saldo',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  saldoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'saldo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tamanhoId', value: value),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tamanhoId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tamanhoId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tamanhoId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tamanhoNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tamanhoNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tamanhoNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tamanhoNome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tamanhoNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tamanhoNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tamanhoNome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tamanhoNome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tamanhoNome', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  tamanhoNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tamanhoNome', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'unidadeMedida'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'unidadeMedida'),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unidadeMedida',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unidadeMedida',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unidadeMedida',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unidadeMedida',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unidadeMedida',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unidadeMedida',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unidadeMedida',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unidadeMedida',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unidadeMedida', value: ''),
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterFilterCondition>
  unidadeMedidaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unidadeMedida', value: ''),
      );
    });
  }
}

extension ProdutoEstoqueDtoQueryObject
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QFilterCondition> {}

extension ProdutoEstoqueDtoQueryLinks
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QFilterCondition> {}

extension ProdutoEstoqueDtoQuerySortBy
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QSortBy> {
  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByCorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByCorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByCorNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByCorNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByIdDoProduto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idDoProduto', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByIdDoProdutoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idDoProduto', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByProdutoIdExterno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoIdExterno', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByProdutoIdExternoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoIdExterno', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByReferenciaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByReferenciaIdExterno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByReferenciaIdExternoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortBySaldo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldo', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortBySaldoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldo', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByTamanhoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByTamanhoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByTamanhoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByTamanhoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByUnidadeMedida() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadeMedida', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  sortByUnidadeMedidaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadeMedida', Sort.desc);
    });
  }
}

extension ProdutoEstoqueDtoQuerySortThenBy
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QSortThenBy> {
  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByCorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByCorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByCorNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByCorNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByIdDoProduto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idDoProduto', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByIdDoProdutoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idDoProduto', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByProdutoIdExterno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoIdExterno', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByProdutoIdExternoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produtoIdExterno', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByReferenciaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByReferenciaIdExterno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByReferenciaIdExternoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaIdExterno', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenBySaldo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldo', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenBySaldoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldo', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByTamanhoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByTamanhoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByTamanhoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByTamanhoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoNome', Sort.desc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByUnidadeMedida() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadeMedida', Sort.asc);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QAfterSortBy>
  thenByUnidadeMedidaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadeMedida', Sort.desc);
    });
  }
}

extension ProdutoEstoqueDtoQueryWhereDistinct
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct> {
  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'atualizadoEm');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByCorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'corId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByCorNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'corNome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByIdDoProduto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idDoProduto');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct> distinctByNome({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByProdutoIdExterno({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'produtoIdExterno',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenciaId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByReferenciaIdExterno({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'referenciaIdExterno',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctBySaldo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saldo');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByTamanhoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tamanhoId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByTamanhoNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tamanhoNome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QDistinct>
  distinctByUnidadeMedida({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'unidadeMedida',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension ProdutoEstoqueDtoQueryProperty
    on QueryBuilder<ProdutoEstoqueDto, ProdutoEstoqueDto, QQueryProperty> {
  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, DateTime?, QQueryOperations>
  atualizadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'atualizadoEm');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations> corIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'corId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, String, QQueryOperations> corNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'corNome');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations> empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations> idDoProdutoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idDoProduto');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, String?, QQueryOperations>
  produtoIdExternoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'produtoIdExterno');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations>
  referenciaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, String?, QQueryOperations>
  referenciaIdExternoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaIdExterno');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, double, QQueryOperations> saldoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saldo');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, int, QQueryOperations> tamanhoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tamanhoId');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, String, QQueryOperations>
  tamanhoNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tamanhoNome');
    });
  }

  QueryBuilder<ProdutoEstoqueDto, String?, QQueryOperations>
  unidadeMedidaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unidadeMedida');
    });
  }
}
