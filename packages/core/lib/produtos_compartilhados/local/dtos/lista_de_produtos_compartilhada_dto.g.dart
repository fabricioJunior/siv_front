// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_de_produtos_compartilhada_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetListaDeProdutosCompartilhadaDtoCollection on Isar {
  IsarCollection<ListaDeProdutosCompartilhadaDto>
      get listaDeProdutosCompartilhadaDtos => this.collection();
}

const ListaDeProdutosCompartilhadaDtoSchema = CollectionSchema(
  name: r'ListaDeProdutosCompartilhadaDto',
  id: 7746312427843076074,
  properties: {
    r'atualizadaEm': PropertySchema(
      id: 0,
      name: r'atualizadaEm',
      type: IsarType.dateTime,
    ),
    r'clienteNome': PropertySchema(
      id: 1,
      name: r'clienteNome',
      type: IsarType.string,
    ),
    r'criadaEm': PropertySchema(
      id: 2,
      name: r'criadaEm',
      type: IsarType.dateTime,
    ),
    r'funcionarioId': PropertySchema(
      id: 3,
      name: r'funcionarioId',
      type: IsarType.long,
    ),
    r'funcionarioNome': PropertySchema(
      id: 4,
      name: r'funcionarioNome',
      type: IsarType.string,
    ),
    r'hash': PropertySchema(
      id: 5,
      name: r'hash',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 6,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'idLista': PropertySchema(
      id: 7,
      name: r'idLista',
      type: IsarType.long,
    ),
    r'origemIndex': PropertySchema(
      id: 8,
      name: r'origemIndex',
      type: IsarType.long,
    ),
    r'pessoaId': PropertySchema(
      id: 9,
      name: r'pessoaId',
      type: IsarType.long,
    ),
    r'processada': PropertySchema(
      id: 10,
      name: r'processada',
      type: IsarType.bool,
    ),
    r'stringify': PropertySchema(
      id: 11,
      name: r'stringify',
      type: IsarType.bool,
    ),
    r'tabelaPrecoId': PropertySchema(
      id: 12,
      name: r'tabelaPrecoId',
      type: IsarType.long,
    ),
    r'tabelaPrecoNome': PropertySchema(
      id: 13,
      name: r'tabelaPrecoNome',
      type: IsarType.string,
    )
  },
  estimateSize: _listaDeProdutosCompartilhadaDtoEstimateSize,
  serialize: _listaDeProdutosCompartilhadaDtoSerialize,
  deserialize: _listaDeProdutosCompartilhadaDtoDeserialize,
  deserializeProp: _listaDeProdutosCompartilhadaDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _listaDeProdutosCompartilhadaDtoGetId,
  getLinks: _listaDeProdutosCompartilhadaDtoGetLinks,
  attach: _listaDeProdutosCompartilhadaDtoAttach,
  version: '3.3.2',
);

int _listaDeProdutosCompartilhadaDtoEstimateSize(
  ListaDeProdutosCompartilhadaDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.clienteNome;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.funcionarioNome;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.hash.length * 3;
  {
    final value = object.tabelaPrecoNome;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _listaDeProdutosCompartilhadaDtoSerialize(
  ListaDeProdutosCompartilhadaDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.atualizadaEm);
  writer.writeString(offsets[1], object.clienteNome);
  writer.writeDateTime(offsets[2], object.criadaEm);
  writer.writeLong(offsets[3], object.funcionarioId);
  writer.writeString(offsets[4], object.funcionarioNome);
  writer.writeString(offsets[5], object.hash);
  writer.writeLong(offsets[6], object.hashCode);
  writer.writeLong(offsets[7], object.idLista);
  writer.writeLong(offsets[8], object.origemIndex);
  writer.writeLong(offsets[9], object.pessoaId);
  writer.writeBool(offsets[10], object.processada);
  writer.writeBool(offsets[11], object.stringify);
  writer.writeLong(offsets[12], object.tabelaPrecoId);
  writer.writeString(offsets[13], object.tabelaPrecoNome);
}

ListaDeProdutosCompartilhadaDto _listaDeProdutosCompartilhadaDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ListaDeProdutosCompartilhadaDto(
    atualizadaEm: reader.readDateTime(offsets[0]),
    clienteNome: reader.readStringOrNull(offsets[1]),
    criadaEm: reader.readDateTime(offsets[2]),
    funcionarioId: reader.readLongOrNull(offsets[3]),
    funcionarioNome: reader.readStringOrNull(offsets[4]),
    hash: reader.readString(offsets[5]),
    idLista: reader.readLongOrNull(offsets[7]),
    origemIndex: reader.readLong(offsets[8]),
    pessoaId: reader.readLongOrNull(offsets[9]),
    processada: reader.readBoolOrNull(offsets[10]),
    tabelaPrecoId: reader.readLongOrNull(offsets[12]),
    tabelaPrecoNome: reader.readStringOrNull(offsets[13]),
  );
  return object;
}

P _listaDeProdutosCompartilhadaDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readBoolOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _listaDeProdutosCompartilhadaDtoGetId(
    ListaDeProdutosCompartilhadaDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _listaDeProdutosCompartilhadaDtoGetLinks(
    ListaDeProdutosCompartilhadaDto object) {
  return [];
}

void _listaDeProdutosCompartilhadaDtoAttach(IsarCollection<dynamic> col, Id id,
    ListaDeProdutosCompartilhadaDto object) {}

extension ListaDeProdutosCompartilhadaDtoQueryWhereSort on QueryBuilder<
    ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto, QWhere> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterWhere> anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ListaDeProdutosCompartilhadaDtoQueryWhere on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QWhereClause> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterWhereClause> dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterWhereClause>
      dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterWhereClause>
      dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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
}

extension ListaDeProdutosCompartilhadaDtoQueryFilter on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QFilterCondition> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> atualizadaEmEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'atualizadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> atualizadaEmGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'atualizadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> atualizadaEmLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'atualizadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> atualizadaEmBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'atualizadaEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteNome',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteNome',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterFilterCondition>
      clienteNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterFilterCondition>
      clienteNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> clienteNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> criadaEmEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> criadaEmGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'criadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> criadaEmLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'criadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> criadaEmBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'criadaEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'funcionarioId',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'funcionarioId',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'funcionarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'funcionarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'funcionarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'funcionarioId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'funcionarioNome',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'funcionarioNome',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'funcionarioNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'funcionarioNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'funcionarioNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'funcionarioNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'funcionarioNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'funcionarioNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterFilterCondition>
      funcionarioNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'funcionarioNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterFilterCondition>
      funcionarioNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'funcionarioNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'funcionarioNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> funcionarioNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'funcionarioNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
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

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> idListaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idLista',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> idListaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idLista',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> idListaEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idLista',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> idListaGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idLista',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> idListaLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idLista',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> idListaBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idLista',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> origemIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origemIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> origemIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origemIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> origemIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origemIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> origemIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origemIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> pessoaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pessoaId',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> pessoaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pessoaId',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> pessoaIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pessoaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> pessoaIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pessoaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> pessoaIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pessoaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> pessoaIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pessoaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> processadaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'processada',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> processadaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'processada',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> processadaEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processada',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> stringifyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> stringifyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stringify',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> stringifyEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringify',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tabelaPrecoId',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tabelaPrecoId',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tabelaPrecoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tabelaPrecoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tabelaPrecoId',
        value: value,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tabelaPrecoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tabelaPrecoNome',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tabelaPrecoNome',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tabelaPrecoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tabelaPrecoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tabelaPrecoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tabelaPrecoNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tabelaPrecoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tabelaPrecoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterFilterCondition>
      tabelaPrecoNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tabelaPrecoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
          QAfterFilterCondition>
      tabelaPrecoNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tabelaPrecoNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tabelaPrecoNome',
        value: '',
      ));
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterFilterCondition> tabelaPrecoNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tabelaPrecoNome',
        value: '',
      ));
    });
  }
}

