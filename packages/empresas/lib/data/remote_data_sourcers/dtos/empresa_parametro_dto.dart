import 'package:empresas/domain/entities/empresa_parametro.dart';

class EmpresaParametroDto implements EmpresaParametro {
  // JSON contract fields
  @override
  final int empresaId;

  final String parametroId;

  @override
  final String descricao;

  String get valor => valorTexto ?? (valorBooleano == true ? 'S' : 'N');

  final int depreciado;

  // Adapted domain fields
  @override
  final TipoEmpresaParametro tipo;

  @override
  final bool? valorBooleano;

  @override
  final String? valorTexto;

  @override
  int get id => parametroId.hashCode;

  @override
  String get chave => parametroId;

  const EmpresaParametroDto({
    required this.empresaId,
    required this.parametroId,
    required this.descricao,
    required this.depreciado,
    required this.tipo,
    required this.valorBooleano,
    this.valorTexto,
  });

  factory EmpresaParametroDto.fromJson(Map<String, dynamic> json) {
    final valor = (json['valor'] as String? ?? '').trim();
    final valorBooleano = _parseBool(valor);
    final ehCheckbox = _parseBool(valor) != null;

    final tipo =
        ehCheckbox ? TipoEmpresaParametro.checkbox : TipoEmpresaParametro.texto;

    final valorTexto = ehCheckbox ? null : valor;

    return EmpresaParametroDto(
      empresaId: (json['empresaId'] as num?)?.toInt() ?? 0,
      parametroId: (json['parametroId'] as String?) ?? '',
      descricao: (json['descricao'] as String?) ?? '',
      depreciado: (json['depreciado'] as int?) ?? 0,
      tipo: tipo,
      valorBooleano: valorBooleano,
      valorTexto: valorTexto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresaId': empresaId,
      'parametroId': parametroId,
      'descricao': descricao,
      'valor': valor,
      'depreciado': depreciado,
    };
  }

  @override
  bool get ehCheckbox => tipo == TipoEmpresaParametro.checkbox;

  @override
  List<Object?> get props => [
        empresaId,
        parametroId,
        descricao,
        valor,
        depreciado,
        tipo,
        valorBooleano,
        valorTexto,
      ];

  @override
  bool? get stringify => true;

  static bool? _parseBool(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final texto = value.toString().trim().toLowerCase();
    if (texto == 'true' || texto == '1' || texto == 's') {
      return true;
    }
    if (texto == 'false' || texto == '0' || texto == 'n') {
      return false;
    }
    return null;
  }

  @override
  bool get descontinuado => depreciado != 0;
}

extension EmpresaParametroToDto on EmpresaParametro {
  EmpresaParametroDto toDto() {
    return EmpresaParametroDto(
      empresaId: empresaId,
      parametroId: chave,
      descricao: descricao,
      depreciado: descontinuado ? 1 : 0,
      tipo: tipo,
      valorBooleano: valorBooleano,
      valorTexto: valorTexto,
    );
  }
}
