import 'package:core/equals.dart';
import 'package:uuid/uuid.dart';

/// Identificador do lote de leituras (UUID v4), gerado quando a fila nasce.
String novoLoteIdLeituras() => const Uuid().v4();

/// Cópia local da fila de leituras da conferência (por pedido). Só é apagada
/// quando o servidor confirma o lote; [loteId] não muda entre tentativas.
class LeiturasEntradaPendentes extends Equatable {
  final int pedidoId;
  final String loteId;
  final DateTime atualizadoEm;
  final String? operador;
  final Map<int, int> deltas;

  const LeiturasEntradaPendentes({
    required this.pedidoId,
    required this.loteId,
    required this.atualizadoEm,
    required this.deltas,
    this.operador,
  });

  @override
  List<Object?> get props =>
      [pedidoId, loteId, atualizadoEm, operador, deltas];
}