extension ListaDeProdutosCompartilhadaDtoQueryObject on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QFilterCondition> {}

extension ListaDeProdutosCompartilhadaDtoQueryLinks on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QFilterCondition> {}

extension ListaDeProdutosCompartilhadaDtoQuerySortBy on QueryBuilder<
    ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto, QSortBy> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByAtualizadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadaEm', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByAtualizadaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadaEm', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByClienteNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNome', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByClienteNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNome', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByCriadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadaEm', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByCriadaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadaEm', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByFuncionarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByFuncionarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByFuncionarioNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioNome', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByFuncionarioNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioNome', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByIdLista() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLista', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByIdListaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLista', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByOrigemIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origemIndex', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByOrigemIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origemIndex', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByPessoaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pessoaId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByPessoaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pessoaId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByProcessada() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processada', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByProcessadaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processada', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByTabelaPrecoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByTabelaPrecoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByTabelaPrecoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoNome', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> sortByTabelaPrecoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoNome', Sort.desc);
    });
  }
}

extension ListaDeProdutosCompartilhadaDtoQuerySortThenBy on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QSortThenBy> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByAtualizadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadaEm', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByAtualizadaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'atualizadaEm', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByClienteNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNome', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByClienteNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNome', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByCriadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadaEm', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByCriadaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadaEm', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByFuncionarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByFuncionarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByFuncionarioNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioNome', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByFuncionarioNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'funcionarioNome', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByIdLista() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLista', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByIdListaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLista', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByOrigemIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origemIndex', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByOrigemIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origemIndex', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByPessoaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pessoaId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByPessoaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pessoaId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByProcessada() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processada', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByProcessadaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processada', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByStringifyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringify', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByTabelaPrecoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoId', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByTabelaPrecoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoId', Sort.desc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByTabelaPrecoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoNome', Sort.asc);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QAfterSortBy> thenByTabelaPrecoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabelaPrecoNome', Sort.desc);
    });
  }
}

