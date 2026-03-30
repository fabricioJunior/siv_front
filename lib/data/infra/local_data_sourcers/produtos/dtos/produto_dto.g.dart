// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProdutoDtoCollection on Isar {
  IsarCollection<ProdutoDto> get produtoDtos => this.collection();
}

const ProdutoDtoSchema = CollectionSchema(
  name: r'ProdutoDto',
  id: -3084195402400621068,
  properties: {
    r'atualizadoEm': PropertySchema(
      id: 0,
      name: r'atualizadoEm',
      type: IsarType.dateTime,
    ),
    r'codigoDeBarras': PropertySchema(
      id: 1,
      name: r'codigoDeBarras',
      type: IsarType.string,
    ),
    r'corId': PropertySchema(
      id: 2,
      name: r'corId',
      type: IsarType.long,
    ),
    r'empresaId': PropertySchema(
      id: 3,
      name: r'empresaId',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.long,
    ),
    r'nomeCor': PropertySchema(
      id: 5,
      name: r'nomeCor',
      type: IsarType.string,
    ),
    r'nomeReferencia': PropertySchema(
      id: 6,
      name: r'nomeReferencia',
      type: IsarType.string,
    ),
    r'nomeTamanho': PropertySchema(
      id: 7,
      name: r'nomeTamanho',
      type: IsarType.string,
    ),
    r'quantidadeEmEstoque': PropertySchema(
      id: 8,
      name: r'quantidadeEmEstoque',
      type: IsarType.long,
    ),
    r'referenciaId': PropertySchema(
      id: 9,
      name: r'referenciaId',
      type: IsarType.long,
    ),
    r'tamanhoId': PropertySchema(
      id: 10,
      name: r'tamanhoId',
      type: IsarType.long,
    )
  },
  estimateSize: _produtoDtoEstimateSize,
  serialize: _produtoDtoSerialize,
  deserialize: _produtoDtoDeserialize,
  deserializeProp: _produtoDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _produtoDtoGetId,
  getLinks: _produtoDtoGetLinks,
  attach: _produtoDtoAttach,
  version: '3.3.0-dev.1',
);

int _produtoDtoEstimateSize(
  ProdutoDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigoDeBarras.length * 3;
  bytesCount += 3 + object.nomeCor.length * 3;
  bytesCount += 3 + object.nomeReferencia.length * 3;
  bytesCount += 3 + object.nomeTamanho.length * 3;
  return bytesCount;
}

void _produtoDtoSerialize(
  ProdutoDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.atualizadoEm);
  writer.writeString(offsets[1], object.codigoDeBarras);
  writer.writeLong(offsets[2], object.corId);
  writer.writeLong(offsets[3], object.empresaId);
  writer.writeLong(offsets[4], object.id);
  writer.writeString(offsets[5], object.nomeCor);
  writer.writeString(offsets[6], object.nomeReferencia);
  writer.writeString(offsets[7], object.nomeTamanho);
  writer.writeLong(offsets[8], object.quantidadeEmEstoque);
  writer.writeLong(offsets[9], object.referenciaId);
  writer.writeLong(offsets[10], object.tamanhoId);
}

ProdutoDto _produtoDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProdutoDto(
    atualizadoEm: reader.readDateTimeOrNull(offsets[0]),
    codigoDeBarras: reader.readString(offsets[1]),
    corId: reader.readLong(offsets[2]),
    empresaId: reader.readLong(offsets[3]),
    id: reader.readLong(offsets[4]),
    nomeCor: reader.readString(offsets[5]),
    nomeReferencia: reader.readString(offsets[6]),
    nomeTamanho: reader.readString(offsets[7]),
    quantidadeEmEstoque: reader.readLong(offsets[8]),
    referenciaId: reader.readLong(offsets[9]),
    tamanhoId: reader.readLong(offsets[10]),
  );
  return object;
}

