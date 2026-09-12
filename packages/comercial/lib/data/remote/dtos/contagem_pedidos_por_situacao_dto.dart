import 'package:comercial/domain/models/contagem_pedidos_por_situacao.dart';

class ContagemPedidosPorSituacaoDto {
  static ContagemPedidosPorSituacao fromJson(Map<String, dynamic> json) {
    final porSituacao = json['porSituacao'] as Map<String, dynamic>? ?? {};
    return ContagemPedidosPorSituacao(
      total: (json['total'] as num?)?.toInt() ?? 0,
      pago: (json['pago'] as num?)?.toInt() ?? 0,
      porSituacao: porSituacao.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
    );
  }
}