extension ListaDeProdutosCompartilhadaDtoQueryWhereDistinct on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QDistinct> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByAtualizadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'atualizadaEm');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByClienteNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteNome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByCriadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criadaEm');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByFuncionarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'funcionarioId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByFuncionarioNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'funcionarioNome',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByIdLista() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idLista');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByOrigemIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origemIndex');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByPessoaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pessoaId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByProcessada() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processada');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByStringify() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringify');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByTabelaPrecoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tabelaPrecoId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, ListaDeProdutosCompartilhadaDto,
      QDistinct> distinctByTabelaPrecoNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tabelaPrecoNome',
          caseSensitive: caseSensitive);
    });
  }
}

extension ListaDeProdutosCompartilhadaDtoQueryProperty on QueryBuilder<
    ListaDeProdutosCompartilhadaDto,
    ListaDeProdutosCompartilhadaDto,
    QQueryProperty> {
  QueryBuilder<ListaDeProdutosCompartilhadaDto, int, QQueryOperations>
      dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, DateTime, QQueryOperations>
      atualizadaEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'atualizadaEm');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, String?, QQueryOperations>
      clienteNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteNome');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, DateTime, QQueryOperations>
      criadaEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criadaEm');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, int?, QQueryOperations>
      funcionarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'funcionarioId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, String?, QQueryOperations>
      funcionarioNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'funcionarioNome');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, String, QQueryOperations>
      hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, int, QQueryOperations>
      hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, int?, QQueryOperations>
      idListaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idLista');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, int, QQueryOperations>
      origemIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origemIndex');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, int?, QQueryOperations>
      pessoaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pessoaId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, bool?, QQueryOperations>
      processadaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processada');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, bool?, QQueryOperations>
      stringifyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringify');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, int?, QQueryOperations>
      tabelaPrecoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tabelaPrecoId');
    });
  }

  QueryBuilder<ListaDeProdutosCompartilhadaDto, String?, QQueryOperations>
      tabelaPrecoNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tabelaPrecoNome');
    });
  }
}