P _produtoDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _produtoDtoGetId(ProdutoDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _produtoDtoGetLinks(ProdutoDto object) {
  return [];
}

void _produtoDtoAttach(IsarCollection<dynamic> col, Id id, ProdutoDto object) {}

extension ProdutoDtoQueryWhereSort
    on QueryBuilder<ProdutoDto, ProdutoDto, QWhere> {
  QueryBuilder<ProdutoDto, ProdutoDto, QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProdutoDtoQueryWhere
    on QueryBuilder<ProdutoDto, ProdutoDto, QWhereClause> {
  QueryBuilder<ProdutoDto, ProdutoDto, QAfterWhereClause> dataBaseIdEqualTo(
      Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterWhereClause> dataBaseIdNotEqualTo(
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterWhereClause> dataBaseIdGreaterThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterWhereClause> dataBaseIdLessThan(
      Id dataBaseId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterWhereClause> dataBaseIdBetween(
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

extension ProdutoDtoQueryFilter
    on QueryBuilder<ProdutoDto, ProdutoDto, QFilterCondition> {
  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      atualizadoEmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'atualizadoEm',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      atualizadoEmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'atualizadoEm',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      atualizadoEmEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'atualizadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      atualizadoEmGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'atualizadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      atualizadoEmLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'atualizadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      atualizadoEmBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'atualizadoEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoDeBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoDeBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoDeBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoDeBarras',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoDeBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoDeBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoDeBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoDeBarras',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoDeBarras',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      codigoDeBarrasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoDeBarras',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> corIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'corId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> corIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'corId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> corIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'corId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> corIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'corId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> dataBaseIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> dataBaseIdBetween(
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> empresaIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      empresaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empresaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> empresaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empresaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> empresaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empresaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> idEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeCor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeCorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomeCor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomeCor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomeCor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomeCor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomeCor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomeCor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomeCor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> nomeCorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeCor',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeCorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomeCor',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeReferencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomeReferencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomeReferencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomeReferencia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomeReferencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomeReferencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomeReferencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomeReferencia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeReferencia',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeReferenciaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomeReferencia',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeTamanho',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomeTamanho',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomeTamanho',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomeTamanho',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomeTamanho',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomeTamanho',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomeTamanho',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomeTamanho',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeTamanho',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      nomeTamanhoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomeTamanho',
        value: '',
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      quantidadeEmEstoqueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantidadeEmEstoque',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      quantidadeEmEstoqueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantidadeEmEstoque',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      quantidadeEmEstoqueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantidadeEmEstoque',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      quantidadeEmEstoqueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantidadeEmEstoque',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      referenciaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenciaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      referenciaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenciaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      referenciaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenciaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      referenciaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenciaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> tamanhoIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tamanhoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition>
      tamanhoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tamanhoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> tamanhoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tamanhoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterFilterCondition> tamanhoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tamanhoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProdutoDtoQueryObject
    on QueryBuilder<ProdutoDto, ProdutoDto, QFilterCondition> {}

extension ProdutoDtoQueryLinks
    on QueryBuilder<ProdutoDto, ProdutoDto, QFilterCondition> {}

extension ProdutoDtoQuerySortBy
    on QueryBuilder<ProdutoDto, ProdutoDto, QSortBy> {
  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByCodigoDeBarras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoDeBarras', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      sortByCodigoDeBarrasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoDeBarras', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByCorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByCorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByNomeCor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeCor', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByNomeCorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeCor', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByNomeReferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeReferencia', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      sortByNomeReferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeReferencia', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByNomeTamanho() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeTamanho', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByNomeTamanhoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeTamanho', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      sortByQuantidadeEmEstoque() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidadeEmEstoque', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      sortByQuantidadeEmEstoqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidadeEmEstoque', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByReferenciaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByTamanhoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> sortByTamanhoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.desc);
    });
  }
}

extension ProdutoDtoQuerySortThenBy
    on QueryBuilder<ProdutoDto, ProdutoDto, QSortThenBy> {
  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByAtualizadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadoEm', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByCodigoDeBarras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoDeBarras', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      thenByCodigoDeBarrasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoDeBarras', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByCorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByCorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'corId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByNomeCor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeCor', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByNomeCorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeCor', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByNomeReferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeReferencia', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      thenByNomeReferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeReferencia', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByNomeTamanho() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeTamanho', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByNomeTamanhoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeTamanho', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      thenByQuantidadeEmEstoque() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidadeEmEstoque', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy>
      thenByQuantidadeEmEstoqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidadeEmEstoque', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByReferenciaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaId', Sort.desc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByTamanhoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.asc);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QAfterSortBy> thenByTamanhoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tamanhoId', Sort.desc);
    });
  }
}

extension ProdutoDtoQueryWhereDistinct
    on QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> {
  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByAtualizadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'atualizadoEm');
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByCodigoDeBarras(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoDeBarras',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByCorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'corId');
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId');
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByNomeCor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomeCor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByNomeReferencia(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomeReferencia',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByNomeTamanho(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomeTamanho', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct>
      distinctByQuantidadeEmEstoque() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantidadeEmEstoque');
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByReferenciaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenciaId');
    });
  }

  QueryBuilder<ProdutoDto, ProdutoDto, QDistinct> distinctByTamanhoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tamanhoId');
    });
  }
}

extension ProdutoDtoQueryProperty
    on QueryBuilder<ProdutoDto, ProdutoDto, QQueryProperty> {
  QueryBuilder<ProdutoDto, int, QQueryOperations> dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<ProdutoDto, DateTime?, QQueryOperations> atualizadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'atualizadoEm');
    });
  }

  QueryBuilder<ProdutoDto, String, QQueryOperations> codigoDeBarrasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoDeBarras');
    });
  }

  QueryBuilder<ProdutoDto, int, QQueryOperations> corIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'corId');
    });
  }

  QueryBuilder<ProdutoDto, int, QQueryOperations> empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<ProdutoDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProdutoDto, String, QQueryOperations> nomeCorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomeCor');
    });
  }

  QueryBuilder<ProdutoDto, String, QQueryOperations> nomeReferenciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomeReferencia');
    });
  }

  QueryBuilder<ProdutoDto, String, QQueryOperations> nomeTamanhoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomeTamanho');
    });
  }

  QueryBuilder<ProdutoDto, int, QQueryOperations>
      quantidadeEmEstoqueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantidadeEmEstoque');
    });
  }

  QueryBuilder<ProdutoDto, int, QQueryOperations> referenciaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaId');
    });
  }

  QueryBuilder<ProdutoDto, int, QQueryOperations> tamanhoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tamanhoId');
    });
  }
}
