// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissao_do_usuario_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPermissaoDoUsuarioDtoCollection on Isar {
  IsarCollection<PermissaoDoUsuarioDto> get permissaoDoUsuarioDtos =>
      this.collection();
}

const PermissaoDoUsuarioDtoSchema = CollectionSchema(
  name: r'PermissaoDoUsuarioDto',
  id: -7971753999369630841,
  properties: {
    r'componenteId': PropertySchema(
      id: 0,
      name: r'componenteId',
      type: IsarType.string,
    ),
    r'componenteNome': PropertySchema(
      id: 1,
      name: r'componenteNome',
      type: IsarType.string,
    ),
    r'descontinuado': PropertySchema(
      id: 2,
      name: r'descontinuado',
      type: IsarType.long,
    ),
    r'empresaId': PropertySchema(
      id: 3,
      name: r'empresaId',
      type: IsarType.long,
    ),
    r'estaDescontinuado': PropertySchema(
      id: 4,
      name: r'estaDescontinuado',
      type: IsarType.bool,
    ),
    r'grupoId': PropertySchema(
      id: 5,
      name: r'grupoId',
      type: IsarType.long,
    ),
    r'grupoNome': PropertySchema(
      id: 6,
      name: r'grupoNome',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 7,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 8,
      name: r'id',
      type: IsarType.long,
    )
  },
  estimateSize: _permissaoDoUsuarioDtoEstimateSize,
  serialize: _permissaoDoUsuarioDtoSerialize,
  deserialize: _permissaoDoUsuarioDtoDeserialize,
  deserializeProp: _permissaoDoUsuarioDtoDeserializeProp,
  idName: r'dataBaseId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _permissaoDoUsuarioDtoGetId,
  getLinks: _permissaoDoUsuarioDtoGetLinks,
  attach: _permissaoDoUsuarioDtoAttach,
  version: '3.3.0-dev.1',
);

int _permissaoDoUsuarioDtoEstimateSize(
  PermissaoDoUsuarioDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.componenteId.length * 3;
  bytesCount += 3 + object.componenteNome.length * 3;
  bytesCount += 3 + object.grupoNome.length * 3;
  return bytesCount;
}

void _permissaoDoUsuarioDtoSerialize(
  PermissaoDoUsuarioDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.componenteId);
  writer.writeString(offsets[1], object.componenteNome);
  writer.writeLong(offsets[2], object.descontinuado);
  writer.writeLong(offsets[3], object.empresaId);
  writer.writeBool(offsets[4], object.estaDescontinuado);
  writer.writeLong(offsets[5], object.grupoId);
  writer.writeString(offsets[6], object.grupoNome);
  writer.writeLong(offsets[7], object.hashCode);
  writer.writeLong(offsets[8], object.id);
}

PermissaoDoUsuarioDto _permissaoDoUsuarioDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PermissaoDoUsuarioDto(
    componenteId: reader.readString(offsets[0]),
    componenteNome: reader.readString(offsets[1]),
    descontinuado: reader.readLong(offsets[2]),
    empresaId: reader.readLong(offsets[3]),
    grupoId: reader.readLong(offsets[5]),
    grupoNome: reader.readString(offsets[6]),
    id: reader.readLong(offsets[8]),
  );
  return object;
}

P _permissaoDoUsuarioDtoDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _permissaoDoUsuarioDtoGetId(PermissaoDoUsuarioDto object) {
  return object.dataBaseId;
}

List<IsarLinkBase<dynamic>> _permissaoDoUsuarioDtoGetLinks(
    PermissaoDoUsuarioDto object) {
  return [];
}

void _permissaoDoUsuarioDtoAttach(
    IsarCollection<dynamic> col, Id id, PermissaoDoUsuarioDto object) {}

