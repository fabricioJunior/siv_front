import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';

class EcommerceChaveMcpDto {
  static EcommerceChaveMcp fromJson(Map<String, dynamic> json) => EcommerceChaveMcp(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        nome: json['nome']?.toString() ?? '',
        chaveMascarada: json['chaveMascarada']?.toString() ?? '',
        escopos: (json['escopos'] as List<dynamic>? ?? const []).map((e) => '$e').toList(),
        criadoEm: _data(json['criadoEm']),
        expiraEm: _data(json['expiraEm']),
        ultimoAcessoEm: _data(json['ultimoAcessoEm']),
        revogadaEm: _data(json['revogadaEm']),
      );

  static CriarChaveMcpResultado resultadoDeJson(Map<String, dynamic> json) =>
      CriarChaveMcpResultado(
        registro: fromJson(json),
        chave: json['chave']?.toString() ?? '',
      );

  static DateTime? _data(Object? valor) => valor == null ? null : DateTime.tryParse('$valor')?.toLocal();
}
