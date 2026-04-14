// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_do_usuario_dto.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TerminalDoUsuarioDtoSchema = Schema(
  name: r'TerminalDoUsuarioDto',
  id: -4894669120949043947,
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

  estimateSize: _terminalDoUsuarioDtoEstimateSize,
  serialize: _terminalDoUsuarioDtoSerialize,
  deserialize: _terminalDoUsuarioDtoDeserialize,
  deserializeProp: _terminalDoUsuarioDtoDeserializeProp,
);

int _terminalDoUsuarioDtoEstimateSize(
  TerminalDoUsuarioDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _terminalDoUsuarioDtoSerialize(
  TerminalDoUsuarioDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeLong(offsets[1], object.id);
  writer.writeLong(offsets[2], object.idEmpresa);
  writer.writeString(offsets[3], object.nome);
}

TerminalDoUsuarioDto _terminalDoUsuarioDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TerminalDoUsuarioDto(
    id: reader.readLongOrNull(offsets[1]) ?? 0,
    idEmpresa: reader.readLongOrNull(offsets[2]) ?? 0,
    nome: reader.readStringOrNull(offsets[3]) ?? '',
  );
  return object;
}

P _terminalDoUsuarioDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TerminalDoUsuarioDtoQueryFilter
    on
        QueryBuilder<
          TerminalDoUsuarioDto,
          TerminalDoUsuarioDto,
          QFilterCondition
        > {
  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
  idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
  idEmpresaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idEmpresa', value: value),
      );
    });
  }

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
  nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<
    TerminalDoUsuarioDto,
    TerminalDoUsuarioDto,
    QAfterFilterCondition
  >
  nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nome', value: ''),
      );
    });
  }
}

extension TerminalDoUsuarioDtoQueryObject
    on
        QueryBuilder<
          TerminalDoUsuarioDto,
          TerminalDoUsuarioDto,
          QFilterCondition
        > {}
