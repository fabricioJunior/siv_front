import 'package:pessoas/domain/models/pessoa.dart';
import 'package:json_annotation/json_annotation.dart';
part 'pessoa_dto.g.dart';

@JsonSerializable()
class PessoaDto with Pessoa {
  @override
  final bool bloqueado;

  @override
  final String contato;

  @override
  final String documento;

  @override
  @JsonKey(name: 'cliente')
  final bool eCliente;

  @override
  @JsonKey(name: 'fornecedor')
  final bool eFornecedor;

  @override
  @JsonKey(name: 'funcionario')
  final bool eFuncionario;

  @override
  final String? email;

  @override
  final int? id;

  @override
  final String? inscricaoEstadual;

  @override
  final String nome;

  // usa funções customizadas para converter TipoPessoa <-> json string
  @override
  @JsonKey(name: 'tipo', fromJson: tipoPessoaFromJson, toJson: tipoPessoaToJson)
  final TipoPessoa tipoPessoa;

  // usa funções customizadas para converter TipoContato <-> json string
  @override
  @JsonKey(fromJson: tipoContatoFromJson, toJson: tipoContatoToJson)
  final TipoContato tipoContato;

  @override
  @JsonKey(name: 'ufInscricaoEstadual')
  final String? uf;

  @override
  DateTime? get dataDeNascimento => nascimento;

  @JsonKey(name: 'nascimento')
  final DateTime? nascimento;

  PessoaDto({
    required this.bloqueado,
    required this.contato,
    required this.documento,
    required this.eCliente,
    required this.eFornecedor,
    required this.eFuncionario,
    required this.email,
    this.id,
    this.inscricaoEstadual,
    required this.nome,
    required this.tipoPessoa,
    required this.tipoContato,
    required this.uf,
    required this.nascimento,
  });

  factory PessoaDto.fromJson(Map<String, dynamic> json) =>
      _$PessoaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PessoaDtoToJson(this);
}

extension ToDto on Pessoa {
  PessoaDto toDto() => PessoaDto(
      bloqueado: bloqueado,
      contato: contato,
      documento: documento,
      eCliente: eCliente,
      eFornecedor: eFornecedor,
      eFuncionario: eFuncionario,
      email: email,
      nome: nome,
      tipoPessoa: tipoPessoa,
      tipoContato: tipoContato,
      uf: uf,
      nascimento: dataDeNascimento);
}

/// Converte a string do JSON para TipoPessoa.
/// Tenta fazer matching flexível (ex.: "Física" <-> TipoPessoa.fisica).
TipoPessoa tipoPessoaFromJson(dynamic json) {
  if (json == null) return TipoPessoa.values.first;
  final s = json.toString();
  final norm = _normalize(s);

  for (final v in TipoPessoa.values) {
    final name = v.toString().split('.').last;
    if (_normalize(name) == norm) return v;
  }

  // heurísticas comuns
  if (norm.contains('fis')) {
    return _findEnumByNameContains(TipoPessoa.values, 'fis') ??
        TipoPessoa.values.first;
  }
  if (norm.contains('jur') || norm.contains('pj') || norm.contains('juri')) {
    return _findEnumByNameContains(TipoPessoa.values, 'jur') ??
        TipoPessoa.values.first;
  }

  return TipoPessoa.values.first;
}

/// Converte TipoPessoa para a string esperada no JSON.
/// Ajuste os textos retornados conforme a API (ex.: "Física", "Jurídica").
String tipoPessoaToJson(TipoPessoa? value) {
  if (value == null) return '';
  final name = value.toString().split('.').last.toLowerCase();
  if (name.contains('fis')) return 'Física';
  if (name.contains('jur') || name.contains('pj')) return 'Jurídica';
  // fallback: usa nome do enum
  return _capitalize(value.toString().split('.').last);
}

/// Converte a string do JSON para TipoContato.
TipoContato tipoContatoFromJson(dynamic json) {
  if (json == null) return TipoContato.values.first;
  final s = json.toString();
  final norm = _normalize(s);

  for (final v in TipoContato.values) {
    final name = v.toString().split('.').last;
    if (_normalize(name) == norm) return v;
  }

  if (norm.contains('tel') || norm.contains('fone')) {
    return _findEnumByNameContains(TipoContato.values, 'tel') ??
        TipoContato.values.first;
  }
  if (norm.contains('email') || norm.contains('e-mail')) {
    return _findEnumByNameContains(TipoContato.values, 'email') ??
        TipoContato.values.first;
  }

  return TipoContato.values.first;
}

/// Converte TipoContato para a string esperada no JSON (ex.: "Telefone", "Email").
String tipoContatoToJson(TipoContato? value) {
  if (value == null) return '';
  final name = value.toString().split('.').last.toLowerCase();
  if (name.contains('tel') || name.contains('fone')) return 'Telefone';
  if (name.contains('email')) return 'Email';
  return _capitalize(value.toString().split('.').last);
}

/// Helpers

String _normalize(String s) {
  var out = s.toLowerCase().trim();
  // remove acentos básicos
  const accents = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ç': 'c',
    'ñ': 'n',
    '–': '-',
    '—': '-',
  };
  accents.forEach((k, v) {
    out = out.replaceAll(k, v);
  });
  out = out.replaceAll(RegExp(r'[^a-z0-9]'), '');
  return out;
}

T? _findEnumByNameContains<T>(Iterable<T> values, String needle) {
  final n = needle.toLowerCase();
  for (final v in values) {
    final name = v.toString().split('.').last.toLowerCase();
    if (name.contains(n)) return v;
  }
  return null;
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  final first = s[0].toUpperCase();
  return '$first${s.substring(1)}';
}