extension PermissaoDoUsuarioDtoQueryWhereSort
    on QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QWhere> {
  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterWhere>
      anyDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PermissaoDoUsuarioDtoQueryWhere on QueryBuilder<PermissaoDoUsuarioDto,
    PermissaoDoUsuarioDto, QWhereClause> {
  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterWhereClause>
      dataBaseIdEqualTo(Id dataBaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dataBaseId,
        upper: dataBaseId,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterWhereClause>
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterWhereClause>
      dataBaseIdGreaterThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dataBaseId, includeLower: include),
      );
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterWhereClause>
      dataBaseIdLessThan(Id dataBaseId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dataBaseId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterWhereClause>
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

extension PermissaoDoUsuarioDtoQueryFilter on QueryBuilder<
    PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QFilterCondition> {
  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componenteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'componenteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'componenteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'componenteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'componenteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'componenteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
          QAfterFilterCondition>
      componenteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'componenteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
          QAfterFilterCondition>
      componenteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'componenteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componenteId',
        value: '',
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'componenteId',
        value: '',
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componenteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'componenteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'componenteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'componenteNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'componenteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'componenteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
          QAfterFilterCondition>
      componenteNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'componenteNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
          QAfterFilterCondition>
      componenteNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'componenteNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componenteNome',
        value: '',
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> componenteNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'componenteNome',
        value: '',
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> dataBaseIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataBaseId',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> descontinuadoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descontinuado',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> descontinuadoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descontinuado',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> descontinuadoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descontinuado',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> descontinuadoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descontinuado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> empresaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> empresaIdGreaterThan(
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> empresaIdLessThan(
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> empresaIdBetween(
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> estaDescontinuadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estaDescontinuado',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grupoId',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grupoId',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grupoId',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grupoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grupoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grupoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grupoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grupoNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grupoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grupoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
          QAfterFilterCondition>
      grupoNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grupoNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
          QAfterFilterCondition>
      grupoNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grupoNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grupoNome',
        value: '',
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> grupoNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grupoNome',
        value: '',
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto,
      QAfterFilterCondition> idBetween(
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
}

extension PermissaoDoUsuarioDtoQueryObject on QueryBuilder<
    PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QFilterCondition> {}

extension PermissaoDoUsuarioDtoQueryLinks on QueryBuilder<PermissaoDoUsuarioDto,
    PermissaoDoUsuarioDto, QFilterCondition> {}

extension PermissaoDoUsuarioDtoQuerySortBy
    on QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QSortBy> {
  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByComponenteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByComponenteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByComponenteNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteNome', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByComponenteNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteNome', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByDescontinuado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descontinuado', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByDescontinuadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descontinuado', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByEstaDescontinuado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaDescontinuado', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByEstaDescontinuadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaDescontinuado', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByGrupoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByGrupoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByGrupoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoNome', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByGrupoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoNome', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension PermissaoDoUsuarioDtoQuerySortThenBy
    on QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QSortThenBy> {
  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByComponenteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByComponenteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByComponenteNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteNome', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByComponenteNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'componenteNome', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByDataBaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByDataBaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBaseId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByDescontinuado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descontinuado', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByDescontinuadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descontinuado', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByEstaDescontinuado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaDescontinuado', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByEstaDescontinuadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaDescontinuado', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByGrupoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoId', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByGrupoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoId', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByGrupoNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoNome', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByGrupoNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoNome', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension PermissaoDoUsuarioDtoQueryWhereDistinct
    on QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct> {
  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByComponenteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'componenteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByComponenteNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'componenteNome',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByDescontinuado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descontinuado');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByEstaDescontinuado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estaDescontinuado');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByGrupoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grupoId');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByGrupoNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grupoNome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QDistinct>
      distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }
}

extension PermissaoDoUsuarioDtoQueryProperty on QueryBuilder<
    PermissaoDoUsuarioDto, PermissaoDoUsuarioDto, QQueryProperty> {
  QueryBuilder<PermissaoDoUsuarioDto, int, QQueryOperations>
      dataBaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBaseId');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, String, QQueryOperations>
      componenteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'componenteId');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, String, QQueryOperations>
      componenteNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'componenteNome');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, int, QQueryOperations>
      descontinuadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descontinuado');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, int, QQueryOperations>
      empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, bool, QQueryOperations>
      estaDescontinuadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estaDescontinuado');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, int, QQueryOperations> grupoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grupoId');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, String, QQueryOperations>
      grupoNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grupoNome');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, int, QQueryOperations>
      hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<PermissaoDoUsuarioDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }
}
